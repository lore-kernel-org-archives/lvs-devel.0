From: Sven Wegener <sven.wegener@stealer.net>
Subject: [RFC,PATCH] ipvs: Fix race condition in lblb and lblcr schedulers
Date: Tue, 12 Aug 2008 00:57:21 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808112202270.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Both schedulers have a race condition that happens in the following 
situation:

We have an entry in our table that already has expired according to it's 
last use time. Then we need to schedule a new connection that uses this 
entry.

CPU 1                           CPU 2

ip_vs_lblc_schedule()
  ip_vs_lblc_get()
    lock table for read
    find entry
    unlock table
                                ip_vs_lblc_check_expire()
                                  lock table for write
                                  kfree() expired entry
                                  unlock table
    return invalid entry

Problem is that we assign the last use time outside of our critical 
region. We can make hitting this race more difficult, if not impossible, 
if we assign the last use time while still holding the lock for reading. 
That gives us six minutes during which it's save to use the entry, which 
should be enough for our use case, as we're going to use it immediately 
and don't keep a long reference to it.

We're holding the lock for reading and not for writing. The last use time 
is an unsigned long, so the assignment should be atomic by itself. And we 
don't care, if some other user sets it to a slightly different value. The 
read_unlock() implies a barrier so that other CPUs see the new last use 
time during cleanup, even if we're just using a read lock.

Other solutions would be: 1) protect the whole ip_vs_lblc_schedule() with 
write_lock()ing the lock, 2) add reference counting for the entries, 3) 
protect each entry with it's own lock. And all are bad for performance.

Comments? Ideas?

---
 net/ipv4/ipvs/ip_vs_lblc.c  |    4 +++-
 net/ipv4/ipvs/ip_vs_lblcr.c |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index 0efa3db..65f8414 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -144,6 +144,8 @@ ip_vs_lblc_new(__be32 daddr, struct ip_vs_dest *dest)
 	atomic_inc(&dest->refcnt);
 	en->dest = dest;
 
+	en->lastuse = jiffies;
+
 	return en;
 }
 
@@ -214,6 +216,7 @@ ip_vs_lblc_get(struct ip_vs_lblc_table *tbl, __be32 addr)
 	list_for_each_entry(en, &tbl->bucket[hash], list) {
 		if (en->addr == addr) {
 			/* HIT */
+			en->lastuse = jiffies;
 			read_unlock(&tbl->lock);
 			return en;
 		}
@@ -519,7 +522,6 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 			en->dest = dest;
 		}
 	}
-	en->lastuse = jiffies;
 
 	IP_VS_DBG(6, "LBLC: destination IP address %u.%u.%u.%u "
 		  "--> server %u.%u.%u.%u:%d\n",
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index 8e3bbeb..3e8cec7 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -328,6 +328,8 @@ static inline struct ip_vs_lblcr_entry *ip_vs_lblcr_new(__be32 daddr)
 	INIT_LIST_HEAD(&en->list);
 	en->addr = daddr;
 
+	en->lastuse = jiffies;
+
 	/* initilize its dest set */
 	atomic_set(&(en->set.size), 0);
 	en->set.list = NULL;
@@ -399,6 +401,7 @@ ip_vs_lblcr_get(struct ip_vs_lblcr_table *tbl, __be32 addr)
 	list_for_each_entry(en, &tbl->bucket[hash], list) {
 		if (en->addr == addr) {
 			/* HIT */
+			en->lastuse = jiffies;
 			read_unlock(&tbl->lock);
 			return en;
 		}
@@ -708,7 +711,6 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 				ip_vs_dest_set_erase(&en->set, m);
 		}
 	}
-	en->lastuse = jiffies;
 
 	IP_VS_DBG(6, "LBLCR: destination IP address %u.%u.%u.%u "
 		  "--> server %u.%u.%u.%u:%d\n",
