From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 3/7] ipvs: use u64_stats_t for the per-cpu counters
Date: Tue, 15 Nov 2022 13:26:02 +0100
Message-ID: <20221115122602.GJ3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-4-ja@ssi.bg>
 <20221112090001.GH3484@incl>
 <20221112090910.GI3484@incl>
 <a7bf3435-aa8f-31a5-b93b-f0ad58fdc3a4@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1668515163; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=gFzWmzZZ2VZ00jeFsROFpg4vYO+Ej6vXwao96SUEnJI=;
        b=EDfq4KZuW12r5gYME7/+sLG9/dnFBvP4ZtcJZCjJhd+LuZzUoBuqXCbY4ROzhgyzquURWX
        NfT3I07f8DNTj4/QNg+auFHWlIkLO5rAHyIk1uBCknghoTwkjgipJI0jIcPD7szi4zl1hN
        rJheMF6bUxzZTVIxPIq/45XV2IIsa4k=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1668515163;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=gFzWmzZZ2VZ00jeFsROFpg4vYO+Ej6vXwao96SUEnJI=;
        b=AwffN08J3nc11DXuiQhFQdDrv2UJVvPflGjutjsIoS+pLYtUY89VZed6pCXZvBCgGYzXJU
        qRresw1AIKBLN6AQ==
Content-Disposition: inline
In-Reply-To: <a7bf3435-aa8f-31a5-b93b-f0ad58fdc3a4@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Sat, Nov 12, 2022 at 06:01:36PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 12 Nov 2022, Jiri Wiesner wrote:
> 
> > On Sat, Nov 12, 2022 at 10:00:01AM +0100, Jiri Wiesner wrote:
> > > On Mon, Oct 31, 2022 at 04:56:43PM +0200, Julian Anastasov wrote:
> > > > Use the provided u64_stats_t type to avoid
> > > > load/store tearing.
> > 
> > I think only 32-bit machines have a problem storing a 64-bit counter atomically. u64_stats_fetch_begin() and u64_stats_fetch_retry() should take care of that.
> 
> 	Some compilers for 64-bit can use two 32-bit
> loads (load tearing) while we require atomic 64-bit read
> in case reader is interrupted by updater. That is why READ_ONCE
> is used now. I don't know which compilers can do this. That is
> why I switched to u64_stats_t to correctly use the u64_stats
> interface. And our data is 8-byte aligned. 32-bit are using
> seqcount_t, so they are protected for this problem.

All right. It is counter-intuitive but I guess those compiles have their reasons. I think it would not hurt to expand the description of the patch with the explanation above.

> > > Converting the per cpu stat to u64_stats_t means that the compiler cannot optimize the memory access and addition on x86_64. Previously, the summation of per cpu counters in ip_vs_chain_estimation() looked like:
> > > 15b65:  add    (%rsi),%r14
> > > 15b68:  add    0x8(%rsi),%r15
> > > 15b6c:  add    0x10(%rsi),%r13
> > > 15b70:  add    0x18(%rsi),%r12
> > > 15b74:  add    0x20(%rsi),%rbp
> > > The u64_stats_read() calls in ip_vs_chain_estimation() turned it into:
> > > 159d5:  mov    (%rcx),%r11
> > > 159d8:  mov    0x8(%rcx),%r10
> > > 159dc:  mov    0x10(%rcx),%r9
> > > 159e0:  mov    0x18(%rcx),%rdi
> > > 159e4:  mov    0x20(%rcx),%rdx
> > > 159e8:  add    %r11,%r14
> > > 159eb:  add    %r10,%r13
> > > 159ee:  add    %r9,%r12
> > > 159f1:  add    %rdi,%rbp
> > > 159f4:  add    %rdx,%rbx
> > > I guess that is not a big deal because the mov should be the instruction taking the most time on account of accessing per cpu regions of other CPUs. The add will be fast.
> > 
> > Another concern is the number of registers needed for the summation. Previously, 5 registers were needed. Now, 10 registers are needed. This would matter mostly if the size of the stack frame of ip_vs_chain_estimation() and the number of callee-saved registers stored to the stack changed, but introducing u64_stats_read() in ip_vs_chain_estimation() did not change that.
> 
> 	It happens in this way probably because compiler should not 
> reorder two or more successive instances of READ_ONCE (rwonce.h), 
> something that hurts u64_stats_read(). As result, it multiplies
> up to 5 times the needed temp storage (registers or stack).
> 
> 	Another option would be to use something like
> this below, try on top of v6. It is rude to add ifdefs here but
> we should avoid unneeded code for 64-bit. On 32-bit, code is
> more but operations are same. On 64-bit it should order
> read+add one by one which can run in parallel. In my compile
> tests it uses 3 times movq(READ_ONCE)+addq(to sum) with same temp
> register which defeats fully parallel operations and for the
> last 2 counters uses movq,movq,addq,addq with different
> registers which can run in parallel. It seems there are no free
> registers to make it for all 5 counters.
> 
> 	With this patch the benefit is that compiler should
> not hold all 5 values before adding them but on
> x86 this patch shows some problem: it does not allocate
> 5 new temp registers to read and add the values in parallel.
> Without this patch, as you show it, it somehow allocates 5+5
> registers which allows parallel operations.
> 
> 	If you think we are better with such change, we
> can include it in patch 4. It will be better in case one day
> we add more counters and there are more available registers.
> You can notice the difference probably by comparing the
> chain_max value in performance mode.

I have tested the change to ip_vs_chain_estimation() and ran profiling with bus-cycles, which are proportional to time spent executing code. The number of estimator per kthread was the same in both tests - 88800. It turns out the change made the code slower:
> #       Util1          Util2                    Diff  Command          Shared Object        Symbol   CPU
> 1,124,932,796  1,143,867,951     18,935,155 (  1.7%)  ipvs-e:0:0       [ip_vs]              all      all
>    16,480,274     16,853,752        373,478 (  2.3%)  ipvs-e:0:1       [ip_vs]              all      all
>             0         21,987         21,987 (100.0%)  ipvs-e:0:0       [kvm]                all      all
>     4,622,992      4,366,150       -256,842 (  5.6%)  ipvs-e:0:1       [kernel.kallsyms]    all      all
>   180,226,857    164,665,271    -15,561,586 (  8.6%)  ipvs-e:0:0       [kernel.kallsyms]    all      all
The most significant component was the time spent in ip_vs_chain_estimation():
> #       Util1          Util2                    Diff  Command          Shared Object        Symbol                     CPU
> 1,124,414,110  1,143,352,233     18,938,123 (  1.7%)  ipvs-e:0:0       [ip_vs]              ip_vs_chain_estimation     all
>    16,291,044     16,574,498        283,454 (  1.7%)  ipvs-e:0:1       [ip_vs]              ip_vs_chain_estimation     all
>       189,230        279,254         90,024 ( 47.6%)  ipvs-e:0:1       [ip_vs]              ip_vs_estimation_kthread   all
>       518,686        515,718         -2,968 (  0.6%)  ipvs-e:0:0       [ip_vs]              ip_vs_estimation_kthread   all
>     1,562,512      1,377,609       -184,903 ( 11.8%)  ipvs-e:0:0       [kernel.kallsyms]    kthread_should_stop        all
>     2,435,803      2,138,404       -297,399 ( 12.2%)  ipvs-e:0:1       [kernel.kallsyms]    _find_next_bit             all
>    16,304,577     15,786,553       -518,024 (  3.2%)  ipvs-e:0:0       [kernel.kallsyms]    _raw_spin_lock             all
>   151,110,969    137,172,160    -13,938,809 (  9.2%)  ipvs-e:0:0       [kernel.kallsyms]    _find_next_bit             all
 
The disassembly shows it is the mov instructions (there is a skid of 1 instruction) what takes the most time:
>Percent |      Source code & Disassembly of kcore for bus-cycles (55354 samples, percent: local period)
>        : ffffffffc0bad980 <ip_vs_chain_estimation>:
>            v6 patchset                            v6 patchset + ip_vs_chain_estimation() change
>-------------------------------------------------------------------------------------------------------
>   0.00 :       nopl   0x0(%rax,%rax,1)             0.00 :       nopl   0x0(%rax,%rax,1)
>   0.00 :       push   %r15                         0.00 :       push   %r15
>   0.00 :       push   %r14                         0.00 :       push   %r14
>   0.00 :       push   %r13                         0.00 :       push   %r13
>   0.00 :       push   %r12                         0.00 :       push   %r12
>   0.00 :       push   %rbp                         0.00 :       push   %rbp
>   0.00 :       push   %rbx                         0.00 :       push   %rbx
>   0.00 :       sub    $0x8,%rsp                    0.00 :       sub    $0x8,%rsp
>   0.00 :       mov    (%rdi),%r15                  0.00 :       mov    (%rdi),%r15
>   0.00 :       test   %r15,%r15                    0.00 :       test   %r15,%r15
>   0.00 :       je     0xffffffffc0badaf1           0.00 :       je     0xffffffffc0b7faf1
>   0.00 :       call   0xffffffff8bcd33a0           0.00 :       call   0xffffffffa1ed33a0
>   0.00 :       test   %al,%al                      0.00 :       test   %al,%al
>   0.00 :       jne    0xffffffffc0badaf1           0.00 :       jne    0xffffffffc0b7faf1
>   0.00 :       mov    -0x334ccb22(%rip),%esi       0.00 :       mov    -0x1d29eb22(%rip),%esi
>   0.00 :       xor    %eax,%eax                    0.00 :       xor    %eax,%eax
>   0.00 :       xor    %ebx,%ebx                    0.00 :       xor    %ebx,%ebx
>   0.00 :       xor    %ebp,%ebp                    0.00 :       xor    %ebp,%ebp
>   0.00 :       xor    %r12d,%r12d                  0.00 :       xor    %r12d,%r12d
>   0.00 :       xor    %r13d,%r13d                  0.00 :       xor    %r13d,%r13d
>   0.05 :       xor    %r14d,%r14d                  0.08 :       xor    %r14d,%r14d
>   0.00 :       jmp    0xffffffffc0bad9f7           0.00 :       jmp    0xffffffffc0b7f9f7
>   0.14 :       movslq %eax,%rdx                    0.08 :       movslq %eax,%rdx
>   0.00 :       mov    0x68(%r15),%rcx              0.00 :       mov    0x68(%r15),%rcx
>  11.92 :       add    $0x1,%eax                   12.25 :       add    $0x1,%eax
>   0.00 :       add    -0x72ead560(,%rdx,8),%rcx    0.00 :       add    -0x5ccad560(,%rdx,8),%rcx
>   4.07 :       mov    (%rcx),%r11                  3.84 :       mov    (%rcx),%rdx
>  34.28 :       mov    0x8(%rcx),%r10              34.17 :       add    %rdx,%r14
>  10.35 :       mov    0x10(%rcx),%r9               2.62 :       mov    0x8(%rcx),%rdx
>   7.28 :       mov    0x18(%rcx),%rdi              9.33 :       add    %rdx,%r13
>   7.70 :       mov    0x20(%rcx),%rdx              1.82 :       mov    0x10(%rcx),%rdx
>   6.80 :       add    %r11,%r14                    6.11 :       add    %rdx,%r12
>   0.27 :       add    %r10,%r13                    1.26 :       mov    0x18(%rcx),%rdx
>   0.36 :       add    %r9,%r12                     6.00 :       add    %rdx,%rbp
>   2.24 :       add    %rdi,%rbp                    2.97 :       mov    0x20(%rcx),%rdx
>   1.21 :       add    %rdx,%rbx                    5.78 :       add    %rdx,%rbx
>   0.07 :       movslq %eax,%rdx                    1.08 :       movslq %eax,%rdx
>   0.35 :       mov    $0xffffffff8d6e0860,%rdi     0.00 :       mov    $0xffffffffa38e0860,%rdi
>   2.26 :       call   0xffffffff8c16e270           2.62 :       call   0xffffffffa236e270
>   0.17 :       mov    -0x334ccb7c(%rip),%esi       0.11 :       mov    -0x1d29eb7c(%rip),%esi
>   0.00 :       cmp    %eax,%esi                    0.00 :       cmp    %eax,%esi
>   0.00 :       ja     0xffffffffc0bad9c3           0.00 :       ja     0xffffffffc0b7f9c3
>   0.00 :       lea    0x70(%r15),%rdx              0.00 :       lea    0x70(%r15),%rdx
>   0.00 :       mov    %rdx,%rdi                    0.00 :       mov    %rdx,%rdi
>   0.04 :       mov    %rdx,(%rsp)                  0.05 :       mov    %rdx,(%rsp)
>   0.00 :       call   0xffffffff8c74d800           0.00 :       call   0xffffffffa294d800
>   0.06 :       mov    %r14,%rax                    0.07 :       mov    %r14,%rax
>   0.00 :       sub    0x20(%r15),%rax              0.00 :       sub    0x20(%r15),%rax
>   9.55 :       mov    0x38(%r15),%rcx              8.97 :       mov    0x38(%r15),%rcx
>   0.01 :       mov    (%rsp),%rdx                  0.03 :       mov    (%rsp),%rdx
 
The results indicate that the extra add instructions should not matter - memory accesses (the mov instructions) are the bottleneck.

-- 
Jiri Wiesner
SUSE Labs
