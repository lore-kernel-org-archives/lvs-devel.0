From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/3] ipvs: make "no destination available" message more informative
Date: Wed, 16 Feb 2011 15:04:53 +0900
Message-ID: <1297836293-5942-4-git-send-email-horms@verge.net.au>
References: <1297836293-5942-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1297836293-5942-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Patrick Schaaf <netdev@bof.de>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Patrick Schaaf <netdev@bof.de>

When IP_VS schedulers do not find a destination, they output a terse
"WLC: no destination available" message through kernel syslog, which I
can not only make sense of because syslog puts them in a logfile
together with keepalived checker results.

This patch makes the output a bit more informative, by telling you which
virtual service failed to find a destination.

Example output:

kernel: [1539214.552233] IPVS: wlc: TCP 192.168.8.30:22 - no destination available
kernel: [1539299.674418] IPVS: wlc: FWM 22 0x00000016 - no destination available

I have tested the code for IPv4 and FWM services, as you can see from
the example; I do not have an IPv6 setup to test the third code path
with.

To avoid code duplication, I put a new function ip_vs_scheduler_err()
into ip_vs_sched.c, and use that from the schedulers instead of calling
IP_VS_ERR_RL directly.

Signed-off-by: Patrick Schaaf <netdev@bof.de>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |    2 ++
 net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 net/netfilter/ipvs/ip_vs_lc.c    |    2 +-
 net/netfilter/ipvs/ip_vs_nq.c    |    2 +-
 net/netfilter/ipvs/ip_vs_rr.c    |    2 +-
 net/netfilter/ipvs/ip_vs_sched.c |   25 +++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_sed.c   |    2 +-
 net/netfilter/ipvs/ip_vs_sh.c    |    2 +-
 net/netfilter/ipvs/ip_vs_wlc.c   |    2 +-
 net/netfilter/ipvs/ip_vs_wrr.c   |   14 ++++++++------
 11 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5d75fea..9399549 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1019,6 +1019,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 			struct ip_vs_proto_data *pd);
 
+extern void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
+
 
 /*
  *      IPVS control data and functions (from ip_vs_ctl.c)
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 00b5ffa..4a9c8cd 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -510,7 +510,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	/* No cache entry or it is invalid, time to schedule */
 	dest = __ip_vs_lblc_schedule(svc);
 	if (!dest) {
-		IP_VS_ERR_RL("LBLC: no destination available\n");
+		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index bfa25f1..bd329b1 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -692,7 +692,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		/* The cache entry is invalid, time to schedule */
 		dest = __ip_vs_lblcr_schedule(svc);
 		if (!dest) {
-			IP_VS_ERR_RL("LBLCR: no destination available\n");
+			ip_vs_scheduler_err(svc, "no destination available");
 			read_unlock(&svc->sched_lock);
 			return NULL;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 4f69db1..6063800 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -70,7 +70,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	if (!least)
-		IP_VS_ERR_RL("LC: no destination available\n");
+		ip_vs_scheduler_err(svc, "no destination available");
 	else
 		IP_VS_DBG_BUF(6, "LC: server %s:%u activeconns %d "
 			      "inactconns %d\n",
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index c413e18..984d9c1 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -99,7 +99,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	if (!least) {
-		IP_VS_ERR_RL("NQ: no destination available\n");
+		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index e210f37..c49b388 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -72,7 +72,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		q = q->next;
 	} while (q != p);
 	write_unlock(&svc->sched_lock);
-	IP_VS_ERR_RL("RR: no destination available\n");
+	ip_vs_scheduler_err(svc, "no destination available");
 	return NULL;
 
   out:
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 076ebe0..08dbdd5 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -29,6 +29,7 @@
 
 #include <net/ip_vs.h>
 
+EXPORT_SYMBOL(ip_vs_scheduler_err);
 /*
  *  IPVS scheduler list
  */
@@ -146,6 +147,30 @@ void ip_vs_scheduler_put(struct ip_vs_scheduler *scheduler)
 		module_put(scheduler->module);
 }
 
+/*
+ * Common error output helper for schedulers
+ */
+
+void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg)
+{
+	if (svc->fwmark) {
+		IP_VS_ERR_RL("%s: FWM %u 0x%08X - %s\n",
+			     svc->scheduler->name, svc->fwmark,
+			     svc->fwmark, msg);
+#ifdef CONFIG_IP_VS_IPV6
+	} else if (svc->af == AF_INET6) {
+		IP_VS_ERR_RL("%s: %s [%pI6]:%d - %s\n",
+			     svc->scheduler->name,
+			     ip_vs_proto_name(svc->protocol),
+			     &svc->addr.in6, ntohs(svc->port), msg);
+#endif
+	} else {
+		IP_VS_ERR_RL("%s: %s %pI4:%d - %s\n",
+			     svc->scheduler->name,
+			     ip_vs_proto_name(svc->protocol),
+			     &svc->addr.ip, ntohs(svc->port), msg);
+	}
+}
 
 /*
  *  Register a scheduler in the scheduler list
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 1ab75a9..89ead24 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -87,7 +87,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 			goto nextstage;
 		}
 	}
-	IP_VS_ERR_RL("SED: no destination available\n");
+	ip_vs_scheduler_err(svc, "no destination available");
 	return NULL;
 
 	/*
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index e6cc174..b5e2556 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -223,7 +223,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
 	    || atomic_read(&dest->weight) <= 0
 	    || is_overloaded(dest)) {
-		IP_VS_ERR_RL("SH: no destination available\n");
+		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index bbddfdb..fdf0f58 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -75,7 +75,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 			goto nextstage;
 		}
 	}
-	IP_VS_ERR_RL("WLC: no destination available\n");
+	ip_vs_scheduler_err(svc, "no destination available");
 	return NULL;
 
 	/*
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 30db633..1ef41f5 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -147,8 +147,9 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 			if (mark->cl == mark->cl->next) {
 				/* no dest entry */
-				IP_VS_ERR_RL("WRR: no destination available: "
-					     "no destinations present\n");
+				ip_vs_scheduler_err(svc,
+					"no destination available: "
+					"no destinations present");
 				dest = NULL;
 				goto out;
 			}
@@ -162,8 +163,8 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 				 */
 				if (mark->cw == 0) {
 					mark->cl = &svc->destinations;
-					IP_VS_ERR_RL("WRR: no destination "
-						     "available\n");
+					ip_vs_scheduler_err(svc,
+						"no destination available");
 					dest = NULL;
 					goto out;
 				}
@@ -185,8 +186,9 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 			/* back to the start, and no dest is found.
 			   It is only possible when all dests are OVERLOADED */
 			dest = NULL;
-			IP_VS_ERR_RL("WRR: no destination available: "
-				     "all destinations are overloaded\n");
+			ip_vs_scheduler_err(svc,
+				"no destination available: "
+				"all destinations are overloaded");
 			goto out;
 		}
 	}
-- 
1.7.2.3

