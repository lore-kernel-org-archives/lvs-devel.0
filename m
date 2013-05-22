From: Simon Horman <horms@verge.net.au>
Subject: [PATCH ipvs-next v3 0/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 22 May 2013 14:50:30 +0900
Message-ID: <1369201832-17163-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Dipankar Sarma <dipankar@in.ibm.com>, Simon Horman <horms@verge.net.au>

Add a helper that for use in loops which read data protected by RCU and
may have a large number of iterations.  Such an example is dumping the list
of connections known to IPVS: ip_vs_conn_array() and ip_vs_conn_seq_next().

This series also updates IPVS to use the helper.

Simon Horman (2):
  sched: add cond_resched_rcu() helper
  ipvs: use cond_resched_rcu() helper when walking connections

 include/linux/sched.h           |  9 +++++++++
 net/netfilter/ipvs/ip_vs_conn.c | 23 ++++++++---------------
 2 files changed, 17 insertions(+), 15 deletions(-)

-- 
1.8.2.1

