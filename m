From: Hannes Eder <heder@google.com>
Subject: [RFC][PATCH 5/5] libxt_ipvs: user space lib for netfilter matcher xt_ipvs
Date: Mon, 27 Jul 2009 15:48:52 +0200
Message-ID: <20090727134852.13319.39035.stgit@jazzy.zrh.corp.google.com>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753051AbZG0PcK@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248708684; bh=JjTLtiOa8K6POoBPV6VY73F6UM8=;
	h=DomainKey-Signature:Subject:To:From:Cc:Date:Message-ID:
	 In-Reply-To:References:User-Agent:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=idgNuZyl7MH2KUNBuq
	PgqP8qwLxlK/Vzul0HYNUK2YxiuKMHq8FUr4liYqv2uVAEUwdOanWBQ3Biycb4XMlGC
	w==
In-Reply-To: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Hannes Eder <heder@google.com>

 extensions/libxt_ipvs.c           |  350 +++++++++++++++++++++++++++++++++++++
 extensions/libxt_ipvs.man         |    7 +
 include/linux/netfilter/xt_ipvs.h |   32 +++
 3 files changed, 389 insertions(+), 0 deletions(-)
 create mode 100644 extensions/libxt_ipvs.c
 create mode 100644 extensions/libxt_ipvs.man
 create mode 100644 include/linux/netfilter/xt_ipvs.h

diff --git a/extensions/libxt_ipvs.c b/extensions/libxt_ipvs.c
new file mode 100644
index 0000000..dc48aee
--- /dev/null
+++ b/extensions/libxt_ipvs.c
@@ -0,0 +1,350 @@
+/* Shared library add-on to iptables to add ipvs matching.
+ *
+ * Detailed doc is in the kernel module source
+ * net/netfilter/xt_ipvs.c
+ *
+ * Author: Hannes Eder <heder@google.com>
+ */
+#include <sys/types.h>
+#include <assert.h>
+#include <ctype.h>
+#include <errno.h>
+#include <getopt.h>
+#include <netdb.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <xtables.h>
+#include <linux/netfilter/xt_ipvs.h>
+
+
+static const struct option ipvs_mt_opts[] = {
+	{ .name = "ipvs",    .has_arg = false, .val = '0' },
+	{ .name = "vproto",  .has_arg = true,  .val = '1' },
+	{ .name = "vaddr",   .has_arg = true,  .val = '2' },
+	{ .name = "vport",   .has_arg = true,  .val = '3' },
+	{ .name = "vdir",    .has_arg = true,  .val = '4' },
+	{ .name = "vmethod", .has_arg = true,  .val = '5' },
+	{ .name = NULL }
+};
+
+static void ipvs_mt_help(void)
+{
+	printf(
+"ipvs match options:\n"
+"[!] --ipvs\n"
+"\n"
+"Any of the following options implies --ipvs (even negated)\n"
+"[!] --vproto protocol\n"
+"[!] --vaddr address[/mask]\n"
+"[!] --vport port\n"
+"    --vdir {ORIGINAL|REPLY}\n"
+"[!] --vmethod {GATE|IPIP|MASQ}\n"
+		);
+}
+
+static void ipvs_mt_parse_addr_and_mask(const char *arg,
+					union nf_inet_addr *address,
+					union nf_inet_addr *mask,
+					unsigned int family)
+{
+	struct in_addr *addr = NULL;
+	struct in6_addr *addr6 = NULL;
+	unsigned int naddrs = 0;
+
+	if (family == NFPROTO_IPV4) {
+		xtables_ipparse_any(arg, &addr, &mask->in, &naddrs);
+		if (naddrs > 1)
+			xtables_error(PARAMETER_PROBLEM,
+				      "multiple IP addresses not allowed");
+		if (naddrs == 1)
+			memcpy(&address->in, addr, sizeof(*addr));
+	} else if (family == NFPROTO_IPV6) {
+		xtables_ip6parse_any(arg, &addr6, &mask->in6, &naddrs);
+		if (naddrs > 1)
+			xtables_error(PARAMETER_PROBLEM,
+				      "multiple IP addresses not allowed");
+		if (naddrs == 1)
+			memcpy(&address->in6, addr6, sizeof(*addr6));
+	} else {
+		/* Hu? */
+		assert(false);
+	}
+}
+
+/* Function which parses command options; returns true if it ate an option */
+static int ipvs_mt_parse(int c, char **argv, int invert, unsigned int *flags,
+			 const void *entry, struct xt_entry_match **match,
+			 unsigned int family)
+{
+	struct xt_ipvs *data = (void *)(*match)->data;
+	char *p = NULL;
+	u_int8_t op = 0;
+
+	if ('0' <= c && c <= '5') {
+		int ops[] = {
+			XT_IPVS_IPVS,
+			XT_IPVS_PROTO,
+			XT_IPVS_VADDR,
+			XT_IPVS_VPORT,
+			XT_IPVS_DIR,
+			XT_IPVS_METHOD
+		};
+		op = ops[c - '0'];
+	} else
+		return 0;
+
+	if (*flags & op & XT_IPVS_ONCE_MASK)
+		goto multiple_use;
+
+	switch (c) {
+	case '0': /* --ipvs */
+		/* Nothing to do here. */
+		break;
+
+	case '1': /* --vproto */
+		/* Canonicalize into lower case */
+		for (p = optarg; *p != '\0'; ++p)
+			*p = tolower(*p);
+
+		data->l4proto = xtables_parse_protocol(optarg);
+		break;
+
+	case '2': /* --vaddr */
+		ipvs_mt_parse_addr_and_mask(optarg, &data->vaddr,
+					    &data->vmask, family);
+		break;
+
+	case '3': /* --vport */
+		data->vport = htons(xtables_parse_port(optarg, "tcp"));
+		break;
+
+	case '4': /* --vdir */
+		xtables_param_act(XTF_NO_INVERT, "ipvs", "--vdir", invert);
+		if (strcasecmp(optarg, "ORIGINAL") == 0) {
+			data->bitmask |= XT_IPVS_DIR;
+			data->invert   &= ~XT_IPVS_DIR;
+		} else if (strcasecmp(optarg, "REPLY") == 0) {
+			data->bitmask |= XT_IPVS_DIR;
+			data->invert  |= XT_IPVS_DIR;
+		} else {
+			xtables_param_act(XTF_BAD_VALUE,
+					  "ipvs", "--vdir", optarg);
+		}
+		break;
+
+	case '5': /* --vmethod */
+		if (strcasecmp(optarg, "GATE") == 0)
+			data->fwd_method = IP_VS_CONN_F_DROUTE;
+		else if (strcasecmp(optarg, "IPIP") == 0)
+			data->fwd_method = IP_VS_CONN_F_TUNNEL;
+		else if (strcasecmp(optarg, "MASQ") == 0)
+			data->fwd_method = IP_VS_CONN_F_MASQ;
+		else
+			xtables_param_act(XTF_BAD_VALUE,
+					  "ipvs", "--vmethod", optarg);
+		break;
+
+	default:
+		/* Hu? How did we came here? */
+		assert(false);
+		return 0;
+	}
+
+	if (op & XT_IPVS_ONCE_MASK) {
+		if (data->invert & XT_IPVS_IPVS)
+			xtables_error(PARAMETER_PROBLEM,
+				      "! --ipvs can not be together with"
+				      " other options");
+		data->bitmask |= XT_IPVS_IPVS;
+	}
+
+	data->bitmask |= op;
+	if (invert)
+		data->invert |= op;
+	*flags |= op;
+	return 1;
+
+multiple_use:
+	xtables_error(PARAMETER_PROBLEM,
+		      "multiple use of the same ipvs option is not allowed");
+}
+
+static int ipvs_mt4_parse(int c, char **argv, int invert, unsigned int *flags,
+			  const void *entry, struct xt_entry_match **match)
+{
+	return ipvs_mt_parse(c, argv, invert, flags, entry, match,
+			     NFPROTO_IPV4);
+}
+
+static int ipvs_mt6_parse(int c, char **argv, int invert, unsigned int *flags,
+			  const void *entry, struct xt_entry_match **match)
+{
+	return ipvs_mt_parse(c, argv, invert, flags, entry, match,
+			     NFPROTO_IPV6);
+}
+
+static void ipvs_mt_check(unsigned int flags)
+{
+	if (flags == 0)
+		xtables_error(PARAMETER_PROBLEM,
+			      "ipvs: At least one option is required");
+}
+
+/* Shamelessly copied from libxt_conntrack.c */
+static void
+ipvs_mt_dump_addr(const union nf_inet_addr *addr,
+		  const union nf_inet_addr *mask,
+		  unsigned int family, bool numeric)
+{
+	char buf[BUFSIZ];
+
+	if (family == NFPROTO_IPV4) {
+		if (!numeric && addr->ip == 0) {
+			printf("anywhere ");
+			return;
+		}
+		if (numeric)
+			strcpy(buf, xtables_ipaddr_to_numeric(&addr->in));
+		else
+			strcpy(buf, xtables_ipaddr_to_anyname(&addr->in));
+		strcat(buf, xtables_ipmask_to_numeric(&mask->in));
+		printf("%s ", buf);
+	} else if (family == NFPROTO_IPV6) {
+		if (!numeric && addr->ip6[0] == 0 && addr->ip6[1] == 0 &&
+		    addr->ip6[2] == 0 && addr->ip6[3] == 0) {
+			printf("anywhere ");
+			return;
+		}
+		if (numeric)
+			strcpy(buf, xtables_ip6addr_to_numeric(&addr->in6));
+		else
+			strcpy(buf, xtables_ip6addr_to_anyname(&addr->in6));
+		strcat(buf, xtables_ip6mask_to_numeric(&mask->in6));
+		printf("%s ", buf);
+	}
+}
+
+static void ipvs_mt_dump(const void *ip, const struct xt_ipvs *data,
+			 unsigned int family, bool numeric, const char *prefix)
+{
+	if (data->bitmask == XT_IPVS_IPVS) {
+		if (data->invert & XT_IPVS_IPVS)
+			printf("! ");
+		printf("%sipvs ", prefix);
+	}
+
+	if (data->bitmask & XT_IPVS_PROTO) {
+		if (data->invert & XT_IPVS_PROTO)
+			printf("! ");
+		printf("%sproto %u ", prefix, data->l4proto);
+	}
+
+	if (data->bitmask & XT_IPVS_VADDR) {
+		if (data->invert & XT_IPVS_VADDR)
+			printf("! ");
+
+		printf("%svaddr ", prefix);
+		ipvs_mt_dump_addr(&data->vaddr, &data->vmask, family, numeric);
+	}
+
+	if (data->bitmask & XT_IPVS_VPORT) {
+		if (data->invert & XT_IPVS_VPORT)
+			printf("! ");
+
+		printf("%svport %u ", prefix, ntohs(data->vport));
+	}
+
+	if (data->bitmask & XT_IPVS_DIR) {
+		if (data->invert & XT_IPVS_DIR)
+			printf("%svdir REPLY ", prefix);
+		else
+			printf("%svdir ORIGINAL ", prefix);
+	}
+
+	if (data->bitmask & XT_IPVS_METHOD) {
+		if (data->invert & XT_IPVS_METHOD)
+			printf("! ");
+
+		printf("%svmethod ", prefix);
+		switch (data->fwd_method) {
+		case IP_VS_CONN_F_DROUTE:
+			printf("GATE ");
+			break;
+		case IP_VS_CONN_F_TUNNEL:
+			printf("IPIP ");
+			break;
+		case IP_VS_CONN_F_MASQ:
+			printf("MASQ ");
+			break;
+		default:
+			/* Hu? */
+			printf("UNKNOWN ");
+			break;
+		}
+	}
+
+}
+
+static void ipvs_mt4_print(const void *ip, const struct xt_entry_match *match,
+			   int numeric)
+{
+	const struct xt_ipvs *data = (const void *)match->data;
+	ipvs_mt_dump(ip, data, NFPROTO_IPV4, numeric, "");
+}
+
+static void ipvs_mt6_print(const void *ip, const struct xt_entry_match *match,
+			   int numeric)
+{
+	const struct xt_ipvs *data = (const void *)match->data;
+	ipvs_mt_dump(ip, data, NFPROTO_IPV6, numeric, "");
+}
+
+static void ipvs_mt4_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_ipvs *data = (const void *)match->data;
+	ipvs_mt_dump(ip, data, NFPROTO_IPV4, true, "--");
+}
+
+static void ipvs_mt6_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_ipvs *data = (const void *)match->data;
+	ipvs_mt_dump(ip, data, NFPROTO_IPV6, true, "--");
+}
+
+static struct xtables_match ipvs_matches_reg[] = {
+	{
+		.version       = XTABLES_VERSION,
+		.name          = "ipvs",
+		.revision      = 0,
+		.family        = NFPROTO_IPV4,
+		.size          = XT_ALIGN(sizeof(struct xt_ipvs)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_ipvs)),
+		.help          = ipvs_mt_help,
+		.parse         = ipvs_mt4_parse,
+		.final_check   = ipvs_mt_check,
+		.print         = ipvs_mt4_print,
+		.save          = ipvs_mt4_save,
+		.extra_opts    = ipvs_mt_opts,
+	},
+	{
+		.version       = XTABLES_VERSION,
+		.name          = "ipvs",
+		.revision      = 0,
+		.family        = NFPROTO_IPV6,
+		.size          = XT_ALIGN(sizeof(struct xt_ipvs)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_ipvs)),
+		.help          = ipvs_mt_help,
+		.parse         = ipvs_mt6_parse,
+		.final_check   = ipvs_mt_check,
+		.print         = ipvs_mt6_print,
+		.save          = ipvs_mt6_save,
+		.extra_opts    = ipvs_mt_opts,
+	},
+};
+
+void _init(void)
+{
+	xtables_register_matches(ipvs_matches_reg,
+				 ARRAY_SIZE(ipvs_matches_reg));
+}
diff --git a/extensions/libxt_ipvs.man b/extensions/libxt_ipvs.man
new file mode 100644
index 0000000..2c842d6
--- /dev/null
+++ b/extensions/libxt_ipvs.man
@@ -0,0 +1,7 @@
+ipvs tests where the packet was modified by IPVS, i.e. is the
+skb_buff->ipvs_property set.
+.TP
+[\fB!\fP] \fB--ipvs
+Does the packet have to IPVS property?
+
+TODO: Write proper documentation.
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
