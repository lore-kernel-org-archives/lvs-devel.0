From: Jacky Hu <hengqing.hu@gmail.com>
Subject: [PATCH v2] ipvs: allow tunneling with gue encapsulation
Date: Sat, 16 Mar 2019 14:06:33 +0800
Message-ID: <20190316060635.2594-1-hengqing.hu@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=IWpaJYdzs3B2aCAoo45V/yz77usHnIUihf40NWutgn4=;
        b=CiEYAYNpIUpGMuOFWDYZEcbv1NonL8xHjZmLMytDNcB97B/50UmAcYXCyQ156jUqsi
         xvaYG1KcLM2AJkouzfPaGKw4Hyr7cDKzG2KpSLa0Rk66E25EstmZO2jhMe+0dBJY/KW1
         otvTAvKI11kNcENpkIvTAEMm+siq4wsfjOAiMVj4UZXNK4rDftMDXtkmr6OIM8Tm6QcR
         CGgndZTFffcaQSFbn6CbZC3d5mrByvEW8BO1woob85VDAs1kG1h7GglPNBF2nm66AAoZ
         w+PQ7bmxNZ0zF9c9v1Qtlhxl5pLPb+fYzUXqjHdSm3K0xA1nOD9hzRsKaqjzuwrpES3U
         cVtg==
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: hengqing.hu@gmail.com
Cc: jacky.hu@walmart.com, jason.niesz@walmart.com, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

ipip packets are blocked in some public cloud environments, this patch
allows gue encapsulation with the tunneling method, which would make
tunneling working in those environments.

Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
---
 include/net/ip_vs.h             |  5 ++
 include/uapi/linux/ip_vs.h      | 17 +++++++
 net/netfilter/ipvs/ip_vs_ctl.c  | 20 +++++++-
 net/netfilter/ipvs/ip_vs_xmit.c | 85 +++++++++++++++++++++++++++++++--
 4 files changed, 122 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a0d2e0bb9a94..56c1770b00fe 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -603,6 +603,9 @@ struct ip_vs_dest_user_kern {
 
 	/* Address family of addr */
 	u16			af;
+
+	u16			tun_type;	/* tunnel type */
+	__be16			tun_port;	/* tunnel port */
 };
 
 
@@ -663,6 +666,8 @@ struct ip_vs_dest {
 	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
 	atomic_t		last_weight;	/* server latest weight */
+	atomic_t		tun_type;	/* tunnel type */
+	atomic_t		tun_port;	/* tunnel port */
 
 	refcount_t		refcnt;		/* reference counter */
 	struct ip_vs_stats      stats;          /* statistics */
diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 1c916b2f89dc..b43297691337 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -124,6 +124,13 @@
 
 #define IP_VS_PEDATA_MAXLEN     255
 
+/* Tunnel types */
+enum {
+	IP_VS_CONN_F_TUNNEL_TYPE_IPIP = 0,	/* IPIP */
+	IP_VS_CONN_F_TUNNEL_TYPE_GUE,		/* GUE */
+	IP_VS_CONN_F_TUNNEL_TYPE_MAX,
+};
+
 /*
  *	The struct ip_vs_service_user and struct ip_vs_dest_user are
  *	used to set IPVS rules through setsockopt.
@@ -155,6 +162,9 @@ struct ip_vs_dest_user {
 	/* thresholds for active connections */
 	__u32		u_threshold;	/* upper threshold */
 	__u32		l_threshold;	/* lower threshold */
+
+	__u16		tun_type;	/* tunnel type */
+	__be16		tun_port;	/* tunnel port */
 };
 
 
@@ -220,6 +230,9 @@ struct ip_vs_dest_entry {
 	__u32		u_threshold;	/* upper threshold */
 	__u32		l_threshold;	/* lower threshold */
 
+	__u16		tun_type;	/* tunnel type */
+	__be16		tun_port;	/* tunnel port */
+
 	__u32		activeconns;	/* active connections */
 	__u32		inactconns;	/* inactive connections */
 	__u32		persistconns;	/* persistent connections */
@@ -392,6 +405,10 @@ enum {
 
 	IPVS_DEST_ATTR_STATS64,		/* nested attribute for dest stats */
 
+	IPVS_DEST_ATTR_TUN_TYPE,	/* tunnel type */
+
+	IPVS_DEST_ATTR_TUN_PORT,	/* tunnel port */
+
 	__IPVS_DEST_ATTR_MAX,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 432141f04af3..48509b03a5ea 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -830,6 +830,10 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
 	conn_flags |= IP_VS_CONN_F_INACTIVE;
 
+	/* set the tunnel info */
+	atomic_set(&dest->tun_type, udest->tun_type);
+	atomic_set(&dest->tun_port, udest->tun_port);
+
 	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
 	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ) {
 		conn_flags |= IP_VS_CONN_F_NOOUTPUT;
@@ -2869,6 +2873,8 @@ static const struct nla_policy ip_vs_dest_policy[IPVS_DEST_ATTR_MAX + 1] = {
 	[IPVS_DEST_ATTR_PERSIST_CONNS]	= { .type = NLA_U32 },
 	[IPVS_DEST_ATTR_STATS]		= { .type = NLA_NESTED },
 	[IPVS_DEST_ATTR_ADDR_FAMILY]	= { .type = NLA_U16 },
+	[IPVS_DEST_ATTR_TUN_TYPE]	= { .type = NLA_U8 },
+	[IPVS_DEST_ATTR_TUN_PORT]	= { .type = NLA_U16 },
 };
 
 static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
@@ -3172,6 +3178,10 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
 			 IP_VS_CONN_F_FWD_MASK)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_WEIGHT,
 			atomic_read(&dest->weight)) ||
+	    nla_put_u8(skb, IPVS_DEST_ATTR_TUN_TYPE,
+		       atomic_read(&dest->tun_type)) ||
+	    nla_put_u16(skb, IPVS_DEST_ATTR_TUN_PORT,
+			atomic_read(&dest->tun_port)) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_U_THRESH, dest->u_threshold) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_L_THRESH, dest->l_threshold) ||
 	    nla_put_u32(skb, IPVS_DEST_ATTR_ACTIVE_CONNS,
@@ -3294,12 +3304,14 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 	/* If a full entry was requested, check for the additional fields */
 	if (full_entry) {
 		struct nlattr *nla_fwd, *nla_weight, *nla_u_thresh,
-			      *nla_l_thresh;
+			      *nla_l_thresh, *nla_tun_type, *nla_tun_port;
 
 		nla_fwd		= attrs[IPVS_DEST_ATTR_FWD_METHOD];
 		nla_weight	= attrs[IPVS_DEST_ATTR_WEIGHT];
 		nla_u_thresh	= attrs[IPVS_DEST_ATTR_U_THRESH];
 		nla_l_thresh	= attrs[IPVS_DEST_ATTR_L_THRESH];
+		nla_tun_type	= attrs[IPVS_DEST_ATTR_TUN_TYPE];
+		nla_tun_port	= attrs[IPVS_DEST_ATTR_TUN_PORT];
 
 		if (!(nla_fwd && nla_weight && nla_u_thresh && nla_l_thresh))
 			return -EINVAL;
@@ -3309,6 +3321,12 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 		udest->weight = nla_get_u32(nla_weight);
 		udest->u_threshold = nla_get_u32(nla_u_thresh);
 		udest->l_threshold = nla_get_u32(nla_l_thresh);
+
+		if (nla_tun_type)
+			udest->tun_type = nla_get_u8(nla_tun_type);
+
+		if (nla_tun_port)
+			udest->tun_port = nla_get_u16(nla_tun_port);
 	}
 
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 473cce2a5231..3efb46a14163 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -32,6 +32,7 @@
 #include <linux/slab.h>
 #include <linux/tcp.h>                  /* for tcphdr */
 #include <net/ip.h>
+#include <net/gue.h>
 #include <net/tcp.h>                    /* for csum_tcpudp_magic */
 #include <net/udp.h>
 #include <net/icmp.h>                   /* for icmp_send */
@@ -989,6 +990,42 @@ static inline int __tun_gso_type_mask(int encaps_af, int orig_af)
 	}
 }
 
+static int
+__build_gue_header(struct net *net, struct sk_buff *skb,
+		   struct ip_vs_conn *cp, __u8 *next_protocol)
+{
+	__be16 dport;
+	__be16 sport;
+	struct udphdr  *udph;	/* Our new UDP header */
+	struct guehdr  *gueh;	/* Our new GUE header */
+
+	skb_push(skb, sizeof(struct guehdr));
+
+	gueh = (struct guehdr *)skb->data;
+
+	gueh->control = 0;
+	gueh->version = 0;
+	gueh->hlen = 0;
+	gueh->flags = 0;
+	gueh->proto_ctype = *next_protocol;
+
+	skb_push(skb, sizeof(struct udphdr));
+	skb_reset_transport_header(skb);
+
+	udph = udp_hdr(skb);
+
+	dport = htons(atomic_read(&cp->dest->tun_port));
+	sport = udp_flow_src_port(net, skb, 0, 0, false);
+	udph->dest = dport;
+	udph->source = sport;
+	udph->len = htons(skb->len);
+	udph->check = 0;
+
+	*next_protocol = IPPROTO_UDP;
+
+	return 0;
+}
+
 /*
  *   IP Tunneling transmitter
  *
@@ -1025,6 +1062,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	int ret, local;
+	int tun_type, gso_type;
 
 	EnterFunction(10);
 
@@ -1033,7 +1071,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
 				   IP_VS_RT_MODE_TUNNEL, &saddr, ipvsh);
-	if (local < 0)
+	if (!cp->dest || local < 0)
 		goto tx_error;
 	if (local)
 		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
@@ -1046,6 +1084,13 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct iphdr);
 
+	tun_type = atomic_read(&cp->dest->tun_type);
+
+	switch (tun_type) {
+	case IP_VS_CONN_F_TUNNEL_TYPE_GUE:
+		max_headroom += sizeof(struct udphdr) + sizeof(struct guehdr);
+	}
+
 	/* We only care about the df field if sysctl_pmtu_disc(ipvs) is set */
 	dfp = sysctl_pmtu_disc(ipvs) ? &df : NULL;
 	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
@@ -1054,11 +1099,23 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (IS_ERR(skb))
 		goto tx_error;
 
-	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET, cp->af)))
+	switch (tun_type) {
+	case IP_VS_CONN_F_TUNNEL_TYPE_IPIP:
+		gso_type = __tun_gso_type_mask(AF_INET, cp->af);
+	case IP_VS_CONN_F_TUNNEL_TYPE_GUE:
+		gso_type = SKB_GSO_UDP_TUNNEL;
+	}
+
+	if (iptunnel_handle_offloads(skb, gso_type))
 		goto tx_error;
 
 	skb->transport_header = skb->network_header;
 
+	switch (tun_type) {
+	case IP_VS_CONN_F_TUNNEL_TYPE_GUE:
+		__build_gue_header(dev_net(tdev), skb, cp, &next_protocol);
+	}
+
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
@@ -1112,6 +1169,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct ipv6hdr  *iph;		/* Our new IP header */
 	unsigned int max_headroom;	/* The extra header space needed */
 	int ret, local;
+	int tun_type, gso_type;
 
 	EnterFunction(10);
 
@@ -1121,7 +1179,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
 				      IP_VS_RT_MODE_TUNNEL);
-	if (local < 0)
+	if (!cp->dest || local < 0)
 		goto tx_error;
 	if (local)
 		return ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 1);
@@ -1134,17 +1192,36 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 */
 	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct ipv6hdr);
 
+	tun_type = atomic_read(&cp->dest->tun_type);
+
+	switch (tun_type) {
+	case IP_VS_CONN_F_TUNNEL_TYPE_GUE:
+		max_headroom += sizeof(struct udphdr) + sizeof(struct guehdr);
+	}
+
 	skb = ip_vs_prepare_tunneled_skb(skb, cp->af, max_headroom,
 					 &next_protocol, &payload_len,
 					 &dsfield, &ttl, NULL);
 	if (IS_ERR(skb))
 		goto tx_error;
 
-	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET6, cp->af)))
+	switch (tun_type) {
+	case IP_VS_CONN_F_TUNNEL_TYPE_IPIP:
+		gso_type = __tun_gso_type_mask(AF_INET, cp->af);
+	case IP_VS_CONN_F_TUNNEL_TYPE_GUE:
+		gso_type = SKB_GSO_UDP_TUNNEL;
+	}
+
+	if (iptunnel_handle_offloads(skb, gso_type))
 		goto tx_error;
 
 	skb->transport_header = skb->network_header;
 
+	switch (tun_type) {
+	case IP_VS_CONN_F_TUNNEL_TYPE_GUE:
+		__build_gue_header(dev_net(tdev), skb, cp, &next_protocol);
+	}
+
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-- 
2.21.0

