From: Hannes Eder <heder@google.com>
Subject: [RFC][PATCH 2/5] netfilter: xt_ipvs (netfilter matcher for ipvs)
Date: Mon, 27 Jul 2009 15:46:21 +0200
Message-ID: <20090727134621.12897.75558.stgit@jazzy.zrh.corp.google.com>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248708680; bh=D0tzsWBBukKExLmfqOESwaIN7h0=;
	h=DomainKey-Signature:Subject:To:From:Cc:Date:Message-ID:
	 In-Reply-To:References:User-Agent:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=F+rNlCadp4eJnYbrHN
	joHV7Gz4Jr7JneuvBsn/tcWM0T1nX5iaiAnyOAVjbPntaNMa+CMpD8ELG9SgJq3c595
	g==
In-Reply-To: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

From: Hannes Eder <hannes@hanneseder.net>

This implements the kernel-space side of the iptables matcher xt_ipvs.

Signed-off-by: Hannes Eder <heder@google.com>

 include/linux/netfilter/xt_ipvs.h |   32 +++++++
 net/netfilter/Kconfig             |    8 ++
 net/netfilter/Makefile            |    1 
 net/netfilter/ipvs/ip_vs_proto.c  |    1 
 net/netfilter/xt_ipvs.c           |  171 +++++++++++++++++++++++++++++++++++++
 5 files changed, 213 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ipvs.h
 create mode 100644 net/netfilter/xt_ipvs.c

diff --git a/include/linux/netfilter/xt_ipvs.h b/include/linux/netfilter/xt_ipvs.h
new file mode 100644
index 0000000..3a70289
--- /dev/null
+++ b/include/linux/netfilter/xt_ipvs.h
@@ -0,0 +1,32 @@
+#ifndef _XT_IPVS_H
+#define _XT_IPVS_H 1
+
+#ifndef _IP_VS_H
+#define IP_VS_CONN_F_FWD_MASK	0x0007		/* mask for the fwd methods */
+#define IP_VS_CONN_F_MASQ	0x0000		/* masquerading/NAT */
+#define IP_VS_CONN_F_LOCALNODE	0x0001		/* local node */
+#define IP_VS_CONN_F_TUNNEL	0x0002		/* tunneling */
+#define IP_VS_CONN_F_DROUTE	0x0003		/* direct routing */
+#define IP_VS_CONN_F_BYPASS	0x0004		/* cache bypass */
+#endif
+
+#define XT_IPVS_IPVS		0x01 /* this is implied by all other options */
+#define XT_IPVS_PROTO		0x02
+#define XT_IPVS_VADDR		0x04
+#define XT_IPVS_VPORT		0x08
+#define XT_IPVS_DIR		0x10
+#define XT_IPVS_METHOD		0x20
+#define XT_IPVS_MASK		(0x40 - 1)
+#define XT_IPVS_ONCE_MASK	(XT_IPVS_MASK & ~XT_IPVS_IPVS)
+
+struct xt_ipvs {
+	union nf_inet_addr	vaddr, vmask;
+	__be16			vport;
+	u_int16_t		l4proto;
+	u_int16_t		fwd_method;
+
+	u_int8_t invert;
+	u_int8_t bitmask;
+};
+
+#endif /* _XT_IPVS_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index cb3ad74..677a880 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -678,6 +678,14 @@ config NETFILTER_XT_MATCH_IPRANGE
 
 	If unsure, say M.
 
+config NETFILTER_XT_MATCH_IPVS
+	tristate '"ipvs" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  This option allows you to match against ipvs properties of a packet.
+
+          To compile it as a module, choos M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_LENGTH
 	tristate '"length" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 6282060..1c18e80 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -72,6 +72,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_HASHLIMIT) += xt_hashlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HELPER) += xt_helper.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HL) += xt_hl.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_IPRANGE) += xt_iprange.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_IPVS) += xt_ipvs.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) += xt_mac.o
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index a01520e..84bf4e6 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -94,6 +94,7 @@ struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto)
 
 	return NULL;
 }
+EXPORT_SYMBOL(ip_vs_proto_get);
 
 
 /*
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
new file mode 100644
index 0000000..00373d9
--- /dev/null
+++ b/net/netfilter/xt_ipvs.c
@@ -0,0 +1,171 @@
+/*
+ *	xt_ipvs - kernel module to match ipvs properties of a packet
+ *
+ *	Author: Hannes Eder <heder@google.com>
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/spinlock.h>
+#include <linux/skbuff.h>
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#endif
+#include <linux/types.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_ipvs.h>
+
+#include <net/ip_vs.h>
+
+MODULE_AUTHOR("Hannes Eder <heder@google.com>");
+MODULE_DESCRIPTION("Xtables: match ipvs");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_ipvs");
+MODULE_ALIAS("ip6t_ipvs");
+
+/* borrowed from xt_conntrack */
+static bool ipvs_mt_addrcmp(const union nf_inet_addr *kaddr,
+			    const union nf_inet_addr *uaddr,
+			    const union nf_inet_addr *umask,
+			    unsigned int l3proto)
+{
+	if (l3proto == NFPROTO_IPV4)
+		return ((kaddr->ip ^ uaddr->ip) & umask->ip) == 0;
+#ifdef CONFIG_IP_VS_IPV6
+	else if (l3proto == NFPROTO_IPV6)
+		return ipv6_masked_addr_cmp(&kaddr->in6, &umask->in6,
+		       &uaddr->in6) == 0;
+#endif
+	else
+		return false;
+}
+
+bool ipvs_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	const struct xt_ipvs *data = par->matchinfo;
+	const u_int8_t family = par->family;
+	struct ip_vs_iphdr iph;
+	struct ip_vs_protocol *pp;
+	struct ip_vs_conn *cp;
+	int af;
+	bool match = true;
+
+	if (data->bitmask == XT_IPVS_IPVS) {
+		match = !!(skb->ipvs_property)
+			^ !!(data->invert & XT_IPVS_IPVS);
+		goto out;
+	}
+
+	/* other flags than XT_IPVS_IPVS are set */
+	if (!skb->ipvs_property) {
+		match = false;
+		goto out;
+	}
+
+	switch (skb->protocol) {
+	case  htons(ETH_P_IP):
+		af = AF_INET;
+		break;
+#ifdef CONFIG_IP_VS_IPV6
+	case  htons(ETH_P_IPV6):
+		af = AF_INET6;
+		break;
+#endif
+	default:
+		match = false;
+		goto out;
+	}
+
+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+
+	if (data->bitmask & XT_IPVS_PROTO)
+		if ((iph.protocol == data->l4proto)
+		    ^ !(data->invert & XT_IPVS_PROTO)) {
+			match = false;
+			goto out;
+		}
+
+	pp = ip_vs_proto_get(iph.protocol);
+	if (unlikely(!pp)) {
+		match = false;
+		goto out;
+	}
+
+	/*
+	 * Check if the packet belongs to an existing entry
+	 */
+	/* TODO: why does it only match in inverse? */
+	cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 1 /* inverse */);
+	if (unlikely(!cp)) {
+		match = false;
+		goto out;
+	}
+
+	/*
+	 * We found a connection, i.e. ct != 0, make sure to call
+	 * __ip_vs_conn_put before returning.  In our case jump to out_put_con.
+	 */
+
+	if (data->bitmask & XT_IPVS_VPORT)
+		if ((cp->vport == data->vport)
+		    ^ !(data->invert & XT_IPVS_VPORT)) {
+			match = false;
+			goto out_put_ct;
+		}
+
+	if (data->bitmask & XT_IPVS_DIR) {
+		/* TODO: implement */
+	}
+
+	if (data->bitmask & XT_IPVS_METHOD)
+		if (((cp->flags & IP_VS_CONN_F_FWD_MASK) == data->fwd_method)
+		    ^ !(data->invert & XT_IPVS_METHOD)) {
+			match = false;
+			goto out_put_ct;
+		}
+
+	if (data->bitmask & XT_IPVS_VADDR) {
+		if (af != family) {
+			match = false;
+			goto out_put_ct;
+		}
+
+		if (ipvs_mt_addrcmp(&cp->vaddr, &data->vaddr, &data->vmask, af)
+		    ^ !(data->invert & XT_IPVS_VADDR)) {
+			match = false;
+			goto out_put_ct;
+		}
+	}
+
+out_put_ct:
+	__ip_vs_conn_put(cp);
+out:
+	return match;
+}
+EXPORT_SYMBOL(ipvs_mt);
+
+static struct xt_match xt_ipvs_mt_reg[] __read_mostly = {
+	{
+		.name       = "ipvs",
+		.revision   = 0,
+		.family     = NFPROTO_UNSPEC,
+		.match      = ipvs_mt,
+		.matchsize  = sizeof(struct xt_ipvs),
+		.me         = THIS_MODULE,
+	},
+};
+
+static int __init ipvs_mt_init(void)
+{
+	return xt_register_matches(xt_ipvs_mt_reg,
+				   ARRAY_SIZE(xt_ipvs_mt_reg));
+}
+
+static void __exit ipvs_mt_exit(void)
+{
+	xt_unregister_matches(xt_ipvs_mt_reg,
+			      ARRAY_SIZE(xt_ipvs_mt_reg));
+}
+
+module_init(ipvs_mt_init);
+module_exit(ipvs_mt_exit);

