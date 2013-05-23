From: Julian Anastasov <ja@ssi.bg>
Subject: Re: activeconns * weight overflowing 32-bit int
Date: Thu, 23 May 2013 23:44:22 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg>
References: <20130413064355.GB24319@hostway.ca> <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg> <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg> <20130523165836.GC436@hostway.ca>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130523165836.GC436@hostway.ca>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Kirby <sim@hostway.ca>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>


	Hello,

On Thu, 23 May 2013, Simon Kirby wrote:

> Hello!
> 
> Yes, see: http://0x.ca/sim/ref/3.9-ipvs/
> 
> The case of just (__u64) on i386 looks not very good, but making the
> weight also unsigned (__u32) seems to improve things. I set up a test

	Hm, only sizeof(long int) should differ between
32-bit and 64-bit platforms, atomic_t is always int, int
is returned from atomic_read and int is always 4 bytes.

> harness (ipvs.c) and disassembled i386 and amd64 compiler outputs for
> both. The only reason I haven't submitted it yet is that I haven't yet
> confirmed that it fixes our problem in production, though it did seem to
> work in testing. Will follow-up shortly.

	Last time I also checked the assembler output from x86-32
and it looked good. I used 'make net/netfilter/ipvs/ip_vs_wlc.s'
to generate asm output, note the 's' extension.

	May be problem in your ipvs.c file comes from the
fact that __u64 is unsigned long long for 32-bit platforms.
I changed the code to use 'unsigned long' as follows:

#if 0
typedef unsigned long long __u64;
#else
typedef unsigned long __u64;
#endif

	and the x86-32 platform works correctly.
x86-64 works for both cases: 'unsigned long long' and
'unsigned long' but x86-32 generates many mul operations
for the 'unsigned long long' case which is not used in
the kernel. That is why I didn't noticed such problem.

	So, I think we should be safe by adding
(__u64) without any (__u32), next days I'll check again
the asm output. May be (__u32) before weight ensures
32x32 multiply but it should not be needed.

Regards

--
Julian Anastasov <ja@ssi.bg>
