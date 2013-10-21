From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 1/3] ipv6: always prefer rt6i_gateway if present
Date: Mon, 21 Oct 2013 07:00:36 +0200
Message-ID: <20131021050036.GD28333@order.stressinduktion.org>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg> <1382272985-1528-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382272985-1528-2-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

On Sun, Oct 20, 2013 at 03:43:03PM +0300, Julian Anastasov wrote:
> In v3.9 6fd6ce2056de2709 ("ipv6: Do not depend on rt->n in
> ip6_finish_output2()." changed the behaviour of ip6_finish_output2()
> such that the recently introduced rt6_nexthop() is used
> instead of an assigned neighbor.
> 
> As rt6_nexthop() prefers rt6i_gateway only for gatewayed
> routes this causes a problem for users like IPVS, xt_TEE and
> RAW(hdrincl) if they want to use different address for routing
> compared to the destination address.
> 
> Another case is when redirect can create RTF_DYNAMIC
> route without RTF_GATEWAY flag, we ignore the rt6i_gateway
> in rt6_nexthop().
> 
> Fix the above problems by considering the rt6i_gateway if
> present, so that traffic routed to address on local subnet is
> not wrongly diverted to the destination address.
> 
> Thanks to Simon Horman and Phil Oester for spotting the
> problematic commit.
> 
> Thanks to Hannes Frederic Sowa for his review and help in testing.
> 
> Reported-by: Phil Oester <kernel@linuxace.com>
> Reported-by: Mark Brooks <mark@loadbalancer.org>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

