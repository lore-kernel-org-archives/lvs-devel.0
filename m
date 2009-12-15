From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] ipvs: zero usvc and udest
Date: Tue, 15 Dec 2009 17:02:37 +0100
Message-ID: <4B27B31D.3050207@trash.net>
References: <20091214223902.GA3784@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20091214223902.GA3784@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Deon van der Merwe <dvdm@truteq.co.za>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.org>

Simon Horman wrote:
> Make sure that any otherwise uninitialised fields of usvc are zero.
> 
> This has been obvserved to cause a problem whereby the port of
> fwmark services may end up as a non-zero value which causes
> scheduling of a destination server to fail for persisitent services.
> 
> As observed by Deon van der Merwe <dvdm@truteq.co.za>.
> This fix suggested by Julian Anastasov <ja@ssi.bg>.
> 
> For good measure also zero udest.
> 
> Cc: Deon van der Merwe <dvdm@truteq.co.za>
> Acked-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> 
> This bug has been present since the netlink interface to IPVS was
> introduced in 2.6.28. I think it is relevant for 2.6.33 as well
> as -stable.

Applied, thanks. I'll push it to -stable as well.

