From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [RFC,PATCH] ipvs: Fix race condition in lblb and lblcr
 schedulers
Date: Tue, 12 Aug 2008 06:27:16 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808120606200.12259@titan.stealer.net>
References: <alpine.LNX.1.10.0808112202270.12259@titan.stealer.net> <20080812021053.GD22142@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080812021053.GD22142@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Tue, 12 Aug 2008, Simon Horman wrote:

> On Tue, Aug 12, 2008 at 12:57:21AM +0200, Sven Wegener wrote:
> > Both schedulers have a race condition that happens in the following 
> > situation:
> > 
> > We have an entry in our table that already has expired according to it's 
> > last use time. Then we need to schedule a new connection that uses this 
> > entry.
> > 
> > CPU 1                           CPU 2
> > 
> > ip_vs_lblc_schedule()
> >   ip_vs_lblc_get()
> >     lock table for read
> >     find entry
> >     unlock table
> >                                 ip_vs_lblc_check_expire()
> >                                   lock table for write
> >                                   kfree() expired entry
> >                                   unlock table
> >     return invalid entry
> > 
> > Problem is that we assign the last use time outside of our critical 
> > region. We can make hitting this race more difficult, if not impossible, 
> > if we assign the last use time while still holding the lock for reading. 
> > That gives us six minutes during which it's save to use the entry, which 
> > should be enough for our use case, as we're going to use it immediately 
> > and don't keep a long reference to it.
> > 
> > We're holding the lock for reading and not for writing. The last use time 
> > is an unsigned long, so the assignment should be atomic by itself. And we 
> > don't care, if some other user sets it to a slightly different value. The 
> > read_unlock() implies a barrier so that other CPUs see the new last use 
> > time during cleanup, even if we're just using a read lock.
> > 
> > Other solutions would be: 1) protect the whole ip_vs_lblc_schedule() with 
> > write_lock()ing the lock, 2) add reference counting for the entries, 3) 
> > protect each entry with it's own lock. And all are bad for performance.
> > 
> > Comments? Ideas?
> 
> Is there a pathological case here if sysctl_ip_vs_lblc_expiration is
> set to be very short and we happen to hit ip_vs_lblc_full_check()?

Yes.

> To be honest I think that I like the reference count approach best,
> as it seems safe and simple. Is it really going to be horrible
> for performance?

Probably not, I guess the sentence was a bit pessimistic.

> If so, I wonder if a workable solution would be to provide a more fine-grained
> lock on tbl. Something like the way that ct_read_lock/unlock() works.

Also possible. But I guess I was thinking too complicated last night. What 
I was after with the "protect the whole ip_vs_lblc_schedule() with 
write_lock()ing the lock" was also to simply prevent someone adding 
duplicate entries. If we just extend the read_lock() region to cover the 
whole usage of the entry and do an additional duplicate check during 
inserting the entry under write_lock(), we fix the issue and also fix the 
race that someone may add duplicate entries. We have a bit overhead, 
because we unlock/lock and also there is a chance of doing one or more 
useless __ip_vs_wlc_schedule(), but in the end this should work. More 
fine-grained locking could help to lower the impact.

Sven
