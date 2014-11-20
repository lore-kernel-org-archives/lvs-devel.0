From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] netfilter: Deletion of unnecessary checks before two
 function calls
Date: Thu, 20 Nov 2014 10:13:59 +0900
Message-ID: <20141120011359.GJ5065@verge.net.au>
References: <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
 <546BA253.6030100@users.sourceforge.net>
 <alpine.LFD.2.11.1411200024280.6497@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1411200024280.6497@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: SF Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Coccinelle <cocci@systeme.lip6.fr>

On Thu, Nov 20, 2014 at 12:26:56AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 18 Nov 2014, SF Markus Elfring wrote:
> 
> > From: Markus Elfring <elfring@users.sourceforge.net>
> > Date: Tue, 18 Nov 2014 20:37:05 +0100
> > 
> > The functions free_percpu() and module_put() test whether their argument
> > is NULL and then return immediately. Thus the test around the call is
> > not needed.
> > 
> > This issue was detected by using the Coccinelle software.
> > 
> > Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> 
> 	Pablo, the IPVS parts look ok to me,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Simon Horman <horms@verge.net.au>

> 
> > ---
> >  net/netfilter/ipvs/ip_vs_ctl.c   | 3 +--
> >  net/netfilter/ipvs/ip_vs_pe.c    | 3 +--
> >  net/netfilter/ipvs/ip_vs_sched.c | 3 +--
> >  net/netfilter/ipvs/ip_vs_sync.c  | 3 +--
> >  net/netfilter/nf_tables_api.c    | 3 +--
> >  5 files changed, 5 insertions(+), 10 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index fd3f444..7c5e40a 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -465,8 +465,7 @@ __ip_vs_bind_svc(struct ip_vs_dest *dest, struct ip_vs_service *svc)
> >  
> >  static void ip_vs_service_free(struct ip_vs_service *svc)
> >  {
> > -	if (svc->stats.cpustats)
> > -		free_percpu(svc->stats.cpustats);
> > +	free_percpu(svc->stats.cpustats);
> >  	kfree(svc);
> >  }
> >  
> > diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
> > index 1a82b29..0df17ca 100644
> > --- a/net/netfilter/ipvs/ip_vs_pe.c
> > +++ b/net/netfilter/ipvs/ip_vs_pe.c
> > @@ -37,8 +37,7 @@ struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name)
> >  			rcu_read_unlock();
> >  			return pe;
> >  		}
> > -		if (pe->module)
> > -			module_put(pe->module);
> > +		module_put(pe->module);
> >  	}
> >  	rcu_read_unlock();
> >  
> > diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
> > index 4dbcda6..199760c 100644
> > --- a/net/netfilter/ipvs/ip_vs_sched.c
> > +++ b/net/netfilter/ipvs/ip_vs_sched.c
> > @@ -104,8 +104,7 @@ static struct ip_vs_scheduler *ip_vs_sched_getbyname(const char *sched_name)
> >  			mutex_unlock(&ip_vs_sched_mutex);
> >  			return sched;
> >  		}
> > -		if (sched->module)
> > -			module_put(sched->module);
> > +		module_put(sched->module);
> >  	}
> >  
> >  	mutex_unlock(&ip_vs_sched_mutex);
> > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > index eadffb2..cafe28d 100644
> > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > @@ -820,8 +820,7 @@ ip_vs_conn_fill_param_sync(struct net *net, int af, union ip_vs_sync_conn *sc,
> >  
> >  		p->pe_data = kmemdup(pe_data, pe_data_len, GFP_ATOMIC);
> >  		if (!p->pe_data) {
> > -			if (p->pe->module)
> > -				module_put(p->pe->module);
> > +			module_put(p->pe->module);
> >  			return -ENOMEM;
> >  		}
> >  		p->pe_data_len = pe_data_len;
> > diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
> > index deeb95f..b115f54 100644
> > --- a/net/netfilter/nf_tables_api.c
> > +++ b/net/netfilter/nf_tables_api.c
> > @@ -3472,8 +3472,7 @@ static int nf_tables_abort(struct sk_buff *skb)
> >  			break;
> >  		case NFT_MSG_NEWCHAIN:
> >  			if (nft_trans_chain_update(trans)) {
> > -				if (nft_trans_chain_stats(trans))
> > -					free_percpu(nft_trans_chain_stats(trans));
> > +				free_percpu(nft_trans_chain_stats(trans));
> >  
> >  				nft_trans_destroy(trans);
> >  			} else {
> > -- 
> > 2.1.3
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
