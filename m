From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Thu, 13 Jun 2013 09:38:37 +0100
Message-ID: <20130613083837.GA31156@eldamar.org.uk>
References: <20130524120935.GL264@eldamar.org.uk>
 <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
 <20130524151408.GM264@eldamar.org.uk>
 <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
 <20130607081252.GC11902@eldamar.org.uk>
 <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk>
 <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg>
 <20130612141018.GC29327@eldamar.org.uk>
 <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> 	Yes, not sure what others think, may be changes for
> ipvsadm will be needed:
> 
> git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

Do you have any preferences for the command-line syntax to set the
flags?  --sched-flag-1 --sched-flag-2, --sched-flag 1 --sched-flag 2,
--sched-flags 12, something else?  Options 2 and 3 mean we can have
corresponding short options; I think option 3 makes the most sense with
-E (you set all the flags, instead of clearing flags by not specifying
the option, which is not obvious, I think), but we need a nice syntax
for the option argument.  What do you think?

The latest IPVS patch looks like this:

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index a245377..81af9b2 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -20,6 +20,9 @@
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
 #define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
+#define IP_VS_SVC_F_SCHED1	0x0008		/* scheduler flag 1 */
+#define IP_VS_SVC_F_SCHED2	0x0010		/* scheduler flag 2 */
+#define IP_VS_SVC_F_SCHED3	0x0020		/* scheduler flag 3 */
 
 /*
  *      Destination Server Flags
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 0df269d..847d1c7 100644
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
@@ -74,7 +78,9 @@ struct ip_vs_sh_state {
 /*
  *	Returns hash value for IPVS SH entry
  */
-static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
+static inline unsigned int ip_vs_sh_hashkey(int af,
+	const union nf_inet_addr *addr, __be16 port,
+	unsigned int offset)
 {
 	__be32 addr_fold = addr->ip;
 
@@ -83,7 +89,8 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
+	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
+		IP_VS_SH_TAB_MASK;
 }
 
 
@@ -91,9 +98,11 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
  *      Get ip_vs_dest associated with supplied parameters.
  */
 static inline struct ip_vs_dest *
-ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr)
+ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr,
+	__be16 port, unsigned int offset)
 {
-	return rcu_dereference(s->buckets[ip_vs_sh_hashkey(af, addr)].dest);
+	return rcu_dereference(
+		s->buckets[ip_vs_sh_hashkey(af, addr, port, offset)].dest);
 }
 
 
@@ -224,6 +233,50 @@ static inline int is_overloaded(struct ip_vs_dest *dest)
 
 
 /*
+ *	Helper function to determine if server is available
+ */
+static inline int
+is_available(struct ip_vs_dest *dest)
+{
+	return (!dest ||
+		atomic_read(&dest->weight) <= 0 ||
+		is_overloaded(dest));
+}
+
+
+/*
+ *	Helper function to get port number
+ */
+static inline __be16
+ip_vs_sh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
+{
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
+}
+
+
+/*
  *      Source Hashing scheduling
  */
 static struct ip_vs_dest *
@@ -232,21 +285,45 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_state *s;
 	struct ip_vs_iphdr iph;
+	__be16 port;
+	unsigned int offset;
+	bool found;
 
 	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
+	if (svc->flags & IP_VS_SVC_F_SCHED1)
+		port = ip_vs_sh_get_port(skb, &iph);
+	else
+		port = 0;
+
 	s = (struct ip_vs_sh_state *) svc->sched_data;
-	dest = ip_vs_sh_get(svc->af, s, &iph.saddr);
-	if (!dest
-	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
-	    || atomic_read(&dest->weight) <= 0
-	    || is_overloaded(dest)) {
+	if (svc->flags & IP_VS_SVC_F_SCHED2) {
+		found = false;
+		for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
+			dest = ip_vs_sh_get(svc->af, s, &iph.saddr,
+				port, offset);
+			if (!is_available(dest))
+				IP_VS_DBG_BUF(6, "SH: selected unavailable"
+					"server %s:%d, retrying with offset"
+					"%d\n",
+					IP_VS_DBG_ADDR(svc->af, &dest->addr),
+					ntohs(dest->port),
+					offset);
+			else
+				goto found_dest;
+		}
+	} else {
+		dest = ip_vs_sh_get(svc->af, s, &iph.saddr, port, 0);
+		found = true;
+	}
+	if (!found || !is_available(dest)) {
 		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
 
+ found_dest:
 	IP_VS_DBG_BUF(6, "SH: source IP address %s --> server %s:%d\n",
 		      IP_VS_DBG_ADDR(svc->af, &iph.saddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr),


Alex

