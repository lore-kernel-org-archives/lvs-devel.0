From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 2/3] ipv6: fill rt6i_gateway with nexthop address
Date: Mon, 21 Oct 2013 07:01:59 +0200
Message-ID: <20131021050159.GE28333@order.stressinduktion.org>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg> <1382272985-1528-3-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382272985-1528-3-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

On Sun, Oct 20, 2013 at 03:43:04PM +0300, Julian Anastasov wrote:
> Make sure rt6i_gateway contains nexthop information in
> all routes returned from lookup or when routes are directly
> attached to skb for generated ICMP packets.
> 
> The effect of this patch should be a faster version of
> rt6_nexthop() and the consideration of local addresses as
> nexthop.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

The patch is fine. I don't mind if we leave it as is or remove rt6_nexthop,
so:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes

