From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH net-next v1] ipvs: add consistent source hashing scheduling
Date: Mon,  2 Apr 2018 19:20:25 +0200
Message-ID: <20180402172025.7380-1-vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=bernat.im; h=from:to:cc
        :subject:date:message-id; s=postfix; bh=23T0FMgxMc3Z3cYALTwOionk
        dbU=; b=atrKAYGjcUJhITWbIdP9P1Iw2IKCPd7rZfJkpedvZcJFc7JPKtxcKYfa
        PEahk7S7495ovl09gDeZUmc7mhKfAUBJUtgQHBGyQPuHdfja+9pksuP5Qmex5iCn
        aIrlXEpg3oGnVAzUQSlav3mpZRxzcBNKKOvV5sUzLmnrxi7mNVM=
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Vincent Bernat <vincent@bernat.im>

Based on Google's Maglev algorithm [1][2], this scheduler builds a
lookup table in a way disruption is minimized when a change
occurs. This helps in case of active/active setup without
synchronization. Like for classic source hashing, this lookup table is
used to assign connections to a real server.

Both source address and port are used to compute the hash (unlike sh
where this is optional).

Weights are correctly handled. Unlike sh, servers with a weight of 0
are considered as absent. Also, unlike sh, when a server becomes
unavailable due to a threshold, no fallback is possible: doing so
would seriously impair the the usefulness of using a consistent hash.

There is a small hack to detect when all real servers have a weight of
0. It relies on the fact it is not possible for the weight of a real
server to change during the execution of the assignment. I believe
this is the case as modifications through netlink are subject to a
mutex, but the use of atomic_read() is unsettling.

The value of 65537 for the hash table size is currently not modifiable
at compile-time. This is the value suggested in the Maglev
paper. Another possible value is 257 (for small tests) and 655373 (for
very large setups).

[1]: https://research.google.com/pubs/pub44824.html
[2]: https://blog.acolyer.org/2016/03/21/maglev-a-fast-and-reliable-software-network-load-balancer/

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 include/net/ip_vs.h            |  27 ++++
 net/netfilter/ipvs/Kconfig     |  13 ++
 net/netfilter/ipvs/Makefile    |   1 +
 net/netfilter/ipvs/ip_vs_csh.c | 339 +++++++++++++++++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_sh.c  |  32 +---
 5 files changed, 381 insertions(+), 31 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_csh.c

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index eb0bec043c96..2184b43b7320 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -195,6 +195,33 @@ static inline int ip_vs_addr_equal(int af, const union nf_inet_addr *a,
 	return a->ip == b->ip;
 }
 
+static inline __be16 ip_vs_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
+{
+	__be16 _ports[2], *ports;
+
+	/* At this point we know that we have a valid packet of some kind.
+	 * Because ICMP packets are only guaranteed to have the first 8
+	 * bytes, let's just grab the ports.  Fortunately they're in the
+	 * same position for all three of the protocols we care about.
+	 */
+	switch (iph->protocol) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_SCTP:
+		ports = skb_header_pointer(skb, iph->len, sizeof(_ports),
+					   &_ports);
+		if (unlikely(!ports))
+			return 0;
+
+		if (likely(!ip_vs_iph_inverse(iph)))
+			return ports[0];
+		else
+			return ports[1];
+	default:
+		return 0;
+	}
+}
+
 #ifdef CONFIG_IP_VS_DEBUG
 #include <linux/net.h>
 
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index b32fb0dbe237..bfd091e020af 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -225,6 +225,19 @@ config	IP_VS_SH
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
+config	IP_VS_CSH
+	tristate "consistent source hashing scheduling"
+	---help---
+	  The consistent source hashing scheduling algorithm assigns
+	  network connections to the servers through looking up a
+	  statically assigned hash table by their source IP addresses
+	  and ports. The hash table is built to minimize disruption
+	  when a server becomes unavailable. It relies on the Maglev
+	  algorithm.
+
+	  If you want to compile it in kernel, say Y. To compile it as a
+	  module, choose M here. If unsure, say N.
+
 config	IP_VS_SED
 	tristate "shortest expected delay scheduling"
 	---help---
diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index c552993fa4b9..7d0badf86dfe 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -33,6 +33,7 @@ obj-$(CONFIG_IP_VS_LBLC) += ip_vs_lblc.o
 obj-$(CONFIG_IP_VS_LBLCR) += ip_vs_lblcr.o
 obj-$(CONFIG_IP_VS_DH) += ip_vs_dh.o
 obj-$(CONFIG_IP_VS_SH) += ip_vs_sh.o
+obj-$(CONFIG_IP_VS_CSH) += ip_vs_csh.o
 obj-$(CONFIG_IP_VS_SED) += ip_vs_sed.o
 obj-$(CONFIG_IP_VS_NQ) += ip_vs_nq.o
 
diff --git a/net/netfilter/ipvs/ip_vs_csh.c b/net/netfilter/ipvs/ip_vs_csh.c
new file mode 100644
index 000000000000..c70db61ba934
--- /dev/null
+++ b/net/netfilter/ipvs/ip_vs_csh.c
@@ -0,0 +1,339 @@
+/*
+ * IPVS:        Consistent Hashing scheduling module using Google's Maglev
+ *
+ * Authors:     Vincent Bernat <vincent@bernat.im>
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Changes:
+ *
+ */
+
+/*
+ * The Maglev algorithm is a consistent hashing algorithm described in
+ * section 3.4 of "Maglev: A Fast and Reliable Software Network Load
+ * Balancer" (https://research.google.com/pubs/pub44824.html).
+ *
+ * The following pseudo-code from listing in page 6 is implemented
+ * using M = 65537. Weight is implemented by allowing servers to push
+ * their candidates several times at each turn. Currently, thresholds
+ * are ignored.
+ *
+ * Both source address and port are used for the hash. IPVS runs after
+ * fragment reassembly, so source port is always available.
+ *
+ */
+
+#define KMSG_COMPONENT "IPVS"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
+#include <linux/ip.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+
+#include <net/ip_vs.h>
+
+#include <net/tcp.h>
+#include <linux/udp.h>
+#include <linux/sctp.h>
+
+#define IP_VS_CSH_TAB_SIZE    65537
+
+/*
+ *      IPVS CSH bucket
+ */
+struct ip_vs_csh_bucket {
+	struct ip_vs_dest __rcu	*dest;	/* real server (cache) */
+	bool assigned;
+};
+
+
+struct ip_vs_csh_state {
+	struct rcu_head		rcu_head;
+	struct ip_vs_csh_bucket	buckets[IP_VS_CSH_TAB_SIZE];
+};
+
+
+/* Helper function to determine if server is unavailable */
+static inline bool is_unavailable(struct ip_vs_dest *dest)
+{
+	return dest->flags & IP_VS_DEST_F_OVERLOAD;
+}
+
+
+/*
+ *	Returns hash value for IPVS CSH entry
+ */
+static inline unsigned int
+ip_vs_csh_hashkey(int af, const union nf_inet_addr *addr,
+		     __be16 port)
+{
+	__be32 addr_fold = addr->ip;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		addr_fold = addr->ip6[0]^addr->ip6[1]^
+			addr->ip6[2]^addr->ip6[3];
+#endif
+	return hash_32(ntohs(port) + ntohl(addr_fold), 32) % IP_VS_CSH_TAB_SIZE;
+}
+
+
+/*
+ *      Get ip_vs_dest associated with supplied parameters.
+ */
+static inline struct ip_vs_dest *
+ip_vs_csh_get(struct ip_vs_service *svc, struct ip_vs_csh_state *s,
+	      const union nf_inet_addr *addr, __be16 port)
+{
+	unsigned int hash = ip_vs_csh_hashkey(svc->af, addr, port);
+	struct ip_vs_dest *dest = rcu_dereference(s->buckets[hash].dest);
+
+	return (!dest || is_unavailable(dest)) ? NULL : dest;
+}
+
+/*
+ *      For provided destination, return the "j"th element of its permutation.
+ */
+static inline u32
+ip_vs_csh_permutation(struct ip_vs_dest *d, int j)
+{
+	u32 offset, skip;
+	__be32 addr_fold = d->addr.ip;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (d->af == AF_INET6)
+		addr_fold = d->addr.ip6[0]^d->addr.ip6[1]^
+			d->addr.ip6[2]^d->addr.ip6[3];
+#endif
+	addr_fold = ntohl(addr_fold) + ntohs(d->port);
+	offset = hash_32(addr_fold, 32) % IP_VS_CSH_TAB_SIZE;
+	skip = (hash_32(addr_fold + 1, 32) % (IP_VS_CSH_TAB_SIZE - 1)) + 1;
+	return (offset + j * skip) % IP_VS_CSH_TAB_SIZE;
+}
+
+
+/*
+ *      Flush all the hash buckets of the specified table.
+ */
+static void ip_vs_csh_flush(struct ip_vs_csh_state *s)
+{
+	int i;
+	struct ip_vs_csh_bucket *b;
+	struct ip_vs_dest *dest;
+
+	b = &s->buckets[0];
+	for (i=0; i<IP_VS_CSH_TAB_SIZE; i++) {
+		dest = rcu_dereference_protected(b->dest, 1);
+		if (dest) {
+			ip_vs_dest_put(dest);
+			RCU_INIT_POINTER(b->dest, NULL);
+		}
+		b++;
+	}
+}
+
+
+/*
+ *      Assign all the hash buckets of the specified table with the service.
+ */
+static int
+ip_vs_csh_reassign(struct ip_vs_csh_state *s, struct ip_vs_service *svc)
+{
+	int n, c, i, j;
+	struct ip_vs_csh_bucket *b;
+	struct list_head *p = &svc->destinations;
+	struct ip_vs_dest *dest, *olddest;
+	int num_dests = svc->num_dests;
+	int d_count, weight;
+	int *next = NULL;
+
+	/* Special case: no real servers */
+	if (list_empty(p)) {
+		ip_vs_csh_flush(s);
+		return 0;
+	}
+
+	/* For each destination, reset the position in the permutation
+	 * list. */
+	next = kzalloc(sizeof(int) * num_dests, GFP_KERNEL);
+	if (next == NULL)
+		return -ENOMEM;
+
+	/* For each bucket, flip the assigned bit: the destination has
+	 * not been set. */
+	for (n=0, b = &s->buckets[0];
+	     n<IP_VS_CSH_TAB_SIZE;
+	     n++, b++) {
+		b->assigned = false;
+	}
+
+	d_count = 0;
+	i = 0;
+	j = 0;
+	n = 0;
+	while (true) {
+		if (p == &svc->destinations)
+			p = p->next;
+		dest = list_entry(p, struct ip_vs_dest, n_list);
+		weight = atomic_read(&dest->weight);
+
+		if (weight > 0) {
+			/* Find the next preferred bucket for the destination. */
+			ip_vs_dest_hold(dest);
+			do {
+				c = ip_vs_csh_permutation(dest, next[i]);
+				b = &s->buckets[c];
+				next[i]++;
+			} while (b->assigned);
+
+			/* Assign the bucket. */
+			b->assigned = 1;
+			olddest = rcu_dereference_protected(b->dest, 1);
+			if (olddest)
+				ip_vs_dest_put(olddest);
+			RCU_INIT_POINTER(b->dest, dest);
+
+			IP_VS_DBG_BUF(6, "CSH: assigned c: %d dest: %s:%d weight: %d\n",
+				      c, IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
+				      atomic_read(&dest->weight));
+			if (++n == IP_VS_CSH_TAB_SIZE) break;
+		}
+
+		if (++j == num_dests && n == 0) {
+			IP_VS_DBG(6, "CSH: all servers have 0 weight\n");
+			ip_vs_csh_flush(s);
+			break;
+		}
+
+		/* Don't move to next dest until filling weight */
+		if (++d_count >= weight) {
+			p = p->next;
+			i = (i + 1) % num_dests;
+			d_count = 0;
+		}
+	}
+
+	kfree(next);
+	return 0;
+}
+
+
+static int ip_vs_csh_init_svc(struct ip_vs_service *svc)
+{
+	struct ip_vs_csh_state *s;
+
+	/* allocate the SH table for this service */
+	s = kzalloc(sizeof(struct ip_vs_csh_state), GFP_KERNEL);
+	if (s == NULL)
+		return -ENOMEM;
+
+	svc->sched_data = s;
+	IP_VS_DBG(6, "CSH: hash table (memory=%zdbytes) allocated for "
+		  "current service\n",
+		  sizeof(struct ip_vs_csh_bucket)*IP_VS_CSH_TAB_SIZE);
+
+	/* assign the hash buckets with current dests */
+	ip_vs_csh_reassign(s, svc);
+
+	return 0;
+}
+
+
+static void ip_vs_csh_done_svc(struct ip_vs_service *svc)
+{
+	struct ip_vs_csh_state *s = svc->sched_data;
+
+	/* got to clean up hash buckets here */
+	ip_vs_csh_flush(s);
+
+	/* release the table itself */
+	kfree_rcu(s, rcu_head);
+	IP_VS_DBG(6, "CSH: hash table (memory=%zdbytes) released\n",
+		  sizeof(struct ip_vs_csh_bucket)*IP_VS_CSH_TAB_SIZE);
+}
+
+
+static int ip_vs_csh_dest_changed(struct ip_vs_service *svc,
+				     struct ip_vs_dest *dest)
+{
+	struct ip_vs_csh_state *s = svc->sched_data;
+
+	/* assign the hash buckets with the updated service */
+	ip_vs_csh_reassign(s, svc);
+
+	return 0;
+}
+
+/*
+ *      Consistent Source Hashing scheduling with Maglev
+ */
+static struct ip_vs_dest *
+ip_vs_csh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		      struct ip_vs_iphdr *iph)
+{
+	struct ip_vs_dest *dest;
+	struct ip_vs_csh_state *s;
+	__be16 port = 0;
+	const union nf_inet_addr *hash_addr;
+
+	hash_addr = ip_vs_iph_inverse(iph) ? &iph->daddr : &iph->saddr;
+	port = ip_vs_get_port(skb, iph);
+
+	s = (struct ip_vs_csh_state *) svc->sched_data;
+	dest = ip_vs_csh_get(svc, s, hash_addr, port);
+
+	if (!dest) {
+		ip_vs_scheduler_err(svc, "no destination available");
+		return NULL;
+	}
+
+	IP_VS_DBG_BUF(6, "CSH: source IP address %s:%d --> server %s:%d\n",
+		      IP_VS_DBG_ADDR(svc->af, hash_addr),
+		      ntohs(port),
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr),
+		      ntohs(dest->port));
+
+	return dest;
+}
+
+
+/*
+ *      IPVS CSH Scheduler structure
+ */
+static struct ip_vs_scheduler ip_vs_csh_scheduler =
+{
+	.name =			"csh",
+	.refcnt =		ATOMIC_INIT(0),
+	.module =		THIS_MODULE,
+	.n_list	 =		LIST_HEAD_INIT(ip_vs_csh_scheduler.n_list),
+	.init_service =		ip_vs_csh_init_svc,
+	.done_service =		ip_vs_csh_done_svc,
+	.add_dest =		ip_vs_csh_dest_changed,
+	.del_dest =		ip_vs_csh_dest_changed,
+	.upd_dest =		ip_vs_csh_dest_changed,
+	.schedule =		ip_vs_csh_schedule,
+};
+
+
+static int __init ip_vs_csh_init(void)
+{
+	return register_ip_vs_scheduler(&ip_vs_csh_scheduler);
+}
+
+
+static void __exit ip_vs_csh_cleanup(void)
+{
+	unregister_ip_vs_scheduler(&ip_vs_csh_scheduler);
+	synchronize_rcu();
+}
+
+
+module_init(ip_vs_csh_init);
+module_exit(ip_vs_csh_cleanup);
+MODULE_LICENSE("GPL");
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 16aaac6eedc9..b67565d12b6a 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -276,36 +276,6 @@ static int ip_vs_sh_dest_changed(struct ip_vs_service *svc,
 }
 
 
-/* Helper function to get port number */
-static inline __be16
-ip_vs_sh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
-{
-	__be16 _ports[2], *ports;
-
-	/* At this point we know that we have a valid packet of some kind.
-	 * Because ICMP packets are only guaranteed to have the first 8
-	 * bytes, let's just grab the ports.  Fortunately they're in the
-	 * same position for all three of the protocols we care about.
-	 */
-	switch (iph->protocol) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_SCTP:
-		ports = skb_header_pointer(skb, iph->len, sizeof(_ports),
-					   &_ports);
-		if (unlikely(!ports))
-			return 0;
-
-		if (likely(!ip_vs_iph_inverse(iph)))
-			return ports[0];
-		else
-			return ports[1];
-	default:
-		return 0;
-	}
-}
-
-
 /*
  *      Source Hashing scheduling
  */
@@ -323,7 +293,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
 	if (svc->flags & IP_VS_SVC_F_SCHED_SH_PORT)
-		port = ip_vs_sh_get_port(skb, iph);
+		port = ip_vs_get_port(skb, iph);
 
 	s = (struct ip_vs_sh_state *) svc->sched_data;
 
-- 
2.16.3

