From: Simon Horman <horms@verge.net.au>
Subject: Advice on RCU for IPVS
Date: Fri, 26 Feb 2010 14:18:12 +1100
Message-ID: <20100226031812.GC6111@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Hi,

I have been looking at converting the rwlocks in IPVS over to use RCU.
A problem that I am facing is that the lblcr scheduler uses
a write lock on list A and then taking a write lock on list B.
Where list B is basically part of one of the elements of list A.

This problem is present in ip_vs_lblcr_schedule() and
the key code looks like this.


	/* First look in our cache */
	read_lock(&svc->sched_lock);
	en = ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
	if (en) {
		...

		/* Get the least loaded destination */
		read_lock(&en->set.lock);
		dest = ip_vs_dest_set_min(&en->set);
		read_unlock(&en->set.lock);

		...

			write_lock(&en->set.lock);
			m = ip_vs_dest_set_max(&en->set);
			if (m)
				ip_vs_dest_set_erase(&en->set, m);
			write_unlock(&en->set.lock);

		...

		/* Update our cache entry */
		write_lock(&en->set.lock);
		ip_vs_dest_set_insert(&en->set, dest);
		write_unlock(&en->set.lock);
	}
	read_unlock(&svc->sched_lock);

dest is referenced counted and doesn't seem to need to be guarded
by svc->sched_lock.

It seems to me that this is quite difficult to convert over to RCU
as there are write-side critical sections inside a read-side critical
section.

I investigated reference counting the return value of
ip_vs_lblcr_get() or the return value of ip_vs_dest_set_max() and
ip_vs_dest_set_insert(). But this seems to be difficult,
especially at rmmod time.

I also considered just making the whole thing a write-side critical section.
Which seems to be somewhat of a sledge-hammer and result in
a critical section that is much larger than I would like. Though
no bigger than the existing area covered by the read-lock on
svc->sched_lock.

Any suggestions would be appreciated.

