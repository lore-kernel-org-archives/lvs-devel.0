From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipvs: fix ipv6 route unreach panic
Date: Tue, 14 Jul 2015 11:21:16 +0200
Message-ID: <1436865676.12408.6.camel@stressinduktion.org>
References: <1435313925-107850-1-git-send-email-agartrell@fb.com>
	 <20150714082041.GA5220@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=
	stressinduktion.org; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-sasl-enc:x-sasl-enc; s=mesmtp; bh=WLK0qefg/y43ilBX
	lbHGqr9IOR8=; b=izDJcQo5liYvX2F6D6NjgtYjQtsKDa1dt24Z7KeDnl3tqn+U
	QIEF5BWY1aQzB5vfNcntX1A5t3ZxeJcXojd+MsKmpqXF1gazU20pSC5V4SghNiJB
	DoQqRsefFGLUTgS53isZog5arBHrdNzQLi3vL6ZJdqyjsjX3EJb8Nqre3aI=
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-sasl-enc:x-sasl-enc; s=smtpout; bh=WLK0qefg/y43ilB
	XlbHGqr9IOR8=; b=DuRdTdywUwxGSHQT1CX10bOH+eCLevCUYgrqAawQA43C5e/
	pCluFzuKQIOsGYMB4qo3h9Psv6oYaI2cmVhs6avjUnFzGftVyt+UxE60borQej6i
	ZjgBScUK6v8vnHiHqDTBjQa/QT0dc0OsOpnoXCdgh2lwWBCeJJXaDMbICZSI=
In-Reply-To: <20150714082041.GA5220@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Alex Gartrell <agartrell@fb.com>
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com

On Tue, 2015-07-14 at 17:20 +0900, Simon Horman wrote:
> [Cc Hannes]
> 
> On Fri, Jun 26, 2015 at 03:18:45AM -0700, Alex Gartrell wrote:
> > Previously there was a trivial panic
> > 
> > unshare -n /bin/bash <<EOF
> > ip addr add dev lo face::1/128
> > ipvsadm -A -t [face::1]:15213
> > ipvsadm -a -t [face::1]:15213 -r b00c::1
> > echo boom | nc face::1 15213
> > EOF
> > 
> > This patch allows us to replicate the net logic above and simply 
> > capture
> > the skb_dst(skb)->dev and use that for the purpose of the 
> > invocation.
> > 
> > Signed-off-by: Alex Gartrell <agartrell@fb.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_xmit.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_xmit.c 
> > b/net/netfilter/ipvs/ip_vs_xmit.c
> > index bf66a86..b99d806 100644
> > --- a/net/netfilter/ipvs/ip_vs_xmit.c
> > +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> > @@ -505,6 +505,13 @@ err_put:
> >  	return -1;
> >  
> >  err_unreach:
> > +	/* The ip6_link_failure function requires the dev field to 
> > be set
> > +	 * in order to get the net (further for the sake of fwmark
> > +	 * reflection).
> > +	 */
> > +	if (!skb->dev)
> > +		skb->dev = skb_dst(skb)->dev;
> > +
> >  	dst_link_failure(skb);
> >  	return -1;
> >  }
> 
> 
> My reading of this is that the above:
> 
> Fixes: 1eb4f7582868 ("ipv6: in case of link failure remove route 
> directly instead of letting it expire")
> 
> As it seems to me that it is that patch that causes ip6_link_failure 
> to
> require the dev field to be set.
> 
> Does that seem sane?

From what dst_link_failure -> ip6_link_failure expects the patch does
make sense.

But the Fixes tag is wrong, because the panic should be triggered during
dereferencing dev_net(skb->dev) in icmp6_send. This part was not touched
by my patch.

Bye,
Hannes

