From: Simon Horman <horms@verge.net.au>
Subject: Re: ovf scheduler
Date: Fri, 17 Jul 2015 15:43:11 +0900
Message-ID: <20150717064311.GB7986@verge.net.au>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com>
 <alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg>
 <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com>
 <alpine.LFD.2.11.1507142152450.1833@ja.home.ssi.bg>
 <CAA0i4Bo3w3msK9Tdn1T3BNa-ZyQ6mon=XeXFRkSfsWHRVEua=w@mail.gmail.com>
 <alpine.LFD.2.11.1507161044500.1681@ja.home.ssi.bg>
 <CAA0i4BrKP91wiFOWpPpmFP3L1ZdVCPTdDk6PkJrGYGPWkqpxxw@mail.gmail.com>
 <alpine.LFD.2.11.1507162119020.2164@ja.home.ssi.bg>
 <CAA0i4Bp6cXF9u9vSWoJkaG98KNro3FweW3t_Fp05TjqybW8vtA@mail.gmail.com>
 <alpine.LFD.2.11.1507170912230.1587@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1507170912230.1587@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Raducu Deaconu <rhadoo.io88@gmail.com>, lvs-devel@vger.kernel.org

On Fri, Jul 17, 2015 at 09:16:40AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 17 Jul 2015, Raducu Deaconu wrote:
> 
> > Hello,
> > 
> > I have done the corrections.
> > 
> > 
> > Subject: [PATCH] Add ovf scheduler
> > 
> > Signed-off-by: Raducu Deaconu <rhadoo.io88@gmail.com>
> 
> 	Thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, please apply the attached patch to -next
> tree after adding the "ipvs: " prefix.

I am happy to do so, but Raducu, could you flesh out the changelog to
describe what the new scheduler does. The Kconfig text (bellow) seems to
provide the necessary information but I'd really like it in the changelog
too.

Thanks.

> 
> > ---
> >  net/netfilter/ipvs/Kconfig     |   11 +++++
> >  net/netfilter/ipvs/Makefile    |    1 +
> >  net/netfilter/ipvs/ip_vs_ovf.c |   86
> > ++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 98 insertions(+)
> >  create mode 100644 net/netfilter/ipvs/ip_vs_ovf.c
> > 
> > diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> > index 3b6929d..b32fb0d 100644
> > --- a/net/netfilter/ipvs/Kconfig
> > +++ b/net/netfilter/ipvs/Kconfig
> > @@ -162,6 +162,17 @@ config  IP_VS_FO
> >           If you want to compile it in kernel, say Y. To compile it as
> > a
> >           module, choose M here. If unsure, say N.
> > 
> > +config  IP_VS_OVF
> > +       tristate "weighted overflow scheduling"
> > +       ---help---
> > +         The weighted overflow scheduling algorithm directs network
> > +         connections to the server with the highest weight that is
> > +         currently available and overflows to the next when active
> > +         connections exceed the node's weight.
> > +
> > +         If you want to compile it in kernel, say Y. To compile it as a
> > +         module, choose M here. If unsure, say N.
> > +
> >  config IP_VS_LBLC
> >         tristate "locality-based least-connection scheduling"
> >         ---help---

[snip]
