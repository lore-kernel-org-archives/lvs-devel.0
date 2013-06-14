From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Fri, 14 Jun 2013 11:22:10 +0100
Message-ID: <20130614102210.GA31800@eldamar.org.uk>
References: <20130524151408.GM264@eldamar.org.uk>
 <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
 <20130607081252.GC11902@eldamar.org.uk>
 <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk>
 <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg>
 <20130612141018.GC29327@eldamar.org.uk>
 <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
 <20130613141804.GB31356@eldamar.org.uk>
 <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> > For the ipvsadm option, I've used (-b|--sched-flags) 123.  I don't
> 	Not sure if we need "-b".

Well, okay.  I just have a personal preference for short options. :-)
It makes ipvsadm -Sn output look nicer, too.

> 	I guess it is difficult to maintain many options,
> may be one option --sched-flags should be enough, for example:
> --sched-flags sh-fallback,sh-port

Okay, that looks good.

I've done some refactoring to simplify ip_vs_sh_schedule.  Let me know
what you think.

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
index 0df269d..4bb9636 100644
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
@@ -71,10 +75,37 @@ struct ip_vs_sh_state {
 	struct rcu_head			rcu_head;
 };
 
+
+/*
+ *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
+ *      consider that the server is overloaded here.
+ */
+static inline int is_overloaded(struct ip_vs_dest *dest)
+{
+	return dest->flags & IP_VS_DEST_F_OVERLOAD;
+}
+
+
+/*
+ *	Helper function to determine if server is unavailable
+ */
+static inline int
+is_unavailable(struct ip_vs_dest *dest)
+{
+	return (!dest ||
+		atomic_read(&dest->weight) <= 0 ||
+		is_overloaded(dest));
+}
+
+
 /*
  *	Returns hash value for IPVS SH entry
  */
-static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
+static inline unsigned int
+ip_vs_sh_hashkey(int af,
+		 const union nf_inet_addr *addr,
+		 __be16 port,
+		 unsigned int offset)
 {
 	__be32 addr_fold = addr->ip;
 
@@ -83,7 +114,8 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
+	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
+		IP_VS_SH_TAB_MASK;
 }
 
 
@@ -91,13 +123,55 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
  *      Get ip_vs_dest associated with supplied parameters.
  */
 static inline struct ip_vs_dest *
-ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr)
+ip_vs_sh_get(struct ip_vs_service *svc,
+	     struct ip_vs_sh_state *s,
+	     const union nf_inet_addr *addr,
+	     __be16 port)
 {
-	return rcu_dereference(s->buckets[ip_vs_sh_hashkey(af, addr)].dest);
+	struct ip_vs_dest *dest;
+
+	dest = rcu_dereference(
+		s->buckets[ip_vs_sh_hashkey(svc->af, addr, port, 0)].dest);
+
+	return is_unavailable(dest) ? NULL : dest;
 }
 
 
 /*
+ *	As ip_vs_sh_get, but with fallback if selected server is unavailable
+ */
+static inline struct ip_vs_dest *
+ip_vs_sh_get_fallback(struct ip_vs_service *svc,
+		      struct ip_vs_sh_state *s,
+		      const union nf_inet_addr *addr,
+		      __be16 port)
+{
+	unsigned int offset;
+	struct ip_vs_dest *dest;
+
+	for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
+		dest = rcu_dereference(s->buckets[
+			ip_vs_sh_hashkey(svc->af, addr, port, offset)].dest);
+		if (!is_unavailable(dest))
+			return dest;
+#ifdef CONFIG_IP_VS_DEBUG
+		else if (dest)
+			IP_VS_DBG_BUF(6, "SH: selected unavailable server "
+				"%s:%d (offset %d)",
+				IP_VS_DBG_ADDR(svc->af, &dest->addr),
+				ntohs(dest->port),
+				offset);
+		else
+			IP_VS_DBG(6, "SH: selected null server "
+				"(offset %d)",
+				offset);
+#endif
+	}
+
+	return NULL;
+}
+
+/*
  *      Assign all the hash buckets of the specified table with the service.
  */
 static int
@@ -214,12 +288,34 @@ static int ip_vs_sh_dest_changed(struct ip_vs_service *svc,
 
 
 /*
- *      If the dest flags is set with IP_VS_DEST_F_OVERLOAD,
- *      consider that the server is overloaded here.
+ *	Helper function to get port number
  */
-static inline int is_overloaded(struct ip_vs_dest *dest)
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
 
 
@@ -232,17 +328,23 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_state *s;
 	struct ip_vs_iphdr iph;
-
-	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
+	__be16 port = 0;
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
+	ip_vs_fill_iph_skb(svc->af, skb, &iph);
+
+	if (svc->flags & IP_VS_SVC_F_SCHED_SH_PORT)
+		port = ip_vs_sh_get_port(skb, &iph);
+
 	s = (struct ip_vs_sh_state *) svc->sched_data;
-	dest = ip_vs_sh_get(svc->af, s, &iph.saddr);
-	if (!dest
-	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
-	    || atomic_read(&dest->weight) <= 0
-	    || is_overloaded(dest)) {
+
+	if (svc->flags & IP_VS_SVC_F_SCHED_SH_FALLBACK)
+		dest = ip_vs_sh_get_fallback(svc, s, &iph.saddr, port);
+	else
+		dest = ip_vs_sh_get(svc, s, &iph.saddr, port);
+
+	if (!dest) {
 		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}


Alex

