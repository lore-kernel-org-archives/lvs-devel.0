From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: avoid oops for passive FTP
Date: Thu, 2 Sep 2010 10:56:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009021052030.2773@u.domain.uli>
References: <Pine.LNX.4.58.1009020226350.14271@u.domain.uli>
 <20100902015229.GO8174@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100902015229.GO8174@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Thu, 2 Sep 2010, Simon Horman wrote:

> On Thu, Sep 02, 2010 at 02:35:14AM +0300, Julian Anastasov wrote:
> > 
> > 	Fix Passive FTP problem in ip_vs_ftp:
> > 
> > - Do not oops in nf_nat_set_seq_adjust (adjust_tcp_sequence) when
> > iptable_nat module is not loaded
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> > 
> > 	This patch is for 2.6.36
> 
> Thanks, looks good. Are you ready for me to send this to netdev and Dave Miller?
> Also, I know that you are working on the bigger picture for post 2.6.36,
> but I think it would be worth getting this change into net-next now.
> Likewise for the next patch.

	Yes, this patch should go both to 2.6.36 (stable) and
net-next, I think. I'm sending all my IPVS patches first to
you for comments and proper merging for net-next. Thanks!

> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> > 
> > --- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-02 00:45:54.000000000 +0300
> > +++ linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-02 02:12:52.000000000 +0300
> > @@ -45,6 +45,7 @@
> >  #include <linux/netfilter.h>
> >  #include <net/netfilter/nf_conntrack.h>
> >  #include <net/netfilter/nf_conntrack_expect.h>
> > +#include <net/netfilter/nf_nat.h>
> >  #include <net/netfilter/nf_nat_helper.h>
> >  #include <linux/gfp.h>
> >  #include <net/protocol.h>
> > @@ -359,7 +360,7 @@ static int ip_vs_ftp_out(struct ip_vs_ap
> >  		buf_len = strlen(buf);
> >  
> >  		ct = nf_ct_get(skb, &ctinfo);
> > -		if (ct && !nf_ct_is_untracked(ct)) {
> > +		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
> >  			/* If mangling fails this function will return 0
> >  			 * which will cause the packet to be dropped.
> >  			 * Mangling can only fail under memory pressure,
> 

Regards

--
Julian Anastasov <ja@ssi.bg>
