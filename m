From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] ipvs: make rerouting optional with snat_reroute
Date: Tue, 21 Sep 2010 17:39:55 +0200
Message-ID: <4C98D1CB.5030505@trash.net>
References: <Pine.LNX.4.58.1009162346520.6976@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.1009162346520.6976@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Am 16.09.2010 22:49, schrieb Julian Anastasov:
> 	Add new sysctl flag "snat_reroute". Recent kernels use
> ip_route_me_harder() to route LVS-NAT responses properly by
> VIP when there are multiple paths to client. But setups
> that do not have alternative default routes can skip this
> routing lookup by using snat_reroute=0.

Applied, thanks.
