From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 3/3] netfilter: nf_conntrack: fix rt6i_gateway checks for H.323 helper
Date: Mon, 21 Oct 2013 07:04:11 +0200
Message-ID: <20131021050411.GF28333@order.stressinduktion.org>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg> <1382272985-1528-4-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382272985-1528-4-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

On Sun, Oct 20, 2013 at 03:43:05PM +0300, Julian Anastasov wrote:
> Now when rt6_nexthop() can return nexthop address we can use it
> for proper nexthop comparison of directly connected destinations.
> For more information refer to commit bbb5823cf742a7
> ("netfilter: nf_conntrack: fix rt_gateway checks for H.323 helper").
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Cool, that the bug is fixed and the code is a bit more simple. :)

Thanks,

  Hannes

