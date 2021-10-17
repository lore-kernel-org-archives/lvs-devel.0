From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next v2 0/4] netfilter: ipvs: remove unneeded hook
 wrappers
Date: Sun, 17 Oct 2021 14:17:17 +0200
Message-ID: <20211017121717.GC8292@vergenet.net>
References: <20211012172959.745-1-fw@strlen.de>
 <c0378ce6-d5d0-6a11-b25f-2f098a2349e@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c0378ce6-d5d0-6a11-b25f-2f098a2349e@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Tue, Oct 12, 2021 at 11:38:01PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 12 Oct 2021, Florian Westphal wrote:
> 
> > V2: Patch 4/4 had a bug that would enter ipv6 branch for
> > ipv4 packets, fix that.
> > 
> > This series reduces the number of different hook function
> > implementations by merging the ipv4 and ipv6 hooks into
> > common code.
> > 
> > selftests/netfilter/ipvs.sh passes.
> > 
> > Florian Westphal (4):
> >   netfilter: ipvs: prepare for hook function reduction
> >   netfilter: ipvs: remove unneeded output wrappers
> >   netfilter: ipvs: remove unneeded input wrappers
> >   netfilter: ipvs: merge ipv4 + ipv6 icmp reply handlers
> 
> 	Patchset v2 looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks Florian,

looks good.

Reviewed-by: Simon Horman <horms@verge.net.au>

Pablo, please consider picking up this series.

