From: Simon Kirby <sim@hostway.ca>
Subject: [PATCH v2] ipvs: fix overflow on dest weight multiply
Date: Sat, 10 Aug 2013 01:26:18 -0700
Message-ID: <20130810082618.GB21768@hostway.ca>
References: <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg>
 <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg>
 <20130523165836.GC436@hostway.ca>
 <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg>
 <20130524004318.GB14587@hostway.ca>
 <alpine.LFD.2.00.1305241013130.1636@ja.ssi.bg>
 <20130806024150.GA2393@hostway.ca>
 <alpine.LFD.2.00.1308060856200.1710@ja.ssi.bg>
 <20130808235434.GD7147@hostway.ca>
 <alpine.LFD.2.00.1308091114230.1702@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308091114230.1702@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>

On Fri, Aug 09, 2013 at 12:02:11PM +0300, Julian Anastasov wrote:

> > > 	It is faster because your loh/doh are u32 and single mul is
> > > generated while for u64*s32 we have u64=u32*s32 which obviously
> > > is not implemented with single imul/mul. Our goal is single imul.
> > 
> > Ok, well, it turns out that GCC doesn't care and uses the signal register
> > instruction form of imull anyway :) ->
> 
> 	OK, so everything is as expected :)
> 
> > Ok, here is a patch (on current ipvs-next) that makes everything "int"
> > and adds only a (__s64) cast in front of the loh and doh during
> > multiplication to solve the original overflow problem.
> 
> 	Very good, thanks!
> 
> > Some scheduling modules such as lblc and lblcr require weight to be as
> > high as the maximum number of expected active connections. Meanwhile,
> > commit b552f7e3a9524abcbcdf, which appeared in 2.6.39-rc, cleaned up the
> > consideration of inactconns and activeconns to always count activeconns
> > as 256 times more important than inactconns.
> > 
> > In our case, this exposed an integer overflow because we regularly exceed
> > 3000 active connections to a real server. A weight of 3000 * 256 * 3000
> > connections overflows the signed integer used when determining when to
> > reschedule. The original factor of 50 did not overflow, though was close.
> > 
> > On amd64, this merely changes the multiply and comparison instructions to
> > 64-bit. On x86, the 64-bit result is already present from imull, so only
> > a few more comparisons are emitted.
> > 
> > Signed-off-by: Simon Kirby <sim@hostway.ca>
> 
> 	Looks good to me, even if you add space
> between "(__s64)" cast and "loh"/"doh".

I think (__s64)loh * doh makes more sense as the cast applies to the
variable before the multiply is evaluated.

> 	But after your fix for ip_vs_dest_conn_overhead
> I see that also ip_vs_nq_dest_overhead and ip_vs_sed_dest_overhead
> need to return int instead of unsigned int. I'll ack
> v2 with these changes.

Ok, fixed. :)

> 	Also, shorter subject is preferred, you can use
> 'ipvs: fix overflow on dest weight multiply' or something
> else that you feel is better, '()' and '*' does not look
> good in subject. Thanks!

-- 8< --

Schedulers such as lblc and lblcr require the weight to be as high as the
maximum number of active connections. In commit b552f7e3a9524abcbcdf, the
consideration of inactconns and activeconns was cleaned up to always
count activeconns as 256 times more important than inactconns. In cases
where 3000 or more connections are expected, a weight of 3000 * 256 *
3000 connections overflows the 32-bit signed result used to determine if
rescheduling is required.

On amd64, this merely changes the multiply and comparison instructions to
64-bit. On x86, a 64-bit result is already present from imull, so only
a few more comparison instructions are emitted.

Signed-off-by: Simon Kirby <sim@hostway.ca>
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
1.8.4.rc1

