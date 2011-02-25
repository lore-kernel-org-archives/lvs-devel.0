From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/3] ipvs: unify the formula to estimate the overhead of processing connections
Date: Fri, 25 Feb 2011 11:43:32 +0900
Message-ID: <1298601812-8168-4-git-send-email-horms@verge.net.au>
References: <1298601812-8168-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1298601812-8168-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Changli Gao <xiaosuo@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Changli Gao <xiaosuo@gmail.com>

lc and wlc use the same formula, but lblc and lblcr use another one. There
is no reason for using two different formulas for the lc variants.

The formula used by lc is used by all the lc variants in this patch.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Acked-by: Wensong Zhang <wensong@linux-vs.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |   14 ++++++++++++++
 net/netfilter/ipvs/ip_vs_lblc.c  |   13 +++----------
 net/netfilter/ipvs/ip_vs_lblcr.c |   25 +++++++------------------
 net/netfilter/ipvs/ip_vs_lc.c    |   18 +-----------------
 net/netfilter/ipvs/ip_vs_wlc.c   |   20 ++------------------
 5 files changed, 27 insertions(+), 63 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 17b01b2..e74da41e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1243,6 +1243,20 @@ static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 /* CONFIG_IP_VS_NFCT */
 #endif
 
+static inline unsigned int
+ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
+{
+	/*
+	 * We think the overhead of processing active connections is 256
+	 * times higher than that of inactive connections in average. (This
+	 * 256 times might not be accurate, we will change it later) We
+	 * use the following formula to estimate the overhead now:
+	 *		  dest->activeconns*256 + dest->inactconns
+	 */
+	return (atomic_read(&dest->activeconns) << 8) +
+		atomic_read(&dest->inactconns);
+}
+
 #endif /* __KERNEL__ */
 
 #endif	/* _NET_IP_VS_H */
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 4a9c8cd..6bf7a80 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -389,12 +389,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 	int loh, doh;
 
 	/*
-	 * We think the overhead of processing active connections is fifty
-	 * times higher than that of inactive connections in average. (This
-	 * fifty times might not be accurate, we will change it later.) We
-	 * use the following formula to estimate the overhead:
-	 *                dest->activeconns*50 + dest->inactconns
-	 * and the load:
+	 * We use the following formula to estimate the load:
 	 *                (dest overhead) / dest->weight
 	 *
 	 * Remember -- no floats in kernel mode!!!
@@ -410,8 +405,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 			continue;
 		if (atomic_read(&dest->weight) > 0) {
 			least = dest;
-			loh = atomic_read(&least->activeconns) * 50
-				+ atomic_read(&least->inactconns);
+			loh = ip_vs_dest_conn_overhead(least);
 			goto nextstage;
 		}
 	}
@@ -425,8 +419,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
-		doh = atomic_read(&dest->activeconns) * 50
-			+ atomic_read(&dest->inactconns);
+		doh = ip_vs_dest_conn_overhead(dest);
 		if (loh * atomic_read(&dest->weight) >
 		    doh * atomic_read(&least->weight)) {
 			least = dest;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index bd329b1..0063176 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -178,8 +178,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 
 		if ((atomic_read(&least->weight) > 0)
 		    && (least->flags & IP_VS_DEST_F_AVAILABLE)) {
-			loh = atomic_read(&least->activeconns) * 50
-				+ atomic_read(&least->inactconns);
+			loh = ip_vs_dest_conn_overhead(least);
 			goto nextstage;
 		}
 	}
@@ -192,8 +191,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
-		doh = atomic_read(&dest->activeconns) * 50
-			+ atomic_read(&dest->inactconns);
+		doh = ip_vs_dest_conn_overhead(dest);
 		if ((loh * atomic_read(&dest->weight) >
 		     doh * atomic_read(&least->weight))
 		    && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
@@ -228,8 +226,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 	list_for_each_entry(e, &set->list, list) {
 		most = e->dest;
 		if (atomic_read(&most->weight) > 0) {
-			moh = atomic_read(&most->activeconns) * 50
-				+ atomic_read(&most->inactconns);
+			moh = ip_vs_dest_conn_overhead(most);
 			goto nextstage;
 		}
 	}
@@ -239,8 +236,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
   nextstage:
 	list_for_each_entry(e, &set->list, list) {
 		dest = e->dest;
-		doh = atomic_read(&dest->activeconns) * 50
-			+ atomic_read(&dest->inactconns);
+		doh = ip_vs_dest_conn_overhead(dest);
 		/* moh/mw < doh/dw ==> moh*dw < doh*mw, where mw,dw>0 */
 		if ((moh * atomic_read(&dest->weight) <
 		     doh * atomic_read(&most->weight))
@@ -563,12 +559,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 	int loh, doh;
 
 	/*
-	 * We think the overhead of processing active connections is fifty
-	 * times higher than that of inactive connections in average. (This
-	 * fifty times might not be accurate, we will change it later.) We
-	 * use the following formula to estimate the overhead:
-	 *                dest->activeconns*50 + dest->inactconns
-	 * and the load:
+	 * We use the following formula to estimate the load:
 	 *                (dest overhead) / dest->weight
 	 *
 	 * Remember -- no floats in kernel mode!!!
@@ -585,8 +576,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 
 		if (atomic_read(&dest->weight) > 0) {
 			least = dest;
-			loh = atomic_read(&least->activeconns) * 50
-				+ atomic_read(&least->inactconns);
+			loh = ip_vs_dest_conn_overhead(least);
 			goto nextstage;
 		}
 	}
@@ -600,8 +590,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
-		doh = atomic_read(&dest->activeconns) * 50
-			+ atomic_read(&dest->inactconns);
+		doh = ip_vs_dest_conn_overhead(dest);
 		if (loh * atomic_read(&dest->weight) >
 		    doh * atomic_read(&least->weight)) {
 			least = dest;
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 6063800..f391819 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -22,22 +22,6 @@
 
 #include <net/ip_vs.h>
 
-
-static inline unsigned int
-ip_vs_lc_dest_overhead(struct ip_vs_dest *dest)
-{
-	/*
-	 * We think the overhead of processing active connections is 256
-	 * times higher than that of inactive connections in average. (This
-	 * 256 times might not be accurate, we will change it later) We
-	 * use the following formula to estimate the overhead now:
-	 *		  dest->activeconns*256 + dest->inactconns
-	 */
-	return (atomic_read(&dest->activeconns) << 8) +
-		atomic_read(&dest->inactconns);
-}
-
-
 /*
  *	Least Connection scheduling
  */
@@ -62,7 +46,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
 		    atomic_read(&dest->weight) == 0)
 			continue;
-		doh = ip_vs_lc_dest_overhead(dest);
+		doh = ip_vs_dest_conn_overhead(dest);
 		if (!least || doh < loh) {
 			least = dest;
 			loh = doh;
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index fdf0f58..bc1bfc4 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -27,22 +27,6 @@
 
 #include <net/ip_vs.h>
 
-
-static inline unsigned int
-ip_vs_wlc_dest_overhead(struct ip_vs_dest *dest)
-{
-	/*
-	 * We think the overhead of processing active connections is 256
-	 * times higher than that of inactive connections in average. (This
-	 * 256 times might not be accurate, we will change it later) We
-	 * use the following formula to estimate the overhead now:
-	 *		  dest->activeconns*256 + dest->inactconns
-	 */
-	return (atomic_read(&dest->activeconns) << 8) +
-		atomic_read(&dest->inactconns);
-}
-
-
 /*
  *	Weighted Least Connection scheduling
  */
@@ -71,7 +55,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
-			loh = ip_vs_wlc_dest_overhead(least);
+			loh = ip_vs_dest_conn_overhead(least);
 			goto nextstage;
 		}
 	}
@@ -85,7 +69,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	list_for_each_entry_continue(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
-		doh = ip_vs_wlc_dest_overhead(dest);
+		doh = ip_vs_dest_conn_overhead(dest);
 		if (loh * atomic_read(&dest->weight) >
 		    doh * atomic_read(&least->weight)) {
 			least = dest;
-- 
1.7.2.3

