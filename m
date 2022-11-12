From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCHv6 3/7] ipvs: use u64_stats_t for the per-cpu
 counters
Date: Sat, 12 Nov 2022 18:01:36 +0200 (EET)
Message-ID: <a7bf3435-aa8f-31a5-b93b-f0ad58fdc3a4@ssi.bg>
References: <20221031145647.156930-1-ja@ssi.bg> <20221031145647.156930-4-ja@ssi.bg> <20221112090001.GH3484@incl> <20221112090910.GI3484@incl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221112090910.GI3484@incl>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Sat, 12 Nov 2022, Jiri Wiesner wrote:

> On Sat, Nov 12, 2022 at 10:00:01AM +0100, Jiri Wiesner wrote:
> > On Mon, Oct 31, 2022 at 04:56:43PM +0200, Julian Anastasov wrote:
> > > Use the provided u64_stats_t type to avoid
> > > load/store tearing.
> 
> I think only 32-bit machines have a problem storing a 64-bit counter atomically. u64_stats_fetch_begin() and u64_stats_fetch_retry() should take care of that.

	Some compilers for 64-bit can use two 32-bit
loads (load tearing) while we require atomic 64-bit read
in case reader is interrupted by updater. That is why READ_ONCE
is used now. I don't know which compilers can do this. That is
why I switched to u64_stats_t to correctly use the u64_stats
interface. And our data is 8-byte aligned. 32-bit are using
seqcount_t, so they are protected for this problem.

> > Converting the per cpu stat to u64_stats_t means that the compiler cannot optimize the memory access and addition on x86_64. Previously, the summation of per cpu counters in ip_vs_chain_estimation() looked like:
> > 15b65:  add    (%rsi),%r14
> > 15b68:  add    0x8(%rsi),%r15
> > 15b6c:  add    0x10(%rsi),%r13
> > 15b70:  add    0x18(%rsi),%r12
> > 15b74:  add    0x20(%rsi),%rbp
> > The u64_stats_read() calls in ip_vs_chain_estimation() turned it into:
> > 159d5:  mov    (%rcx),%r11
> > 159d8:  mov    0x8(%rcx),%r10
> > 159dc:  mov    0x10(%rcx),%r9
> > 159e0:  mov    0x18(%rcx),%rdi
> > 159e4:  mov    0x20(%rcx),%rdx
> > 159e8:  add    %r11,%r14
> > 159eb:  add    %r10,%r13
> > 159ee:  add    %r9,%r12
> > 159f1:  add    %rdi,%rbp
> > 159f4:  add    %rdx,%rbx
> > I guess that is not a big deal because the mov should be the instruction taking the most time on account of accessing per cpu regions of other CPUs. The add will be fast.
> 
> Another concern is the number of registers needed for the summation. Previously, 5 registers were needed. Now, 10 registers are needed. This would matter mostly if the size of the stack frame of ip_vs_chain_estimation() and the number of callee-saved registers stored to the stack changed, but introducing u64_stats_read() in ip_vs_chain_estimation() did not change that.

	It happens in this way probably because compiler should not 
reorder two or more successive instances of READ_ONCE (rwonce.h), 
something that hurts u64_stats_read(). As result, it multiplies
up to 5 times the needed temp storage (registers or stack).

	Another option would be to use something like
this below, try on top of v6. It is rude to add ifdefs here but
we should avoid unneeded code for 64-bit. On 32-bit, code is
more but operations are same. On 64-bit it should order
read+add one by one which can run in parallel. In my compile
tests it uses 3 times movq(READ_ONCE)+addq(to sum) with same temp
register which defeats fully parallel operations and for the
last 2 counters uses movq,movq,addq,addq with different
registers which can run in parallel. It seems there are no free
registers to make it for all 5 counters.

	With this patch the benefit is that compiler should
not hold all 5 values before adding them but on
x86 this patch shows some problem: it does not allocate
5 new temp registers to read and add the values in parallel.
Without this patch, as you show it, it somehow allocates 5+5
registers which allows parallel operations.

	If you think we are better with such change, we
can include it in patch 4. It will be better in case one day
we add more counters and there are more available registers.
You can notice the difference probably by comparing the
chain_max value in performance mode.

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 4489a3dbad1e..52d77715f7ea 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -83,7 +83,9 @@ static void ip_vs_chain_estimation(struct hlist_head *chain)
 	u64 rate;
 
 	hlist_for_each_entry_rcu(e, chain, list) {
+#if BITS_PER_LONG == 32
 		u64 conns, inpkts, outpkts, inbytes, outbytes;
+#endif
 		u64 kconns = 0, kinpkts = 0, koutpkts = 0;
 		u64 kinbytes = 0, koutbytes = 0;
 		unsigned int start;
@@ -95,19 +97,30 @@ static void ip_vs_chain_estimation(struct hlist_head *chain)
 		s = container_of(e, struct ip_vs_stats, est);
 		for_each_possible_cpu(i) {
 			c = per_cpu_ptr(s->cpustats, i);
-			do {
-				start = u64_stats_fetch_begin(&c->syncp);
-				conns = u64_stats_read(&c->cnt.conns);
-				inpkts = u64_stats_read(&c->cnt.inpkts);
-				outpkts = u64_stats_read(&c->cnt.outpkts);
-				inbytes = u64_stats_read(&c->cnt.inbytes);
-				outbytes = u64_stats_read(&c->cnt.outbytes);
-			} while (u64_stats_fetch_retry(&c->syncp, start));
-			kconns += conns;
-			kinpkts += inpkts;
-			koutpkts += outpkts;
-			kinbytes += inbytes;
-			koutbytes += outbytes;
+#if BITS_PER_LONG == 32
+			conns = kconns;
+			inpkts = kinpkts;
+			outpkts = koutpkts;
+			inbytes = kinbytes;
+			outbytes = koutbytes;
+#endif
+			for (;;) {
+				start += u64_stats_fetch_begin(&c->syncp);
+				kconns += u64_stats_read(&c->cnt.conns);
+				kinpkts += u64_stats_read(&c->cnt.inpkts);
+				koutpkts += u64_stats_read(&c->cnt.outpkts);
+				kinbytes += u64_stats_read(&c->cnt.inbytes);
+				koutbytes += u64_stats_read(&c->cnt.outbytes);
+				if (!u64_stats_fetch_retry(&c->syncp, start))
+					break;
+#if BITS_PER_LONG == 32
+				kconns = conns;
+				kinpkts = inpkts;
+				koutpkts = outpkts;
+				kinbytes = inbytes;
+				koutbytes = outbytes;
+#endif
+			}
 		}
 
 		spin_lock(&s->lock);

Regards

--
Julian Anastasov <ja@ssi.bg>

