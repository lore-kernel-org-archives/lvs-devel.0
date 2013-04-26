From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Fri, 26 Apr 2013 10:03:13 +0200
Message-ID: <20130426080313.GC8669@dyad.programming.kicks-ass.net>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
 <1366940708-10180-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366940708-10180-3-git-send-email-horms@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Apr 26, 2013 at 10:45:08AM +0900, Simon Horman wrote:

> @@ -975,8 +975,7 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
>  				return cp;
>  			}
>  		}
> -		rcu_read_unlock();
> -		rcu_read_lock();
> +		cond_resched_rcu_lock();
>  	}


While I agree with the sentiment I do find it a somewhat dangerous construct in
that it might become far too easy to keep an RCU reference over this break and
thus violate the RCU premise.

Is there anything that can detect this? Sparse / cocinelle / smatch? If so it
would be great to add this to these checkers.
