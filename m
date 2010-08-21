From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Sat, 21 Aug 2010 12:28:32 +0900
Message-ID: <20100821032832.GB8616@verge.net.au>
References: <20100820133320.GA29311@verge.net.au>
 <20100820135918.GB17980@verge.net.au>
 <20100820192900.GD2447@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100820192900.GD2447@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Aug 20, 2010 at 12:29:00PM -0700, Paul E. McKenney wrote:
> On Fri, Aug 20, 2010 at 10:59:19PM +0900, Simon Horman wrote:
> > On Fri, Aug 20, 2010 at 10:33:21PM +0900, Simon Horman wrote:
> > > Signed-off-by: Simon Horman <horms@verge.net.au>

[ snip ]

> > > @@ -223,8 +223,8 @@ int unregister_ip_vs_scheduler(struct ip
> > >  	/*
> > >  	 *	Remove it from the d-linked scheduler list
> > >  	 */
> > > -	list_del(&scheduler->n_list);
> > > -	write_unlock_bh(&__ip_vs_sched_lock);
> > > +	list_del_rcu(&scheduler->n_list);
> > > +	spin_unlock_bh(&ip_vs_sched_mutex);
> > 
> > On further reading, I believe that I need a synchronize_rcu(); here,
> 
> Good catch!

:-)

> However, you actually need synchronize_rcu_bh() to match your
> rcu_read_lock_bh() calls.  Also, given Julian's comment, you probably
> need something to show that this conversion is a real improvement.

Thanks.  As suggested by Julian and others, I've decided to just
use a spinlock and not use RCU for this.

