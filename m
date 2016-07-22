From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] lvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc)
 || svc == NULL
Date: Fri, 22 Jul 2016 17:11:43 +0900
Message-ID: <20160722081143.GB29153@verge.net.au>
References: <1469145341-15488-1-git-send-email-fgao@ikuai8.com>
 <alpine.LFD.2.11.1607220757100.1764@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1469175105; bh=M9RGhngqX9Irg2ZJNRjB/Xrd6dKVzkrtpSgcWjh5ACc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ntSZbYvnHhXzLy5BSs9+2V4y6/LZqvnprxeZhkxRcog/A/AyjjGIldOxMeZiY9WiE
	 dKpCVE79mUL3qFMxfD619A/FU/EptYHB2dQVYuqFknHpPBSsbCVesck/UzbQBxHaqm
	 0xxN/7JR+UB/E20YUTsCDQTJTSLoHWZaB/umUF2o=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1607220757100.1764@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Gao Feng <fgao@ikuai8.com.aqb.so>, wensong@linux-vs.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, gfree.wind@gmail.com

On Fri, Jul 22, 2016 at 08:04:50AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 22 Jul 2016, fgao@ikuai8.com.aqb.so wrote:
> 
> > From: Gao Feng <fgao@ikuai8.com>
> > 
> > This minor refactoring does not change the logic of function
> > ip_vs_genl_dump_dests.
> > 
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> 
> 	Looks good to me,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	If there is a next version you can change above
> "lvs" with "ipvs" in the Subject, this is the name we use
> for the kernel part.

No need to repost just to fix that,
I can fix it up when queuing up the patch.

> 
> > ---
> >  v1: Initial patch
> > 
> >  net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index c3c809b..6dc86cc 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -3267,7 +3267,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
> >  
> >  
> >  	svc = ip_vs_genl_find_service(ipvs, attrs[IPVS_CMD_ATTR_SERVICE]);
> > -	if (IS_ERR(svc) || svc == NULL)
> > +	if (IS_ERR_OR_NULL(svc))
> >  		goto out_err;
> >  
> >  	/* Dump the destinations */
> > -- 
> > 1.9.1
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
