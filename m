From: Simon Horman <horms@verge.net.au>
Subject: [patch 5/5] ipvsadm: one-packet scheduling
Date: Mon, 26 Jul 2010 17:04:53 +0900
Message-ID: <20100726080646.517901560@vergenet.net>
References: <20100726080448.476781076@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ops-2.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Allow one-packet scheduling for UDP connections. When the fwmark-based or
normal virtual service is marked with '-o' or '--ops' options all
connections are created only to schedule one packet. Useful to schedule UDP
packets from same client port to different real servers. Recommended with
RR or WRR schedulers (the connections are not visible with ipvsadm -L).

The kernel side of this change has already been merged
and should appear in 2.6.35.

Based on http://www.ssi.bg/~ja/tmp/ops-ipvsadm-1.21-1.diff
by Julian Anastasov <ja@ssi.bg>

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: trunk/ipvsadm.c
===================================================================
--- trunk.orig/ipvsadm.c	2010-07-25 21:01:02.000000000 +0900
+++ trunk/ipvsadm.c	2010-07-25 21:01:04.000000000 +0900
@@ -180,7 +180,8 @@ static const char* cmdnames[] = {
 #define OPT_NOSORT		0x040000
 #define OPT_SYNCID		0x080000
 #define OPT_EXACT		0x100000
-#define NUMBER_OF_OPT		21
+#define OPT_ONEPACKET		0x200000
+#define NUMBER_OF_OPT		22
 
 static const char* optnames[] = {
 	"numeric",
@@ -204,6 +205,7 @@ static const char* optnames[] = {
 	"nosort",
 	"syncid",
 	"exact",
+	"ops",
 };
 
 /*
@@ -418,6 +420,7 @@ parse_options(int argc, char **argv, str
 		{ "sort", '\0', POPT_ARG_NONE, NULL, TAG_SORT, NULL, NULL },
 		{ "exact", 'X', POPT_ARG_NONE, NULL, 'X', NULL, NULL },
 		{ "ipv6", '6', POPT_ARG_NONE, NULL, '6', NULL, NULL },
+		{ "ops", 'o', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -520,7 +523,7 @@ parse_options(int argc, char **argv, str
 			break;
 		case 'p':
 			set_option(options, OPT_PERSISTENT);
-			ce->svc.flags = IP_VS_SVC_F_PERSISTENT;
+			ce->svc.flags |= IP_VS_SVC_F_PERSISTENT;
 			ce->svc.timeout =
 				parse_timeout(optarg, 1, MAX_TIMEOUT);
 			break;
@@ -640,6 +643,10 @@ parse_options(int argc, char **argv, str
 				fail(2, "-6 used before -f\n");
 			}
 			break;
+		case 'o':
+			set_option(options, OPT_ONEPACKET);
+			ce->svc.flags |= IP_VS_SVC_F_ONEPACKET;
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -725,10 +732,15 @@ static int process_options(int argc, cha
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
@@ -1116,6 +1128,7 @@ static void usage_exit(const char *progr
 		"  --persistent-conn                   output of persistent connection info\n"
 		"  --nosort                            disable sorting output of service/server entries\n"
 		"  --sort                              does nothing, for backwards compatibility\n"
+		"  --ops          -o                   one-packet scheduling\n"
 		"  --numeric      -n                   numeric output of addresses and ports\n",
 		DEF_SCHED);
 
@@ -1448,6 +1461,8 @@ print_service_entry(ipvs_service_entry_t
 					printf(" -M %i", se->netmask);
 				}
 		}
+		if (se->flags & IP_VS_SVC_F_ONEPACKET)
+			printf(" ops");
 	} else if (format & FMT_STATS) {
 		printf("%-33s", svc_name);
 		print_largenum(se->stats.conns, format);
@@ -1475,6 +1490,8 @@ print_service_entry(ipvs_service_entry_t
 			if (se->af == AF_INET6)
 				if (se->netmask != 128)
 					printf(" mask %i", se->netmask);
+			if (se->flags & IP_VS_SVC_F_ONEPACKET)
+				printf(" ops");
 		}
 	}
 	printf("\n");
Index: trunk/libipvs/ip_vs.h
===================================================================
--- trunk.orig/libipvs/ip_vs.h	2010-07-25 20:58:51.000000000 +0900
+++ trunk/libipvs/ip_vs.h	2010-07-25 21:01:04.000000000 +0900
@@ -28,6 +28,7 @@
  */
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
+#define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
 
 /*
  *      IPVS sync daemon states
@@ -88,6 +89,7 @@
 #define IP_VS_CONN_F_SEQ_MASK	0x0600		/* in/out sequence mask */
 #define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
+#define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
Index: trunk/ipvsadm.8
===================================================================
--- trunk.orig/ipvsadm.8	2010-07-25 21:01:08.000000000 +0900
+++ trunk/ipvsadm.8	2010-07-25 21:04:03.000000000 +0900
@@ -414,6 +414,12 @@ option is only relevant for the -L comma
 .TP
 .B -6, --ipv6
 Use with -f to signify fwmark rule uses IPv6 addresses.
+.TP
+.B -o, --ops
+One-packet scheduling.
+Used in conjunction with a UDP virtual service or
+a fwmark virtual service that handles only UDP packets.
+All connections are created such that they only schedule one packet.
 .SH EXAMPLE 1 - Simple Virtual Service
 The following commands configure a Linux Director to distribute
 incoming requests addressed to port 80 on 207.175.44.110 equally to

