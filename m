From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] ipvs: unify the formula to estimate the overhead of processing connections
Date: Sat, 19 Feb 2011 17:32:28 +0800
Message-ID: <1298107948-9224-1-git-send-email-xiaosuo@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:from:to:cc:subject:date:message-id:x-mailer;
        bh=FT/ccRmUXGRyxOXdXCRzI4IPVMxMgAbD4MKac7iKeqU=;
        b=e/oyHSokCv2fNkmQ8qKlm/j6aXuG2lgH4eCHgNGPBl++ru4uS3NA9bR34ZFn1Dc/XJ
         FoatXM8dE/d7goM5WHawPQtD49y7PpgsdhgJhhJoF5XIXPyBDlX9fBXTG135/9mlzMO9
         OPSdJ4XKdAl0g8xHPPn3mhlRI9KRbMpXwl68U=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>

lc and wlc use the same formula, but lblc and lblcr use another one. There
is no reason for using two different formulas for the lc variants.

The formula used by lc is used by all the lc variants in this patch.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: use ip_vs_dest_conn_overhead() instead.
 include/net/ip_vs.h              |   14 ++++++++++++++
 net/netfilter/ipvs/ip_vs_lblc.c  |   13 +++----------
 net/netfilter/ipvs/ip_vs_lblcr.c |   25 +++++++------------------
 net/netfilter/ipvs/ip_vs_lc.c    |   18 +-----------------
 net/netfilter/ipvs/ip_vs_wlc.c   |   20 ++------------------
 5 files changed, 27 insertions(+), 63 deletions(-)
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5d75fea..e80ffb7 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1241,6 +1241,20 @@ static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
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
index 00b5ffa..58ae403 100644
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
index bfa25f1..2ddefe8 100644
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
index 4f69db1..160cb80 100644
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
index bbddfdb..db751f5 100644
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
