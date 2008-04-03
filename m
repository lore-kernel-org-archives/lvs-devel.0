From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: Least Connection Scheduler
Date: Thu, 3 Apr 2008 09:58:46 +0900
Message-ID: <200804030958.46796.j.stubbs@linkthink.co.jp>
References: <200804011336.08118.j.stubbs@linkthink.co.jp> <200804021138.15828.j.stubbs@linkthink.co.jp> <20080402080412.GC9691@verge.net.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_GvC9H+/bOOUrXK7"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080402080412.GC9691@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org

--Boundary-00=_GvC9H+/bOOUrXK7
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 02 April 2008 17:04:14 Simon Horman wrote:
> On Wed, Apr 02, 2008 at 11:38:15AM +0900, Jason Stubbs wrote:
> > On Tuesday 01 April 2008 14:55:58 Jason Stubbs wrote:
> > > The request distribution should be nearly identical in the case of real
> > > servers of equal specs. I guess I should brush off my mathematics and
> > > calculate what the difference is in the various other cases. ;)
> >
> > My mathematics was never really that good that I can just brush it off.
> > ;) Instead, I wrote a little simulation (attached) that compares
> > behaviours. The unbracketed figures below are values at the end of the
> > run, the bracketed figures below are peak values during the run and T is
> > the total number of connections sent to that server.
> >
> > With 1000reqs/sec and two servers where #1 can handle 20% more requests:
> >
> > Current LC
> > 1:  A 21(23)  I 30567(30618)  T 153040
> > 2:  A 24(26)  I 29388(29595)  T 146960
> >
> > Patched LC
> > 1:  A 22(22)  I 32978(32979)  T 164998
> > 2:  A 23(23)  I 26977(26980)  T 135002
> >
> > With 1000reqs/sec and two servers where #1 can handle 400% more requests:
> >
> > Current LC
> > 1:  A  5(11)  I 32352(32546)  T 162414
> > 2:  A 24(26)  I 27619(28344)  T 137586
> >
> > Patched LC
> > 1:  A  9(10)  I 49191(49195)  T 245998
> > 2:  A  9(10)  I 10791(10793)  T  54002
> >
> > Looking at these figures, the only real problem would be the extra number
> > of inactive connections on the faster server. However, after thinking
> > about adding server weights to the equation, I'm wondering if this would
> > not be better as yet-another-scheduler? I don't really like the idea of
> > adding extra configuration as it steps away from LVS's current
> > simplicity, but the difference in behaviour compared to the WLC scheduler
> > is too great to be able to merge as is... Would yet-another-scheduler be
> > accepted?
>
> Nice numbers :-)

Remember that these come from the simulation, but should be fairly accurate. I 
haven't actually done more than compile tested the scheduler patches. I was 
going to/will do that once the patches are generally okayed. I don't have a 
test bed at the moment. :(

> LVS does already have a number of /proc values that can be twiddled
> so I personally don't see a problem with adding one more - then again
> I'm bound to say that as it was my idea.

I coded up param twiddling before receiving this mail but didn't get a chance 
to send it out. Instead of proc values, I put the config into Kconfig. To get 
round-robining happening when the inactive weight is 0, I essentially merged 
the RR and (W)LC schedulers.

Slightly off-topic but is the compiler able to remove the 
atomic_read(&dest->inactconns) * CONFIG_IP_VS_LC_INACTIVE_WEIGHT calculation 
when CONFIG_IP_VS_LC_INACTIVE_WEIGHT is 0? If these values were changed to be 
configuration via proc, what's the overhead for retrieving the values?

> If you want to code it up as an additional scheduler that is fine.
> But looking at your numbers, I am kind of leaning towards just
> using your existing patch.
>
> I agree that the only real problem would be the extra number of
> inactive connections on the faster server. But the overhead of such
> things is really quite small - ~128 bytes of memory and a bit of
> extra time to go through the hash table (maybe).

It's not such of a big deal with the LC scheduler, but users may have finely 
tuned weights with the WLC scheduler. Without user intervention to change the 
values, these users will find that higher weighted servers are suddenly 
getting a whole lot more connections...

-- 
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
東京都渋谷区桜ヶ丘町22-14 N.E.S S棟 3F
TEL 03-5728-4772  FAX 03-5728-4773

--Boundary-00=_GvC9H+/bOOUrXK7
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="lvs-lc-rr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="lvs-lc-rr.patch"

diff -uNr linux-2.6.24-orig/net/ipv4/ipvs/Kconfig linux-2.6.24/net/ipv4/ipvs/Kconfig
--- linux-2.6.24-orig/net/ipv4/ipvs/Kconfig	2008-01-25 07:58:37.000000000 +0900
+++ linux-2.6.24/net/ipv4/ipvs/Kconfig	2008-04-02 14:32:47.415956873 +0900
@@ -127,6 +127,18 @@
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.

+if IP_VS_LC || IP_VS_WLC
+
+config	IP_VS_LC_ACTIVE_WEIGHT
+	int "LC active connection weight"
+	default "255"
+
+config	IP_VS_LC_INACTIVE_WEIGHT
+	int "LC inactive connection weight"
+	default "1"
+
+endif # IP_VS_LC || IP_VS_WLC
+
 config	IP_VS_LBLC
 	tristate "locality-based least-connection scheduling"
 	---help---
diff -uNr linux-2.6.24-orig/net/ipv4/ipvs/ip_vs_lc.c linux-2.6.24/net/ipv4/ipvs/ip_vs_lc.c
--- linux-2.6.24-orig/net/ipv4/ipvs/ip_vs_lc.c	2008-01-25 07:58:37.000000000 +0900
+++ linux-2.6.24/net/ipv4/ipvs/ip_vs_lc.c	2008-04-02 15:13:54.121724765 +0900
@@ -24,6 +24,7 @@

 static int ip_vs_lc_init_svc(struct ip_vs_service *svc)
 {
+	svc->sched_data = &svc->destinations;
 	return 0;
 }

@@ -36,6 +37,7 @@

 static int ip_vs_lc_update_svc(struct ip_vs_service *svc)
 {
+	svc->sched_data = &svc->destinations;
 	return 0;
 }

@@ -43,15 +45,8 @@
 static inline unsigned int
 ip_vs_lc_dest_overhead(struct ip_vs_dest *dest)
 {
-	/*
-	 * We think the overhead of processing active connections is 256
-	 * times higher than that of inactive connections in average. (This
-	 * 256 times might not be accurate, we will change it later) We
-	 * use the following formula to estimate the overhead now:
-	 *		  dest->activeconns*256 + dest->inactconns
-	 */
-	return (atomic_read(&dest->activeconns) << 8) +
-		atomic_read(&dest->inactconns);
+	return atomic_read(&dest->activeconns) * CONFIG_IP_VS_LC_ACTIVE_WEIGHT +
+		atomic_read(&dest->inactconns) * CONFIG_IP_VS_LC_INACTIVE_WEIGHT;
 }


@@ -61,6 +56,7 @@
 static struct ip_vs_dest *
 ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
+	struct list_head *p;
 	struct ip_vs_dest *dest, *least = NULL;
 	unsigned int loh = 0, doh;

@@ -75,16 +71,31 @@
 	 * served, but no new connection is assigned to the server.
 	 */

-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	write_lock(&svc->sched_lock);
+	p = (struct list_head *)svc->sched_data;
+	do {
+		/* skip list head */
+		if (p == &svc->destinations)
+			goto next;
+
+		dest = list_entry(p, struct ip_vs_dest, n_list);
 		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
 		    atomic_read(&dest->weight) == 0)
-			continue;
+			goto next;
+
 		doh = ip_vs_lc_dest_overhead(dest);
 		if (!least || doh < loh) {
 			least = dest;
 			loh = doh;
 		}
-	}
+
+	next:
+		p = p->next;
+	} while (p != (struct list_head *)svc->sched_data);
+
+	p = p->next;
+	svc->sched_data = p;
+	write_unlock(&svc->sched_lock);

 	if (least)
 	IP_VS_DBG(6, "LC: server %u.%u.%u.%u:%u activeconns %d inactconns %d\n",
diff -uNr linux-2.6.24-orig/net/ipv4/ipvs/ip_vs_wlc.c linux-2.6.24/net/ipv4/ipvs/ip_vs_wlc.c
--- linux-2.6.24-orig/net/ipv4/ipvs/ip_vs_wlc.c	2008-01-25 07:58:37.000000000 +0900
+++ linux-2.6.24/net/ipv4/ipvs/ip_vs_wlc.c	2008-04-02 15:14:11.731531485 +0900
@@ -30,6 +30,7 @@
 static int
 ip_vs_wlc_init_svc(struct ip_vs_service *svc)
 {
+	svc->sched_data = &svc->destinations;
 	return 0;
 }

@@ -44,6 +45,7 @@
 static int
 ip_vs_wlc_update_svc(struct ip_vs_service *svc)
 {
+	svc->sched_data = &svc->destinations;
 	return 0;
 }

@@ -51,15 +53,8 @@
 static inline unsigned int
 ip_vs_wlc_dest_overhead(struct ip_vs_dest *dest)
 {
-	/*
-	 * We think the overhead of processing active connections is 256
-	 * times higher than that of inactive connections in average. (This
-	 * 256 times might not be accurate, we will change it later) We
-	 * use the following formula to estimate the overhead now:
-	 *		  dest->activeconns*256 + dest->inactconns
-	 */
-	return (atomic_read(&dest->activeconns) << 8) +
-		atomic_read(&dest->inactconns);
+	return atomic_read(&dest->activeconns) * CONFIG_IP_VS_LC_ACTIVE_WEIGHT +
+		atomic_read(&dest->inactconns) * CONFIG_IP_VS_LC_INACTIVE_WEIGHT;
 }


@@ -69,8 +64,9 @@
 static struct ip_vs_dest *
 ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 {
-	struct ip_vs_dest *dest, *least;
-	unsigned int loh, doh;
+	struct list_head *p;
+	struct ip_vs_dest *dest, *least = NULL;
+	unsigned int loh = 0, doh;

 	IP_VS_DBG(6, "ip_vs_wlc_schedule(): Scheduling...\n");

@@ -87,31 +83,36 @@
 	 * new connections.
 	 */

-	list_for_each_entry(dest, &svc->destinations, n_list) {
-		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
-		    atomic_read(&dest->weight) > 0) {
-			least = dest;
-			loh = ip_vs_wlc_dest_overhead(least);
-			goto nextstage;
+	write_lock(&svc->sched_lock);
+	p = (struct list_head *)svc->sched_data;
+	do {
+		/* skip list head */
+		if (p == &svc->destinations) {
+			goto next;
+		}
+
+		dest = list_entry(p, struct ip_vs_dest, n_list);
+		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
+		    atomic_read(&dest->weight) == 0) {
+			goto next;
 		}
-	}
-	return NULL;

-	/*
-	 *    Find the destination with the least load.
-	 */
-  nextstage:
-	list_for_each_entry_continue(dest, &svc->destinations, n_list) {
-		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
-			continue;
 		doh = ip_vs_wlc_dest_overhead(dest);
-		if (loh * atomic_read(&dest->weight) >
+		if (!least || loh * atomic_read(&dest->weight) >
 		    doh * atomic_read(&least->weight)) {
 			least = dest;
 			loh = doh;
 		}
-	}

+	next:
+		p = p->next;
+	} while (p != (struct list_head *)svc->sched_data);
+
+	p = p->next;
+	svc->sched_data = p;
+	write_unlock(&svc->sched_lock);
+
+	if (least)
 	IP_VS_DBG(6, "WLC: server %u.%u.%u.%u:%u "
 		  "activeconns %d refcnt %d weight %d overhead %d\n",
 		  NIPQUAD(least->addr), ntohs(least->port),

--Boundary-00=_GvC9H+/bOOUrXK7--
