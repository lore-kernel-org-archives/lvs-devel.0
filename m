From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter, ipvs: Avoid undefined order of evaluation in
 assignments to struct nf_conn *
Date: Mon, 30 May 2011 08:23:37 +0900
Message-ID: <20110529232337.GD5856@verge.net.au>
References: <alpine.LNX.2.00.1105292011450.4411@swampdragon.chaosbits.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1105292011450.4411@swampdragon.chaosbits.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>

On Sun, May 29, 2011 at 08:22:56PM +0200, Jesper Juhl wrote:
> In net/netfilter/ipvs/ip_vs_nfct.c::ip_vs_update_conntrack(),
> net/netfilter/ipvs/ip_vs_xmit.c::ip_vs_nat_xmit(), 
> net/netfilter/ipvs/ip_vs_xmit.c::ip_vs_nat_xmit_v6(), 
> net/netfilter/ipvs/ip_vs_xmit.c::ip_vs_icmp_xmit)() 
> net/netfilter/ipvs/ip_vs_xmit.c::and ip_vs_icmp_xmit_v6() we do this:
> 	...
> 	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
> 	...
> 
> Since '=' is not a sequence point the order of these assignments happening 
> is undefined. Luckily it's easy to avoid by just doing what is obviously 
> the intended thing:
> 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Acked-by: Simon Horman <horms@verge.net.au>
