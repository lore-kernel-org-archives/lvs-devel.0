From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 2/2] IPVS: use pr_err and friends instead of
	IP_VS_ERR and friends
Date: Wed, 29 Jul 2009 09:33:38 +1000
Message-ID: <20090728233338.GD4026@verge.net.au>
References: <20090728203414.7654.73236.stgit@jazzy.zrh.corp.google.com> <20090728203554.7654.29628.stgit@jazzy.zrh.corp.google.com> <1248814615.18284.22.camel@Joe-Laptop.home>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1248814615.18284.22.camel@Joe-Laptop.home>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Hannes Eder <heder@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>

On Tue, Jul 28, 2009 at 01:56:55PM -0700, Joe Perches wrote:
> On Tue, 2009-07-28 at 22:35 +0200, Hannes Eder wrote:
> > Since pr_err and friends is used instead of printk there is not point
> > in keeping IP_VS_ERR and friends.
> > +			pr_err("Schedule: port zero only supported "
> > +			       "in persistent services, "
> > +			       "check your ipvs configuration\n");
> 
> You might consider ignoring the checkpatch 80 char limit here
> and consolidate the message into a single string.

Personally, I prefer it the way it is.

> It helps when grepping.
> 
> > @@ -377,8 +377,8 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
> >  static int ip_vs_svc_unhash(struct ip_vs_service *svc)
> >  {
> >  	if (!(svc->flags & IP_VS_SVC_F_HASHED)) {
> > -		IP_VS_ERR("ip_vs_svc_unhash(): request for unhash flagged, "
> > -			  "called from %p\n", __builtin_return_address(0));
> > +		pr_err("ip_vs_svc_unhash(): request for unhash flagged, "
> > +		       "called from %p\n", __builtin_return_address(0));
> 
> Maybe use something like:
> 	"%s(): <foo> called from %pf",
> 	 __func__, __builtin_return_address(0)
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
