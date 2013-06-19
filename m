From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: [PATCH] ipvs: SH fallback and L4 hashing
Date: Wed, 19 Jun 2013 10:54:25 +0100
Message-ID: <20130619095425.GA20145@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

By default the SH scheduler rejects connections that are hashed onto a
realserver of weight 0.  This patch adds a flag to make SH choose a
different realserver in this case, instead of rejecting the connection.

The patch also adds a flag to make SH include the source port (TCP, UDP,
SCTP) in the hash as well as the source address.  This basically allows
for deterministic round-robin load balancing (i.e., where any director
in a cluster of directors with identical config will send the same
packet the same way).

The flags are service flags (IP_VS_SVC_F_SCHED*) so that these options
can be set per service.  They are set using a new option to ipvsadm.

Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>
---
The patch is against the ipvs-next tree.

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index a245377..2945822 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -20,6 +20,12 @@
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
 #define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
+#define IP_VS_SVC_F_SCHED1	0x0008		/* scheduler flag 1 */
+#define IP_VS_SVC_F_SCHED2	0x0010		/* scheduler flag 2 */
+#define IP_VS_SVC_F_SCHED3	0x0020		/* scheduler flag 3 */
+
+#define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
+#define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
 
 /*
  *      Destination Server Flags
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index e0130f8..b7e2c5a 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -48,6 +48,10 @@
 
 #include <net/ip_vs.h>
 
+#include <net/tcp.h>
+#include <linux/udp.h>
+#include <linux/sctp.h>
+
 
 /*
  *      IPVS SH bucket
@@ -71,10 +75,19 @@ struct ip_vs_sh_state {
 	struct rcu_head			rcu_head;
 };
 
+/* Helper function to determine if server is unavailable */
+static inline bool is_unavailable(struct ip_vs_dest *dest)
+{
+	return atomic_read(&dest->weight) <= 0 ||
+	       dest->flags & IP_VS_DEST_F_OVERLOAD;
+}
+
 /*
  *	Returns hash value for IPVS SH entry
  */
-static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
+static inline unsigned int
+ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr,
+		 __be16 port, unsigned int offset)
 {
 	__be32 addr_fold = addr->ip;
 
@@ -83,7 +96,8 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
+	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
+		IP_VS_SH_TAB_MASK;
 }
 
 
@@ -91,12 +105,42 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
  *      Get ip_vs_dest associated with supplied parameters.
  */
 static inline struct ip_vs_dest *
-ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr)
+ip_vs_sh_get(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
+	     const union nf_inet_addr *addr, __be16 port)
 {
-	return rcu_dereference(s->buckets[ip_vs_sh_hashkey(af, addr)].dest);
+	unsigned int hash = ip_vs_sh_hashkey(svc->af, addr, port, 0);
+	struct ip_vs_dest *dest = rcu_dereference(s->buckets[hash].dest);
+
+	return (!dest || is_unavailable(dest)) ? NULL : dest;
 }
 
 
+/* As ip_vs_sh_get, but with fallback if selected server is unavailable */
+static inline struct ip_vs_dest *
+ip_vs_sh_get_fallback(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
+		      const union nf_inet_addr *addr, __be16 port)
+{
+	unsigned int offset;
+	unsigned int hash;
+	struct ip_vs_dest *dest;
+
+	for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
+		hash = ip_vs_sh_hashkey(svc->af, addr, port, offset);
+		dest = rcu_dereference(s->buckets[hash].dest);
+		if (!dest)
+			break;
+		if (is_unavailable(dest))
+			IP_VS_DBG_BUF(6, "SH: selected unavailable server "
+				      "%s:%d (offset %d)",
+				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+				      ntohs(dest->port), offset);
+		else
+			return dest;
+	}
+
+	return NULL;
+}
+
 /*
  *      Assign all the hash buckets of the specified table with the service.
  */
@@ -213,13 +257,33 @@ static int ip_vs_sh_dest_changed(struct ip_vs_service *svc,
 }
 
 
-/*
- *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
- *      consider that the server is overloaded here.
- */
-static inline int is_overloaded(struct ip_vs_dest *dest)
+/* Helper function to get port number */
+static inline __be16
+ip_vs_sh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
 {
-	return dest->flags & IP_VS_DEST_F_OVERLOAD;
+	__be16 port;
+	struct tcphdr _tcph, *th;
+	struct udphdr _udph, *uh;
+	sctp_sctphdr_t _sctph, *sh;
+
+	switch (iph->protocol) {
+	case IPPROTO_TCP:
+		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
+		port = th->source;
+		break;
+	case IPPROTO_UDP:
+		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
+		port = uh->source;
+		break;
+	case IPPROTO_SCTP:
+		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
+		port = sh->source;
+		break;
+	default:
+		port = 0;
+	}
+
+	return port;
 }
 
 
@@ -232,15 +296,21 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_state *s;
+	__be16 port = 0;
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
+	if (svc->flags & IP_VS_SVC_F_SCHED_SH_PORT)
+		port = ip_vs_sh_get_port(skb, iph);
+
 	s = (struct ip_vs_sh_state *) svc->sched_data;
-	dest = ip_vs_sh_get(svc->af, s, &iph->saddr);
-	if (!dest
-	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
-	    || atomic_read(&dest->weight) <= 0
-	    || is_overloaded(dest)) {
+
+	if (svc->flags & IP_VS_SVC_F_SCHED_SH_FALLBACK)
+		dest = ip_vs_sh_get_fallback(svc, s, &iph->saddr, port);
+	else
+		dest = ip_vs_sh_get(svc, s, &iph->saddr, port);
+
+	if (!dest) {
 		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
