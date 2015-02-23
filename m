From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH] ipvs: allow rescheduling of new connections when port
 reuse is detected
Date: Mon, 23 Feb 2015 11:59:14 -0300
Message-ID: <20150223145914.GA27465@localhost.localdomain>
References: <0c0456705c99cfb43e3e613bc942bf5085ef9a4f.1424461040.git.mleitner@redhat.com>
 <alpine.LFD.2.11.1502211906380.1558@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1502211906380.1558@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

On Sat, Feb 21, 2015 at 07:15:40PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 20 Feb 2015, Marcelo Ricardo Leitner wrote:
> 
> > Currently, when TCP/SCTP port reusing happens, IPVS will find the old
> > entry and use it for the new one, behaving like a forced persistence.
> > But if you consider a cluster with a heavy load of small connections,
> > such reuse will happen often and may lead to a not optimal load
> > balancing and might prevent a new node from getting a fair load.
> > 
> > This patch introduces a new sysctl, conn_reuse_mode, that allows
> > controlling how to proceed when port reuse is detected. The default
> > value will allow rescheduling of new connections only if the old entry
> > was in TIME_WAIT state for TCP or CLOSED for SCTP.
> > 
> > Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> > ---
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > index c47ffd7a0a709cb73834c84652f251960f25db79..0b4ae02dabf784eebf0bb196f010e239d5c14838 100644
> > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > @@ -845,10 +845,25 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
> >  	struct ip_vs_conn *cp;
> >  	struct netns_ipvs *ipvs = net_ipvs(net);
> >  
> > -	if (!(flags & IP_VS_CONN_F_TEMPLATE))
> > +	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
> >  		cp = ip_vs_conn_in_get(param);
> > -	else
> > +		if (cp && ((cp->dport != dport) ||
> > +			   !ip_vs_addr_equal(cp->daf, &cp->daddr, daddr))) {
> > +			if (!(flags & IP_VS_CONN_F_INACTIVE)) {
> > +				ip_vs_conn_expire_now(cp);
> > +				__ip_vs_conn_put(cp);
> > +				cp = NULL;
> > +			} else {
> > +				/* This is the expiration message for the
> > +				 * connection that was already replaced, so we
> > +				 * just ignore it.
> > +				 */
> 
> 	Just noticed that a small change is needed here.
> We have very odd handling of pe and pe_data. Can you
> change the code so that we here use:
> 
> 				__ip_vs_conn_put(cp);
> 				kfree(param->pe_data);
> 				return;
> 
> instead of the goto out. I know that pe_data is not
> expected for non-templates but better to be safe.

Took me a while to understand the memory leak it would be creating.
Nice catch, thanks. 

> And __ip_vs_conn_put will not restart the timer for
> ignored messages. Then I'll post another fix for
> problem with pe, I hope it will not intersect with
> your patch.

Ok. Please let me know if I can do anything to help.

Thanks,
Marcelo

> > +				goto out;
> > +			}
> > +		}
> > +	} else {
> >  		cp = ip_vs_ct_in_get(param);
> > +	}
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
