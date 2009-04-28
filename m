From: Simon Horman <horms@verge.net.au>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Tue, 28 Apr 2009 19:23:55 +1000
Message-ID: <20090428092351.GC8165@verge.net.au>
References: <20090428081509.GA746@verge.net.au> <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, Fabien =?iso-8859-1?Q?Duch=EAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>

On Tue, Apr 28, 2009 at 11:07:40AM +0200, Jan Engelhardt wrote:
> 
> On Tuesday 2009-04-28 10:15, Simon Horman wrote:
> >
> >It seems to me that it should be easy enough to fix by changing
> >fwmark in ip_vs_sched_persist() from:
> >
> >union nf_inet_addr fwmark = {
> >	.all = { 0, 0, 0, htonl(svc->fwmark) }
> >};
> >
> >to:
> >
> >union nf_inet_addr fwmark = {
> >	.all = { htonl(svc->fwmark), 0, 0, 0 }
> >};
> >
> >Assuming that this would result in fwmark->ip being set to
> >htonl(svc->fwmark), which is relevant if svc->af is AF_INET - that is,
> >for IPv4.[...]
> >An alternate idea would be to change the af value used for fwmarks,
> >but this seems to be even less clean than the current (slightly broken)
> >technique of using nf_inet_addr for IPv4 or IPv6 addresses, or fwmarks.
> 
> If you use ->all, then using NFPROTO_UNSPEC as af
> seems to me like a good match.

That seems reasonable, though ip_vs_ct_in_get() would still
need to use the real af for the cp->af == af and
ip_vs_addr_equal(af, s_addr, &cp->caddr) portinos of the check.

-- 
Simon Horman
  VA Linux Systems Japan K.K. Satellite Lab in Sydney, Australia
  H: www.vergenet.net/~horms/            W: www.valinux.co.jp/en

