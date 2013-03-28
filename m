From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 00/19] IPVS optimizations, part 2
Date: Thu, 28 Mar 2013 10:57:12 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303281052370.2010@ja.ssi.bg>
References: <1363945614-11752-1-git-send-email-ja@ssi.bg> <20130328054127.GC10171@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130328054127.GC10171@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Thu, 28 Mar 2013, Simon Horman wrote:

> On Fri, Mar 22, 2013 at 11:46:35AM +0200, Julian Anastasov wrote:
> > 	This is the second patchset with IPVS optimizations.
> > Now we convert the schedulers, dests and services to RCU.
> > 
> > 	All patches are for net-next based on the first
> > patchset v3. The idea is after discussion and review Simon to
> > apply the patchset after a week or so to ipvs-next tree.
> > 
> > 	The changes in this patchset eliminate global locks
> > from packet processing by using RCU. There are more details
> > in the patches.
> > 
> > 	After this patchset the situation is as follows:
> > 
> > - dests:
> > 	- lookups under RCU lock allow ip_vs_dest_hold, used
> > 	for binding dest to conn or to select dest by scheduler
> > 	- dests are freed by dest_trash code long after grace period
> > 
> > - services:
> > 	- no global read_lock
> > 	- lookups under RCU lock allow scheduler to select
> > 	dests under RCU lock
> > 	- grace period implemented with IP_VS_WAIT_WHILE is
> > 	gone allowing scheduler's dest selection and scheduler
> > 	reconfiguration to run in parallel
> > 
> > - schedulers:
> > 	- schedule method runs under RCU lock, needs _rcu
> > 	if using svc->destinations, needs _bh suffix to locks
> > 	because it can be called in LOCAL_OUT hook
> > 	- when dest is added, the add_dest method is called
> > 	instead of update_service
> > 	- when dest is deleted, the del_dest method is called
> > 	instead of update_service
> > 	- when dest is updated, the upd_dest method is called
> > 	instead of update_service
> > 	- scheduler can hold dests in its state long after they are
> > 	unlinked from svc, even without providing del_dest handler.
> > 	But such dests must not be returned by the
> > 	schedule method (needs IP_VS_DEST_F_AVAILABLE check)
> > 	- sched_data must be freed after grace period and
> > 	module exit should be delayed with synchronize_rcu
> > 	to wait all RCU read-side critical sections to
> > 	complete
> > 
> > - BH:
> > 	- we do not disable BHs in LOCAL_OUT and sync code anymore
> > 	- _bh suffixes are added to all places that need them,
> > 	except timer handlers
> 
> Hi Julian,
> 
> what is the status of this series?
> 
> N.B: THis series is different to "[PATCH 00/15 v3] IPVS optimizations (repost)"

	Yes, I posted 2 parts with optimizations. Part 1 is
at v3 while part 2 is at its first version. Both series
are ready for applying. BTW, Hans plans more tests in
the next days, may be we will have some numbers for
comparison.

Regards

--
Julian Anastasov <ja@ssi.bg>
