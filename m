From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: avoid expiring many connections from timer
Date: Wed, 1 Jul 2020 08:54:52 +0200
Message-ID: <20200701065452.GA14771@vergenet.net>
References: <20200620100355.4364-1-ja@ssi.bg>
 <20200630151922.GA12560@vergenet.net>
 <alpine.LFD.2.22.394.2006301851400.4282@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.22.394.2006301851400.4282@ja.home.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Andrew Sy Kim <kim.andrewsy@gmail.com>

Hi,

On Tue, Jun 30, 2020 at 07:10:06PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 30 Jun 2020, Simon Horman wrote:
> 
> > > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > > index 02f2f636798d..b3921ae92740 100644
> > > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> 
> > > @@ -827,14 +852,17 @@ static void ip_vs_conn_expire(struct timer_list *t)
> > >  
> > >  		/* does anybody control me? */
> > >  		if (ct) {
> > > +			bool has_ref = !cp->timeout && __ip_vs_conn_get(ct);
> > > +
> > >  			ip_vs_control_del(cp);
> > >  			/* Drop CTL or non-assured TPL if not used anymore */
> > > -			if (!cp->timeout && !atomic_read(&ct->n_control) &&
> > > +			if (has_ref && !atomic_read(&ct->n_control) &&
> > >  			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
> > >  			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
> > >  				IP_VS_DBG(4, "drop controlling connection\n");
> > > -				ct->timeout = 0;
> > > -				ip_vs_conn_expire_now(ct);
> > > +				ip_vs_conn_del_put(ct);
> > 
> > Previously this code did not put the ct, now it does.
> > Is that intentional.
> 
> 	Yes, as ip_vs_conn_expire() now can be called both in
> timer and process context we need a reference for ct while
> calling del_timer() in ip_vs_conn_del_put(). As ct->n_control
> is 0 after our ip_vs_control_del(), ct can be expired by
> timer while we are trying to del it here.
> 
> > > @@ -1341,19 +1368,15 @@ static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
> > >  		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
> > >  			if (cp->ipvs != ipvs)
> > >  				continue;
> > > -			/* As timers are expired in LIFO order, restart
> > > -			 * the timer of controlling connection first, so
> > > -			 * that it is expired after us.
> > > -			 */
> > > +			if (atomic_read(&cp->n_control))
> > > +				continue;
> > >  			cp_c = cp->control;
> > > -			/* cp->control is valid only with reference to cp */
> > > -			if (cp_c && __ip_vs_conn_get(cp)) {
> > > +			IP_VS_DBG(4, "del connection\n");
> > > +			ip_vs_conn_del(cp);
> > > +			if (cp_c && !atomic_read(&cp_c->n_control)) {
> > >  				IP_VS_DBG(4, "del controlling connection\n");
> > > -				ip_vs_conn_expire_now(cp_c);
> > > -				__ip_vs_conn_put(cp);
> > > +				ip_vs_conn_del(cp_c);
> > 
> > Conversely, previously this code put the ct, now it doesn't.
> > Is that also intentional?
> 
> 	Now we do not get reference to cp because in RCU
> section the cp structure can not go away. So, we have an
> implicit reference to cp. Same for its cp->control (ct).
> The conn structures are freed later in RCU callback.
> 
> 	In this case we may run del_timer() after
> another CPU, eg. after ip_vs_conn_expire() was already
> called after timer expire or after ip_vs_conn_del*(). But
> for us del_timer will not succeed.

Thanks for the explanation. This now looks good to me.

Reviewed-by: Simon Horman <horms@verge.net.au>

Pablo, could you consider applying this to nf-next?

