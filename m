From: Simon Horman <horms@verge.net.au>
Subject: Re: [Patch nf] ipvs: initialize tbl->entries after allocation
Date: Thu, 26 Apr 2018 14:14:25 +0200
Message-ID: <20180426121423.5c7iy2ddhjy2clzf@verge.net.au>
References: <20180423205341.13142-1-xiyou.wangcong@gmail.com>
 <alpine.LFD.2.20.1804240815120.2470@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1524744869; bh=ltuRwu7ccEwFTXDMOcPHRaV7DIUb46drH7tmvRrUV+E=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=KVGhrkAyugFwCdPW7ka54BBg8nkluwnS4yPMydr3hfrejdpGz0f5QmKsP+jFPxVaX
         xtfEG7FleHcq26NzE7y/eZTTeNvpUb7DdkqJVlMA0iYv76k/rn13RPAr+Wy5izLktU
         35d5ts4yYg+pA8W28Y0BJVpt48bUunmncWVBGeuw=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1804240815120.2470@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Tue, Apr 24, 2018 at 08:16:14AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 23 Apr 2018, Cong Wang wrote:
> 
> > tbl->entries is not initialized after kmalloc(), therefore
> > causes an uninit-value warning in ip_vs_lblc_check_expire()
> > as reported by syzbot.
> > 
> > Reported-by: <syzbot+3dfdea57819073a04f21@syzkaller.appspotmail.com>
> > Cc: Simon Horman <horms@verge.net.au>
> > Cc: Julian Anastasov <ja@ssi.bg>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> 	Thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks.

Pablo, could you take this into nf?

Acked-by: Simon Horman <horms@verge.net.au>

> 
> > ---
> >  net/netfilter/ipvs/ip_vs_lblcr.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> > index 92adc04557ed..bc2bc5eebcb8 100644
> > --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> > +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> > @@ -534,6 +534,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
> >  	tbl->counter = 1;
> >  	tbl->dead = false;
> >  	tbl->svc = svc;
> > +	atomic_set(&tbl->entries, 0);
> >  
> >  	/*
> >  	 *    Hook periodic timer for garbage collection
> > -- 
> > 2.13.0
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
