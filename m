From: Inju Song <inju.song@navercorp.com>
Subject: [PATCH] netfilter: ipvs: Add Maglev consistent hashing scheduler
Date: Sun, 19 Nov 2017 15:35:13 +0900
Message-ID: <20171119063507.GA9306@centos7.nhncorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, =?iso-8859-1?Q?=A0Simon?= Horman <horms@verge.net.au>, =?iso-8859-1?Q?=A0Julian?= Anastasov <ja@ssi.bg>

Implements the Google's Maglev hashing algorithm as a IPVS scheduler.

Basically it provides consistent hashing but=A0offers some special
features about disruption and load balancing.

  1)=A0minimal disruption: when the set of destinations changes,
     a connection will likely be sent to the same destination
     as it was before.

  2)=A0load balancing: each destination will receive an almost
     equal number of connections.

Seel also for detail: [3.4 Consistent Hasing] in
https://static.googleusercontent.com/media/research.google.com/ko//pubs/arc=
hive/44824.pdf

Signed-off-by: Inju Song <inju.song@navercorp.com>
---
 net/netfilter/ipvs/ip_vs_mh.c | 402 ++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 402 insertions(+)
 create mode 100644 net/netfilter/ipvs/ip_vs_mh.c

diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
new file mode 100644
index 0000000..534a9f5
--- /dev/null
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -0,0 +1,402 @@
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
+
+#define IP_VS_SVC_F_SCHED_MH_FALLBACK	IP_VS_SVC_F_SCHED1 /* MH fallback */
+#define IP_VS_SVC_F_SCHED_MH_PORT	IP_VS_SVC_F_SCHED2 /* MH use port */
+
+struct ip_vs_mh_lookup {
+	struct ip_vs_dest __rcu	*dest;	/* real server (cache) */
+};
+
+/* for IPVS MH entry hash table */
+#define IP_VS_MH_LOOKUP_SIZE	65537 /* Must be prime number */
+
+struct ip_vs_mh_state {
+	struct rcu_head		rcu_head;
+	struct ip_vs_mh_lookup  lookup[IP_VS_MH_LOOKUP_SIZE];
+	hsiphash_key_t		hash1, hash2;
+};
+
+static inline void
+ip_vs_mh_generate_hash_secret(hsiphash_key_t *hash1, hsiphash_key_t *hash2)
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
+static inline unsigned int **
+ip_vs_mh_permutate(struct ip_vs_mh_state *s, struct ip_vs_service *svc)
+{
+	int i, j;
+	unsigned int **permutation;
+	struct list_head *p;
+	struct ip_vs_dest *dest;
+	unsigned int offset, skip;
+	int dcnt;
+
+	dcnt =3D svc->num_dests;
+	permutation =3D kcalloc(dcnt, sizeof(unsigned int *), GFP_KERNEL);
+	permutation[0] =3D kcalloc(dcnt * IP_VS_MH_LOOKUP_SIZE,
+				 sizeof(unsigned int), GFP_KERNEL);
+	for (i =3D 1; i < dcnt; i++)
+		permutation[i] =3D permutation[i - 1] + IP_VS_MH_LOOKUP_SIZE;
+
+	p =3D &svc->destinations;
+	i =3D 0;
+	while ((p =3D p->next) !=3D &svc->destinations) {
+		dest =3D list_entry(p, struct ip_vs_dest, n_list);
+		offset =3D ip_vs_mh_hashkey(svc->af, &dest->addr,	dest->port,
+					  &s->hash1, 0) % IP_VS_MH_LOOKUP_SIZE;
+		skip =3D ip_vs_mh_hashkey(svc->af, &dest->addr,
+					dest->port, &s->hash2, 0) %
+					(IP_VS_MH_LOOKUP_SIZE - 1) + 1;
+
+		for (j =3D 0; j < IP_VS_MH_LOOKUP_SIZE; j++) {
+			permutation[i][j] =3D (offset + (j * skip)) %
+						IP_VS_MH_LOOKUP_SIZE;
+		}
+		i++;
+	}
+
+	return permutation;
+}
+
+static inline int
+ip_vs_mh_populate(struct ip_vs_mh_state *s, struct ip_vs_service *svc,
+		  unsigned int **permutation)
+{
+	int i;
+	unsigned int *next;
+	struct ip_vs_mh_lookup *entry, *l;
+	struct list_head *p;
+	struct ip_vs_dest *dest;
+	int dcnt;
+	unsigned int n, c;
+
+	dcnt =3D svc->num_dests;
+	next =3D kcalloc(dcnt, sizeof(unsigned int), GFP_KERNEL);
+	entry =3D kcalloc(IP_VS_MH_LOOKUP_SIZE, sizeof(*entry),
+			GFP_KERNEL);
+	for (i =3D 0; i < IP_VS_MH_LOOKUP_SIZE; i++)
+		RCU_INIT_POINTER(entry[i].dest, NULL);
+
+	n =3D 0;
+	while (n < IP_VS_MH_LOOKUP_SIZE) {
+		p =3D &svc->destinations;
+		for (i =3D 0; i < dcnt; i++) {
+			p =3D p->next;
+			c =3D permutation[i][next[i]];
+
+			while (entry[c].dest) {
+				next[i] =3D next[i] + 1;
+				c =3D permutation[i][next[i]];
+			}
+
+			dest =3D list_entry(p, struct ip_vs_dest, n_list);
+			RCU_INIT_POINTER(entry[c].dest, dest);
+
+			next[i] =3D next[i] + 1;
+			n++;
+			if (n =3D=3D IP_VS_MH_LOOKUP_SIZE)
+				break;
+		}
+	}
+
+	l =3D &s->lookup[0];
+	for (i =3D 0; i < IP_VS_MH_LOOKUP_SIZE; i++) {
+		dest =3D rcu_dereference_protected(entry[i].dest, 1);
+		ip_vs_dest_hold(dest);
+		RCU_INIT_POINTER(l->dest, dest);
+
+		IP_VS_DBG_BUF(6, "assigned i: %d dest: %s weight: %d\n",
+			      i, IP_VS_DBG_ADDR(dest->af, &dest->addr),
+			      atomic_read(&dest->weight));
+
+		RCU_INIT_POINTER(entry[i].dest, NULL);
+		l++;
+	}
+	kfree(next);
+	kfree(entry);
+
+	return 0;
+}
+
+/* Get ip_vs_dest associated with supplied parameters. */
+static inline struct ip_vs_dest *
+ip_vs_mh_get(struct ip_vs_service *svc, struct ip_vs_mh_state *s,
+	     const union nf_inet_addr *addr, __be16 port)
+{
+	unsigned int hash =3D ip_vs_mh_hashkey(svc->af, addr, port, &s->hash1, 0)
+					     % IP_VS_MH_LOOKUP_SIZE;
+	struct ip_vs_dest *dest =3D rcu_dereference(s->lookup[hash].dest);
+
+	return (!dest || is_unavailable(dest)) ? NULL : dest;
+}
+
+/* As ip_vs_mh_get, but with fallback if selected server is unavailable
+ */
+static inline struct ip_vs_dest *
+ip_vs_mh_get_fallback(struct ip_vs_service *svc, struct ip_vs_mh_state *s,
+		      const union nf_inet_addr *addr, __be16 port)
+{
+	unsigned int offset, roffset;
+	unsigned int hash, ihash;
+	struct ip_vs_dest *dest;
+
+	/* first try the dest it's supposed to go to */
+	ihash =3D ip_vs_mh_hashkey(svc->af, addr, port,
+				 &s->hash1, 0) % IP_VS_MH_LOOKUP_SIZE;
+	dest =3D rcu_dereference(s->lookup[ihash].dest);
+	if (!dest)
+		return NULL;
+	if (!is_unavailable(dest))
+		return dest;
+
+	IP_VS_DBG_BUF(6, "MH: selected unavailable server %s:%d, reselecting",
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port));
+
+	/* if the original dest is unavailable, loop around the table
+	 * starting from ihash to find a new dest
+	 */
+	for (offset =3D 0; offset < IP_VS_MH_LOOKUP_SIZE; offset++) {
+		roffset =3D (offset + ihash) % IP_VS_MH_LOOKUP_SIZE;
+		hash =3D ip_vs_mh_hashkey(svc->af, addr, port, &s->hash1,
+					roffset) % IP_VS_MH_LOOKUP_SIZE;
+		dest =3D rcu_dereference(s->lookup[hash].dest);
+		if (!dest)
+			break;
+		if (!is_unavailable(dest))
+			return dest;
+		IP_VS_DBG_BUF(6,
+			      "MH: selected unavailable server %s:%d (offset %d), reselecting",
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
+			      ntohs(dest->port), roffset);
+	}
+
+	return NULL;
+}
+
+/* Flush all the hash buckets of the specified table. */
+static void ip_vs_mh_flush(struct ip_vs_mh_state *s)
+{
+	int i;
+	struct ip_vs_mh_lookup *l;
+	struct ip_vs_dest *dest;
+
+	l =3D &s->lookup[0];
+	for (i =3D 0; i < IP_VS_MH_LOOKUP_SIZE; i++) {
+		dest =3D rcu_dereference_protected(l->dest, 1);
+		if (dest) {
+			ip_vs_dest_put(dest);
+			RCU_INIT_POINTER(l->dest, NULL);
+		}
+		l++;
+	}
+}
+
+/* Assign all the hash buckets of the specified table with the service.
+ */
+static int
+ip_vs_mh_reassign(struct ip_vs_mh_state *s, struct ip_vs_service *svc)
+{
+	int dcnt;
+	unsigned int **permutation;
+
+	/* flush all the hash entry before assigning mh entry */
+	ip_vs_mh_flush(s);
+
+	/* if destination number is zero, skip mh assign */
+	dcnt =3D svc->num_dests;
+	if (dcnt <=3D 0)
+		return 0;
+
+	permutation =3D ip_vs_mh_permutate(s, svc);
+	ip_vs_mh_populate(s, svc, permutation);
+
+	kfree(permutation[0]);
+	kfree(permutation);
+
+	return 0;
+}
+
+static int ip_vs_mh_init_svc(struct ip_vs_service *svc)
+{
+	struct ip_vs_mh_state *s;
+
+	/* allocate the MH table for this service */
+	s =3D kzalloc(sizeof(*s), GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+
+	svc->sched_data =3D s;
+
+	IP_VS_DBG(6,
+		  "MH lookup table (memory=3D%zdbytes) allocated for current service\n",
+		  sizeof(struct ip_vs_mh_lookup) * IP_VS_MH_LOOKUP_SIZE);
+
+	ip_vs_mh_generate_hash_secret(&s->hash1, &s->hash2);
+
+	/* permutate & populate with current dests */
+	ip_vs_mh_reassign(s, svc);
+
+	return 0;
+}
+
+static void ip_vs_mh_done_svc(struct ip_vs_service *svc)
+{
+	struct ip_vs_mh_state *s =3D svc->sched_data;
+
+	/* got to clean up hash buckets here */
+	ip_vs_mh_flush(s);
+
+	/* release the table itself */
+	kfree_rcu(s, rcu_head);
+	IP_VS_DBG(6, "MH lookup table (memory=3D%zdbytes) released\n",
+		  sizeof(struct ip_vs_mh_lookup) * IP_VS_MH_LOOKUP_SIZE);
+}
+
+static int ip_vs_mh_dest_changed(struct ip_vs_service *svc,
+				 struct ip_vs_dest *dest)
+{
+	struct ip_vs_mh_state *s =3D svc->sched_data;
+
+	/* assign the hash buckets with the updated service */
+	ip_vs_mh_reassign(s, svc);
+
+	return 0;
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
+	IP_VS_DBG_BUF(6, "MH: source IP address %s:%d --> server %s:%d\n",
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
+	synchronize_rcu();
+}
+
+module_init(ip_vs_mh_init);
+module_exit(ip_vs_mh_cleanup);
+MODULE_DESCRIPTION("Maglev hashing ipvs scheduler");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Inju Song <inju.song@navercorp.com>");
--=20
1.8.3.1


