From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH V4 0/7] ipvs: IPv6 fragment handling for IPVS
Date: Thu, 27 Sep 2012 17:46:43 +0900
Message-ID: <20120927084643.GB16643@verge.net.au>
References: <20120926120534.24804.78415.stgit@dragon>
 <alpine.LFD.2.00.1209262347280.2156@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1209262347280.2156@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Wed, Sep 26, 2012 at 11:50:02PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 26 Sep 2012, Jesper Dangaard Brouer wrote:
> 
> > The following patchset implement IPv6 fragment handling for IPVS.
> > 
> > This work is based upon patches from Hans Schillstrom.  I have taken
> > over the patchset, in close agreement with Hans, because he don't have
> > (gotten allocated) time to complete his work.
> > 
> > I have cleaned up the patchset significantly, and split the patchset
> > up into seven patches.
> > 
> > The first 3 patches, are ready to be merged
> > 
> >  Patch01: Trivial changes, use compressed IPv6 address in output
> >  Patch02: IPv6 extend ICMPv6 handling for future types
> >  Patch03: Use config macro IS_ENABLED()
> > 
> > The next 4 patches, is V4 of the patches I have submitted earlier.
> > Where I have incorporated Julian's recent feedback.
> > 
> > - Notice that patch04 of patchset V3, have been dropped.
> > 
> > I have also tried to make the patches easier to review, by
> > reorganizing the changes, to be more strictly split (exthdr
> > vs. fragment handling).
> > 
> > I have also removed the API changes, and moved those to patch06.  This
> > is done, (1) to make it easier to review the patches, and (2) to allow
> > easier integration of Patricks idea and my RFC patch of caching exthdr
> > info in skb->cb[].  Thus, we can get these patches applied (and later
> > go back and apply the caching scheme easier).
> > 
> >  Patch04: Fix faulty IPv6 extension header handling in IPVS
> >  Patch05: Complete IPv6 fragment handling for IPVS
> >  Patch06: IPVS API change to avoid rescan of IPv6 exthdr
> >  Patch07: IPVS SIP fragment handling
> > 
> > The SIP frag handling have been split into its own patch, as I have
> > not been able to test this part my self.
> > 
> > This patchset is based upon:
> >   Pablo's nf-next tree:  git://1984.lsi.us.es/nf-next
> >   On top of:
> >     commit 2cbc78a29e76a2e92c172651204f3117491877d2
> >     (netfilter: combine ipt_REDIRECT and ip6t_REDIRECT)
> > 
> > ---
> > 
> > Jesper Dangaard Brouer (7):
> >       ipvs: SIP fragment handling
> >       ipvs: API change to avoid rescan of IPv6 exthdr
> >       ipvs: Complete IPv6 fragment handling for IPVS
> >       ipvs: Fix faulty IPv6 extension header handling in IPVS
> >       ipvs: Use config macro IS_ENABLED()
> >       ipvs: IPv6 extend ICMPv6 handling for future types
> >       ipvs: Trivial changes, use compressed IPv6 address in output
> 
> 	All 7 patches look good to me. Thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I aim to review these tomorrow.
