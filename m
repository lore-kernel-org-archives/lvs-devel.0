From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 18/34] ipvs: add ip_vs_dest_hold and ip_vs_dest_put
Date: Fri, 29 Mar 2013 13:11:35 +0900
Message-ID: <1364530311-11512-19-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

ip_vs_dest_hold will be used under RCU lock
while ip_vs_dest_put can be called even after dest
is removed from service, as it happens for conns and
some schedulers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |   10 ++++++++++
 net/netfilter/ipvs/ip_vs_conn.c |    9 ++-------
 net/netfilter/ipvs/ip_vs_ctl.c  |    4 ++--
 net/netfilter/ipvs/ip_vs_sync.c |    4 ++--
 4 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d91385c..7d3027f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1427,6 +1427,16 @@ ip_vs_find_dest(struct net *net, int af, const union nf_inet_addr *daddr,
 		__u16 protocol, __u32 fwmark, __u32 flags);
 extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
+static inline void ip_vs_dest_hold(struct ip_vs_dest *dest)
+{
+	atomic_inc(&dest->refcnt);
+}
+
+static inline void ip_vs_dest_put(struct ip_vs_dest *dest)
+{
+	smp_mb__before_atomic_dec();
+	atomic_dec(&dest->refcnt);
+}
 
 /*
  *      IPVS sync daemon data and function prototypes
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index e3e2b4d..1b29e4a 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -554,7 +554,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		return;
 
 	/* Increase the refcnt counter of the dest */
-	atomic_inc(&dest->refcnt);
+	ip_vs_dest_hold(dest);
 
 	conn_flags = atomic_read(&dest->conn_flags);
 	if (cp->protocol != IPPROTO_UDP)
@@ -700,12 +700,7 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 			dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
 	}
 
-	/*
-	 * Simply decrease the refcnt of the dest, because the
-	 * dest will be either in service's destination list
-	 * or in the trash.
-	 */
-	atomic_dec(&dest->refcnt);
+	ip_vs_dest_put(dest);
 }
 
 static int expire_quiescent_template(struct netns_ipvs *ipvs,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d64f800..a4f6388 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -616,7 +616,7 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 	if (!dest)
 		dest = ip_vs_lookup_dest(svc, daddr, port ^ dport);
 	if (dest)
-		atomic_inc(&dest->refcnt);
+		ip_vs_dest_hold(dest);
 	ip_vs_service_put(svc);
 	return dest;
 }
@@ -1056,7 +1056,7 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
 		list_add(&dest->n_list, &ipvs->dest_trash);
-		atomic_inc(&dest->refcnt);
+		ip_vs_dest_hold(dest);
 	}
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 44fd10c..6cc3e52 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -861,7 +861,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		if (!dest) {
 			dest = ip_vs_try_bind_dest(cp);
 			if (dest)
-				atomic_dec(&dest->refcnt);
+				ip_vs_dest_put(dest);
 		}
 	} else {
 		/*
@@ -874,7 +874,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 
 		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
 		if (dest)
-			atomic_dec(&dest->refcnt);
+			ip_vs_dest_put(dest);
 		if (!cp) {
 			if (param->pe_data)
 				kfree(param->pe_data);
-- 
1.7.10.4
