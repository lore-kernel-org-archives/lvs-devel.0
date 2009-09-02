From: Hannes Eder <heder@google.com>
Subject: [PATCH 1/3] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Wed,  2 Sep 2009 16:39:22 +0200 (CEST)
Message-ID: <20090902101527.11561.59498.stgit@jazzy.zrh.corp.google.com>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1251902376; bh=fpeMPcT9IVT9HwN51eSw0T7INqg=;
	h=DomainKey-Signature:Subject:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:
	 Cc:From:Message-ID:In-Reply-To:References:User-Agent:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Date:X-System-Of-Record;
	b=mJV0TI1H7drwnF7CQd8L3fjHV06WQLZQIQXxqNzaYuZ39TNY24PgjPmnw63AITwE+
	huP7lWkugZpvSP+okE4Mw==
In-Reply-To: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-1?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Jan Engelhardt <jengelh@medozas.de>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

This implements the kernel-space side of the netfilter matcher
xt_ipvs.

Signed-off-by: Hannes Eder <heder@google.com>
---

 include/linux/netfilter/xt_ipvs.h |   23 +++++
 net/netfilter/Kconfig             |    9 ++
 net/netfilter/Makefile            |    1 
 net/netfilter/ipvs/ip_vs_proto.c  |    1 
 net/netfilter/xt_ipvs.c           |  183 +++++++++++++++++++++++++++++++++++++
 5 files changed, 217 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ipvs.h
 create mode 100644 net/netfilter/xt_ipvs.c

diff --git a/include/linux/netfilter/xt_ipvs.h b/include/linux/netfilter/xt_ipvs.h
new file mode 100644
index 0000000..eb09759
--- /dev/null
+++ b/include/linux/netfilter/xt_ipvs.h
@@ -0,0 +1,23 @@
+#ifndef _XT_IPVS_H
+#define _XT_IPVS_H 1
+
+#define XT_IPVS_IPVS_PROPERTY	0x01 /* this is implied by all other options */
+#define XT_IPVS_PROTO		0x02
+#define XT_IPVS_VADDR		0x04
+#define XT_IPVS_VPORT		0x08
+#define XT_IPVS_DIR		0x10
+#define XT_IPVS_METHOD		0x20
+#define XT_IPVS_MASK		(0x40 - 1)
+#define XT_IPVS_ONCE_MASK	(XT_IPVS_MASK & ~XT_IPVS_IPVS_PROPERTY)
+
+struct xt_ipvs {
+	union nf_inet_addr	vaddr, vmask;
+	__be16			vport;
+	__u16			l4proto;
+	__u16			fwd_method;
+
+	__u8			invert;
+	__u8			bitmask;
+};
+
+#endif /* _XT_IPVS_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 634d14a..fc35bd6 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -678,6 +678,15 @@ config NETFILTER_XT_MATCH_IPRANGE
 
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
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 49f62ee..ff95372 100644
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
index 3e76716..db083c3 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -97,6 +97,7 @@ struct ip_vs_protocol * ip_vs_proto_get(unsigned short proto)
 
 	return NULL;
 }
+EXPORT_SYMBOL(ip_vs_proto_get);
 
 
 /*
diff --git a/net/netfilter/xt_ipvs.c b/net/netfilter/xt_ipvs.c
new file mode 100644
index 0000000..579b053
--- /dev/null
+++ b/net/netfilter/xt_ipvs.c
@@ -0,0 +1,183 @@
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
+	cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 1 /* inverse */);
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
+		if (af != family) {
+			match = false;
+			goto out_put_cp;
+		}
+
+		if (ipvs_mt_addrcmp(&cp->vaddr, &data->vaddr,
+				    &data->vmask, af) ^
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
+static struct xt_match xt_ipvs_mt_reg __read_mostly = {
+	.name       = "ipvs",
+	.revision   = 0,
+	.family     = NFPROTO_UNSPEC,
+	.match      = ipvs_mt,
+	.matchsize  = sizeof(struct xt_ipvs),
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

