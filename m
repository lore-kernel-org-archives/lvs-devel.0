From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [RFC,PATCH] ipvs: Fix race condition in lblb and lblcr
 schedulers
Date: Wed, 13 Aug 2008 08:59:32 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808130842540.12259@titan.stealer.net>
References: <alpine.LNX.1.10.0808112202270.12259@titan.stealer.net> <20080812021053.GD22142@verge.net.au> <alpine.LNX.1.10.0808120606200.12259@titan.stealer.net> <alpine.LNX.1.10.0808121007130.12259@titan.stealer.net> <20080813054247.GA21168@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080813054247.GA21168@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, 13 Aug 2008, Simon Horman wrote:

> On Tue, Aug 12, 2008 at 03:07:48PM +0200, Sven Wegener wrote:
> > On Tue, 12 Aug 2008, Sven Wegener wrote:
> > 
> > > On Tue, 12 Aug 2008, Simon Horman wrote:
> > > 
> > > > On Tue, Aug 12, 2008 at 12:57:21AM +0200, Sven Wegener wrote:
> > > > > Both schedulers have a race condition that happens in the following 
> > > > > situation:
> > > > > 
> > > > > We have an entry in our table that already has expired according to it's 
> > > > > last use time. Then we need to schedule a new connection that uses this 
> > > > > entry.
> > > > > 
> > > > > CPU 1                           CPU 2
> > > > > 
> > > > > ip_vs_lblc_schedule()
> > > > >   ip_vs_lblc_get()
> > > > >     lock table for read
> > > > >     find entry
> > > > >     unlock table
> > > > >                                 ip_vs_lblc_check_expire()
> > > > >                                   lock table for write
> > > > >                                   kfree() expired entry
> > > > >                                   unlock table
> > > > >     return invalid entry
> > > > > 
> > > > > Problem is that we assign the last use time outside of our critical 
> > > > > region. We can make hitting this race more difficult, if not impossible, 
> > > > > if we assign the last use time while still holding the lock for reading. 
> > > > > That gives us six minutes during which it's save to use the entry, which 
> > > > > should be enough for our use case, as we're going to use it immediately 
> > > > > and don't keep a long reference to it.
> > > > > 
> > > > > We're holding the lock for reading and not for writing. The last use time 
> > > > > is an unsigned long, so the assignment should be atomic by itself. And we 
> > > > > don't care, if some other user sets it to a slightly different value. The 
> > > > > read_unlock() implies a barrier so that other CPUs see the new last use 
> > > > > time during cleanup, even if we're just using a read lock.
> > > > > 
> > > > > Other solutions would be: 1) protect the whole ip_vs_lblc_schedule() with 
> > > > > write_lock()ing the lock, 2) add reference counting for the entries, 3) 
> > > > > protect each entry with it's own lock. And all are bad for performance.
> > > > > 
> > > > > Comments? Ideas?
> > > > 
> > > > Is there a pathological case here if sysctl_ip_vs_lblc_expiration is
> > > > set to be very short and we happen to hit ip_vs_lblc_full_check()?
> > > 
> > > Yes.
> > > 
> > > > To be honest I think that I like the reference count approach best,
> > > > as it seems safe and simple. Is it really going to be horrible
> > > > for performance?
> > > 
> > > Probably not, I guess the sentence was a bit pessimistic.
> > > 
> > > > If so, I wonder if a workable solution would be to provide a more fine-grained
> > > > lock on tbl. Something like the way that ct_read_lock/unlock() works.
> > > 
> > > Also possible. But I guess I was thinking too complicated last night. What 
> > > I was after with the "protect the whole ip_vs_lblc_schedule() with 
> > > write_lock()ing the lock" was also to simply prevent someone adding 
> > > duplicate entries. If we just extend the read_lock() region to cover the 
> > > whole usage of the entry and do an additional duplicate check during 
> > > inserting the entry under write_lock(), we fix the issue and also fix the 
> > > race that someone may add duplicate entries. We have a bit overhead, 
> > > because we unlock/lock and also there is a chance of doing one or more 
> > > useless __ip_vs_wlc_schedule(), but in the end this should work. More 
> > > fine-grained locking could help to lower the impact.
> > 
> > I wondered if this whole thing can ever be totally race condition free, 
> > without changing how destinations are purged from the trash. Initial 
> > version of the patch below. Basically it pushes the locking up into 
> > ip_vs_lblc_schedule() and rearranges the code to be safe that we have a 
> > valid destination.
> 
> Hi Sven,
> 
> I think that I am happy with this, except for updating lastuse
> under a read lock, is it really safe? Do you still have any concerns?
> 
> I've annotated the code with my thoughts on how your locking is working
> - thinking aloud if you like.

Your locking description is exactly how it was intented by me.

> > diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
> > index 7a6a319..67f7b04 100644
> > --- a/net/ipv4/ipvs/ip_vs_lblc.c
> > +++ b/net/ipv4/ipvs/ip_vs_lblc.c
> > @@ -123,31 +123,6 @@ static ctl_table vs_vars_table[] = {
> >  
> >  static struct ctl_table_header * sysctl_header;
> >  
> > -/*
> > - *      new/free a ip_vs_lblc_entry, which is a mapping of a destionation
> > - *      IP address to a server.
> > - */
> > -static inline struct ip_vs_lblc_entry *
> > -ip_vs_lblc_new(__be32 daddr, struct ip_vs_dest *dest)
> > -{
> > -	struct ip_vs_lblc_entry *en;
> > -
> > -	en = kmalloc(sizeof(struct ip_vs_lblc_entry), GFP_ATOMIC);
> > -	if (en == NULL) {
> > -		IP_VS_ERR("ip_vs_lblc_new(): no memory\n");
> > -		return NULL;
> > -	}
> > -
> > -	INIT_LIST_HEAD(&en->list);
> > -	en->addr = daddr;
> > -
> > -	atomic_inc(&dest->refcnt);
> > -	en->dest = dest;
> > -
> > -	return en;
> > -}
> > -
> > -
> >  static inline void ip_vs_lblc_free(struct ip_vs_lblc_entry *en)
> >  {
> >  	list_del(&en->list);
> > @@ -189,10 +164,8 @@ ip_vs_lblc_hash(struct ip_vs_lblc_table *tbl, struct ip_vs_lblc_entry *en)
> >  	 */
> >  	hash = ip_vs_lblc_hashkey(en->addr);
> >  
> > -	write_lock(&tbl->lock);
> >  	list_add(&en->list, &tbl->bucket[hash]);
> >  	atomic_inc(&tbl->entries);
> > -	write_unlock(&tbl->lock);
> >  
> >  	return 1;
> >  }
> > @@ -209,23 +182,54 @@ ip_vs_lblc_get(struct ip_vs_lblc_table *tbl, __be32 addr)
> >  
> >  	hash = ip_vs_lblc_hashkey(addr);
> >  
> > -	read_lock(&tbl->lock);
> > -
> >  	list_for_each_entry(en, &tbl->bucket[hash], list) {
> >  		if (en->addr == addr) {
> >  			/* HIT */
> > -			read_unlock(&tbl->lock);
> >  			return en;
> >  		}
> >  	}
> >  
> > -	read_unlock(&tbl->lock);
> > -
> >  	return NULL;
> >  }
> >  
> >  
> >  /*
> > + *      new/free a ip_vs_lblc_entry, which is a mapping of a destionation
> > + *      IP address to a server.
> > + */
> > +static inline struct ip_vs_lblc_entry *
> > +ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, __be32 daddr,
> > +	       struct ip_vs_dest *dest)
> > +{
> > +	struct ip_vs_lblc_entry *en;
> > +
> > +	en = ip_vs_lblc_get(tbl, daddr);
> > +	if (!en) {
> > +		en = kmalloc(sizeof(*en), GFP_ATOMIC);
> > +		if (!en) {
> > +			IP_VS_ERR("ip_vs_lblc_new(): no memory\n");
> > +			return NULL;
> > +		}
> > +
> > +		INIT_LIST_HEAD(&en->list);
> > +		en->addr = daddr;
> > +		en->lastuse = jiffies;
> > +
> > +		atomic_inc(&dest->refcnt);
> > +		en->dest = dest;
> > +
> > +		ip_vs_lblc_hash(tbl, en);
> > +	} else if (en->dest != dest) {
> > +		atomic_dec(&en->dest->refcnt);
> > +		atomic_inc(&dest->refcnt);
> > +		en->dest = dest;
> > +	}
> > +
> > +	return en;
> > +}
> > +
> > +
> > +/*
> >   *      Flush all the entries of the specified table.
> >   */
> >  static void ip_vs_lblc_flush(struct ip_vs_lblc_table *tbl)
> > @@ -484,7 +488,7 @@ is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
> >  static struct ip_vs_dest *
> >  ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  {
> > -	struct ip_vs_dest *dest;
> > +	struct ip_vs_dest *dest = NULL;
> >  	struct ip_vs_lblc_table *tbl;
> >  	struct ip_vs_lblc_entry *en;
> >  	struct iphdr *iph = ip_hdr(skb);
> > @@ -492,38 +496,43 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  	IP_VS_DBG(6, "ip_vs_lblc_schedule(): Scheduling...\n");
> >  
> >  	tbl = (struct ip_vs_lblc_table *)svc->sched_data;
> > +	/* First look in our cache */
> > +	read_lock(&tbl->lock);
> >  	en = ip_vs_lblc_get(tbl, iph->daddr);
> > -	if (en == NULL) {
> > -		dest = __ip_vs_wlc_schedule(svc, iph);
> > -		if (dest == NULL) {
> > -			IP_VS_DBG(1, "no destination available\n");
> > -			return NULL;
> > -		}
> > -		en = ip_vs_lblc_new(iph->daddr, dest);
> > -		if (en == NULL) {
> > -			return NULL;
> > -		}
> > -		ip_vs_lblc_hash(tbl, en);
> > -	} else {
> > +	if (en) {
> >  		dest = en->dest;
> > -		if (!(dest->flags & IP_VS_DEST_F_AVAILABLE)
> > -		    || atomic_read(&dest->weight) <= 0
> > -		    || is_overloaded(dest, svc)) {
> > -			dest = __ip_vs_wlc_schedule(svc, iph);
> > -			if (dest == NULL) {
> > -				IP_VS_DBG(1, "no destination available\n");
> > -				return NULL;
> > -			}
> > -			atomic_dec(&en->dest->refcnt);
> > -			atomic_inc(&dest->refcnt);
> > -			en->dest = dest;
> > -		}
> > +		en->lastuse = jiffies;
> 
> Setting en->lastuse with a read lock held makes me feel uncomfortable.
> Are you sure it is safe?

It looks suspicous, but word-size writes should be atomic by itself. So 
even doing it under read lock should not lead to corrupted values. We 
don't care if the values that are set concurrently are overwritten, 
because they should only differ in a couple of jiffies. Might be good to 
have someone other comment on the issue too.

> > +
> > +		/*
> > +		 * If the destination is not available, i.e. it's in the trash,
> > +		 * ignore it, as it may be removed from under our feet
> > +		 */
> > +
> > +		if (!(dest->flags & IP_VS_DEST_F_AVAILABLE))
> > +			dest = NULL;
> >  	}
> > -	en->lastuse = jiffies;
> 
> At this point we know that dest exists and is not in the trash.
> We know that dest can't disapear given that its not already
> in the trash and our caller holds a read lock on __ip_vs_svc_lock.
> So dest will be safe until after ip_vs_lblc_schedule() returns.
> 
> Dest seems ok :-)
> 
> Ok, that seems complex but non-racy to me :-)
> 
> Perhaps a longer comment would be in order.

Yeah, that's the point where we prevent the race with the trash purging. 
We could change the purging of destinations from the trash to be under 
__ip_vs_svc_lock write locked, then we know that all destinations, even 
the ones in the trash are valid. Might make more sense than duplicating 
this logic in other schedulers.

> > +	read_unlock(&tbl->lock);
> 
> After the lock is released we may now lose en, but we don't care
> as its not used again inside ip_vs_lblc_schedule().
> 
> So far so good :-)
> 
> > +
> > +	/* If the destination has a weight and is not overloaded, use it */
> > +	if (dest && atomic_read(&dest->weight) > 0 && !is_overloaded(dest, svc))
> > +		goto out;
> > +
> > +	/* No cache entry or it is invalid, time to schedule */
> > +	dest = __ip_vs_wlc_schedule(svc, iph);
> > +	if (!dest) {
> > +		IP_VS_DBG(1, "no destination available\n");
> > +		return NULL;
> > +	}
> 
> This new dest must also not be in the trash by virtue of
> being returned by __ip_vs_wlc_schedule() and delitions from
> svc->destinations being protected by __ip_vs_svc_lock, which
> is held by the caller.
> 
> Also good :-)
> 
> BTW, the name of __ip_vs_wlc_schedule, really ought to be changed
> to __ip_vs_lblc_schedule. I'll make a trivial patch for that.
> 
> > +
> > +	/* If we fail to create a cache entry, we'll just use the valid dest */
> > +	write_lock(&tbl->lock);
> > +	ip_vs_lblc_new(tbl, iph->daddr, dest);
> > +	write_unlock(&tbl->lock);
> 
> This write lock looks obviously correct as the destructors
> do the same thing.
> 
> > +out:
> >  	IP_VS_DBG(6, "LBLC: destination IP address %u.%u.%u.%u "
> >  		  "--> server %u.%u.%u.%u:%d\n",
> > -		  NIPQUAD(en->addr),
> > +		  NIPQUAD(iph->daddr),
> >  		  NIPQUAD(dest->addr),
> >  		  ntohs(dest->port));
> >  
