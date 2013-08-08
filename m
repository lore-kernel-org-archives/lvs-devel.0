From: Simon Kirby <sim@hostway.ca>
Subject: [PATCH] ipvs: Use 64-bit comparisons (connections * weight) to avoid
 overflow
Date: Thu, 8 Aug 2013 16:54:34 -0700
Message-ID: <20130808235434.GD7147@hostway.ca>
References: <20130413064355.GB24319@hostway.ca>
 <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg>
 <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg>
 <20130523165836.GC436@hostway.ca>
 <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg>
 <20130524004318.GB14587@hostway.ca>
 <alpine.LFD.2.00.1305241013130.1636@ja.ssi.bg>
 <20130806024150.GA2393@hostway.ca>
 <alpine.LFD.2.00.1308060856200.1710@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1308060856200.1710@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>

On Tue, Aug 06, 2013 at 09:45:24AM +0300, Julian Anastasov wrote:

> On Mon, 5 Aug 2013, Simon Kirby wrote:
> 
> > > 1. same as my first email:
> > > 
> > > int loh, doh;
> > > 
> > > (__u64/__s64) loh * atomic_read(&dest->weight)
> > > 
> > > 	In this case I see only one difference between
> > > __u64 and __s64:
> > > 
> > > -       jb      .L41    #,
> > > -       ja      .L79    #,
> > > +       jl      .L41    #,
> > > +       jg      .L79    #,
> > > 
> > > 2. Your patch:
> > > 
> > > unsigned int loh, doh;
> > > 
> > > (__u64) loh * (__u32) atomic_read(&dest->weight)
> > > or
> > > (__s64) loh * (__u32) atomic_read(&dest->weight)
> > 
> > Did you mean here "(__s64) loh * (__s32) atomic_read(&dest->sweight)"?
> > 
> > If not, the results for me on GCC 4.7.2 were what I posted at
> > http://0x.ca/sim/ref/3.9-ipvs/.
> 
> 	Reading your reply I see that the key issue you are
> missing here is that the type of loh/doh matters, it should
> match the type of atomic_read (and its signedness).

I'm not missing it, I was just trying to determine if the weight _should_
be signed or not. :) I've never seen a negative weight documented
anywhere.

> 	It is faster because your loh/doh are u32 and single mul is
> generated while for u64*s32 we have u64=u32*s32 which obviously
> is not implemented with single imul/mul. Our goal is single imul.

Ok, well, it turns out that GCC doesn't care and uses the signal register
instruction form of imull anyway :) ->

sim@simonk:/d/linux$ diff -u <(sed 's/#.*//' /tmp/u64_u32.s) <(sed 's/#.*//' /tmp/s64_s32.s)
--- /dev/fd/63	2013-08-08 16:39:10.692645777 -0700
+++ /dev/fd/62	2013-08-08 16:39:10.692645777 -0700
@@ -125,22 +125,22 @@
 	testb	$2, %al	
 	jne	.L8	
 	movl	216(%ebx), %eax	
-	movl	220(%ebx), %esi	
+	movl	220(%ebx), %edx	
 	sall	$8, %eax	
-	addl	%eax, %esi	
+	leal	(%eax,%edx), %esi	
 	movl	44(%ebx), %eax	
 	movl	%eax, -24(%ebp)	
 	movl	44(%ecx), %eax	
 	movl	%eax, -28(%ebp)	
 	movl	-24(%ebp), %eax	
-	mull	-32(%ebp)	
+	imull	-32(%ebp)	
 	movl	%eax, -24(%ebp)	
 	movl	-28(%ebp), %eax	
 	movl	%edx, -20(%ebp)	
-	mull	%esi	
+	imull	%esi	
 	cmpl	%edx, -20(%ebp)	
-	ja	.L11	
-	jb	.L8	
+	jg	.L11	
+	jl	.L8	
 	cmpl	%eax, -24(%ebp)	
 	jbe	.L8	
 .L11:

That is the only output difference from ip_vs_wlc.c with (signed) int loh
and doh as opposed to unsigned int (and the atomic_t to u32 cast).

> > But what actually makes sense? Do negative weights ever make sense?
> 
> 	__u64/__s64 cast does not matter because both
> operands are positive values. As result, this solution
> looks better:
> 
> int loh, doh;
> 
> (__s64) loh * atomic_read(&dest->weight)
> 
> 	because:
> 
> - both operands are 'int' => no extra casts before atomic_read
> 
> - 'int',  not 'unsigned int' because imul is better than mul

Ok, here is a patch (on current ipvs-next) that makes everything "int"
and adds only a (__s64) cast in front of the loh and doh during
multiplication to solve the original overflow problem.

Simon-


Some scheduling modules such as lblc and lblcr require weight to be as
high as the maximum number of expected active connections. Meanwhile,
commit b552f7e3a9524abcbcdf, which appeared in 2.6.39-rc, cleaned up the
consideration of inactconns and activeconns to always count activeconns
as 256 times more important than inactconns.

In our case, this exposed an integer overflow because we regularly exceed
3000 active connections to a real server. A weight of 3000 * 256 * 3000
connections overflows the signed integer used when determining when to
reschedule. The original factor of 50 did not overflow, though was close.

On amd64, this merely changes the multiply and comparison instructions to
64-bit. On x86, the 64-bit result is already present from imull, so only
a few more comparisons are emitted.

Signed-off-by: Simon Kirby <sim@hostway.ca>
---
 include/net/ip_vs.h              |  2 +-
 net/netfilter/ipvs/ip_vs_lblc.c  |  4 ++--
 net/netfilter/ipvs/ip_vs_lblcr.c | 12 ++++++------
 net/netfilter/ipvs/ip_vs_nq.c    |  6 +++---
 net/netfilter/ipvs/ip_vs_sed.c   |  6 +++---
 net/netfilter/ipvs/ip_vs_wlc.c   |  6 +++---
 6 files changed, 18 insertions(+), 18 deletions(-)

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
index d8d9860..368b23e 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
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
index a5284cc..f90e7e6 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
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
