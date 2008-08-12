From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC,PATCH] ipvs: Fix race condition in lblb and lblcr
	schedulers
Date: Tue, 12 Aug 2008 12:10:57 +1000
Message-ID: <20080812021053.GD22142@verge.net.au>
References: <alpine.LNX.1.10.0808112202270.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808112202270.12259@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Tue, Aug 12, 2008 at 12:57:21AM +0200, Sven Wegener wrote:
> Both schedulers have a race condition that happens in the following 
> situation:
> 
> We have an entry in our table that already has expired according to it's 
> last use time. Then we need to schedule a new connection that uses this 
> entry.
> 
> CPU 1                           CPU 2
> 
> ip_vs_lblc_schedule()
>   ip_vs_lblc_get()
>     lock table for read
>     find entry
>     unlock table
>                                 ip_vs_lblc_check_expire()
>                                   lock table for write
>                                   kfree() expired entry
>                                   unlock table
>     return invalid entry
> 
> Problem is that we assign the last use time outside of our critical 
> region. We can make hitting this race more difficult, if not impossible, 
> if we assign the last use time while still holding the lock for reading. 
> That gives us six minutes during which it's save to use the entry, which 
> should be enough for our use case, as we're going to use it immediately 
> and don't keep a long reference to it.
> 
> We're holding the lock for reading and not for writing. The last use time 
> is an unsigned long, so the assignment should be atomic by itself. And we 
> don't care, if some other user sets it to a slightly different value. The 
> read_unlock() implies a barrier so that other CPUs see the new last use 
> time during cleanup, even if we're just using a read lock.
> 
> Other solutions would be: 1) protect the whole ip_vs_lblc_schedule() with 
> write_lock()ing the lock, 2) add reference counting for the entries, 3) 
> protect each entry with it's own lock. And all are bad for performance.
> 
> Comments? Ideas?

Is there a pathological case here if sysctl_ip_vs_lblc_expiration is
set to be very short and we happen to hit ip_vs_lblc_full_check()?

To be honest I think that I like the reference count approach best,
as it seems safe and simple. Is it really going to be horrible
for performance?

If so, I wonder if a workable solution would be to provide a more fine-grained
lock on tbl. Something like the way that ct_read_lock/unlock() works.
