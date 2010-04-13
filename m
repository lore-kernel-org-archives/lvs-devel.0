From: Simon Horman <horms@verge.net.au>
Subject: Re: [Linux-HA] UDP / DHCP / LDIRECTORD
Date: Tue, 13 Apr 2010 12:55:54 +1000
Message-ID: <20100413025551.GA25064@verge.net.au>
References: <20100412020447.GB10826@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100412020447.GB10826@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Brian Carpio <bcarpio@broadhop.com>
Cc: linux-ha@lists.linux-ha.org, lvs-devel <lvs-devel@vger.kernel.org>, Julian Anastasov <ja@ssi.bg>


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Brian,

here are some patches to test.
I have only lightly tested them to the extent that they
compile and appear to configure a valid service.

You can enable one packet scheduling (OPS) by passing the -o option
to ipvsadm when creating a virtual service.

	e.g.

	# ipvsadm -A -u 172.17.60.211:80 -o
	# ipvsadm -L -n
	IP Virtual Server version 1.2.1 (size=4096)
	Prot LocalAddress:Port Scheduler Flags
	  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
	UDP  172.17.60.211:80 wlc ops

There are three patches:

ops-kernel-2.6.18-128.el5.patch: Patch against CentOS-5.3's 2.6.18-128 kernel.
ops-ipvsadm-1.24-10: Patch against CentOS-5.3's ipvsadm 1.24-10.
ops-ipvsadm-1.24: Patch against upstream ipvsadm 1.24

I have not up-ported the code to the 2.6.33 kernel and ipvsadm 1.25 yet.


--Nq2Wo0NMKNjxTN9z
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="ops-ipvsadm-1.24-10.patch"

From: Julian Anastasov <ja@ssi.bg>

ipvsadm: one-packet scheduling

Allow one-packet scheduling for UDP connections. When the fwmark-based or
normal virtual service is marked with '-o' or '--ops' options all
connections are created only to schedule one packet. Useful to schedule UDP
packets from same client port to different real servers. Recommended with
RR or WRR schedulers (the connections are not visible with ipvsadm -L).

Up-port of http://www.ssi.bg/~ja/tmp/ops-ipvsadm-1.21-1.diff to
ipvsadm-1.24-10 by Simon Horman.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: ipvsadm-1.24-10/ipvsadm.c
===================================================================
--- ipvsadm-1.24-10.orig/ipvsadm.c	2004-01-10 18:39:03.000000000 +0900
+++ ipvsadm-1.24-10/ipvsadm.c	2010-04-13 10:57:53.000000000 +0900
@@ -182,7 +182,8 @@ static const char* cmdnames[] = {
 #define OPT_PERSISTENTCONN	0x20000
 #define OPT_SORT		0x40000
 #define OPT_SYNCID		0x80000
-#define NUMBER_OF_OPT		20
+#define OPT_ONEPACKET		0x200000
+#define NUMBER_OF_OPT		21
 
 static const char* optnames[] = {
 	"numeric",
@@ -205,6 +206,7 @@ static const char* optnames[] = {
 	"persistent-conn",
 	"sort",
 	"syncid",
+	"ops",
 };
 
 /*
@@ -388,6 +390,7 @@ parse_options(int argc, char **argv, str
 		{"thresholds", '\0', POPT_ARG_NONE, NULL, '9'},
 		{"persistent-conn", '\0', POPT_ARG_NONE, NULL, 'P'},
 		{"sort", '\0', POPT_ARG_NONE, NULL, '0'},
+		{"ops", 'o', POPT_ARG_NONE, NULL, 'o'},
 		{NULL, 0, 0, NULL, 0}
 	};
 
@@ -492,7 +495,7 @@ parse_options(int argc, char **argv, str
 			break;
 		case 'p':
 			set_option(options, OPT_PERSISTENT);
-			ce->svc.flags = IP_VS_SVC_F_PERSISTENT;
+			ce->svc.flags |= IP_VS_SVC_F_PERSISTENT;
 			ce->svc.timeout =
 				parse_timeout(optarg, 1, MAX_TIMEOUT);
 			break;
@@ -590,6 +593,10 @@ parse_options(int argc, char **argv, str
 			set_option(options, OPT_SORT);
 			*format |= FMT_SORT;
 			break;
+		case 'o':
+			set_option(options, OPT_ONEPACKET);
+			ur->vs_flags |= IP_VS_SVC_F_ONEPACKET;
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -636,7 +643,7 @@ parse_options(int argc, char **argv, str
 	      unsigned int *options, unsigned int *format)
 {
 	int c, parse;
-	const char *optstring = "AEDCZSRaedlLhvt:u:f:s:M:p::r:gmiw:x:y:cn";
+	const char *optstring = "AEDCZSRaedlLhvt:u:f:s:M:p::r:gmiw:x:y:cno";
 	const struct option long_options[] = {
 		{"add-service", 0, 0, 'A'},
 		{"edit-service", 0, 0, 'E'},
@@ -678,6 +685,7 @@ parse_options(int argc, char **argv, str
 		{"thresholds", 0, 0, '9'},
 		{"persistent-conn", 0, 0, 'P'},
 		{"sort", 0, 0, '0'},
+		{"ops", 0, 0, 'o'},
 		{"help", 0, 0, 'h'},
 		{0, 0, 0, 0}
 	};
@@ -801,7 +809,7 @@ parse_options(int argc, char **argv, str
 			break;
 		case 'p':
 			set_option(options, OPT_PERSISTENT);
-			ce->svc.flags = IP_VS_SVC_F_PERSISTENT;
+			ce->svc.flags |= IP_VS_SVC_F_PERSISTENT;
 			if (!optarg && optind < argc && argv[optind][0] != '-'
 			    && argv[optind][0] != '!')
 				optarg = argv[optind++];
@@ -902,6 +910,10 @@ parse_options(int argc, char **argv, str
 			set_option(options, OPT_SORT);
 			*format |= FMT_SORT;
 			break;
+		case 'o':
+			set_option(options, OPT_ONEPACKET);
+			ce->svc.flags |= IP_VS_SVC_F_ONEPACKET;
+			break;
 		default:
 			fail(2, "invalid option `%s'", argv[optind-1]);
 		}
@@ -960,10 +972,15 @@ static int process_options(int argc, cha
 	if (ce.cmd == CMD_ADD || ce.cmd == CMD_EDIT) {
 		/* Make sure that port zero service is persistent */
 		if (!ce.svc.fwmark && !ce.svc.port &&
-		    (ce.svc.flags != IP_VS_SVC_F_PERSISTENT))
+		    !(ce.svc.flags & IP_VS_SVC_F_PERSISTENT))
 			fail(2, "Zero port specified "
 			     "for non-persistent service");
 
+		if (ce.svc.flags & IP_VS_SVC_F_ONEPACKET &&
+		    !ce.svc.fwmark && ce.svc.protocol != IPPROTO_UDP)
+			fail(2, "One-Packet Scheduling is only "
+			     "for UDP virtual services");
+
 		/* Set the default scheduling algorithm if not specified */
 		if (strlen(ce.svc.sched_name) == 0)
 			strcpy(ce.svc.sched_name, DEF_SCHED);
@@ -1328,6 +1345,7 @@ static void usage_exit(const char *progr
 		"  --thresholds                        output of thresholds information\n"
 		"  --persistent-conn                   output of persistent connection info\n"
 		"  --sort                              sorting output of service/server entries\n"
+		"  --ops          -o                   one-packet scheduling\n"
 		"  --numeric      -n                   numeric output of addresses and ports\n",
 		DEF_SCHED);
 
@@ -1629,6 +1647,8 @@ print_service_entry(ipvs_service_entry_t
 				printf(" -M %s", inet_ntoa(mask));
 			}
 		}
+		if (se->flags & IP_VS_SVC_F_ONEPACKET)
+			printf(" ops");
 	} else if (format & FMT_STATS) {
 		printf("%-33s", svc_name);
 		print_largenum(se->stats.conns);
@@ -1653,6 +1673,8 @@ print_service_entry(ipvs_service_entry_t
 				printf(" mask %s", inet_ntoa(mask));
 			}
 		}
+		if (se->flags & IP_VS_SVC_F_ONEPACKET)
+			printf(" ops");
 	}
 	printf("\n");
 

--Nq2Wo0NMKNjxTN9z
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="ops-ipvsadm-1.24.patch"

From: Julian Anastasov <ja@ssi.bg>

ipvsadm: one-packet scheduling

Allow one-packet scheduling for UDP connections. When the fwmark-based or
normal virtual service is marked with '-o' or '--ops' options all
connections are created only to schedule one packet. Useful to schedule UDP
packets from same client port to different real servers. Recommended with
RR or WRR schedulers (the connections are not visible with ipvsadm -L).

Up-port of http://www.ssi.bg/~ja/tmp/ops-ipvsadm-1.21-1.diff to
ipvsadm-1.24 by Simon Horman.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: ipvsadm-1.24/ipvsadm.c
===================================================================
--- ipvsadm-1.24.orig/ipvsadm.c	2005-12-11 01:00:07.000000000 +0900
+++ ipvsadm-1.24/ipvsadm.c	2010-04-13 10:50:10.000000000 +0900
@@ -184,7 +184,8 @@ static const char* cmdnames[] = {
 #define OPT_SORT		0x040000
 #define OPT_SYNCID		0x080000
 #define OPT_EXACT		0x100000
-#define NUMBER_OF_OPT		21
+#define OPT_ONEPACKET		0x200000
+#define NUMBER_OF_OPT		22
 
 static const char* optnames[] = {
 	"numeric",
@@ -208,6 +209,7 @@ static const char* optnames[] = {
 	"sort",
 	"syncid",
 	"exact",
+	"ops",
 };
 
 /*
@@ -393,6 +395,7 @@ parse_options(int argc, char **argv, str
 		{"persistent-conn", '\0', POPT_ARG_NONE, NULL, 'P'},
 		{"sort", '\0', POPT_ARG_NONE, NULL, '0'},
 		{"exact", 'X', POPT_ARG_NONE, NULL, 'X'},
+		{"ops", 'o', POPT_ARG_NONE, NULL, 'o'},
 		{NULL, 0, 0, NULL, 0}
 	};
 
@@ -497,7 +500,7 @@ parse_options(int argc, char **argv, str
 			break;
 		case 'p':
 			set_option(options, OPT_PERSISTENT);
-			ce->svc.flags = IP_VS_SVC_F_PERSISTENT;
+			ce->svc.flags |= IP_VS_SVC_F_PERSISTENT;
 			ce->svc.timeout =
 				parse_timeout(optarg, 1, MAX_TIMEOUT);
 			break;
@@ -599,6 +602,10 @@ parse_options(int argc, char **argv, str
 			set_option(options, OPT_EXACT);
 			*format |= FMT_EXACT;
 			break;
+		case 'o':
+			set_option(options, OPT_ONEPACKET);
+			ur->vs_flags |= IP_VS_SVC_F_ONEPACKET;
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -645,7 +652,7 @@ parse_options(int argc, char **argv, str
 	      unsigned int *options, unsigned int *format)
 {
 	int c, parse;
-	const char *optstring = "AEDCZSRaedlLhvt:u:f:s:M:p::r:gmiw:x:y:cnX";
+	const char *optstring = "AEDCZSRaedlLhvt:u:f:s:M:p::r:gmiw:x:y:cnoX";
 	const struct option long_options[] = {
 		{"add-service", 0, 0, 'A'},
 		{"edit-service", 0, 0, 'E'},
@@ -688,6 +695,7 @@ parse_options(int argc, char **argv, str
 		{"persistent-conn", 0, 0, 'P'},
 		{"sort", 0, 0, '0'},
 		{"exact", 0, 0, 'X'},
+		{"ops", 0, 0, 'o'},
 		{"help", 0, 0, 'h'},
 		{0, 0, 0, 0}
 	};
@@ -811,7 +819,7 @@ parse_options(int argc, char **argv, str
 			break;
 		case 'p':
 			set_option(options, OPT_PERSISTENT);
-			ce->svc.flags = IP_VS_SVC_F_PERSISTENT;
+			ce->svc.flags |= IP_VS_SVC_F_PERSISTENT;
 			if (!optarg && optind < argc && argv[optind][0] != '-'
 			    && argv[optind][0] != '!')
 				optarg = argv[optind++];
@@ -916,6 +924,10 @@ parse_options(int argc, char **argv, str
 			set_option(options, OPT_EXACT);
 			*format |= FMT_EXACT;
 			break;
+		case 'o':
+			set_option(options, OPT_ONEPACKET);
+			ce->svc.flags |= IP_VS_SVC_F_ONEPACKET;
+			break;
 		default:
 			fail(2, "invalid option `%s'", argv[optind-1]);
 		}
@@ -974,10 +986,15 @@ static int process_options(int argc, cha
 	if (ce.cmd == CMD_ADD || ce.cmd == CMD_EDIT) {
 		/* Make sure that port zero service is persistent */
 		if (!ce.svc.fwmark && !ce.svc.port &&
-		    (ce.svc.flags != IP_VS_SVC_F_PERSISTENT))
+		    !(ce.svc.flags & IP_VS_SVC_F_PERSISTENT))
 			fail(2, "Zero port specified "
 			     "for non-persistent service");
 
+		if (ce.svc.flags & IP_VS_SVC_F_ONEPACKET &&
+		    !ce.svc.fwmark && ce.svc.protocol != IPPROTO_UDP)
+			fail(2, "One-Packet Scheduling is only "
+			     "for UDP virtual services");
+
 		/* Set the default scheduling algorithm if not specified */
 		if (strlen(ce.svc.sched_name) == 0)
 			strcpy(ce.svc.sched_name, DEF_SCHED);
@@ -1343,6 +1360,7 @@ static void usage_exit(const char *progr
 		"  --thresholds                        output of thresholds information\n"
 		"  --persistent-conn                   output of persistent connection info\n"
 		"  --sort                              sorting output of service/server entries\n"
+		"  --ops          -o                   one-packet scheduling\n"
 		"  --numeric      -n                   numeric output of addresses and ports\n",
 		DEF_SCHED);
 
@@ -1653,6 +1671,8 @@ print_service_entry(ipvs_service_entry_t
 				printf(" -M %s", inet_ntoa(mask));
 			}
 		}
+		if (se->flags & IP_VS_SVC_F_ONEPACKET)
+			printf(" ops");
 	} else if (format & FMT_STATS) {
 		printf("%-33s", svc_name);
 		print_largenum(se->stats.conns, format);
@@ -1677,6 +1697,8 @@ print_service_entry(ipvs_service_entry_t
 				printf(" mask %s", inet_ntoa(mask));
 			}
 		}
+		if (se->flags & IP_VS_SVC_F_ONEPACKET)
+			printf(" ops");
 	}
 	printf("\n");
 

--Nq2Wo0NMKNjxTN9z
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="ops-kernel-2.6.18-128.el5.patch"

From: Julian Anastasov <ja@ssi.bg>

IPVS: one-packet scheduling

Allow one-packet scheduling for UDP connections. When the fwmark-based or
normal virtual service is marked with '-o' or '--ops' options all
connections are created only to schedule one packet. Useful to schedule UDP
packets from same client port to different real servers. Recommended with
RR or WRR schedulers (the connections are not visible with ipvsadm -L).

Up-port of http://www.ssi.bg/~ja/tmp/ops-2.4.32-1.diff to
2.6.18-128.el5 by Simon Horman.

Signed-off-by: Simon Horman <horms@verge.net.au>

diff -ur v2.4.32/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- v2.4.32/linux/include/net/ip_vs.h	2005-11-17 00:18:44.000000000 +0200
+++ linux/include/net/ip_vs.h	2005-11-17 10:36:57.461647080 +0200
@@ -19,6 +19,7 @@
  */
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
+#define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
 
 /*
  *      Destination Server Flags
@@ -83,6 +84,7 @@
 #define IP_VS_CONN_F_SEQ_MASK	0x0600		/* in/out sequence mask */
 #define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
+#define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
 /* Move it to better place one day, for now keep it unique */
 #define NFC_IPVS_PROPERTY	0x10000
diff -ur v2.4.32/linux/net/ipv4/ipvs/ip_vs_conn.c linux/net/ipv4/ipvs/ip_vs_conn.c
--- v2.4.32/linux/net/ipv4/ipvs/ip_vs_conn.c	2005-11-17 00:18:44.000000000 +0200
+++ linux/net/ipv4/ipvs/ip_vs_conn.c	2005-11-17 10:39:41.570698712 +0200
@@ -139,6 +139,9 @@
 	unsigned hash;
 	int ret;
 
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		return 0;
+
 	/* Hash by protocol, client address and port */
 	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr, cp->cport);
 
@@ -327,6 +330,12 @@
  */
 void ip_vs_conn_put(struct ip_vs_conn *cp)
 {
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET) {
+		ip_vs_conn_expire_now(cp);
+		__ip_vs_conn_put(cp);
+		return;
+	}
+
 	/* reset it expire in its timeout */
 	mod_timer(&cp->timer, jiffies+cp->timeout);
 
@@ -1240,7 +1249,7 @@
 	/*
 	 *	unhash it if it is hashed in the conn table
 	 */
-	if (!ip_vs_conn_unhash(cp))
+	if (!ip_vs_conn_unhash(cp) && !(cp->flags & IP_VS_CONN_F_ONE_PACKET))
 		goto expire_later;
 
 	/*
diff -ur v2.4.32/linux/net/ipv4/ipvs/ip_vs_core.c linux/net/ipv4/ipvs/ip_vs_core.c
--- v2.4.32/linux/net/ipv4/ipvs/ip_vs_core.c	2005-11-17 00:18:44.000000000 +0200
+++ linux/net/ipv4/ipvs/ip_vs_core.c	2005-11-17 10:36:57.463646776 +0200
@@ -159,6 +159,7 @@
 	const __u16 *portp;
 	struct ip_vs_conn *ct;
 	__u16  dport;	 /* destination port to forward */
+	__u16 flags;
 	__u32  snet;	 /* source network of the client, after masking */
 
 	portp = (__u16 *)&(((char *)iph)[iph->ihl*4]);
@@ -290,6 +291,9 @@
 		dport = portp[1];
 	}
 
+	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
+		 && iph->protocol == IPPROTO_UDP)?
+		IP_VS_CONN_F_ONE_PACKET : 0;
 	/*
 	 *    Create a new connection according to the template
 	 */
@@ -297,7 +301,7 @@
 			    iph->saddr, portp[0],
 			    iph->daddr, portp[1],
 			    dest->addr, dport,
-			    0,
+			    flags,
 			    dest);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
@@ -332,6 +336,7 @@
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_dest *dest;
 	__u16 _ports[2], *pptr;
+	__u16 flags;
 
 	pptr = skb_header_pointer(skb, iph->ihl*4,
 				  sizeof(_ports), _ports);
@@ -357,6 +362,9 @@
 		return NULL;
 	}
 
+	flags = (svc->flags & IP_VS_SVC_F_ONEPACKET
+		 && iph->protocol == IPPROTO_UDP)?
+		IP_VS_CONN_F_ONE_PACKET : 0;
 	/*
 	 *    Create a connection entry.
 	 */
@@ -364,7 +372,7 @@
 			    iph->saddr, pptr[0],
 			    iph->daddr, pptr[1],
 			    dest->addr, dest->port?dest->port:pptr[1],
-			    0,
+			    flags,
 			    dest);
 	if (cp == NULL)
 		return NULL;
@@ -404,6 +412,9 @@
 	    && (inet_addr_type(iph->daddr) == RTN_UNICAST)) {
 		int ret;
 		struct ip_vs_conn *cp;
+		__u16 flags = (svc->flags & IP_VS_SVC_F_ONEPACKET &&
+				iph->protocol == IPPROTO_UDP)?
+				IP_VS_CONN_F_ONE_PACKET : 0;
 
 		ip_vs_service_put(svc);
 
@@ -413,7 +424,7 @@
 				    iph->saddr, portp[0],
 				    iph->daddr, portp[1],
 				    0, 0,
-				    IP_VS_CONN_F_BYPASS,
+				    IP_VS_CONN_F_BYPASS | flags,
 				    NULL);
 		if (cp == NULL) {
 			kfree_skb(skb);

--Nq2Wo0NMKNjxTN9z--
