From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 3/3] ipvs: make rerouting optional with snat_reroute
Date: Sun, 19 Sep 2010 21:02:49 +0900
Message-ID: <20100919120249.GC18134@verge.net.au>
References: <Pine.LNX.4.58.1009162346520.6976@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.1009162346520.6976@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Thu, Sep 16, 2010 at 11:49:52PM +0300, Julian Anastasov wrote:
> 
> 	Add new sysctl flag "snat_reroute". Recent kernels use
> ip_route_me_harder() to route LVS-NAT responses properly by
> VIP when there are multiple paths to client. But setups
> that do not have alternative default routes can skip this
> routing lookup by using snat_reroute=0.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Simon Horman <horms@verge.net.au>
