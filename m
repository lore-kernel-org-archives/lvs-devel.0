From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: fix ipv6 route unreach panic
Date: Wed, 15 Jul 2015 14:21:52 +0900
Message-ID: <20150715052152.GA7915@verge.net.au>
References: <1435313925-107850-1-git-send-email-agartrell@fb.com>
 <20150714082041.GA5220@verge.net.au>
 <1436865676.12408.6.camel@stressinduktion.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436865676.12408.6.camel@stressinduktion.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Alex Gartrell <agartrell@fb.com>, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com

On Tue, Jul 14, 2015 at 11:21:16AM +0200, Hannes Frederic Sowa wrote:
> On Tue, 2015-07-14 at 17:20 +0900, Simon Horman wrote:
> > [Cc Hannes]
> > 
> > On Fri, Jun 26, 2015 at 03:18:45AM -0700, Alex Gartrell wrote:
> > > Previously there was a trivial panic
> > > 
> > > unshare -n /bin/bash <<EOF
> > > ip addr add dev lo face::1/128
> > > ipvsadm -A -t [face::1]:15213
> > > ipvsadm -a -t [face::1]:15213 -r b00c::1
> > > echo boom | nc face::1 15213
> > > EOF
> > > 
> > > This patch allows us to replicate the net logic above and simply 
> > > capture
> > > the skb_dst(skb)->dev and use that for the purpose of the 
> > > invocation.
> > > 
> > > Signed-off-by: Alex Gartrell <agartrell@fb.com>
> > > ---
> > >  net/netfilter/ipvs/ip_vs_xmit.c | 7 +++++++
> > >  1 file changed, 7 insertions(+)
> > > 
> > > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c 
> > > b/net/netfilter/ipvs/ip_vs_xmit.c
> > > index bf66a86..b99d806 100644
> > > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> > > @@ -505,6 +505,13 @@ err_put:
> > >  	return -1;
> > >  
> > >  err_unreach:
> > > +	/* The ip6_link_failure function requires the dev field to 
> > > be set
> > > +	 * in order to get the net (further for the sake of fwmark
> > > +	 * reflection).
> > > +	 */
> > > +	if (!skb->dev)
> > > +		skb->dev = skb_dst(skb)->dev;
> > > +
> > >  	dst_link_failure(skb);
> > >  	return -1;
> > >  }
> > 
> > 
> > My reading of this is that the above:
> > 
> > Fixes: 1eb4f7582868 ("ipv6: in case of link failure remove route 
> > directly instead of letting it expire")
> > 
> > As it seems to me that it is that patch that causes ip6_link_failure 
> > to
> > require the dev field to be set.
> > 
> > Does that seem sane?
> 
> >From what dst_link_failure -> ip6_link_failure expects the patch does
> make sense.
> 
> But the Fixes tag is wrong, because the panic should be triggered during
> dereferencing dev_net(skb->dev) in icmp6_send. This part was not touched
> by my patch.

Thanks, of course you are correct.

I now wonder if this bug may not have been present ever since 
IPv6 support was added to IPv6 in v2.6.28 and thus this patch fixes
b3cdd2a73867 ("IPVS: Add and bind IPv6 xmit functions") which originally
added the call to dst_link_failure for IPv6.
