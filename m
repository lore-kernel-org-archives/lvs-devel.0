From: Julian Anastasov <ja@ssi.bg>
Subject: Re: activeconns * weight overflowing 32-bit int
Date: Tue, 6 Aug 2013 09:45:24 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308060856200.1710@ja.ssi.bg>
References: <20130413064355.GB24319@hostway.ca> <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg> <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg> <20130523165836.GC436@hostway.ca> <alpine.LFD.2.00.1305232243220.1810@ja.ssi.bg> <20130524004318.GB14587@hostway.ca>
 <alpine.LFD.2.00.1305241013130.1636@ja.ssi.bg> <20130806024150.GA2393@hostway.ca>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130806024150.GA2393@hostway.ca>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Kirby <sim@hostway.ca>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>


	Hello,

On Mon, 5 Aug 2013, Simon Kirby wrote:

> > 1. same as my first email:
> > 
> > int loh, doh;
> > 
> > (__u64/__s64) loh * atomic_read(&dest->weight)
> > 
> > 	In this case I see only one difference between
> > __u64 and __s64:
> > 
> > -       jb      .L41    #,
> > -       ja      .L79    #,
> > +       jl      .L41    #,
> > +       jg      .L79    #,
> > 
> > 2. Your patch:
> > 
> > unsigned int loh, doh;
> > 
> > (__u64) loh * (__u32) atomic_read(&dest->weight)
> > or
> > (__s64) loh * (__u32) atomic_read(&dest->weight)
> 
> Did you mean here "(__s64) loh * (__s32) atomic_read(&dest->sweight)"?
> 
> If not, the results for me on GCC 4.7.2 were what I posted at
> http://0x.ca/sim/ref/3.9-ipvs/.

	Reading your reply I see that the key issue you are
missing here is that the type of loh/doh matters, it should
match the type of atomic_read (and its signedness).
As atomic_t is int we prefer loh and doh to be int.
The __u64/__s64 cast before loh/doh does not matter at all.
If both operands are not from same signedness the
32*32 optimization is not applied.

> > 	Both solutions generate code that differs only
> > in imul vs. mul. In internet I see that imul is
> > preferred/faster than mul. That is why I prefer solution 1,
> > it has less casts.
> > 
> > 	So, I think you can change your patch as follows:
> > 
> > 1. Use int for loh, doh. Note that some schedulers
> > use 'unsigned int' and should be patched for this
> > definition: NQ, SED, WLC
> > 
> > 2. Use (__u64) prefix only, no (__u32) before atomic_read:
> > LBLC, LBLCR, NQ, SED, WLC
> > 
> > 	(__u64) loh * atomic_read(&dest->weight) ...
> > 	(__u64) doh * ...
> > 
> > 3. Explain in commit message that we find the
> > result64=int32*int32 faster than result64=uint32*uint32
> > and far better than using 64*64 multiply which is
> > a bit slower on older CPUs.
> 
> I found that u64*u32 was faster than u64*s32, but I didn't check s64*s32.

	It is faster because your loh/doh are u32 and single mul is
generated while for u64*s32 we have u64=u32*s32 which obviously
is not implemented with single imul/mul. Our goal is single imul.

> I checked now and found that u64*u32 and s64*s32 have the same number of
> output instructions on i386, with just the different signedness tests.
> Both actually use imul since it's the comparison after which it cares
> about for signedness.

	IIRC, (u64) u32 * u32 uses mul if you compile
with optimizations (-O).

> But what actually makes sense? Do negative weights ever make sense?

	__u64/__s64 cast does not matter because both
operands are positive values. As result, this solution
looks better:

int loh, doh;

(__s64) loh * atomic_read(&dest->weight)

	because:

- both operands are 'int' => no extra casts before atomic_read

- 'int',  not 'unsigned int' because imul is better than mul

Regards

--
Julian Anastasov <ja@ssi.bg>
