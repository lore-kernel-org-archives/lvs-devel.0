From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH ipvs-next v3 0/2] sched: Add cond_resched_rcu_lock()
 helper
Date: Wed, 22 May 2013 09:54:38 +0200
Message-ID: <20130522075438.GO26912@twins.programming.kicks-ass.net>
References: <1369201832-17163-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369201832-17163-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

On Wed, May 22, 2013 at 02:50:30PM +0900, Simon Horman wrote:
> Add a helper that for use in loops which read data protected by RCU and
> may have a large number of iterations.  Such an example is dumping the list
> of connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().
> 
> This series also updates IPVS to use the helper.
> 
> Simon Horman (2):
>   sched: add cond_resched_rcu() helper
>   ipvs: use cond_resched_rcu() helper when walking connections
> 
>  include/linux/sched.h           |  9 +++++++++
>  net/netfilter/ipvs/ip_vs_conn.c | 23 ++++++++---------------
>  2 files changed, 17 insertions(+), 15 deletions(-)

Acked-by: Peter Zijlstra <peterz@infradead.org>

How do you want to go about merging this? Do you want to route it
through the net tree or through -tip?


