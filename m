From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [rfc] IPVS: convert scheduler management to RCU
Date: Fri, 20 Aug 2010 21:03:03 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1008202045070.5207@u.domain.uli>
References: <20100820133320.GA29311@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100820133320.GA29311@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Fri, 20 Aug 2010, Simon Horman wrote:

> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> 
> I'm still getting my head around RCU, so review would be greatly appreciated.
> 
> It occurs to me that this code is not performance critical, so
> perhaps simply replacing the rwlock with a spinlock would be better?

	This specific code does not need RCU conversion, see below

> Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c
> ===================================================================
> --- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_sched.c	2010-08-20 22:21:01.000000000 +0900
> +++ nf-next-2.6/net/netfilter/ipvs/ip_vs_sched.c	2010-08-20 22:21:51.000000000 +0900
> @@ -35,7 +35,7 @@
>  static LIST_HEAD(ip_vs_schedulers);
>  
>  /* lock for service table */
> -static DEFINE_RWLOCK(__ip_vs_sched_lock);
> +static DEFINE_SPINLOCK(ip_vs_sched_mutex);

	Here is what I got as list of locking points:

__ip_vs_conntbl_lock_array:
	- can benefit from RCU, main benefits come from here

- ip_vs_conn_unhash() followed by ip_vs_conn_hash() is tricky with RCU,
	needs more thinking, eg. when cport is changed

cp->lock, cp->refcnt:
	- not a problem

tcp_app_lock, udp_app_lock, sctp_app_lock:
	- can benefit from RCU (once per connection)

svc->sched_lock:
	- only 1 read_lock, mostly writers that need exclusive access
	- so, not suitable for RCU, can be switched to spin_lock for speed

__ip_vs_sched_lock:
	- not called by packet handlers, no need for RCU
	- used only by one ip_vs_ctl user (configuration) and the
	scheduler modules
	- can remain RWLOCK, no changes in locking are needed

__ip_vs_svc_lock:
	- spin_lock, use RCU
	- restrictions for schedulers with .update_service method
	because svc->sched_lock is write locked, see below

__ip_vs_rs_lock:
	- spin_lock, use RCU

Schedulers:
	- every .schedule method has its own locking, two examples:
		- write_lock: to protect the scheduler state (can be
		changed to spin_lock), see WRR. Difficult for RCU.
		- no lock: relies on IP_VS_WAIT_WHILE, no state
		is protected explicitly, fast like RCU, see WLC

Scheduler state, eg. mark->cl:
	- careful RCU assignment, may be all .update_service methods
	should use copy-on-update (WRR). OTOH, ip_vs_wlc_schedule (WLC)
	has no locks at all, thanks to the IP_VS_WAIT_WHILE, so
	it is fast as RCU.

Statistics:
dest->stats.lock, svc->stats.lock, ip_vs_stats.lock:
	- called for every packet, BAD for SMP, see ip_vs_in_stats(),
	ip_vs_out_stats(), ip_vs_conn_stats()

curr_sb_lock:
	- called for every packet depending on conn state
	- No benefits from RCU, should be spin_lock

	To summarize:

- the main problem remains stats:
	dest->stats.lock, svc->stats.lock, ip_vs_stats.lock

- RCU benefits when connection processes many packets per connection, eg.
	for TCP, SCTP, not much for UDP. No gains for the 1st
	packet in connection.

- svc: no benefits from RCU, some schedulers protect state and
need exclusive access, others have no state (and they do not use
locks even now)

Regards

--
Julian Anastasov <ja@ssi.bg>
