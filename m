From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 08/25] IPVS: Add IPv6 support flag to schedulers
Date: Mon,  1 Sep 2008 14:56:05 +0200
Message-ID: <1220273782-19901-9-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273822; bh=dadq1mQ/ljgvWPdK95AtlzZvAjg=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=QtJWLXvSEEeANtKDx+CZ/6yiW1h6Otk2I4CJVzL2
	EHQkOiglnkIzhRKDbMCZHGv3z78QkogrSx44gnaYUjOtrw==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add 'supports_ipv6' flag to struct ip_vs_scheduler to indicate whether a
scheduler supports IPv6. Set the flag to 1 in schedulers that work with
IPv6, 0 otherwise. This flag is checked in a later patch while trying to
add a service with a specific scheduler. Adjust debug in v6-supporting
schedulers to work with both address families.

Signed-off-by: Julius Volz <juliusv@google.com>

 11 files changed, 66 insertions(+), 33 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d653e8b..881e60a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -516,6 +516,9 @@ struct ip_vs_scheduler {
 	char			*name;		/* scheduler name */
 	atomic_t		refcnt;		/* reference counter */
 	struct module		*module;	/* THIS_MODULE/NULL */
+#ifdef CONFIG_IP_VS_IPV6
+	int			supports_ipv6;	/* scheduler has IPv6 support */
+#endif
 
 	/* scheduler initializing service */
 	int (*init_service)(struct ip_vs_service *svc);
diff --git a/net/ipv4/ipvs/ip_vs_dh.c b/net/ipv4/ipvs/ip_vs_dh.c
index 9f9d795..a16943f 100644
--- a/net/ipv4/ipvs/ip_vs_dh.c
+++ b/net/ipv4/ipvs/ip_vs_dh.c
@@ -234,6 +234,9 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_dh_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
 	.update_service =	ip_vs_dh_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index 69309ed..6ecef35 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -522,6 +522,9 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
 	.schedule =		ip_vs_lblc_schedule,
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index 51c746e..1f75ea8 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -722,6 +722,9 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblcr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
 	.schedule =		ip_vs_lblcr_schedule,
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index 551d293..b69f808 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -67,10 +67,10 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	if (least)
-	IP_VS_DBG(6, "LC: server %u.%u.%u.%u:%u activeconns %d inactconns %d\n",
-		  NIPQUAD(least->addr.ip), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->inactconns));
+	IP_VS_DBG_BUF(6, "LC: server %s:%u activeconns %d inactconns %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->inactconns));
 
 	return least;
 }
@@ -81,6 +81,9 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.schedule =		ip_vs_lc_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index aa0e32a..9a2d803 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -99,12 +99,12 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		return NULL;
 
   out:
-	IP_VS_DBG(6, "NQ: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr.ip), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_BUF(6, "NQ: server %s:%u "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 
 	return least;
 }
@@ -116,6 +116,9 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_nq_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.schedule =		ip_vs_nq_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
index 27f0b62..a22195f 100644
--- a/net/ipv4/ipvs/ip_vs_rr.c
+++ b/net/ipv4/ipvs/ip_vs_rr.c
@@ -74,11 +74,11 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
   out:
 	svc->sched_data = q;
 	write_unlock(&svc->sched_lock);
-	IP_VS_DBG(6, "RR: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d\n",
-		  NIPQUAD(dest->addr.ip), ntohs(dest->port),
-		  atomic_read(&dest->activeconns),
-		  atomic_read(&dest->refcnt), atomic_read(&dest->weight));
+	IP_VS_DBG_BUF(6, "RR: server %s:%u "
+		      "activeconns %d refcnt %d weight %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port),
+		      atomic_read(&dest->activeconns),
+		      atomic_read(&dest->refcnt), atomic_read(&dest->weight));
 
 	return dest;
 }
@@ -89,6 +89,9 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_rr_init_svc,
 	.update_service =	ip_vs_rr_update_svc,
 	.schedule =		ip_vs_rr_schedule,
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index 38b574b..7d2f22f 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -101,12 +101,12 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "SED: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr.ip), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_BUF(6, "SED: server %s:%u "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 
 	return least;
 }
@@ -118,6 +118,9 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_sed_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.schedule =		ip_vs_sed_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_sh.c b/net/ipv4/ipvs/ip_vs_sh.c
index c9e54e2..1d96de2 100644
--- a/net/ipv4/ipvs/ip_vs_sh.c
+++ b/net/ipv4/ipvs/ip_vs_sh.c
@@ -231,6 +231,9 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list	 =		LIST_HEAD_INIT(ip_vs_sh_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
 	.update_service =	ip_vs_sh_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 09fd993..8c596e7 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -89,12 +89,12 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "WLC: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d overhead %d\n",
-		  NIPQUAD(least->addr.ip), ntohs(least->port),
-		  atomic_read(&least->activeconns),
-		  atomic_read(&least->refcnt),
-		  atomic_read(&least->weight), loh);
+	IP_VS_DBG_BUF(6, "WLC: server %s:%u "
+		      "activeconns %d refcnt %d weight %d overhead %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      atomic_read(&least->activeconns),
+		      atomic_read(&least->refcnt),
+		      atomic_read(&least->weight), loh);
 
 	return least;
 }
@@ -106,6 +106,9 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_wlc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.schedule =		ip_vs_wlc_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 19c49b2..7ea92fe 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -195,12 +195,12 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 	}
 
-	IP_VS_DBG(6, "WRR: server %u.%u.%u.%u:%u "
-		  "activeconns %d refcnt %d weight %d\n",
-		  NIPQUAD(dest->addr.ip), ntohs(dest->port),
-		  atomic_read(&dest->activeconns),
-		  atomic_read(&dest->refcnt),
-		  atomic_read(&dest->weight));
+	IP_VS_DBG_BUF(6, "WRR: server %s:%u "
+		      "activeconns %d refcnt %d weight %d\n",
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port),
+		      atomic_read(&dest->activeconns),
+		      atomic_read(&dest->refcnt),
+		      atomic_read(&dest->weight));
 
   out:
 	write_unlock(&svc->sched_lock);
@@ -213,6 +213,9 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_wrr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_wrr_init_svc,
 	.done_service =		ip_vs_wrr_done_svc,
 	.update_service =	ip_vs_wrr_update_svc,
-- 
1.5.4.5

