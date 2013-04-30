From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Tue, 30 Apr 2013 11:45:52 +0900
Message-ID: <20130430024552.GA26726@verge.net.au>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
 <1366940708-10180-3-git-send-email-horms@verge.net.au>
 <20130426061534.GB25912@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130426061534.GB25912@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Apr 26, 2013 at 08:15:34AM +0200, Ingo Molnar wrote:
> 
> * Simon Horman <horms@verge.net.au> wrote:
> 
> > This avoids the situation where a dump of a large number of connections
> > may prevent scheduling for a long time while also avoiding excessive
> > calls to rcu_read_unlock() and rcu_read_lock().
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Julian Anastasov <ja@ssi.bg>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > ---
> >  net/netfilter/ipvs/ip_vs_conn.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index a083bda..42a7b33 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -975,8 +975,7 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
> >  				return cp;
> >  			}
> >  		}
> > -		rcu_read_unlock();
> > -		rcu_read_lock();
> > +		cond_resched_rcu_lock();
> >  	}
> >  
> >  	return NULL;
> > @@ -1015,8 +1014,7 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> >  			iter->l = &ip_vs_conn_tab[idx];
> >  			return cp;
> >  		}
> > -		rcu_read_unlock();
> > -		rcu_read_lock();
> > +		cond_resched_rcu_lock();
> 
> Feel free to route this via the networking tree.
> 
> Note that this change isn't a pure clean-up but has functional effects as 
> well: on !PREEMPT or PREEMPT_VOLUNTARY kernels it will add in a potential 
> cond_resched() - while previously it would only rcu unlock and relock 
> (which in itself isn't scheduling).
> 
> This should probably be pointed out in the changelog.

Thanks, I have added some text which I will include in v2.
