From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC][PATCH 2/5] netfilter: xt_ipvs (netfilter matcher for
 ipvs)
Date: Mon, 27 Jul 2009 20:35:38 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0907272017280.20984@fbirervta.pbzchgretzou.qr>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com> <20090727134621.12897.75558.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090727134621.12897.75558.stgit@jazzy.zrh.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Eder <heder@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org


On Monday 2009-07-27 15:46, Hannes Eder wrote:
>--- /dev/null
>+++ b/include/linux/netfilter/xt_ipvs.h
>@@ -0,0 +1,32 @@
>+#ifndef _XT_IPVS_H
>+#define _XT_IPVS_H 1
>+
>+#ifndef _IP_VS_H

Do the definitions (should probably be enums) exist in
very old <linux/ip_vs.h>? Then maybe you can get rid of them
from xt_ipvs.h.

>+#define IP_VS_CONN_F_FWD_MASK	0x0007		/* mask for the fwd methods */
>+#define IP_VS_CONN_F_MASQ	0x0000		/* masquerading/NAT */
>+#define IP_VS_CONN_F_LOCALNODE	0x0001		/* local node */
>+#define IP_VS_CONN_F_TUNNEL	0x0002		/* tunneling */
>+#define IP_VS_CONN_F_DROUTE	0x0003		/* direct routing */
>+#define IP_VS_CONN_F_BYPASS	0x0004		/* cache bypass */
>+#endif
>+
>+#define XT_IPVS_IPVS		0x01 /* this is implied by all other options */
>+#define XT_IPVS_PROTO		0x02
>+#define XT_IPVS_VADDR		0x04
>+#define XT_IPVS_VPORT		0x08
>+#define XT_IPVS_DIR		0x10
>+#define XT_IPVS_METHOD		0x20
>+#define XT_IPVS_MASK		(0x40 - 1)
>+#define XT_IPVS_ONCE_MASK	(XT_IPVS_MASK & ~XT_IPVS_IPVS)
>+
>+struct xt_ipvs {
>+	union nf_inet_addr	vaddr, vmask;
>+	__be16			vport;
>+	u_int16_t		l4proto;
>+	u_int16_t		fwd_method;
>+
>+	u_int8_t invert;
>+	u_int8_t bitmask;
>+};

As per the "Writing Netfilter modules" e-book, __u16/__u8 is required.

>+config NETFILTER_XT_MATCH_IPVS
>+	tristate '"ipvs" match support'
>+	depends on NETFILTER_ADVANCED
>+	help
>+	  This option allows you to match against ipvs properties of a packet.
>+
>+          To compile it as a module, choos M here.  If unsure, say N.
>+

IMHO the "to compile it as a module, choos[e] M" is a relict from
old times and should just be dropped. These days, I stupilate,
everyone knows that M makes modules. And if it doesnot, then
it's not allowed by Kconfig :>

>+MODULE_AUTHOR("Hannes Eder <heder@google.com>");
>+MODULE_DESCRIPTION("Xtables: match ipvs");

"Match IPVS connection properties" is what you previously stated,
and which I think is good. Use it here, too.

>+bool ipvs_mt(const struct sk_buff *skb, const struct xt_match_param *par)
>+{
>+	const struct xt_ipvs *data = par->matchinfo;
>+	const u_int8_t family = par->family;
>+	struct ip_vs_iphdr iph;
>+	struct ip_vs_protocol *pp;
>+	struct ip_vs_conn *cp;
>+	int af;
>+	bool match = true;
>+
>+	if (data->bitmask == XT_IPVS_IPVS) {
>+		match = !!(skb->ipvs_property)
>+			^ !!(data->invert & XT_IPVS_IPVS);
>+		goto out;
>+	}

XT_IPVS_IPVS? What's that supposed to tell me...
Anyway, this can be made much shorter, given that all following
the "out" label is a return:

	if (data->bitmask == XT_IPVS_IPVS)
		return skb->ipvs_property ^ !!(data->invert & XT_IPVS_IPVS);

>+	/* other flags than XT_IPVS_IPVS are set */
>+	if (!skb->ipvs_property) {
>+		match = false;
>+		goto out;
>+	}

	if (!skb->ipvs_property)
		return false;

>+	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
>+
>+	if (data->bitmask & XT_IPVS_PROTO)
>+		if ((iph.protocol == data->l4proto)
>+		    ^ !(data->invert & XT_IPVS_PROTO)) {
>+			match = false;
>+			goto out;
>+		}

		if (iph.protocol == data->l4proto ^
		    !(data->invert & XT_IPVS_PROTO))
			return false;

>+	pp = ip_vs_proto_get(iph.protocol);
>+	if (unlikely(!pp)) {
>+		match = false;
>+		goto out;
>+	}

	if (unlikely(pp == NULL))
		return false;

Only after here we really need goto (to put pp).

>+	/*
>+	 * Check if the packet belongs to an existing entry
>+	 */
>+	/* TODO: why does it only match in inverse? */

FIXME: Figure it out :)

>+	cp = pp->conn_out_get(af, skb, pp, &iph, iph.len, 1 /* inverse */);
>+	if (unlikely(!cp)) {
>+		match = false;
>+		goto out;
>+	}
>+
>+	/*
>+	 * We found a connection, i.e. ct != 0, make sure to call
>+	 * __ip_vs_conn_put before returning.  In our case jump to out_put_con.
>+	 */
>+
>+	if (data->bitmask & XT_IPVS_VPORT)
>+		if ((cp->vport == data->vport)
>+		    ^ !(data->invert & XT_IPVS_VPORT)) {
>+			match = false;
>+			goto out_put_ct;
>+		}
>+
>+	if (data->bitmask & XT_IPVS_DIR) {
>+		/* TODO: implement */

		/* Yes please */

>+	}
>+
>+	if (data->bitmask & XT_IPVS_METHOD)
>+		if (((cp->flags & IP_VS_CONN_F_FWD_MASK) == data->fwd_method)
>+		    ^ !(data->invert & XT_IPVS_METHOD)) {
>+			match = false;
>+			goto out_put_ct;
>+		}
>+
>+	if (data->bitmask & XT_IPVS_VADDR) {
>+		if (af != family) {
>+			match = false;
>+			goto out_put_ct;
>+		}
>+
>+		if (ipvs_mt_addrcmp(&cp->vaddr, &data->vaddr, &data->vmask, af)
>+		    ^ !(data->invert & XT_IPVS_VADDR)) {

I think the operator (^ in this case) always goes onto the same line as the ')'
((a) ^\n(b), not ((a)\n ^(b)), though some legacy code seems to do it
random so-so.)

>+	return match;
>+}
>+EXPORT_SYMBOL(ipvs_mt);

What will be using ipvs_mt?

>+static struct xt_match xt_ipvs_mt_reg[] __read_mostly = {
>+	{
>+		.name       = "ipvs",
>+		.revision   = 0,
>+		.family     = NFPROTO_UNSPEC,
>+		.match      = ipvs_mt,
>+		.matchsize  = sizeof(struct xt_ipvs),
>+		.me         = THIS_MODULE,
>+	},
>+};

There is just one element, so no strict need for the [] array.

