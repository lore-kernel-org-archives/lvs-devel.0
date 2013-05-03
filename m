From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Fri, 3 May 2013 20:09:26 +0200
Message-ID: <20130503180926.GA32350@dyad.programming.kicks-ass.net>
References: <alpine.LFD.2.00.1305021848450.31548@ja.ssi.bg>
 <20130502173257.GX3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022140020.31548@ja.ssi.bg>
 <20130502193409.GA3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305022249010.25417@ja.ssi.bg>
 <20130502223107.GB3780@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1305031024080.1657@ja.ssi.bg>
 <20130503163045.GE3780@linux.vnet.ibm.com>
 <20130503170447.GB30733@dyad.programming.kicks-ass.net>
 <20130503173444.GH3780@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130503173444.GH3780@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>

> This happens in only two cases:
> 
> 1.	CONFIG_PREEMPT_RCU=n kernels.  But in this case, rcu_read_unlock()
> 	and rcu_read_lock() are free, at least for CONFIG_PROVE_LOCKING=n
> 	kernels.  And if you have CONFIG_PROVE_LOCKING=y, any contribution
> 	from rcu_read_unlock() and rcu_read_lock() will be in the noise.

Oh argh.. I completely overlooked that rcu_read_{,un}lock() are NOPs for
PREEMPT=n kernels.

/me crawls back under his stone..
