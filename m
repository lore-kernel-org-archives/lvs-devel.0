From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCHv6 3/7] ipvs: use u64_stats_t for the per-cpu
 counters
Date: Tue, 15 Nov 2022 18:53:22 +0200 (EET)
Message-ID: <2152a987-19ee-083-d6f8-5ad73d8f83c@ssi.bg>
References: <20221031145647.156930-1-ja@ssi.bg> <20221031145647.156930-4-ja@ssi.bg> <20221112090001.GH3484@incl> <20221112090910.GI3484@incl> <a7bf3435-aa8f-31a5-b93b-f0ad58fdc3a4@ssi.bg> <20221115122602.GJ3484@incl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221115122602.GJ3484@incl>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Tue, 15 Nov 2022, Jiri Wiesner wrote:

> On Sat, Nov 12, 2022 at 06:01:36PM +0200, Julian Anastasov wrote:
> > 
> > 	Some compilers for 64-bit can use two 32-bit
> > loads (load tearing) while we require atomic 64-bit read
> > in case reader is interrupted by updater. That is why READ_ONCE
> > is used now. I don't know which compilers can do this. That is
> > why I switched to u64_stats_t to correctly use the u64_stats
> > interface. And our data is 8-byte aligned. 32-bit are using
> > seqcount_t, so they are protected for this problem.
> 
> All right. It is counter-intuitive but I guess those compiles have their reasons. I think it would not hurt to expand the description of the patch with the explanation above.

	OK. I relied on the mentioned commit to explain the problem
as other similar patches do.

> > 	If you think we are better with such change, we
> > can include it in patch 4. It will be better in case one day
> > we add more counters and there are more available registers.
> > You can notice the difference probably by comparing the
> > chain_max value in performance mode.
> 
> I have tested the change to ip_vs_chain_estimation() and ran profiling with bus-cycles, which are proportional to time spent executing code. The number of estimator per kthread was the same in both tests - 88800. It turns out the change made the code slower:
> > #       Util1          Util2                    Diff  Command          Shared Object        Symbol   CPU
> > 1,124,932,796  1,143,867,951     18,935,155 (  1.7%)  ipvs-e:0:0       [ip_vs]              all      all

	chain_max is probably 37 here and 1.7% is low
enough (below 1/37) not to be accounted in chain_max.

> >    16,480,274     16,853,752        373,478 (  2.3%)  ipvs-e:0:1       [ip_vs]              all      all
> >             0         21,987         21,987 (100.0%)  ipvs-e:0:0       [kvm]                all      all
> >     4,622,992      4,366,150       -256,842 (  5.6%)  ipvs-e:0:1       [kernel.kallsyms]    all      all
> >   180,226,857    164,665,271    -15,561,586 (  8.6%)  ipvs-e:0:0       [kernel.kallsyms]    all      all
> The most significant component was the time spent in ip_vs_chain_estimation():
> > #       Util1          Util2                    Diff  Command          Shared Object        Symbol                     CPU
> > 1,124,414,110  1,143,352,233     18,938,123 (  1.7%)  ipvs-e:0:0       [ip_vs]              ip_vs_chain_estimation     all
> >    16,291,044     16,574,498        283,454 (  1.7%)  ipvs-e:0:1       [ip_vs]              ip_vs_chain_estimation     all
> >       189,230        279,254         90,024 ( 47.6%)  ipvs-e:0:1       [ip_vs]              ip_vs_estimation_kthread   all
> >       518,686        515,718         -2,968 (  0.6%)  ipvs-e:0:0       [ip_vs]              ip_vs_estimation_kthread   all
> >     1,562,512      1,377,609       -184,903 ( 11.8%)  ipvs-e:0:0       [kernel.kallsyms]    kthread_should_stop        all
> >     2,435,803      2,138,404       -297,399 ( 12.2%)  ipvs-e:0:1       [kernel.kallsyms]    _find_next_bit             all
> >    16,304,577     15,786,553       -518,024 (  3.2%)  ipvs-e:0:0       [kernel.kallsyms]    _raw_spin_lock             all
> >   151,110,969    137,172,160    -13,938,809 (  9.2%)  ipvs-e:0:0       [kernel.kallsyms]    _find_next_bit             all
>  
> The disassembly shows it is the mov instructions (there is a skid of 1 instruction) what takes the most time:
> >Percent |      Source code & Disassembly of kcore for bus-cycles (55354 samples, percent: local period)
> >        : ffffffffc0bad980 <ip_vs_chain_estimation>:
> >            v6 patchset                            v6 patchset + ip_vs_chain_estimation() change
> >-------------------------------------------------------------------------------------------------------

> >   0.00 :       add    -0x72ead560(,%rdx,8),%rcx    0.00 :       add    -0x5ccad560(,%rdx,8),%rcx
> >   4.07 :       mov    (%rcx),%r11                  3.84 :       mov    (%rcx),%rdx
> >  34.28 :       mov    0x8(%rcx),%r10              34.17 :       add    %rdx,%r14
> >  10.35 :       mov    0x10(%rcx),%r9               2.62 :       mov    0x8(%rcx),%rdx
> >   7.28 :       mov    0x18(%rcx),%rdi              9.33 :       add    %rdx,%r13
> >   7.70 :       mov    0x20(%rcx),%rdx              1.82 :       mov    0x10(%rcx),%rdx
> >   6.80 :       add    %r11,%r14                    6.11 :       add    %rdx,%r12
> >   0.27 :       add    %r10,%r13                    1.26 :       mov    0x18(%rcx),%rdx
> >   0.36 :       add    %r9,%r12                     6.00 :       add    %rdx,%rbp
> >   2.24 :       add    %rdi,%rbp                    2.97 :       mov    0x20(%rcx),%rdx

	Bad, same register RDX used. I guess, this is
CONFIG_GENERIC_CPU=y kernel which is suitable for different
CPUs. My example was tested with CONFIG_MCORE2=y. But the
optimizations are compiler's job, there can be a cost
to free registers for our operations. Who knows, change
can be faster on other platforms with less available
registers to hold the 5 counters and their sum in registers.

	Probably, we can force it to add mem8 into reg by using
something like this:

static inline void u64_stats_read_add(u64_stats_t *p, u64 *sum)
{
	local64_add_to(&p->v, (long *) sum);
}

static inline void local_add_to(local_t *l, long *sum)
{
	asm(_ASM_ADD "%1,%0"
	    : "+r" (*sum)
	    : "m" (l->a.counter));
}

	But it deserves more testing.

> The results indicate that the extra add instructions should not matter - memory accesses (the mov instructions) are the bottleneck.

	Yep, then lets work without this change for now,
no need to deviate much from the general u64_stats usage
if difference is negligible.

Regards

--
Julian Anastasov <ja@ssi.bg>

