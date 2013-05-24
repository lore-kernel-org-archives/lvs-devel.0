From: Julian Anastasov <ja@ssi.bg>
Subject: Re: activeconns * weight overflowing 32-bit int
Date: Fri, 24 May 2013 11:11:35 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305241013130.1636@ja.ssi.bg>
References: <20130413064355.GB24319@hostway.ca> <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg> <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg> <20130523165836.GC436@hostway.ca> <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg>
 <20130524004318.GB14587@hostway.ca>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130524004318.GB14587@hostway.ca>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Kirby <sim@hostway.ca>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>


	Hello,

On Thu, 23 May 2013, Simon Kirby wrote:

> > 	Last time I also checked the assembler output from x86-32
> > and it looked good. I used 'make net/netfilter/ipvs/ip_vs_wlc.s'
> > to generate asm output, note the 's' extension.
> > 
> > 	May be problem in your ipvs.c file comes from the
> > fact that __u64 is unsigned long long for 32-bit platforms.
> > I changed the code to use 'unsigned long' as follows:
> > 
> > #if 0
> > typedef unsigned long long __u64;
> > #else
> > typedef unsigned long __u64;
> > #endif
> > 
> > 	and the x86-32 platform works correctly.
> > x86-64 works for both cases: 'unsigned long long' and
> > 'unsigned long' but x86-32 generates many mul operations
> > for the 'unsigned long long' case which is not used in
> > the kernel. That is why I didn't noticed such problem.
> > 
> > 	So, I think we should be safe by adding
> > (__u64) without any (__u32), next days I'll check again
> > the asm output. May be (__u32) before weight ensures
> > 32x32 multiply but it should not be needed.
> 
> Hmm, I was comparing atomic_t being s32 versus u32, not u64 being u64. :)
> Anyway, the .s results are much easier to read, and (closer to) reality!
> I did a comparison with (__u64)loh * atomic_read(dest->weight) versus
> (__u64)loh * (__u32)atomic_read(dest->weight) on both arches and uploaded
> them to http://0x.ca/sim/ref/3.9-ipvs/. It's not a huge difference, but I
> prefer the shorter/faster version. ;)

	I now see why your patch shows difference compared
to my tests month ago. This change is the culprit:

-       int loh, doh;
+       unsigned int loh, doh;

	It effectively changes the operation from:

(__u64/__s64) int * int

	into

(__u64) unsigned int * int

	that is why you fix it by using __u32:

(__u64) unsigned int * unsigned int

	so that both operands are from same 4-byte signedness.

	I think, we should keep loh and doh to be int, may be
the following both solutions should generate 32x32 multiply:

1. same as my first email:

int loh, doh;

(__u64/__s64) loh * atomic_read(&dest->weight)

	In this case I see only one difference between
__u64 and __s64:

-       jb      .L41    #,
-       ja      .L79    #,
+       jl      .L41    #,
+       jg      .L79    #,

2. Your patch:

unsigned int loh, doh;

(__u64) loh * (__u32) atomic_read(&dest->weight)
or
(__s64) loh * (__u32) atomic_read(&dest->weight)

	Both solutions generate code that differs only
in imul vs. mul. In internet I see that imul is
preferred/faster than mul. That is why I prefer solution 1,
it has less casts.

	So, I think you can change your patch as follows:

1. Use int for loh, doh. Note that some schedulers
use 'unsigned int' and should be patched for this
definition: NQ, SED, WLC

2. Use (__u64) prefix only, no (__u32) before atomic_read:
LBLC, LBLCR, NQ, SED, WLC

	(__u64) loh * atomic_read(&dest->weight) ...
	(__u64) doh * ...

3. Explain in commit message that we find the
result64=int32*int32 faster than result64=uint32*uint32
and far better than using 64*64 multiply which is
a bit slower on older CPUs.

Regards

--
Julian Anastasov <ja@ssi.bg>
