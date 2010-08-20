From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 12:29:00 -0700
Message-ID: <20100820192900.GD2447@linux.vnet.ibm.com>
References: <20100820133320.GA29311@verge.net.au>
 <20100820135918.GB17980@verge.net.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100820135918.GB17980@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Aug 20, 2010 at 10:59:19PM +0900, Simon Horman wrote:
> On Fri, Aug 20, 2010 at 10:33:21PM +0900, Simon Horman wrote:
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > --- 
> > 
> > I'm still getting my head around RCU, so review would be greatly appreciated.
> > 
> > It occurs to me that this code is not performance critical, so
> > perhaps simply replacing the rwlock with a spinlock would be better?
> > 
> > Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
> > ===================================================================
> > --- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_sched.c	2010-08-20 22:21:01.000000000 +0900
> > +++ nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c	2010-08-20 22:21:51.000000000 +0900
> > @@ -35,7 +35,7 @@
> >  static LIST_HEAD(ip_vs_schedulers);
> >  
> >  /* lock for service table */
> > -static DEFINE_RWLOCK(__ip_vs_sched_lock);
> > +static DEFINE_SPINLOCK(ip_vs_sched_mutex);
> >  
> >  
> >  /*
> > @@ -91,9 +91,9 @@ static struct ip_vs_scheduler *ip_vs_sch
> >  
> >  	IP_VS_DBG(2, "%s(): sched_name \"%s\"\n", __func__, sched_name);
> >  
> > -	read_lock_bh(&__ip_vs_sched_lock);
> > +	rcu_read_lock_bh();
> >  
> > -	list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
> > +	list_for_each_entry_rcu(sched, &ip_vs_schedulers, n_list) {
> >  		/*
> >  		 * Test and get the modules atomically
> >  		 */
> > @@ -105,14 +105,14 @@ static struct ip_vs_scheduler *ip_vs_sch
> >  		}
> >  		if (strcmp(sched_name, sched->name)==0) {
> >  			/* HIT */
> > -			read_unlock_bh(&__ip_vs_sched_lock);
> > +			rcu_read_unlock_bh();
> >  			return sched;
> >  		}
> >  		if (sched->module)
> >  			module_put(sched->module);
> >  	}
> >  
> > -	read_unlock_bh(&__ip_vs_sched_lock);
> > +	rcu_read_unlock_bh();
> >  	return NULL;
> >  }
> >  
> > @@ -167,10 +167,10 @@ int register_ip_vs_scheduler(struct ip_v
> >  	/* increase the module use count */
> >  	ip_vs_use_count_inc();
> >  
> > -	write_lock_bh(&__ip_vs_sched_lock);
> > +	spin_lock_bh(&ip_vs_sched_mutex);
> >  
> >  	if (!list_empty(&scheduler->n_list)) {
> > -		write_unlock_bh(&__ip_vs_sched_lock);
> > +		spin_unlock_bh(&ip_vs_sched_mutex);
> >  		ip_vs_use_count_dec();
> >  		pr_err("%s(): [%s] scheduler already linked\n",
> >  		       __func__, scheduler->name);
> > @@ -181,9 +181,9 @@ int register_ip_vs_scheduler(struct ip_v
> >  	 *  Make sure that the scheduler with this name doesn't exist
> >  	 *  in the scheduler list.
> >  	 */
> > -	list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
> > +	list_for_each_entry_rcu(sched, &ip_vs_schedulers, n_list) {
> >  		if (strcmp(scheduler->name, sched->name) == 0) {
> > -			write_unlock_bh(&__ip_vs_sched_lock);
> > +			spin_unlock_bh(&ip_vs_sched_mutex);
> >  			ip_vs_use_count_dec();
> >  			pr_err("%s(): [%s] scheduler already existed "
> >  			       "in the system\n", __func__, scheduler->name);
> > @@ -193,8 +193,8 @@ int register_ip_vs_scheduler(struct ip_v
> >  	/*
> >  	 *	Add it into the d-linked scheduler list
> >  	 */
> > -	list_add(&scheduler->n_list, &ip_vs_schedulers);
> > -	write_unlock_bh(&__ip_vs_sched_lock);
> > +	list_add_rcu(&scheduler->n_list, &ip_vs_schedulers);
> > +	spin_unlock_bh(&ip_vs_sched_mutex);
> >  
> >  	pr_info("[%s] scheduler registered.\n", scheduler->name);
> >  
> > @@ -212,9 +212,9 @@ int unregister_ip_vs_scheduler(struct ip
> >  		return -EINVAL;
> >  	}
> >  
> > -	write_lock_bh(&__ip_vs_sched_lock);
> > +	spin_lock_bh(&ip_vs_sched_mutex);
> >  	if (list_empty(&scheduler->n_list)) {
> > -		write_unlock_bh(&__ip_vs_sched_lock);
> > +		spin_unlock_bh(&ip_vs_sched_mutex);
> >  		pr_err("%s(): [%s] scheduler is not in the list. failed\n",
> >  		       __func__, scheduler->name);
> >  		return -EINVAL;
> > @@ -223,8 +223,8 @@ int unregister_ip_vs_scheduler(struct ip
> >  	/*
> >  	 *	Remove it from the d-linked scheduler list
> >  	 */
> > -	list_del(&scheduler->n_list);
> > -	write_unlock_bh(&__ip_vs_sched_lock);
> > +	list_del_rcu(&scheduler->n_list);
> > +	spin_unlock_bh(&ip_vs_sched_mutex);
> 
> On further reading, I believe that I need a synchronize_rcu(); here,

Good catch!

However, you actually need synchronize_rcu_bh() to match your
rcu_read_lock_bh() calls.  Also, given Julian's comment, you probably
need something to show that this conversion is a real improvement.

							Thanx, Paul

> >  	/* decrease the module use count */
> >  	ip_vs_use_count_dec();
> > --
> > To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
