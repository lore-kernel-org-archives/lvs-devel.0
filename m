From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/5] netfilter: ipvs: Add Maglev hashing scheduler
Date: Thu, 19 Apr 2018 10:56:12 +0200
Message-ID: <20180419085614.7437-4-horms@verge.net.au>
References: <20180419085614.7437-1-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1524128186; bh=g9E8h9054434RB37/bYkwHZM563xwM1RU6cl4Ha1OEM=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=ShCoH9nEIqPPGwYkDfqkgjIl8fec7TzEub92fbqStJO2CA9HTeytuGs0fcdmAN0gA
         GbAdkSekoVRS63EP97OBLzNP10tZND+Bx8+ippEIeZVTlSTtuZFbu6EIaMfetDb2tb
         mvth/Uc1E8h48AoNuA64ps1QB38DLRhhB5OE6q1Q=
In-Reply-To: <20180419085614.7437-1-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Inju Song <inju.song@navercorp.com>, Simon Horman <horms@verge.net.au>

From: Inju Song <inju.song@navercorp.com>

Implements the Google's Maglev hashing algorithm as a IPVS scheduler.

Basically it provides consistent hashing but=C2=A0offers some special
features about disruption and load balancing.

 1)=C2=A0minimal disruption: when the set of destinations changes,
    a connection will likely be sent to the same destination
    as it was before.

 2)=C2=A0load balancing: each destination will receive an almost
    equal number of connections.

Seel also for detail: [3.4 Consistent Hasing] in
https://www.usenix.org/system/files/conference/nsdi16/nsdi16-paper-eisenbud=
.pdf

Signed-off-by: Inju Song <inju.song@navercorp.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_mh.c | 540 ++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 540 insertions(+)
 create mode 100644 net/netfilter/ipvs/ip_vs_mh.c

diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
new file mode 100644
index 000000000000..0f795b186eb3
--- /dev/null
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -0,0 +1,540 @@
+// SPDX-License-Identifier: GPL-2.0
+/* IPVS:	Maglev Hashing scheduling module
+ *
+ * Authors:	Inju Song <inju.song@navercorp.com>
+ *
+ */
+
+/* The mh algorithm is to assign=A0a preference list of all the lookup
+ * table positions to each destination and populate the table with
+ * the most-preferred position of destinations. Then it is to select
+ * destination with the hash key of source IP address=A0through looking
+ * up a the lookup table.
+ *
+ * The algorithm is detailed in:
+ * [3.4 Consistent Hasing]
+https://www.usenix.org/system/files/conference/nsdi16/nsdi16-paper-eisenbu=
d.pdf
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
+#include <linux/siphash.h>
+#include <linux/bitops.h>
+#include <linux/gcd.h>
+
+#define IP_VS_SVC_F_SCHED_MH_FALLBACK	IP_VS_SVC_F_SCHED1 /* MH fallback */
+#define IP_VS_SVC_F_SCHED_MH_PORT	IP_VS_SVC_F_SCHED2 /* MH use port */
+
+struct ip_vs_mh_lookup {
+	struct ip_vs_dest __rcu	*dest;	/* real server (cache) */
+};
+
+struct ip_vs_mh_dest_setup {
+	unsigned int	offset; /* starting offset */
+	unsigned int	skip;	/* skip */
+	unsigned int	perm;	/* next_offset */
+	int		turns;	/* weight / gcd() and rshift */
+};
+
+/* Available prime numbers for MH table */
+static int primes[] =3D {251, 509, 1021, 2039, 4093,
+		       8191, 16381, 32749, 65521, 131071};
+
+/* For IPVS MH entry hash table */
+#ifndef CONFIG_IP_VS_MH_TAB_INDEX
+#define CONFIG_IP_VS_MH_TAB_INDEX	12
+#endif
+#define IP_VS_MH_TAB_BITS		(CONFIG_IP_VS_MH_TAB_INDEX / 2)
+#define IP_VS_MH_TAB_INDEX		(CONFIG_IP_VS_MH_TAB_INDEX - 8)
+#define IP_VS_MH_TAB_SIZE               primes[IP_VS_MH_TAB_INDEX]
+
+struct ip_vs_mh_state {
+	struct rcu_head			rcu_head;
+	struct ip_vs_mh_lookup		*lookup;
+	struct ip_vs_mh_dest_setup	*dest_setup;
+	hsiphash_key_t			hash1, hash2;
+	int				gcd;
+	int				rshift;
+};
+
+static inline void generate_hash_secret(hsiphash_key_t *hash1,
+					hsiphash_key_t *hash2)
+{
+	hash1->key[0] =3D 2654435761UL;
+	hash1->key[1] =3D 2654435761UL;
+
+	hash2->key[0] =3D 2654446892UL;
+	hash2->key[1] =3D 2654446892UL;
+}
+
+/* Helper function to determine if server is unavailable */
+static inline bool is_unavailable(struct ip_vs_dest *dest)
+{
+	return atomic_read(&dest->weight) <=3D 0 ||
+	       dest->flags & IP_VS_DEST_F_OVERLOAD;
+}
+
+/* Returns hash value for IPVS MH entry */
+static inline unsigned int
+ip_vs_mh_hashkey(int af, const union nf_inet_addr *addr,
+		 __be16 port, hsiphash_key_t *key, unsigned int offset)
+{
+	unsigned int v;
+	__be32 addr_fold =3D addr->ip;
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (af =3D=3D AF_INET6)
+		addr_fold =3D addr->ip6[0] ^ addr->ip6[1] ^
+			    addr->ip6[2] ^ addr->ip6[3];
+#endif
+	v =3D (offset + ntohs(port) + ntohl(addr_fold));
+	return hsiphash(&v, sizeof(v), key);
+}
+
+/* Reset all the hash buckets of the specified table. */
+static void ip_vs_mh_reset(struct ip_vs_mh_state *s)
+{
+	int i;
+	struct ip_vs_mh_lookup *l;
+	struct ip_vs_dest *dest;
+
+	l =3D &s->lookup[0];
+	for (i =3D 0; i < IP_VS_MH_TAB_SIZE; i++) {
+		dest =3D rcu_dereference_protected(l->dest, 1);
+		if (dest) {
+			ip_vs_dest_put(dest);
+			RCU_INIT_POINTER(l->dest, NULL);
+		}
+		l++;
+	}
+}
+
+static int ip_vs_mh_permutate(struct ip_vs_mh_state *s,
+			      struct ip_vs_service *svc)
+{
+	struct list_head *p;
+	struct ip_vs_mh_dest_setup *ds;
+	struct ip_vs_dest *dest;
+	int lw;
+
+	/* If gcd is smaller then 1, number of dests or
+	 * all last_weight of dests are zero. So, skip
+	 * permutation for the dests.
+	 */
+	if (s->gcd < 1)
+		return 0;
+
+	/* Set dest_setup for the dests permutation */
+	p =3D &svc->destinations;
+	ds =3D &s->dest_setup[0];
+	while ((p =3D p->next) !=3D &svc->destinations) {
+		dest =3D list_entry(p, struct ip_vs_dest, n_list);
+
+		ds->offset =3D ip_vs_mh_hashkey(svc->af, &dest->addr,
+					      dest->port, &s->hash1, 0) %
+					      IP_VS_MH_TAB_SIZE;
+		ds->skip =3D ip_vs_mh_hashkey(svc->af, &dest->addr,
+					    dest->port, &s->hash2, 0) %
+					    (IP_VS_MH_TAB_SIZE - 1) + 1;
+		ds->perm =3D ds->offset;
+
+		lw =3D atomic_read(&dest->last_weight);
+		ds->turns =3D ((lw / s->gcd) >> s->rshift) ? : (lw !=3D 0);
+		ds++;
+	}
+
+	return 0;
+}
+
+static int ip_vs_mh_populate(struct ip_vs_mh_state *s,
+			     struct ip_vs_service *svc)
+{
+	int n, c, dt_count;
+	unsigned long *table;
+	struct list_head *p;
+	struct ip_vs_mh_dest_setup *ds;
+	struct ip_vs_dest *dest, *new_dest;
+
+	/* If gcd is smaller then 1, number of dests or
+	 * all last_weight of dests are zero. So, skip
+	 * the population for the dests and reset lookup table.
+	 */
+	if (s->gcd < 1) {
+		ip_vs_mh_reset(s);
+		return 0;
+	}
+
+	table =3D  kcalloc(BITS_TO_LONGS(IP_VS_MH_TAB_SIZE),
+			 sizeof(unsigned long), GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+
+	p =3D &svc->destinations;
+	n =3D 0;
+	dt_count =3D 0;
+	while (n < IP_VS_MH_TAB_SIZE) {
+		if (p =3D=3D &svc->destinations)
+			p =3D p->next;
+
+		ds =3D &s->dest_setup[0];
+		while (p !=3D &svc->destinations) {
+			/* Ignore added server with zero weight */
+			if (ds->turns < 1) {
+				p =3D p->next;
+				ds++;
+				continue;
+			}
+
+			c =3D ds->perm;
+			while (test_bit(c, table)) {
+				/* Add skip, mod IP_VS_MH_TAB_SIZE */
+				ds->perm +=3D ds->skip;
+				if (ds->perm >=3D IP_VS_MH_TAB_SIZE)
+					ds->perm -=3D IP_VS_MH_TAB_SIZE;
+				c =3D ds->perm;
+			}
+
+			__set_bit(c, table);
+
+			dest =3D rcu_dereference_protected(s->lookup[c].dest, 1);
+			new_dest =3D list_entry(p, struct ip_vs_dest, n_list);
+			if (dest !=3D new_dest) {
+				if (dest)
+					ip_vs_dest_put(dest);
+				ip_vs_dest_hold(new_dest);
+				RCU_INIT_POINTER(s->lookup[c].dest, new_dest);
+			}
+
+			if (++n =3D=3D IP_VS_MH_TAB_SIZE)
+				goto out;
+
+			if (++dt_count >=3D ds->turns) {
+				dt_count =3D 0;
+				p =3D p->next;
+				ds++;
+			}
+		}
+	}
+
+out:
+	kfree(table);
+	return 0;
+}
+
+/* Get ip_vs_dest associated with supplied parameters. */
+static inline struct ip_vs_dest *
+ip_vs_mh_get(struct ip_vs_service *svc, struct ip_vs_mh_state *s,
+	     const union nf_inet_addr *addr, __be16 port)
+{
+	unsigned int hash =3D ip_vs_mh_hashkey(svc->af, addr, port, &s->hash1, 0)
+					     % IP_VS_MH_TAB_SIZE;
+	struct ip_vs_dest *dest =3D rcu_dereference(s->lookup[hash].dest);
+
+	return (!dest || is_unavailable(dest)) ? NULL : dest;
+}
+
+/* As ip_vs_mh_get, but with fallback if selected server is unavailable */
+static inline struct ip_vs_dest *
+ip_vs_mh_get_fallback(struct ip_vs_service *svc, struct ip_vs_mh_state *s,
+		      const union nf_inet_addr *addr, __be16 port)
+{
+	unsigned int offset, roffset;
+	unsigned int hash, ihash;
+	struct ip_vs_dest *dest;
+
+	/* First try the dest it's supposed to go to */
+	ihash =3D ip_vs_mh_hashkey(svc->af, addr, port,
+				 &s->hash1, 0) % IP_VS_MH_TAB_SIZE;
+	dest =3D rcu_dereference(s->lookup[ihash].dest);
+	if (!dest)
+		return NULL;
+	if (!is_unavailable(dest))
+		return dest;
+
+	IP_VS_DBG_BUF(6, "MH: selected unavailable server %s:%u, reselecting",
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port));
+
+	/* If the original dest is unavailable, loop around the table
+	 * starting from ihash to find a new dest
+	 */
+	for (offset =3D 0; offset < IP_VS_MH_TAB_SIZE; offset++) {
+		roffset =3D (offset + ihash) % IP_VS_MH_TAB_SIZE;
+		hash =3D ip_vs_mh_hashkey(svc->af, addr, port, &s->hash1,
+					roffset) % IP_VS_MH_TAB_SIZE;
+		dest =3D rcu_dereference(s->lookup[hash].dest);
+		if (!dest)
+			break;
+		if (!is_unavailable(dest))
+			return dest;
+		IP_VS_DBG_BUF(6,
+			      "MH: selected unavailable server %s:%u (offset %u), reselecting",
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
+			      ntohs(dest->port), roffset);
+	}
+
+	return NULL;
+}
+
+/* Assign all the hash buckets of the specified table with the service. */
+static int ip_vs_mh_reassign(struct ip_vs_mh_state *s,
+			     struct ip_vs_service *svc)
+{
+	int ret;
+
+	if (svc->num_dests > IP_VS_MH_TAB_SIZE)
+		return -EINVAL;
+
+	if (svc->num_dests >=3D 1) {
+		s->dest_setup =3D kcalloc(svc->num_dests,
+					sizeof(struct ip_vs_mh_dest_setup),
+					GFP_KERNEL);
+		if (!s->dest_setup)
+			return -ENOMEM;
+	}
+
+	ip_vs_mh_permutate(s, svc);
+
+	ret =3D ip_vs_mh_populate(s, svc);
+	if (ret < 0)
+		goto out;
+
+	IP_VS_DBG_BUF(6, "MH: reassign lookup table of %s:%u\n",
+		      IP_VS_DBG_ADDR(svc->af, &svc->addr),
+		      ntohs(svc->port));
+
+out:
+	if (svc->num_dests >=3D 1) {
+		kfree(s->dest_setup);
+		s->dest_setup =3D NULL;
+	}
+	return ret;
+}
+
+static int ip_vs_mh_gcd_weight(struct ip_vs_service *svc)
+{
+	struct ip_vs_dest *dest;
+	int weight;
+	int g =3D 0;
+
+	list_for_each_entry(dest, &svc->destinations, n_list) {
+		weight =3D atomic_read(&dest->last_weight);
+		if (weight > 0) {
+			if (g > 0)
+				g =3D gcd(weight, g);
+			else
+				g =3D weight;
+		}
+	}
+	return g;
+}
+
+/* To avoid assigning huge weight for the MH table,
+ * calculate shift value with gcd.
+ */
+static int ip_vs_mh_shift_weight(struct ip_vs_service *svc, int gcd)
+{
+	struct ip_vs_dest *dest;
+	int new_weight, weight =3D 0;
+	int mw, shift;
+
+	/* If gcd is smaller then 1, number of dests or
+	 * all last_weight of dests are zero. So, return
+	 * shift value as zero.
+	 */
+	if (gcd < 1)
+		return 0;
+
+	list_for_each_entry(dest, &svc->destinations, n_list) {
+		new_weight =3D atomic_read(&dest->last_weight);
+		if (new_weight > weight)
+			weight =3D new_weight;
+	}
+
+	/* Because gcd is greater than zero,
+	 * the maximum weight and gcd are always greater than zero
+	 */
+	mw =3D weight / gcd;
+
+	/* shift =3D occupied bits of weight/gcd - MH highest bits */
+	shift =3D fls(mw) - IP_VS_MH_TAB_BITS;
+	return (shift >=3D 0) ? shift : 0;
+}
+
+static void ip_vs_mh_state_free(struct rcu_head *head)
+{
+	struct ip_vs_mh_state *s;
+
+	s =3D container_of(head, struct ip_vs_mh_state, rcu_head);
+	kfree(s->lookup);
+	kfree(s);
+}
+
+static int ip_vs_mh_init_svc(struct ip_vs_service *svc)
+{
+	int ret;
+	struct ip_vs_mh_state *s;
+
+	/* Allocate the MH table for this service */
+	s =3D kzalloc(sizeof(*s), GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+
+	s->lookup =3D kcalloc(IP_VS_MH_TAB_SIZE, sizeof(struct ip_vs_mh_lookup),
+			    GFP_KERNEL);
+	if (!s->lookup) {
+		kfree(s);
+		return -ENOMEM;
+	}
+
+	generate_hash_secret(&s->hash1, &s->hash2);
+	s->gcd =3D ip_vs_mh_gcd_weight(svc);
+	s->rshift =3D ip_vs_mh_shift_weight(svc, s->gcd);
+
+	IP_VS_DBG(6,
+		  "MH lookup table (memory=3D%zdbytes) allocated for current service\n",
+		  sizeof(struct ip_vs_mh_lookup) * IP_VS_MH_TAB_SIZE);
+
+	/* Assign the lookup table with current dests */
+	ret =3D ip_vs_mh_reassign(s, svc);
+	if (ret < 0) {
+		ip_vs_mh_reset(s);
+		ip_vs_mh_state_free(&s->rcu_head);
+		return ret;
+	}
+
+	/* No more failures, attach state */
+	svc->sched_data =3D s;
+	return 0;
+}
+
+static void ip_vs_mh_done_svc(struct ip_vs_service *svc)
+{
+	struct ip_vs_mh_state *s =3D svc->sched_data;
+
+	/* Got to clean up lookup entry here */
+	ip_vs_mh_reset(s);
+
+	call_rcu(&s->rcu_head, ip_vs_mh_state_free);
+	IP_VS_DBG(6, "MH lookup table (memory=3D%zdbytes) released\n",
+		  sizeof(struct ip_vs_mh_lookup) * IP_VS_MH_TAB_SIZE);
+}
+
+static int ip_vs_mh_dest_changed(struct ip_vs_service *svc,
+				 struct ip_vs_dest *dest)
+{
+	struct ip_vs_mh_state *s =3D svc->sched_data;
+
+	s->gcd =3D ip_vs_mh_gcd_weight(svc);
+	s->rshift =3D ip_vs_mh_shift_weight(svc, s->gcd);
+
+	/* Assign the lookup table with the updated service */
+	return ip_vs_mh_reassign(s, svc);
+}
+
+/* Helper function to get port number */
+static inline __be16
+ip_vs_mh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
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
+		ports =3D skb_header_pointer(skb, iph->len, sizeof(_ports),
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
+/* Maglev Hashing scheduling */
+static struct ip_vs_dest *
+ip_vs_mh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
+		  struct ip_vs_iphdr *iph)
+{
+	struct ip_vs_dest *dest;
+	struct ip_vs_mh_state *s;
+	__be16 port =3D 0;
+	const union nf_inet_addr *hash_addr;
+
+	hash_addr =3D ip_vs_iph_inverse(iph) ? &iph->daddr : &iph->saddr;
+
+	IP_VS_DBG(6, "%s : Scheduling...\n", __func__);
+
+	if (svc->flags & IP_VS_SVC_F_SCHED_MH_PORT)
+		port =3D ip_vs_mh_get_port(skb, iph);
+
+	s =3D (struct ip_vs_mh_state *)svc->sched_data;
+
+	if (svc->flags & IP_VS_SVC_F_SCHED_MH_FALLBACK)
+		dest =3D ip_vs_mh_get_fallback(svc, s, hash_addr, port);
+	else
+		dest =3D ip_vs_mh_get(svc, s, hash_addr, port);
+
+	if (!dest) {
+		ip_vs_scheduler_err(svc, "no destination available");
+		return NULL;
+	}
+
+	IP_VS_DBG_BUF(6, "MH: source IP address %s:%u --> server %s:%u\n",
+		      IP_VS_DBG_ADDR(svc->af, hash_addr),
+		      ntohs(port),
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr),
+		      ntohs(dest->port));
+
+	return dest;
+}
+
+/* IPVS MH Scheduler structure */
+static struct ip_vs_scheduler ip_vs_mh_scheduler =3D {
+	.name =3D			"mh",
+	.refcnt =3D		ATOMIC_INIT(0),
+	.module =3D		THIS_MODULE,
+	.n_list	 =3D		LIST_HEAD_INIT(ip_vs_mh_scheduler.n_list),
+	.init_service =3D		ip_vs_mh_init_svc,
+	.done_service =3D		ip_vs_mh_done_svc,
+	.add_dest =3D		ip_vs_mh_dest_changed,
+	.del_dest =3D		ip_vs_mh_dest_changed,
+	.upd_dest =3D		ip_vs_mh_dest_changed,
+	.schedule =3D		ip_vs_mh_schedule,
+};
+
+static int __init ip_vs_mh_init(void)
+{
+	return register_ip_vs_scheduler(&ip_vs_mh_scheduler);
+}
+
+static void __exit ip_vs_mh_cleanup(void)
+{
+	unregister_ip_vs_scheduler(&ip_vs_mh_scheduler);
+	rcu_barrier();
+}
+
+module_init(ip_vs_mh_init);
+module_exit(ip_vs_mh_cleanup);
+MODULE_DESCRIPTION("Maglev hashing ipvs scheduler");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Inju Song <inju.song@navercorp.com>");
--=20
2.11.0

