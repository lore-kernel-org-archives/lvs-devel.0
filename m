From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next v2 0/4] netfilter: ipvs: remove unneeded hook
 wrappers
Date: Tue, 12 Oct 2021 23:38:01 +0300 (EEST)
Message-ID: <c0378ce6-d5d0-6a11-b25f-2f098a2349e@ssi.bg>
References: <20211012172959.745-1-fw@strlen.de>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20211012172959.745-1-fw@strlen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au


	Hello,

On Tue, 12 Oct 2021, Florian Westphal wrote:

> V2: Patch 4/4 had a bug that would enter ipv6 branch for
> ipv4 packets, fix that.
> 
> This series reduces the number of different hook function
> implementations by merging the ipv4 and ipv6 hooks into
> common code.
> 
> selftests/netfilter/ipvs.sh passes.
> 
> Florian Westphal (4):
>   netfilter: ipvs: prepare for hook function reduction
>   netfilter: ipvs: remove unneeded output wrappers
>   netfilter: ipvs: remove unneeded input wrappers
>   netfilter: ipvs: merge ipv4 + ipv6 icmp reply handlers

	Patchset v2 looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

>  net/netfilter/ipvs/ip_vs_core.c | 166 ++++++--------------------------
>  1 file changed, 32 insertions(+), 134 deletions(-)
> 
> -- 
> 2.32.0

Regards

--
Julian Anastasov <ja@ssi.bg>
