From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 0/2] sched: Add cond_resched_rcu_lock() helper
Date: Fri, 26 Apr 2013 10:45:06 +0900
Message-ID: <1366940708-10180-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Simon Horman <horms@verge.net.au>

Add a helper that for use in loops which read data protected by RCU and
may have a large number of iterations.  Such an example is dumping the list
of connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().

This series also updates the two ip_vs functions mentioned above
to use the helper.

As suggested by Eric Dumazet.

Simon Horman (2):
  sched: Add cond_resched_rcu_lock() helper
  ipvs: Use cond_resched_rcu_lock() helper when dumping connections

 include/linux/sched.h           | 9 +++++++++
 net/netfilter/ipvs/ip_vs_conn.c | 6 ++----
 2 files changed, 11 insertions(+), 4 deletions(-)

-- 
1.8.2.1
