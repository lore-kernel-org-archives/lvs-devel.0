From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/5] ipvs: fix overflow on dest weight multiply
Date: Wed, 18 Sep 2013 14:45:38 -0500
Message-ID: <1379533542-9891-2-git-send-email-horms@verge.net.au>
References: <1379533542-9891-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1379533542-9891-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Kirby <sim@hostway.ca>, Simon Horman <horms@verge.net.au>

From: Simon Kirby <sim@hostway.ca>

Schedulers such as lblc and lblcr require the weight to be as high as the
maximum number of active connections. In commit b552f7e3a9524abcbcdf
("ipvs: unify the formula to estimate the overhead of processing
connections"), the consideration of inactconns and activeconns was cleaned
up to always count activeconns as 256 times more important than inactconns.
In cases where 3000 or more connections are expected, a weight of 3000 *
256 * 3000 connections overflows the 32-bit signed result used to determine
if rescheduling is required.

On amd64, this merely changes the multiply and comparison instructions to
64-bit. On x86, a 64-bit result is already present from imull, so only
a few more comparison instructions are emitted.

Signed-off-by: Simon Kirby <sim@hostway.ca>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h              |  2 +-
 net/netfilter/ipvs/ip_vs_lblc.c  |  4 ++--
 net/netfilter/ipvs/ip_vs_lblcr.c | 12 ++++++------
 net/netfilter/ipvs/ip_vs_nq.c    |  8 ++++----
 net/netfilter/ipvs/ip_vs_sed.c   |  8 ++++----
 net/netfilter/ipvs/ip_vs_wlc.c   |  6 +++---
 6 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f0d70f0..fe782ed 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1649,7 +1649,7 @@ static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 /* CONFIG_IP_VS_NFCT */
 #endif
 
-static inline unsigned int
+static inline int
 ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
 {
 	/*
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 1383b0e..eb814bf 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -443,8 +443,8 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
-		if (loh * atomic_read(&dest->weight) >
-		    doh * atomic_read(&least->weight)) {
+		if ((__s64)loh * atomic_read(&dest->weight) >
+		    (__s64)doh * atomic_read(&least->weight)) {
 			least = dest;
 			loh = doh;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 5199448..e65f7c5 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -200,8 +200,8 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
-		if ((loh * atomic_read(&dest->weight) >
-		     doh * atomic_read(&least->weight))
+		if (((__s64)loh * atomic_read(&dest->weight) >
+		     (__s64)doh * atomic_read(&least->weight))
 		    && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 			least = dest;
 			loh = doh;
@@ -246,8 +246,8 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 		dest = rcu_dereference_protected(e->dest, 1);
 		doh = ip_vs_dest_conn_overhead(dest);
 		/* moh/mw < doh/dw ==> moh*dw < doh*mw, where mw,dw>0 */
-		if ((moh * atomic_read(&dest->weight) <
-		     doh * atomic_read(&most->weight))
+		if (((__s64)moh * atomic_read(&dest->weight) <
+		     (__s64)doh * atomic_read(&most->weight))
 		    && (atomic_read(&dest->weight) > 0)) {
 			most = dest;
 			moh = doh;
@@ -611,8 +611,8 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 			continue;
 
 		doh = ip_vs_dest_conn_overhead(dest);
-		if (loh * atomic_read(&dest->weight) >
-		    doh * atomic_read(&least->weight)) {
+		if ((__s64)loh * atomic_read(&dest->weight) >
+		    (__s64)doh * atomic_read(&least->weight)) {
 			least = dest;
 			loh = doh;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index d8d9860..961a6de 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -40,7 +40,7 @@
 #include <net/ip_vs.h>
 
 
-static inline unsigned int
+static inline int
 ip_vs_nq_dest_overhead(struct ip_vs_dest *dest)
 {
 	/*
@@ -59,7 +59,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		  struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least = NULL;
-	unsigned int loh = 0, doh;
+	int loh = 0, doh;
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
@@ -92,8 +92,8 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		}
 
 		if (!least ||
-		    (loh * atomic_read(&dest->weight) >
-		     doh * atomic_read(&least->weight))) {
+		    ((__s64)loh * atomic_read(&dest->weight) >
+		     (__s64)doh * atomic_read(&least->weight))) {
 			least = dest;
 			loh = doh;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index a5284cc..e446b9f 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -44,7 +44,7 @@
 #include <net/ip_vs.h>
 
 
-static inline unsigned int
+static inline int
 ip_vs_sed_dest_overhead(struct ip_vs_dest *dest)
 {
 	/*
@@ -63,7 +63,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least;
-	unsigned int loh, doh;
+	int loh, doh;
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
@@ -99,8 +99,8 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		doh = ip_vs_sed_dest_overhead(dest);
-		if (loh * atomic_read(&dest->weight) >
-		    doh * atomic_read(&least->weight)) {
+		if ((__s64)loh * atomic_read(&dest->weight) >
+		    (__s64)doh * atomic_read(&least->weight)) {
 			least = dest;
 			loh = doh;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index 6dc1fa1..b5b4650 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -35,7 +35,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_dest *dest, *least;
-	unsigned int loh, doh;
+	int loh, doh;
 
 	IP_VS_DBG(6, "ip_vs_wlc_schedule(): Scheduling...\n");
 
@@ -71,8 +71,8 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		doh = ip_vs_dest_conn_overhead(dest);
-		if (loh * atomic_read(&dest->weight) >
-		    doh * atomic_read(&least->weight)) {
+		if ((__s64)loh * atomic_read(&dest->weight) >
+		    (__s64)doh * atomic_read(&least->weight)) {
 			least = dest;
 			loh = doh;
 		}
-- 
1.8.4
