From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH ipvs-next v3 2/2] ipvs: use cond_resched_rcu() helper
 when walking connections
Date: Thu, 23 May 2013 13:30:46 +0200
Message-ID: <20130523113046.GF22553@localhost>
References: <1369201832-17163-1-git-send-email-horms@verge.net.au>
 <1369201832-17163-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369201832-17163-3-git-send-email-horms@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Dipankar Sarma <dipankar@in.ibm.com>

On Wed, May 22, 2013 at 02:50:32PM +0900, Simon Horman wrote:
> This avoids the situation where walking of a large number of connections
> may prevent scheduling for a long time while also avoiding excessive
> calls to rcu_read_unlock() and rcu_read_lock().
> 
> Note that in the case of !CONFIG_PREEMPT_RCU this will
> add a call to cond_resched().

Applied, thanks.
