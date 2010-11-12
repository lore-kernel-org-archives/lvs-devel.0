From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v2 PATCH 0/9] IPVS: staging head
Date: Fri, 12 Nov 2010 10:30:00 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011121028380.1686@ja.ssi.bg>
References: <201011120834.56591.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201011120834.56591.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>


 	Hello,

On Fri, 12 Nov 2010, Hans Schillstrom wrote:

> Hello Simon
>
> I had some probelms with the mailer and will resend this a gain...
>
> The first patch in the staging head was not the "current" so I switched them
> That effected the patch 2,3 and 4
> There was no changes in patch 5,6 and 7
>
> The changes is in the class - trivial.
>  Removed fwmark from ip_vs_conn_param,
>  and add fwmark to ip_vs_conn_new()

v2 PATCH 1-8/9
 	OK

v2 PATCH 9/9
 	OK but check for skb_shinfo(skb)->nr_frags is not needed,
 	skb_linearize is inline func that has check if skb is nonlinear.
 	So, just put skb_linearize with enough spaces in assignment.

Regards

--
Julian Anastasov <ja@ssi.bg>
