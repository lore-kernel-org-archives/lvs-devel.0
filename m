From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC v2] ipvs: allow transmit of GRO aggregated skbs
Date: Sat, 6 Nov 2010 23:28:21 +0900
Message-ID: <20101106142817.GA27212@verge.net.au>
References: <20101105135222.GA8714@verge.net.au>
 <20101105235411.GA2443@verge.net.au>
 <alpine.LFD.2.00.1011061608510.4009@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1011061608510.4009@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Sat, Nov 06, 2010 at 04:18:21PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 6 Nov 2010, Simon Horman wrote:
> 
> >This is a first attempt at allowing LVS to transmit
> >skbs of greater than MTU length that have been aggregated by GRO.
> >
> >I have lightly tested the ip_vs_dr_xmit() portion of this patch and
> >although it seems to work I am unsure that netif_needs_gso() is the correct
> >test to use.
> 
> 	ip_forward() uses !skb_is_gso(skb), so may be it is
> enough to check for GRO instead of using netif_needs_gso?

Thanks, I'll look into that.
