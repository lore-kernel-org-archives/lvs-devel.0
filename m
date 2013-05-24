From: Simon Kirby <sim@hostway.ca>
Subject: Re: activeconns * weight overflowing 32-bit int
Date: Thu, 23 May 2013 17:43:18 -0700
Message-ID: <20130524004318.GB14587@hostway.ca>
References: <20130413064355.GB24319@hostway.ca>
 <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg>
 <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg>
 <20130523165836.GC436@hostway.ca>
 <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>

On Thu, May 23, 2013 at 11:44:22PM +0300, Julian Anastasov wrote:

> 	Hello,
> 
> On Thu, 23 May 2013, Simon Kirby wrote:
> 
> > Hello!
> > 
> > Yes, see: http://0x.ca/sim/ref/3.9-ipvs/
> > 
> > The case of just (__u64) on i386 looks not very good, but making the
> > weight also unsigned (__u32) seems to improve things. I set up a test
> 
> 	Hm, only sizeof(long int) should differ between
> 32-bit and 64-bit platforms, atomic_t is always int, int
> is returned from atomic_read and int is always 4 bytes.

It's always 4 bytes, but gcc does more stuff with u64 * s32 than it does
with u64 * s32. atomic_t seems to be int, so s32 on either arch. :)

For the u64 * u32 case, it is using the single operand form of imul which
puts a 64-bit result in eax:edx, and then does an expanded unsigned
comparison, as expected. The u64 * s32 case uses a mix of 2 imul and 2
mul and some other things.

> > harness (ipvs.c) and disassembled i386 and amd64 compiler outputs for
> > both. The only reason I haven't submitted it yet is that I haven't yet
> > confirmed that it fixes our problem in production, though it did seem to
> > work in testing. Will follow-up shortly.
> 
> 	Last time I also checked the assembler output from x86-32
> and it looked good. I used 'make net/netfilter/ipvs/ip_vs_wlc.s'
> to generate asm output, note the 's' extension.
> 
> 	May be problem in your ipvs.c file comes from the
> fact that __u64 is unsigned long long for 32-bit platforms.
> I changed the code to use 'unsigned long' as follows:
> 
> #if 0
> typedef unsigned long long __u64;
> #else
> typedef unsigned long __u64;
> #endif
> 
> 	and the x86-32 platform works correctly.
> x86-64 works for both cases: 'unsigned long long' and
> 'unsigned long' but x86-32 generates many mul operations
> for the 'unsigned long long' case which is not used in
> the kernel. That is why I didn't noticed such problem.
> 
> 	So, I think we should be safe by adding
> (__u64) without any (__u32), next days I'll check again
> the asm output. May be (__u32) before weight ensures
> 32x32 multiply but it should not be needed.

Hmm, I was comparing atomic_t being s32 versus u32, not u64 being u64. :)
Anyway, the .s results are much easier to read, and (closer to) reality!
I did a comparison with (__u64)loh * atomic_read(dest->weight) versus
(__u64)loh * (__u32)atomic_read(dest->weight) on both arches and uploaded
them to http://0x.ca/sim/ref/3.9-ipvs/. It's not a huge difference, but I
prefer the shorter/faster version. ;)

Simon-
