From: Simon Horman <horms@verge.net.au>
Subject: [patch v2.2 1/4] [PATCH v2.1 1/4] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Sat, 01 May 2010 13:20:15 +1000
Message-ID: <20100501032120.298829234@vergenet.net>
References: <20100501032014.406353538@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

From:	Hannes Eder <heder@google.com>

This implements the kernel-space side of the netfilter matcher
xt_ipvs.

Signed-off-by: Hannes Eder <heder@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

 include/linux/netfilter/xt_ipvs.h |   25 +++++
 net/netfilter/Kconfig             |    9 ++
 net/netfilter/Makefile            |    1 
 net/netfilter/ipvs/ip_vs_proto.c  |    1 
 net/netfilter/xt_ipvs.c           |  187 +++++++++++++++++++++++++++++++++++++
 5 files changed, 223 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ipvs.h
 create mode 100644 net/netfilter/xt_ipvs.c

Index: nf-next-2.6/include/linux/netfilter/xt_ipvs.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ nf-next-2.6/include/linux/netfilter/xt_ipvs.h	2010-04-29 20:11:53.000000000 +0900
@@ -0,0 +1,25 @@
+#ifndef _XT_IPVS_H
+#define _XT_IPVS_H 1
+
+#define XT_IPVS_IPVS_PROPERTY	(1 << 0) /* all other options imply this one */
+#define XT_IPVS_PROTO		(1 << 1)
+#define XT_IPVS_VADDR		(1 << 2)
+#define XT_IPVS_VPORT		(1 << 3)
+#define XT_IPVS_DIR		(1 << 4)
+#define XT_IPVS_METHOD		(1 << 5)
+#define XT_IPVS_VPORTCTL	(1 << 6)
+#define XT_IPVS_MASK		((1 << 7) - 1)
+#define XT_IPVS_ONCE_MASK	(XT_IPVS_MASK & ~XT_IPVS_IPVS_PROPERTY)
+
+struct xt_ipvs_mtinfo {
+	union nf_inet_addr	vaddr, vmask;
+	__be16			vport;
+	__u16			l4proto;
+	__u16			fwd_method;
+	__be16			vportctl;
+
+	__u8			invert;
+	__u8			bitmask;
+};
+
+#endif /* _XT_IPVS_H */
Index: nf-next-2.6/net/netfilter/Kconfig
===================================================================
--- nf-next-2.6.orig/net/netfilter/Kconfig	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/net/netfilter/Kconfig	2010-04-29 20:11:53.000000000 +0900
@@ -703,6 +703,15 @@ config NETFILTER_XT_MATCH_IPRANGE
 
 	If unsure, say M.
 
+config NETFILTER_XT_MATCH_IPVS
+	tristate '"ipvs" match support'
+	depends on IP_VS
+	depends on NETFILTER_ADVANCED
+	help
+	  This option allows you to match against IPVS properties of a packet.
+
+	  If unsure, say N.
+
 config NETFILTER_XT_MATCH_LENGTH
 	tristate '"length" match support'
 	depends on NETFILTER_ADVANCED
Index: nf-next-2.6/net/netfilter/Makefile
===================================================================
--- nf-next-2.6.orig/net/netfilter/Makefile	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/net/netfilter/Makefile	2010-04-29 20:11:53.000000000 +0900
@@ -73,6 +73,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_HASHLIMI
 obj-$(CONFIG_NETFILTER_XT_MATCH_HELPER) += xt_helper.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_HL) += xt_hl.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_IPRANGE) += xt_iprange.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_IPVS) += xt_ipvs.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LENGTH) += xt_length.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) += xt_mac.o
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_proto.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_proto.c	2010-04-29 20:11:51.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_proto.c	2010-04-29 20:11:53.000000000 +0900
@@ -97,6 +97,7 @@ struct ip_vs_protocol * ip_vs_proto_get(
 
 	return NULL;
 }
+EXPORT_SYMBOL(ip_vs_proto_get);
 
 
 /*
Index: nf-next-2.6/net/netfilter/xt_ipvs.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ nf-next-2.6/net/netfilter/xt_ipvs.c	2010-04-29 20:11:53.000000000 +0900
@@ -0,0 +1,187 @@
+/*
+ *	xt_ipvs - kernel module to match IPVS connection properties
+ *
+ *	Author: Hannes Eder <heder@google.com>
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/spinlock.h>
+#include <linux/skbuff.h>
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#endif
+#include <linux/ip_vs.h>
+#include <linux/types.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_ipvs.h>
+#include <net/netfilter/nf_conntrack.h>
+
+#include <net/ip_vs.h>
+
+MODULE_AUTHOR("Hannes Eder <heder@google.com>");
+MODULE_DESCRIPTION("Xtables: match IPVS connection properties");
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
+static bool ipvs_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	const struct xt_ipvs_mtinfo *data = par->matchinfo;
+	/* ipvs_mt_check ensures that family is only NFPROTO_IPV[46]. */
+	const u_int8_t family = par->family;
+	struct ip_vs_iphdr iph;
+	struct ip_vs_protocol *pp;
+	struct ip_vs_conn *cp;
+	bool match = true;
+
+	if (data->bitmask == XT_IPVS_IPVS_PROPERTY) {
+		match = skb->ipvs_property ^
+			!!(data->invert & XT_IPVS_IPVS_PROPERTY);
+		goto out;
+	}
+
+	/* other flags than XT_IPVS_IPVS_PROPERTY are set */
+	if (!skb->ipvs_property) {
+		match = false;
+		goto out;
+	}
+
+	ip_vs_fill_iphdr(family, skb_network_header(skb), &iph);
+
+	if (data->bitmask & XT_IPVS_PROTO)
+		if ((iph.protocol == data->l4proto) ^
+		    !(data->invert & XT_IPVS_PROTO)) {
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
+	cp = pp->conn_out_get(family, skb, pp, &iph, iph.len, 1 /* inverse */);
+	if (unlikely(cp == NULL)) {
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
+		if ((cp->vport == data->vport) ^
+		    !(data->invert & XT_IPVS_VPORT)) {
+			match = false;
+			goto out_put_cp;
+		}
+
+	if (data->bitmask & XT_IPVS_VPORTCTL)
+		if ((cp->control != NULL &&
+		     cp->control->vport == data->vportctl) ^
+		    !(data->invert & XT_IPVS_VPORTCTL)) {
+			match = false;
+			goto out_put_cp;
+		}
+
+	if (data->bitmask & XT_IPVS_DIR) {
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
+
+		if (ct == NULL || ct == &nf_conntrack_untracked) {
+			match = false;
+			goto out_put_cp;
+		}
+
+		if ((ctinfo >= IP_CT_IS_REPLY) ^
+		    !!(data->invert & XT_IPVS_DIR)) {
+			match = false;
+			goto out_put_cp;
+		}
+	}
+
+	if (data->bitmask & XT_IPVS_METHOD)
+		if (((cp->flags & IP_VS_CONN_F_FWD_MASK) == data->fwd_method) ^
+		    !(data->invert & XT_IPVS_METHOD)) {
+			match = false;
+			goto out_put_cp;
+		}
+
+	if (data->bitmask & XT_IPVS_VADDR) {
+		if (ipvs_mt_addrcmp(&cp->vaddr, &data->vaddr,
+				    &data->vmask, family) ^
+		    !(data->invert & XT_IPVS_VADDR)) {
+			match = false;
+			goto out_put_cp;
+		}
+	}
+
+out_put_cp:
+	__ip_vs_conn_put(cp);
+out:
+	pr_debug("match=%d\n", match);
+	return match;
+}
+
+static bool ipvs_mt_check(const struct xt_mtchk_param *par)
+{
+	if (par->family != NFPROTO_IPV4
+#ifdef CONFIG_IP_VS_IPV6
+	    && par->family != NFPROTO_IPV6
+#endif
+		) {
+		pr_info("protocol family %u not supported\n", par->family);
+		return false;
+	}
+
+	return true;
+}
+
+static struct xt_match xt_ipvs_mt_reg __read_mostly = {
+	.name       = "ipvs",
+	.revision   = 0,
+	.family     = NFPROTO_UNSPEC,
+	.match      = ipvs_mt,
+	.checkentry = ipvs_mt_check,
+	.matchsize  = XT_ALIGN(sizeof(struct xt_ipvs_mtinfo)),
+	.me         = THIS_MODULE,
+};
+
+static int __init ipvs_mt_init(void)
+{
+	return xt_register_match(&xt_ipvs_mt_reg);
+}
+
+static void __exit ipvs_mt_exit(void)
+{
+	xt_unregister_match(&xt_ipvs_mt_reg);
+}
+
+module_init(ipvs_mt_init);
+module_exit(ipvs_mt_exit);

