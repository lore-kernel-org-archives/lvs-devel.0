From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: remove unnecessary assignment in
 __ip_vs_get_out_rt
Date: Fri, 17 Oct 2014 08:29:17 +0200
Message-ID: <20141017062917.GC8618@verge.net.au>
References: <1412627408-13766-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1410070112250.2258@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1410070112250.2258@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, kernel-team@fb.com

On Tue, Oct 07, 2014 at 01:22:00AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 6 Oct 2014, Alex Gartrell wrote:
> 
> > It is a precondition of the function that daddr be equal to dest->addr.ip
> > if dest is non-NULL, so this additional assignment is just confusing for
> > stupid engineers like me.
> > 
> > Signed-off-by: Alex Gartrell <agartrell@fb.com>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Looks like this line appeared unexpectedly
> in commit "ipvs: Eliminate rt->rt_dst usage in __ip_vs_get_out_rt()."

Thanks, I have applied this to ipvs-next and will see about
getting it included in v3.18.

> > ---
> >  net/netfilter/ipvs/ip_vs_xmit.c | 1 -
> >  1 file changed, 1 deletion(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> > index 91f17c1..5efa597 100644
> > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> > @@ -293,7 +293,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
> >  				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
> >  				  atomic_read(&rt->dst.__refcnt));
> >  		}
> > -		daddr = dest->addr.ip;
> >  		if (ret_saddr)
> >  			*ret_saddr = dest_dst->dst_saddr.ip;
> >  	} else {
> > -- 
> > Alex Gartrell <agartrell@fb.com>
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
