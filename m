From: Hans Schillstrom <hans@schillstrom.com>
Subject: [RFC] ipvs ipv6 fragment handling
Date: Thu, 9 Feb 2012 18:15:21 +0100
Message-ID: <201202091815.26458.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3166711.VMINqoBc6X";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org

--nextPart3166711.VMINqoBc6X
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello,
Long time since the last ipvs patches from me...

IPVS do not have any kind of fragmentation handling for IPv6,
neither can it handle extension headers in front of upper layer headers.

The last issue is easy to fix with ipv6_find_hdr() which also is a part of =
this RFC.
This implementation relies on how nf_defrag_ipv6 works today.

Netfilter-team (Patrick) pls let me know if ipv6-nat makes any big changes =
to the=20
defrag procedure.

IPVS do like conntrack i.e. use the skb->nfct_reasm;
(i.e. when all fragments is collected, nf_ct_frag6_output() starts a "re-pl=
ay"
of all fragments into the interrupted PREROUTING chain att prio -399 with n=
fct_reasm
pointing to the assembled packet.)

IPVS adds a new hook into prerouting chain at prio -100 to catch fragments,
and copy fw-mark and routing info from the first packet with an upper layer=
 header.

=46or the first fragment ip_vs_in() and ip_vs_out() uses the skb->nfct_reasm
to "store" fw-mark" and skb_dst().
Which will be copied into the following fragments.

This patch needs  "NETFILTER added flags to ipv6_find_hdr()" patch

The patch is far from ready since this is only a RFC,=20
ex ip_vs_nat_xmit_v6() doesn't work since it writes right into the fragment=
 header..
tunnel is not tested at all.=20
Only Direct routing is tested. (not to localhost)

Plenty of formatting rules is violated and there is also debug printouts to=
 remove...
(and kmail seems to corrupt tabs)

IPVS will depend on ip6tables and its defragmentation but NOT on conntrack.
Is the design idea OK ?
Will IPv6-NAT break everything ?
Is there a reason not to use the skb->nfct_reasm as "storage" for mark and =
dst_entry ?

This doesn't violate the RFC 2460 "fragmentation in IPv6 is performed only =
by source nodes"




diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ebe517f..2d3aeab 100644
=2D-- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -22,6 +22,9 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#include <linux/netfilter_ipv6/ip6_tables.h>
+#endif
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
 #endif
@@ -105,8 +108,10 @@ extern int ip_vs_conn_tab_size;
=20
=20
 struct ip_vs_iphdr {
=2D	int len;
=2D	__u8 protocol;
+	__s32 len; 	/* offset where to find next header */
+	__s32 flags;
+	__u16 fragoffs;
+	__s16 protocol;
 	union nf_inet_addr saddr;
 	union nf_inet_addr daddr;
 };
@@ -132,6 +137,42 @@ ip_vs_fill_iphdr(int af, const void *nh, struct ip_vs_=
iphdr *iphdr)
 	}
 }
=20
+static inline void
+ip_vs_fill_iph_skb(int af, const struct sk_buff *skb, struct ip_vs_iphdr *=
iphdr)
+{
+	iphdr->len =3D 0;
+	iphdr->flags =3D 0;
+#ifdef CONFIG_IP_VS_IPV6
+	if (af =3D=3D AF_INET6) {
+		const struct ipv6hdr *iph =3D (struct ipv6hdr *)skb_network_header(skb);
+
+		iphdr->protocol =3D ipv6_find_hdr(skb, &iphdr->len, -1,
+		                                &iphdr->fragoffs,
+		                                &iphdr->flags);
+		iphdr->saddr.in6 =3D iph->saddr;
+		iphdr->daddr.in6 =3D iph->daddr;
+	} else
+#endif
+	{
+		const struct iphdr *iph =3D (struct iphdr *)skb_network_header(skb);
+		iphdr->len =3D iph->ihl * 4;
+		iphdr->protocol =3D iph->protocol;
+		iphdr->saddr.ip =3D iph->saddr;
+		iphdr->daddr.ip =3D iph->daddr;
+	}
+}
+#if defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MODULE)
+static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb)
+{
+	return skb->nfct_reasm;
+}
+#else
+static inline struct sk_buff *skb_reasm(const struct sk_buff *skb)
+{
+	return NULL;
+}
+#endif
+
 static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
 				   const union nf_inet_addr *src)
 {
@@ -412,7 +453,7 @@ struct ip_vs_protocol {
 			const struct sk_buff *skb,
 			const struct ip_vs_iphdr *iph,
 			unsigned int proto_off,
=2D			int inverse);
+			int inverse, unsigned short foffs);
=20
 	int (*snat_handler)(struct sk_buff *skb,
 			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
@@ -1001,7 +1042,7 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip=
_vs_conn_param *p);
 struct ip_vs_conn * ip_vs_conn_out_get_proto(int af, const struct sk_buff =
*skb,
 					     const struct ip_vs_iphdr *iph,
 					     unsigned int proto_off,
=2D					     int inverse);
+					     int inverse, unsigned short foffs);
=20
 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_con=
n.c
index 29fa5ba..36e65ca 100644
=2D-- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -432,13 +432,19 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip=
_vs_conn_param *p)
=20
 struct ip_vs_conn *
 ip_vs_conn_out_get_proto(int af, const struct sk_buff *skb,
=2D			 const struct ip_vs_iphdr *iph,
=2D			 unsigned int proto_off, int inverse)
+			 const struct ip_vs_iphdr *iph, unsigned int proto_off,
+			 int inverse, unsigned short foffs)
 {
 	struct ip_vs_conn_param p;
=20
=2D	if (ip_vs_conn_fill_param_proto(af, skb, iph, proto_off, inverse, &p))
=2D		return NULL;
+	if (unlikely(foffs)) {
+		if (ip_vs_conn_fill_param_proto(af, skb_nfct_reasm(skb), iph,
+						proto_off, inverse, &p))
+			return NULL;
+	} else {
+		if (ip_vs_conn_fill_param_proto(af, skb, iph, proto_off, inverse, &p))
+			return NULL;
+	}
=20
 	return ip_vs_conn_out_get(&p);
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_cor=
e.c
index 611c335..e67144f 100644
=2D-- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -235,7 +235,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
=20
=2D	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(svc->af, skb, &iph);
=20
 	/* Mask saddr with the netmask to adjust template granularity */
 #ifdef CONFIG_IP_VS_IPV6
@@ -402,7 +402,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buf=
f *skb,
 	unsigned int flags;
=20
 	*ignored =3D 1;
=2D	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(svc->af, skb, &iph);
 	pptr =3D skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr =3D=3D NULL)
 		return NULL;
@@ -506,7 +506,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_bu=
ff *skb,
 	int unicast;
 #endif
=20
=2D	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(svc->af, skb, &iph);
=20
 	pptr =3D skb_header_pointer(skb, iph.len, sizeof(_ports), _ports);
 	if (pptr =3D=3D NULL) {
@@ -654,14 +654,6 @@ static inline int ip_vs_gather_frags(struct sk_buff *s=
kb, u_int32_t user)
 	return err;
 }
=20
=2D#ifdef CONFIG_IP_VS_IPV6
=2Dstatic inline int ip_vs_gather_frags_v6(struct sk_buff *skb, u_int32_t u=
ser)
=2D{
=2D	/* TODO IPv6: Find out what to do here for IPv6 */
=2D	return 0;
=2D}
=2D#endif
=2D
 static int ip_vs_route_me_harder(int af, struct sk_buff *skb)
 {
 #ifdef CONFIG_IP_VS_IPV6
@@ -819,6 +811,11 @@ static int handle_response_icmp(int af, struct sk_buff=
 *skb,
 	ip_vs_out_stats(cp, skb);
=20
 	skb->ipvs_property =3D 1;
+	IP_VS_DBG(1, " ICMP(%p) response set track(%x) %pI6c#%d %pI6c#%d %pI6c#%d=
 fw:%d len:%d\n",
+			skb, cp->flags & IP_VS_CONN_F_NFCT,
+			&cp->caddr.in6, ntohs(cp->cport),
+			&cp->vaddr.in6, ntohs(cp->vport),
+			&cp->daddr.in6, ntohs(cp->dport), cp->fwmark, skb->len);
 	if (!(cp->flags & IP_VS_CONN_F_NFCT))
 		ip_vs_notrack(skb);
 	else
@@ -902,7 +899,7 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *rel=
ated,
=20
 	ip_vs_fill_iphdr(AF_INET, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
=2D	cp =3D pp->conn_out_get(AF_INET, skb, &ciph, offset, 1);
+	cp =3D pp->conn_out_get(AF_INET, skb, &ciph, offset, 1, 0);
 	if (!cp)
 		return NF_ACCEPT;
=20
@@ -913,36 +910,34 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *r=
elated,
=20
 #ifdef CONFIG_IP_VS_IPV6
 static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
=2D			     unsigned int hooknum)
+			     unsigned int hooknum, struct ip_vs_iphdr *ipvsh,
+			     unsigned short fragoffs)
 {
=2D	struct ipv6hdr *iph;
 	struct icmp6hdr	_icmph, *ic;
=2D	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
+	struct ipv6hdr _ip6, *ip6;	/* The ip header contained
 					   within the ICMP */
=2D	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
=2D	unsigned int offset;
 	union nf_inet_addr snet;
=20
 	*related =3D 1;
=20
=2D	/* reassemble IP fragments */
=2D	if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_FRAGMENT) {
=2D		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
=2D			return NF_STOLEN;
=2D	}
=2D
=2D	iph =3D ipv6_hdr(skb);
=2D	offset =3D sizeof(struct ipv6hdr);
=2D	ic =3D skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	/*
+	 * Fragment is before ICMP header which tells us that this is not an
+	 * error message since they can't be fragmented.
+	 */
+	if (unlikely(fragoffs)) {
+		IP_VS_DBG(1,"Outgoing ICMPv6 frag(%d) %pI6c->%pI6c offs:%d\n",
+		          fragoffs, &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+		          ipvsh->fragoffs);
+		ic =3D skb_header_pointer(skb_nfct_reasm(skb), ipvsh->len,
+					sizeof(_icmph), &_icmph);
+	} else
+		ic =3D skb_header_pointer(skb, ipvsh->len, sizeof(_icmph),
+					&_icmph);
 	if (ic =3D=3D NULL)
 		return NF_DROP;
=20
=2D	IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) %pI6->%pI6\n",
=2D		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
=2D		  &iph->saddr, &iph->daddr);
=2D
 	/*
 	 * Work through seeing if this is for us.
 	 * These checks are supposed to be in an order that means easy
@@ -956,36 +951,51 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int=
 *related,
 		*related =3D 0;
 		return NF_ACCEPT;
 	}
=2D
=2D	/* Now find the contained IP header */
=2D	offset +=3D sizeof(_icmph);
=2D	cih =3D skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
=2D	if (cih =3D=3D NULL)
=2D		return NF_ACCEPT; /* The packet looks wrong, ignore */
=2D
=2D	pp =3D ip_vs_proto_get(cih->nexthdr);
=2D	if (!pp)
+	if (unlikely(fragoffs)) {
+		IP_VS_DBG(1, "***ERROR*** Don't frag an ICMPv6 Error(%d,%d)"
+			     " %pI6->%pI6\n",
+			     ic->icmp6_type, ntohs(icmpv6_id(ic)),
+			     &ipvsh->saddr, &ipvsh->daddr);
 		return NF_ACCEPT;
+	}
=20
=2D	/* Is the embedded protocol header present? */
=2D	/* TODO: we don't support fragmentation at the moment anyways */
=2D	if (unlikely(cih->nexthdr =3D=3D IPPROTO_FRAGMENT && pp->dont_defrag))
=2D		return NF_ACCEPT;
+	IP_VS_DBG(1, "Outgoing ICMPv6 Error (%d,%d) %pI6->%pI6\n",
+		  ic->icmp6_type, ntohs(icmpv6_id(ic)),
+		  &ipvsh->saddr, &ipvsh->daddr);
=20
=2D	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
=2D		      "Checking outgoing ICMPv6 for");
+	/* Now find the contained IP header after icmp hdr */
+	ipvsh->len +=3D sizeof(_icmph);
+	ip6 =3D skb_header_pointer(skb, ipvsh->len, sizeof(_ip6), &_ip6);
+	ipvsh->protocol =3D ipv6_find_hdr(skb, &ipvsh->len, -1,
+					&ipvsh->fragoffs, &ipvsh->flags);
=20
=2D	offset +=3D sizeof(struct ipv6hdr);
+	/*
+	 * Is the embedded protocol header present?
+	 * If not we can't do very much, and if it's an error on a fragment
+	 *  we don't have the history anyway..
+	 */
+	pp =3D ip_vs_proto_get(ipvsh->protocol);
+	if (!pp || (ipvsh->protocol < 0))
+		return NF_ACCEPT;
+	/* fill the rest of ipvsh */
+	ipvsh->saddr.in6 =3D ip6->saddr;
+	ipvsh->daddr.in6 =3D ip6->daddr;
=20
=2D	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
=2D	cp =3D pp->conn_out_get(AF_INET6, skb, &ciph, offset, 1);
+	cp =3D pp->conn_out_get(AF_INET6, skb, ipvsh, ipvsh->len, 1, 0);
 	if (!cp)
 		return NF_ACCEPT;
+	{
+		__be16 _ports[2], *pptr;
+
+		pptr =3D skb_header_pointer(skb, ipvsh->len, sizeof(_ports), _ports);
=20
=2D	snet.in6 =3D iph->saddr;
=2D	return handle_response_icmp(AF_INET6, skb, &snet, cih->nexthdr, cp,
=2D				    pp, offset, sizeof(struct ipv6hdr));
+		IP_VS_DBG(1, "Outg ICMPv6 Error found %pI6[%d] -> %pI6[%d]\n",
+		  &ip6->saddr, ntohs(pptr[0]), &ip6->daddr, ntohs(pptr[1]));
+	}
+	snet.in6 =3D ipvsh->saddr.in6;
+	return handle_response_icmp(AF_INET6, skb, &snet, ipvsh->protocol, cp,
+				    pp, ipvsh->len, sizeof(struct ipv6hdr));
 }
 #endif
=20
@@ -1064,6 +1074,11 @@ handle_response(int af, struct sk_buff *skb, struct =
ip_vs_proto_data *pd,
 	ip_vs_out_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pd);
 	skb->ipvs_property =3D 1;
+	IP_VS_DBG(1, " IP(%p) response set track(%x) %pI6c#%d %pI6c#%d %pI6c#%d f=
w:%d len:%d\n",
+			skb, cp->flags & IP_VS_CONN_F_NFCT,
+			&cp->caddr.in6, ntohs(cp->cport),
+			&cp->vaddr.in6, ntohs(cp->vport),
+			&cp->daddr.in6, ntohs(cp->dport), cp->fwmark, skb->len);
 	if (!(cp->flags & IP_VS_CONN_F_NFCT))
 		ip_vs_notrack(skb);
 	else
@@ -1083,14 +1098,14 @@ drop:
 /*
  *	Check if outgoing packet belongs to the established ip_vs_conn.
  */
=2Dstatic unsigned int
=2Dip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
+static unsigned int ip_vs_out(unsigned int hooknum, struct sk_buff *skb, i=
nt af)
 {
 	struct net *net =3D NULL;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
+	unsigned short fragoffs =3D 0;
=20
 	EnterFunction(11);
=20
@@ -1115,17 +1130,32 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb=
, int af)
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
=20
=2D	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	/* It's a fragment take first frag */
+	if (skb_nfct_reasm(skb))
+		ip_vs_fill_iph_skb(af, skb_nfct_reasm(skb), &iph);
+	else
+		ip_vs_fill_iph_skb(af, skb, &iph);
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (af =3D=3D AF_INET6) {
+		if (skb_nfct_reasm(skb)) {
+			struct sk_buff *reasm =3D skb_nfct_reasm(skb);
+			int len =3D 0;
+
+			ipv6_find_hdr(skb, &len, -1, &fragoffs, NULL);
+
+			if (!fragoffs) {
+				reasm->mark =3D skb->mark;
+				skb_dst_copy(reasm, skb);
+			}
+		}
 		if (unlikely(iph.protocol =3D=3D IPPROTO_ICMPV6)) {
 			int related;
=2D			int verdict =3D ip_vs_out_icmp_v6(skb, &related,
=2D							hooknum);
=2D
+			int verdict =3D ip_vs_out_icmp_v6(skb, &related, hooknum,
+							&iph, fragoffs);
+			/* Related means an icmp error on an ipvs_conn */
 			if (related)
 				return verdict;
=2D			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 	} else
 #endif
@@ -1135,7 +1165,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, =
int af)
=20
 			if (related)
 				return verdict;
=2D			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
=20
 	pd =3D ip_vs_proto_data_get(net, iph.protocol);
@@ -1145,28 +1175,20 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb=
, int af)
=20
 	/* reassemble IP fragments */
 #ifdef CONFIG_IP_VS_IPV6
=2D	if (af =3D=3D AF_INET6) {
=2D		if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_FRAGMENT) {
=2D			if (ip_vs_gather_frags_v6(skb,
=2D						  ip_vs_defrag_user(hooknum)))
=2D				return NF_STOLEN;
=2D		}
=2D
=2D		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
=2D	} else
+	if (af =3D=3D AF_INET)
 #endif
 		if (unlikely(ip_is_fragment(ip_hdr(skb)) && !pp->dont_defrag)) {
 			if (ip_vs_gather_frags(skb,
 					       ip_vs_defrag_user(hooknum)))
 				return NF_STOLEN;
=20
=2D			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
=20
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
=2D	cp =3D pp->conn_out_get(af, skb, &iph, iph.len, 0);
+	cp =3D pp->conn_out_get(af, skb, &iph, iph.len, 0, fragoffs);
=20
 	if (likely(cp))
 		return handle_response(af, skb, pd, cp, iph.len);
@@ -1176,8 +1198,13 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,=
 int af)
 	     pp->protocol =3D=3D IPPROTO_SCTP)) {
 		__be16 _ports[2], *pptr;
=20
=2D		pptr =3D skb_header_pointer(skb, iph.len,
=2D					  sizeof(_ports), _ports);
+		/* Handle fragments */
+		if (fragoffs)
+			pptr =3D skb_header_pointer(skb_nfct_reasm(skb), iph.len,
+						  sizeof(_ports), _ports);
+		else
+			pptr =3D skb_header_pointer(skb, iph.len,
+						  sizeof(_ports), _ports);
 		if (pptr =3D=3D NULL)
 			return NF_ACCEPT;	/* Not for me */
 		if (ip_vs_lookup_real_service(net, af, iph.protocol,
@@ -1389,14 +1416,11 @@ out:
 }
=20
 #ifdef CONFIG_IP_VS_IPV6
=2Dstatic int
=2Dip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
+static int ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,
+			    unsigned int hooknum, struct ip_vs_iphdr *iph)
 {
 	struct net *net =3D NULL;
=2D	struct ipv6hdr *iph;
 	struct icmp6hdr	_icmph, *ic;
=2D	struct ipv6hdr	_ciph, *cih;	/* The ip header contained
=2D					   within the ICMP */
 	struct ip_vs_iphdr ciph;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
@@ -1405,15 +1429,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, =
unsigned int hooknum)
=20
 	*related =3D 1;
=20
=2D	/* reassemble IP fragments */
=2D	if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_FRAGMENT) {
=2D		if (ip_vs_gather_frags_v6(skb, ip_vs_defrag_user(hooknum)))
=2D			return NF_STOLEN;
=2D	}
=2D
=2D	iph =3D ipv6_hdr(skb);
=2D	offset =3D sizeof(struct ipv6hdr);
=2D	ic =3D skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	ic =3D skb_header_pointer(skb, iph->len, sizeof(_icmph), &_icmph);
 	if (ic =3D=3D NULL)
 		return NF_DROP;
=20
@@ -1435,39 +1451,48 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related,=
 unsigned int hooknum)
 		return NF_ACCEPT;
 	}
=20
=2D	/* Now find the contained IP header */
=2D	offset +=3D sizeof(_icmph);
=2D	cih =3D skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
=2D	if (cih =3D=3D NULL)
=2D		return NF_ACCEPT; /* The packet looks wrong, ignore */
=2D
+	/*
+	 * Now find the contained IP header
+	 * an icmp error message will never be fragmented, but
+	 * the contained IP header might contain an fragment...
+	 */
+	ciph.len =3D iph->len + sizeof(_icmph);
+	ciph.flags =3D 0;
+	ciph.fragoffs =3D 0;
+	ciph.protocol =3D ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs,
+				      &ciph.flags);
+	ciph.saddr =3D iph->saddr;	/* con_in_get() handles reverse order */
+	ciph.daddr =3D iph->daddr;
+
+	/* Hmm todo: check if find_hdr should be used instead */
 	net =3D skb_net(skb);
=2D	pd =3D ip_vs_proto_data_get(net, cih->nexthdr);
+	pd =3D ip_vs_proto_data_get(net, ciph.protocol);
 	if (!pd)
 		return NF_ACCEPT;
 	pp =3D pd->pp;
=20
=2D	/* Is the embedded protocol header present? */
=2D	/* TODO: we don't support fragmentation at the moment anyways */
=2D	if (unlikely(cih->nexthdr =3D=3D IPPROTO_FRAGMENT && pp->dont_defrag))
+	/* Is the embedded protocol header present?
+	 * If it's the second or later fragment we don't know what it is
+	 * i.e. just let it through.
+	 */
+	if (ciph.fragoffs)
 		return NF_ACCEPT;
=20
+	offset =3D ciph.len;
 	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
 		      "Checking incoming ICMPv6 for");
=20
=2D	offset +=3D sizeof(struct ipv6hdr);
=2D
=2D	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
 	/* The embedded headers contain source and dest in reverse order */
=2D	cp =3D pp->conn_in_get(AF_INET6, skb, &ciph, offset, 1);
+	cp =3D pp->conn_in_get(AF_INET6, skb, &ciph, ciph.len, 1);
 	if (!cp)
 		return NF_ACCEPT;
=20
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
=2D	if (IPPROTO_TCP =3D=3D cih->nexthdr || IPPROTO_UDP =3D=3D cih->nexthdr =
||
=2D	    IPPROTO_SCTP =3D=3D cih->nexthdr)
=2D		offset +=3D 2 * sizeof(__u16);
+	if (IPPROTO_TCP =3D=3D ciph.protocol|| IPPROTO_UDP =3D=3D ciph.protocol ||
+	    IPPROTO_SCTP =3D=3D ciph.protocol)
+		offset =3D ciph.len + (2 * sizeof(__u16));
+
 	verdict =3D ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum);
=20
 	__ip_vs_conn_put(cp);
@@ -1489,13 +1514,21 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,=
 int af)
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
+	unsigned short fragoffs =3D 0;
 	int ret, pkts;
 	struct netns_ipvs *ipvs;
=20
+	struct sk_buff *reasm;
+
 	/* Already marked as IPVS request or reply? */
 	if (skb->ipvs_property)
 		return NF_ACCEPT;
=20
+	/* ipvs enabled in this netns ? */
+	net =3D skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
+
 	/*
 	 *	Big tappo:
 	 *	- remote client: only PACKET_HOST
@@ -1503,20 +1536,10 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,=
 int af)
 	 */
 	if (unlikely((skb->pkt_type !=3D PACKET_HOST &&
 		      hooknum !=3D NF_INET_LOCAL_OUT) ||
=2D		     !skb_dst(skb))) {
=2D		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
=2D		IP_VS_DBG_BUF(12, "packet type=3D%d proto=3D%d daddr=3D%s"
=2D			      " ignored in hook %u\n",
=2D			      skb->pkt_type, iph.protocol,
=2D			      IP_VS_DBG_ADDR(af, &iph.daddr), hooknum);
+		      !skb_dst(skb))) {
+		LeaveFunction(12);
 		return NF_ACCEPT;
 	}
=2D	/* ipvs enabled in this netns ? */
=2D	net =3D skb_net(skb);
=2D	if (!net_ipvs(net)->enable)
=2D		return NF_ACCEPT;
=2D
=2D	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
=20
 	/* Bad... Do not break raw sockets */
 	if (unlikely(skb->sk !=3D NULL && hooknum =3D=3D NF_INET_LOCAL_OUT &&
@@ -1528,15 +1551,36 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,=
 int af)
 			return NF_ACCEPT;
 	}
=20
+	reasm =3D skb_nfct_reasm(skb);
+	ip_vs_fill_iph_skb(af, (reasm ? reasm : skb), &iph);
+
 #ifdef CONFIG_IP_VS_IPV6
 	if (af =3D=3D AF_INET6) {
+		if (reasm) {
+			int len =3D 0;
+
+			ipv6_find_hdr(skb, &len, -1, &fragoffs, NULL);
+			IP_VS_DBG(1, "IN FRAG %s(%p s:%p) %pI6c %pI6c hdr:%d len:%d/%d %d fw:%u=
/%u\n",
+			          (fragoffs) ? "+2:nd" : "1:st", reasm, skb,
+			          &ipv6_hdr(reasm)->saddr, &ipv6_hdr(reasm)->daddr,
+			          ipv6_hdr(reasm)->nexthdr, skb->len, reasm->len, fragoffs,
+			          skb->mark, reasm->mark);
+		}
+		/*
+		 * Save first fragment dst & fwmark to the re-assembly skb
+		 */
+		if (!fragoffs && reasm) {
+			reasm->mark =3D skb->mark;
+			skb_dst_copy(reasm, skb);
+		}
+
 		if (unlikely(iph.protocol =3D=3D IPPROTO_ICMPV6)) {
 			int related;
=2D			int verdict =3D ip_vs_in_icmp_v6(skb, &related, hooknum);
+			int verdict =3D ip_vs_in_icmp_v6(skb, &related, hooknum,
+			                               &iph);
=20
 			if (related)
 				return verdict;
=2D			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 	} else
 #endif
@@ -1546,7 +1590,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, i=
nt af)
=20
 			if (related)
 				return verdict;
=2D			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+			/* I don't think this one is needed ... /HS */
+			ip_vs_fill_iph_skb(af, skb, &iph);
 		}
=20
 	/* Protocol supported? */
@@ -1556,14 +1601,19 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,=
 int af)
 	pp =3D pd->pp;
 	/*
 	 * Check if the packet belongs to an existing connection entry
+	 * Only sched first IPv6 fragment.
 	 */
=2D	cp =3D pp->conn_in_get(af, skb, &iph, iph.len, 0);
+	if (fragoffs)
+		cp =3D pp->conn_in_get(af, reasm, &iph, iph.len, 0);
+	else {
+		cp =3D pp->conn_in_get(af, skb, &iph, iph.len, 0);
=20
=2D	if (unlikely(!cp)) {
=2D		int v;
+		if (unlikely(!cp)) {
+			int v;
=20
=2D		if (!pp->conn_schedule(af, skb, pd, &v, &cp))
=2D			return v;
+			if (!pp->conn_schedule(af, skb, pd, &v, &cp))
+				return v;
+		}
 	}
=20
 	if (unlikely(!cp)) {
@@ -1678,6 +1728,38 @@ ip_vs_local_request4(unsigned int hooknum, struct sk=
_buff *skb,
 }
=20
 #ifdef CONFIG_IP_VS_IPV6
+/*
+ * AF_INET6 fragment handling
+ * Copy info from first fragment, to the rest of them.
+ */
+static unsigned int
+ip_vs_preroute_frag6(unsigned int hooknum, struct sk_buff *skb,
+		      const struct net_device *in,
+		      const struct net_device *out,
+		      int (*okfn)(struct sk_buff *))
+{
+	struct ip_vs_iphdr iphdr  =3D { .len =3D 0, .flags =3D 0, };
+	struct sk_buff *reasm =3D skb_nfct_reasm(skb);
+	struct net *net;
+
+	/* This is not a "replay" from nf_ct_frag6_output */
+	if (!reasm)
+		return NF_ACCEPT;
+
+	net =3D skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
+
+	iphdr.protocol =3D ipv6_find_hdr(skb, &iphdr.len, -1, &iphdr.fragoffs,
+				       &iphdr.flags);
+	if (!iphdr.fragoffs)
+		return NF_ACCEPT;
+	/* Copy stored mark & dst from ip_vs_in / out */
+	skb->mark =3D reasm->mark;
+	skb_dst_copy(skb,reasm);
+
+	return NF_ACCEPT;
+}
=20
 /*
  *	AF_INET6 handler in NF_INET_LOCAL_IN chain
@@ -1749,8 +1831,10 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct s=
k_buff *skb,
 {
 	int r;
 	struct net *net;
+	struct ip_vs_iphdr iphdr;
=20
=2D	if (ipv6_hdr(skb)->nexthdr !=3D IPPROTO_ICMPV6)
+	ip_vs_fill_iph_skb(AF_INET6, skb, &iphdr);
+	if (iphdr.protocol !=3D IPPROTO_ICMPV6)
 		return NF_ACCEPT;
=20
 	/* ipvs enabled in this netns ? */
@@ -1758,7 +1842,7 @@ ip_vs_forward_icmp_v6(unsigned int hooknum, struct sk=
_buff *skb,
 	if (!net_ipvs(net)->enable)
 		return NF_ACCEPT;
=20
=2D	return ip_vs_in_icmp_v6(skb, &r, hooknum);
+	return ip_vs_in_icmp_v6(skb, &r, hooknum, &iphdr);
 }
 #endif
=20
@@ -1816,6 +1900,14 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly =
=3D {
 		.priority	=3D 100,
 	},
 #ifdef CONFIG_IP_VS_IPV6
+	/* After mangle & nat fetch 2:nd fragment and following  */
+	{
+		.hook		=3D ip_vs_preroute_frag6,
+		.owner		=3D THIS_MODULE,
+		.pf		=3D PF_INET6,
+		.hooknum	=3D NF_INET_PRE_ROUTING,
+		.priority	=3D NF_IP6_PRI_NAT_DST + 1,
+	},
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		=3D ip_vs_reply6,
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/i=
p_vs_proto_ah_esp.c
index 5b8eb8b..bda8560 100644
=2D-- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -87,7 +87,7 @@ static struct ip_vs_conn *
 ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 		    const struct ip_vs_iphdr *iph,
 		    unsigned int proto_off,
=2D		    int inverse)
+		    int inverse, unsigned short foffs)
 {
 	struct ip_vs_conn *cp;
 	struct ip_vs_conn_param p;
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_v=
s_proto_tcp.c
index ef8641f..0199bb2 100644
=2D-- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -40,7 +40,7 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_=
vs_proto_data *pd,
 	struct tcphdr _tcph, *th;
 	struct ip_vs_iphdr iph;
=20
=2D	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
=20
 	th =3D skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
 	if (th =3D=3D NULL) {
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_v=
s_proto_udp.c
index f4b7262..6064f6e 100644
=2D-- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -37,7 +37,7 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_=
vs_proto_data *pd,
 	struct udphdr _udph, *uh;
 	struct ip_vs_iphdr iph;
=20
=2D	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+	ip_vs_fill_iph_skb(af, skb, &iph);
=20
 	uh =3D skb_header_pointer(skb, iph.len, sizeof(_udph), &_udph);
 	if (uh =3D=3D NULL) {
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmi=
t.c
index 7fd66de..1d1b5ad 100644
=2D-- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1080,6 +1080,11 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_c=
onn *cp,
 		IP_VS_XMIT(NFPROTO_IPV6, skb, cp, 1);
 	}
=20
+	IP_VS_DBG(1, "DR XMIT(%p): %pI6c %pI6c via %pI6c dp:%d fw:%d hdr:%d proto=
:%d len:%d\n",
+	          skb, &cp->caddr, &cp->vaddr, &cp->daddr,
+	          ntohs(cp->dport), cp->fwmark,
+	          ipv6_hdr(skb)->nexthdr, cp->protocol, skb->len);
+
 	/* MTU checking */
 	mtu =3D dst_mtu(&rt->dst);
 	if (skb->len > mtu) {
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
index bb10b07..d475f01 100644
=2D-- a/net/netfilter/xt_ipvs.c
+++ b/net/netfilter/xt_ipvs.c
@@ -85,7 +85,7 @@ ipvs_mt(const struct sk_buff *skb, struct xt_action_param=
 *par)
 	/*
 	 * Check if the packet belongs to an existing entry
 	 */
=2D	cp =3D pp->conn_out_get(family, skb, &iph, iph.len, 1 /* inverse */);
+	cp =3D pp->conn_out_get(family, skb, &iph, iph.len, 1 /* inverse */, 0);
 	if (unlikely(cp =3D=3D NULL)) {
 		match =3D false;
 		goto out;

=2D--
Regards
Hans Schillstrom <hans@schillstrom.com>


--nextPart3166711.VMINqoBc6X
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAk8z/y4ACgkQsPw1jACzjGZgzwCeMOyq8RTxfTIxL/Qn/Pb5Nly7
0TEAoIXEXuS1OEhOudMtyuVXExFMGxgK
=csCy
-----END PGP SIGNATURE-----

--nextPart3166711.VMINqoBc6X--
