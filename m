From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs-next] ipvs: Remove rcu_read_unlock();rcu_read_lock();
Date: Fri, 26 Apr 2013 09:28:16 +0900
Message-ID: <20130426002813.GD29748@verge.net.au>
References: <1366852353-32561-1-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304251038541.1752@ja.ssi.bg>
 <1366880726.2628.177.camel@hawk.mlab.se>
 <20130425133639.GC10898@verge.net.au>
 <1366898643.8964.139.camel@edumazet-glaptop>
 <alpine.LFD.2.00.1304252224250.1948@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1304252224250.1948@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Hans Schillstrom <hans@schillstrom.com>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Thu, Apr 25, 2013 at 10:46:55PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 25 Apr 2013, Eric Dumazet wrote:
> 
> > On Thu, 2013-04-25 at 22:36 +0900, Simon Horman wrote:
> > 
> > > Ok, leaving it seems reasonable.
> > > Pablo, do you have any objections?
> > 
> > I have objections.
> > 
> > I would _add_ a cond_resched() there to explicitly do what we want
> > 
> > Maybe a macro/inline doing this already exists.
> > 
> > static void inline cond_resched_rcu_lock(void)
> > {
> > 	if (need_resched()) {
> > 		rcu_read_unlock();
> > 		cond_resched();
> > 		rcu_read_lock();
> > 	}
> > }
> 
> 	Thanks, looks like a good idea to me, I guess
> its place is include/linux/sched.h. Simon, can you prepare
> 2 patches instead, one for cond_resched_rcu_lock and second
> for ipvs?

Sure, will do.
