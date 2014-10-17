From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Fri, 17 Oct 2014 08:27:18 +0200
Message-ID: <20141017062718.GB8618@verge.net.au>
References: <20141006073232.GA10073@verge.net.au>
 <1412610379-6295-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1410062159290.2258@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1410062159290.2258@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, dan.carpenter@oracle.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kernel-team@fb.com

On Mon, Oct 06, 2014 at 10:01:08PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 6 Oct 2014, Alex Gartrell wrote:
> 
> > Use daddr instead of reaching into dest.
> > 
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Signed-off-by: Alex Gartrell <agartrell@fb.com>
> 
> 	Thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have applied this to the ipvs tree and will see about
both getting it included in v3.18 and v3.17-stable.

> > ---
> >  net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> > index 91f17c1..437a366 100644
> > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> > @@ -316,7 +316,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
> >  	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
> >  						  local))) {
> >  		IP_VS_DBG_RL("We are crossing local and non-local addresses"
> > -			     " daddr=%pI4\n", &dest->addr.ip);
> > +			     " daddr=%pI4\n", &daddr);
> >  		goto err_put;
> >  	}
> >  
> > @@ -458,7 +458,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
> >  	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
> >  						  local))) {
> >  		IP_VS_DBG_RL("We are crossing local and non-local addresses"
> > -			     " daddr=%pI6\n", &dest->addr.in6);
> > +			     " daddr=%pI6\n", daddr);
> >  		goto err_put;
> >  	}
> >  
> > -- 
> > Alex Gartrell <agartrell@fb.com>
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
