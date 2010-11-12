From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [*v2 PATCH 0/9] IPVS: staging head
Date: Fri, 12 Nov 2010 10:41:25 +0100
Message-ID: <201011121041.26767.hans.schillstrom@ericsson.com>
References: <201011120834.56591.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011121028380.1686@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1011121028380.1686@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On Friday 12 November 2010 09:30:00 Julian Anastasov wrote:
> 
>  	Hello,
> 
> On Fri, 12 Nov 2010, Hans Schillstrom wrote:
> 
> > Hello Simon
> >
> > I had some probelms with the mailer and will resend this a gain...
> >
> > The first patch in the staging head was not the "current" so I switched them
> > That effected the patch 2,3 and 4
> > There was no changes in patch 5,6 and 7
> >
> > The changes is in the class - trivial.
> >  Removed fwmark from ip_vs_conn_param,
> >  and add fwmark to ip_vs_conn_new()
> 
> v2 PATCH 1-8/9
>  	OK
> 
> v2 PATCH 9/9
>  	OK but check for skb_shinfo(skb)->nr_frags is not needed,
>  	skb_linearize is inline func that has check if skb is nonlinear.
>  	So, just put skb_linearize with enough spaces in assignment.

Thank,
I'll resend the patch

> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
