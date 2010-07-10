From: Simon Horman <horms@verge.net.au>
Subject: [patch v2.5 4/4] libxt_ipvs: user-space lib for netfilter matcher xt_ipvs
Date: Sat, 10 Jul 2010 12:01:01 +0900
Message-ID: <20100710030222.990842668@vergenet.net>
References: <20100710030057.731118760@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
From: Simon Horman <horms@verge.net.au>
Content-Disposition: inline; filename=libxt_ipvs-user-space-lib-for-netfilter-matcher-xt_ipvs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Malcolm Turnbull <malcolm@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

From:	Hannes Eder <heder@google.com>

The user-space library for the netfilter matcher xt_ipvs.

[ trivial up-port by Simon Horman <horms@verge.net.au> ]
Signed-off-by: Hannes Eder <heder@google.com>
Acked-by: Simon Horman <horms@verge.net.au>

 configure.ac                      |   10 -
 extensions/libxt_ipvs.c           |  365 +++++++++++++++++++++++++++++++++++++
 extensions/libxt_ipvs.man         |   24 ++
 include/linux/netfilter/xt_ipvs.h |   25 +++
 4 files changed, 422 insertions(+), 2 deletions(-)
 create mode 100644 extensions/libxt_ipvs.c
 create mode 100644 extensions/libxt_ipvs.man
 create mode 100644 include/linux/netfilter/xt_ipvs.h

v2.1, v2.3
Trivial up-port

v2.2
No change

Index: iptables/configure.ac
===================================================================
--- iptables.orig/configure.ac	2010-07-04 20:21:07.000000000 +0900
+++ iptables/configure.ac	2010-07-04 20:23:30.000000000 +0900
@@ -52,12 +52,18 @@ AC_ARG_WITH([pkgconfigdir], AS_HELP_STRI
 	[Path to the pkgconfig directory [[LIBDIR/pkgconfig]]]),
 	[pkgconfigdir="$withval"], [pkgconfigdir='${libdir}/pkgconfig'])
 
-AC_CHECK_HEADER([linux/dccp.h])
-
 blacklist_modules="";
+
+AC_CHECK_HEADER([linux/dccp.h])
 if test "$ac_cv_header_linux_dccp_h" != "yes"; then
 	blacklist_modules="$blacklist_modules dccp";
 fi;
+
+AC_CHECK_HEADER([linux/ip_vs.h])
+if test "$ac_cv_header_linux_ip_vs_h" != "yes"; then
+	blacklist_modules="$blacklist_modules ipvs";
+fi;
+
 AC_SUBST([blacklist_modules])
 
 AM_CONDITIONAL([ENABLE_STATIC], [test "$enable_static" = "yes"])
Index: iptables/extensions/libxt_ipvs.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ iptables/extensions/libxt_ipvs.c	2010-07-04 20:24:01.000000000 +0900
@@ -0,0 +1,365 @@
+/*
+ * Shared library add-on to iptables to add IPVS matching.
+ *
+ * Detailed doc is in the kernel module source net/netfilter/xt_ipvs.c
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
+#include <linux/ip_vs.h>
+#include <linux/netfilter/xt_ipvs.h>
+
+static const struct option ipvs_mt_opts[] = {
+	{ .name = "ipvs",     .has_arg = false, .val = '0' },
+	{ .name = "vproto",   .has_arg = true,  .val = '1' },
+	{ .name = "vaddr",    .has_arg = true,  .val = '2' },
+	{ .name = "vport",    .has_arg = true,  .val = '3' },
+	{ .name = "vdir",     .has_arg = true,  .val = '4' },
+	{ .name = "vmethod",  .has_arg = true,  .val = '5' },
+	{ .name = "vportctl", .has_arg = true,  .val = '6' },
+	{ .name = NULL }
+};
+
+static void ipvs_mt_help(void)
+{
+	printf(
+"IPVS match options:\n"
+"[!] --ipvs                      packet belongs to an IPVS connection\n"
+"\n"
+"Any of the following options implies --ipvs (even negated)\n"
+"[!] --vproto protocol           VIP protocol to match; by number or name,\n"
+"                                e.g. \"tcp\"\n"
+"[!] --vaddr address[/mask]      VIP address to match\n"
+"[!] --vport port                VIP port to match; by number or name,\n"
+"                                e.g. \"http\"\n"
+"    --vdir {ORIGINAL|REPLY}     flow direction of packet\n"
+"[!] --vmethod {GATE|IPIP|MASQ}  IPVS forwarding method used\n"
+"[!] --vportctl port             VIP port of the controlling connection to\n"
+"                                match, e.g. 21 for FTP\n"
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
+	struct xt_ipvs_mtinfo *data = (void *)(*match)->data;
+	char *p = NULL;
+	u_int8_t op = 0;
+
+	if ('0' <= c && c <= '6') {
+		static const int ops[] = {
+			XT_IPVS_IPVS_PROPERTY,
+			XT_IPVS_PROTO,
+			XT_IPVS_VADDR,
+			XT_IPVS_VPORT,
+			XT_IPVS_DIR,
+			XT_IPVS_METHOD,
+			XT_IPVS_VPORTCTL
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
+	case '6': /* --vportctl */
+		data->vportctl = htons(xtables_parse_port(optarg, "tcp"));
+		break;
+
+	default:
+		/* Hu? How did we come here? */
+		assert(false);
+		return 0;
+	}
+
+	if (op & XT_IPVS_ONCE_MASK) {
+		if (data->invert & XT_IPVS_IPVS_PROPERTY)
+			xtables_error(PARAMETER_PROBLEM,
+				      "! --ipvs cannot be together with"
+				      " other options");
+		data->bitmask |= XT_IPVS_IPVS_PROPERTY;
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
+		      "multiple use of the same IPVS option is not allowed");
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
+			      "IPVS: At least one option is required");
+}
+
+/* Shamelessly copied from libxt_conntrack.c */
+static void ipvs_mt_dump_addr(const union nf_inet_addr *addr,
+			      const union nf_inet_addr *mask,
+			      unsigned int family, bool numeric)
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
+static void ipvs_mt_dump(const void *ip, const struct xt_ipvs_mtinfo *data,
+			 unsigned int family, bool numeric, const char *prefix)
+{
+	if (data->bitmask == XT_IPVS_IPVS_PROPERTY) {
+		if (data->invert & XT_IPVS_IPVS_PROPERTY)
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
+	if (data->bitmask & XT_IPVS_VPORTCTL) {
+		if (data->invert & XT_IPVS_VPORTCTL)
+			printf("! ");
+
+		printf("%svportctl %u ", prefix, ntohs(data->vportctl));
+	}
+}
+
+static void ipvs_mt4_print(const void *ip, const struct xt_entry_match *match,
+			   int numeric)
+{
+	const struct xt_ipvs_mtinfo *data = (const void *)match->data;
+	ipvs_mt_dump(ip, data, NFPROTO_IPV4, numeric, "");
+}
+
+static void ipvs_mt6_print(const void *ip, const struct xt_entry_match *match,
+			   int numeric)
+{
+	const struct xt_ipvs_mtinfo *data = (const void *)match->data;
+	ipvs_mt_dump(ip, data, NFPROTO_IPV6, numeric, "");
+}
+
+static void ipvs_mt4_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_ipvs_mtinfo *data = (const void *)match->data;
+	ipvs_mt_dump(ip, data, NFPROTO_IPV4, true, "--");
+}
+
+static void ipvs_mt6_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_ipvs_mtinfo *data = (const void *)match->data;
+	ipvs_mt_dump(ip, data, NFPROTO_IPV6, true, "--");
+}
+
+static struct xtables_match ipvs_matches_reg[] = {
+	{
+		.version       = XTABLES_VERSION,
+		.name          = "ipvs",
+		.revision      = 0,
+		.family        = NFPROTO_IPV4,
+		.size          = XT_ALIGN(sizeof(struct xt_ipvs_mtinfo)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_ipvs_mtinfo)),
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
+		.size          = XT_ALIGN(sizeof(struct xt_ipvs_mtinfo)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_ipvs_mtinfo)),
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
Index: iptables/extensions/libxt_ipvs.man
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ iptables/extensions/libxt_ipvs.man	2010-07-04 20:23:30.000000000 +0900
@@ -0,0 +1,24 @@
+Match IPVS connection properties.
+.TP
+[\fB!\fR] \fB\-\-ipvs\fP
+packet belongs to an IPVS connection
+.TP
+Any of the following options implies \-\-ipvs (even negated)
+.TP
+[\fB!\fR] \fB\-\-vproto\fP \fIprotocol\fP
+VIP protocol to match; by number or name, e.g. "tcp"
+.TP
+[\fB!\fR] \fB\-\-vaddr\fP \fIaddress\fP[\fB/\fP\fImask\fP]
+VIP address to match
+.TP
+[\fB!\fR] \fB\-\-vport\fP \fIport\fP
+VIP port to match; by number or name, e.g. "http"
+.TP
+\fB\-\-vdir\fP {\fBORIGINAL\fP|\fBREPLY\fP}
+flow direction of packet
+.TP
+[\fB!\fR] \fB\-\-vmethod\fP {\fBGATE\fP|\fBIPIP\fP|\fBMASQ\fP}
+IPVS forwarding method used
+.TP
+[\fB!\fR] \fB\-\-vportctl\fP \fIport\fP
+VIP port of the controlling connection to match, e.g. 21 for FTP
Index: iptables/include/linux/netfilter/xt_ipvs.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ iptables/include/linux/netfilter/xt_ipvs.h	2010-07-04 20:23:30.000000000 +0900
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

