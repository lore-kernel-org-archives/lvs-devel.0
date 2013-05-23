From: Simon Kirby <sim@hostway.ca>
Subject: Re: activeconns * weight overflowing 32-bit int
Date: Thu, 23 May 2013 09:58:36 -0700
Message-ID: <20130523165836.GC436@hostway.ca>
References: <20130413064355.GB24319@hostway.ca>
 <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg>
 <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1305220915480.1953@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>

On Wed, May 22, 2013 at 09:18:03AM +0300, Julian Anastasov wrote:

> > > With b552f7e3a9524abcbcdf86f0a99b2be58e55a9c6, which "git tag --contains"
> > > says appeared in 2.6.39-rc, the open-coded activeconns * 50 + inactconns
> > > was changed to ip_vs_dest_conn_overhead() that matches the implementation
> > > in ip_vs_wlc.c and others. The problem for us is that ip_vs_lblc.c uses
> > > "int" (and wlc uses "unsigned int") for "loh" and "doh" variables that
> > > the ip_vs_dest_conn_overhead() result is stored in, and then these are
> > > multiplied by the weight.
> > > 
> > > ip_vs_dest_conn_overhead() uses (activeconns << 8) + inactconns (* 256
> > > instead of * 50), so before where 3000 * 3000 * 50 would fit in an int,
> > > 3000 * 3000 * 256 does not.
> > 
> > 	There is no big difference between 50 and 256.
> > 
> > > We really don't care about inactconns, so removing the "<< 8" and just
> > > using activeconns would work for us, but I suspect it must be there for a
> > > raeason. "unsigned long" would fix the problem only for 64-bit arches.
> > > Using __u64 would work everywhere, but perhaps be slow on 32-bit arches.
> > > Thoughts?
> > 
> > 	May be we can avoid 64-bit multiply with a
> > 32*32=>64 optimization, for example:
> > 
> > -               if (loh * atomic_read(&dest->weight) >
> > -                   doh * atomic_read(&least->weight)) {
> > +               if ((__u64) loh * atomic_read(&dest->weight) >
> > +                   (__u64) doh * atomic_read(&least->weight)) {
> > 
> > 	May be __s64/__u64 does not matter here. Can you
> > create and test such patch for lblc and lblcr against
> > ipvs-next or net-next tree? Such change should be also
> > applied to other schedulers but it does not look so critical.
> 
> 	Any progress on this problem?

Hello!

Yes, see: http://0x.ca/sim/ref/3.9-ipvs/

The case of just (__u64) on i386 looks not very good, but making the
weight also unsigned (__u32) seems to improve things. I set up a test
harness (ipvs.c) and disassembled i386 and amd64 compiler outputs for
both. The only reason I haven't submitted it yet is that I haven't yet
confirmed that it fixes our problem in production, though it did seem to
work in testing. Will follow-up shortly.

Simon-
