From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH net-next 0/4] ipvs: check scheduler callback return
 values
Date: Tue, 24 Feb 2015 11:17:47 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502241048540.1755@ja.home.ssi.bg>
References: <1424754462-3253312-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1502240914430.1755@ja.home.ssi.bg> <54EC2D69.5070300@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <54EC2D69.5070300@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Mon, 23 Feb 2015, Alex Gartrell wrote:

> > 	Can a new create_dest(svc, bool for_update) method
> > solve such problem? Such modifications are serialized, so
> > create_dest can attach new structure to sched_data just before
> > the add_dest/upd_dest call. IPVS does not clone dests on
> > update but scheduler may need this for RCU update.
> > create_dest should be called early in __ip_vs_update_dest.
> > Note that kfree(dest) is not enough, see ip_vs_dest_free(),
> > more fields may be allocated before __ip_vs_update_dest is
> > reached.
> 
> More context on the custom scheduler:
> 
> It's a consistent hash ring algorithm which requires sorting all of the
> members and then inserting them one at a time (a entry per weight).  It
> requires a massive allocation to load balance to the number of machines we
> need to.

	The schedulers do not need RCU for list traversal
if they implement their own lists. But if dest is returned
from the schedule() method this dest is not freed while
in RCU grace period. And this logic is not part of the
scheduler. So, the scheduler may use some lock(s) which is
bad for SMP (most schedulers already use such lock) and
the only thing that they should care if their schedule
method uses RCU for their internal structures. Lock
is needed only as syncronization between schedule() and
the other methods that maintain internal structures.

> Right here I'm going to admit that this is not ideal.  This is somewhat
> "inherited," but I'm currently stuck solving this problem so I'll make the
> best of it :)
> 
> So now we're in this position where adds, deletes, and updates all can force
> us to recalculate this giant hash ring.  We can either simply lock the ring
> (but this actually takes long enough with a large number of real servers with
> large weights that it causes soft lock up detection!) or do RCU (a new
> allocation every time).  We're trying out the RCU thing now which is where
> this hurt us.
> 
> One aside, if it's safe to call synchronize_rcu in that path, then it may
> solve our most painful allocation problem in part.

	Yes, it is safe to use synchronize_rcu in
scheduler, except in schedule() method, of course.
IPVS holds just a mutex on configuration changes.
But synchronize_rcu should be avoided, it is always
possible to use another way.

> > Patch 4:
> > 	As for del_dest result, failure should not happen,
> > we should be able to flush dests on module cleanup. I think, there
> > should not be any allocations in this case.
> 
> As mentioned above, we may need to reallocate in this path.  But it does
> offend my sensibilities that this is the case, so I think it'd be fair to
> change the del_dest function to return void and we'd just find another way to
> do it.

	Looks like, patch 4 can be used, just
use 'dest->flags = old_flags;' before list_add_rcu.
Because the module removal will not call del_dest, the
done_service method called by ip_vs_unbind_scheduler()
is called when service is deleted. More details here:

- init_service:
	- can be called when service is edited, eg. when
	changing scheduler
	- we can see empty list or the list of all destinations
	before the scheduler is changed
- done_service:
	- sched_data must be freed after grace period and
	module exit should be delayed with synchronize_rcu
	to wait all RCU read-side critical sections to
	complete
	- can be called without calling del_dest when
	service is deleted
- add_dest:
	- after dest is linked
- del_dest:
	- after dest is unlinked
	- not called if service is deleted, in this case
	only done_service is called
- upd_dest:
	- after dest is edited (new weight)
- schedule:
	- called under RCU read lock, services are in list
	protected by RCU
	- needs _rcu if using svc->destinations
	- can call ip_vs_dest_hold
	- scheduler can hold dests in its state long after they are
	unlinked from svc, even without providing del_dest handler.
	- should check for IP_VS_DEST_F_AVAILABLE if
	using stale dest from sched_data structures
	- should use _bh suffix for sched_lock or other locks

Regards

--
Julian Anastasov <ja@ssi.bg>
