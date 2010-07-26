From: Simon Horman <horms@verge.net.au>
Subject: [patch 4/5] ipvsadm: Use an enum for the val of options that have no short option
Date: Mon, 26 Jul 2010 17:04:52 +0900
Message-ID: <20100726080646.244663698@vergenet.net>
References: <20100726080448.476781076@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=OPT-2.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

I think that this significantly aids in the management of
these values while leaving all valid shortopts available as 'val' entries.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: trunk/ipvsadm.c
===================================================================
--- trunk.orig/ipvsadm.c	2010-07-25 21:53:57.000000000 +0900
+++ trunk/ipvsadm.c	2010-07-25 21:54:41.000000000 +0900
@@ -264,6 +264,23 @@ struct ipvs_command_entry {
 	ipvs_daemon_t		daemon;
 };
 
+/* Use values outside ASCII range so that if an option has
+ * a short name it can be used as the tag
+ */
+enum {
+	TAG_SET	= 128,
+	TAG_START_DAEMON,
+	TAG_STOP_DAEMON	,
+	TAG_MCAST_INTERFACE,
+	TAG_TIMEOUT,
+	TAG_DAEMON,
+	TAG_STATS,
+	TAG_RATE,
+	TAG_THRESHOLDS,
+	TAG_PERSISTENTCONN,
+	TAG_SORT,
+	TAG_NO_SORT,
+};
 
 /* various parsing helpers & parsing functions */
 static int str_is_digit(const char *str);
@@ -353,15 +370,15 @@ parse_options(int argc, char **argv, str
 		{ "add-server", 'a', POPT_ARG_NONE, NULL, 'a', NULL, NULL },
 		{ "edit-server", 'e', POPT_ARG_NONE, NULL, 'e', NULL, NULL },
 		{ "delete-server", 'd', POPT_ARG_NONE, NULL, 'd', NULL, NULL },
-		{ "set", '\0', POPT_ARG_NONE, NULL, '4', NULL, NULL },
+		{ "set", '\0', POPT_ARG_NONE, NULL, TAG_SET, NULL, NULL },
 		{ "help", 'h', POPT_ARG_NONE, NULL, 'h', NULL, NULL },
 		{ "version", 'v', POPT_ARG_NONE, NULL, 'v', NULL, NULL },
 		{ "restore", 'R', POPT_ARG_NONE, NULL, 'R', NULL, NULL },
 		{ "save", 'S', POPT_ARG_NONE, NULL, 'S', NULL, NULL },
-		{ "start-daemon", '\0', POPT_ARG_STRING, &optarg, '1',
-		  NULL, NULL },
-		{ "stop-daemon", '\0', POPT_ARG_STRING, &optarg, '2',
-		  NULL, NULL },
+		{ "start-daemon", '\0', POPT_ARG_STRING, &optarg,
+		  TAG_START_DAEMON, NULL, NULL },
+		{ "stop-daemon", '\0', POPT_ARG_STRING, &optarg,
+		  TAG_STOP_DAEMON, NULL, NULL },
 		{ "tcp-service", 't', POPT_ARG_STRING, &optarg, 't',
 		  NULL, NULL },
 		{ "udp-service", 'u', POPT_ARG_STRING, &optarg, 'u',
@@ -384,20 +401,23 @@ parse_options(int argc, char **argv, str
 		  NULL, NULL },
 		{ "numeric", 'n', POPT_ARG_NONE, NULL, 'n', NULL, NULL },
 		{ "connection", 'c', POPT_ARG_NONE, NULL, 'c', NULL, NULL },
-		{ "mcast-interface", '\0', POPT_ARG_STRING, &optarg, '3',
-		  NULL, NULL },
+		{ "mcast-interface", '\0', POPT_ARG_STRING, &optarg,
+		  TAG_MCAST_INTERFACE, NULL, NULL },
 		{ "syncid", '\0', POPT_ARG_STRING, &optarg, 'I', NULL, NULL },
-		{ "timeout", '\0', POPT_ARG_NONE, NULL, '5', NULL, NULL },
-		{ "daemon", '\0', POPT_ARG_NONE, NULL, '6', NULL, NULL },
-		{ "stats", '\0', POPT_ARG_NONE, NULL, '7', NULL, NULL },
-		{ "rate", '\0', POPT_ARG_NONE, NULL, '8', NULL, NULL },
-		{ "thresholds", '\0', POPT_ARG_NONE, NULL, '9', NULL, NULL },
-		{ "persistent-conn", '\0', POPT_ARG_NONE, NULL, 'P',
+		{ "timeout", '\0', POPT_ARG_NONE, NULL, TAG_TIMEOUT,
 		  NULL, NULL },
-		{ "nosort", '\0', POPT_ARG_NONE, NULL, '0', NULL, NULL },
-		{ "sort", '\0', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
+		{ "daemon", '\0', POPT_ARG_NONE, NULL, TAG_DAEMON, NULL, NULL },
+		{ "stats", '\0', POPT_ARG_NONE, NULL, TAG_STATS, NULL, NULL },
+		{ "rate", '\0', POPT_ARG_NONE, NULL, TAG_RATE, NULL, NULL },
+		{ "thresholds", '\0', POPT_ARG_NONE, NULL,
+		   TAG_THRESHOLDS, NULL, NULL },
+		{ "persistent-conn", '\0', POPT_ARG_NONE, NULL,
+		  TAG_PERSISTENTCONN, NULL, NULL },
+		{ "nosort", '\0', POPT_ARG_NONE, NULL,
+		   TAG_NO_SORT, NULL, NULL },
+		{ "sort", '\0', POPT_ARG_NONE, NULL, TAG_SORT, NULL, NULL },
 		{ "exact", 'X', POPT_ARG_NONE, NULL, 'X', NULL, NULL },
-		{ "ipv6", '6', POPT_ARG_NONE, NULL, '%', NULL, NULL },
+		{ "ipv6", '6', POPT_ARG_NONE, NULL, '6', NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -436,7 +456,7 @@ parse_options(int argc, char **argv, str
 	case 'Z':
 		set_command(&ce->cmd, CMD_ZERO);
 		break;
-	case '4':
+	case TAG_SET:
 		set_command(&ce->cmd, CMD_TIMEOUT);
 		break;
 	case 'R':
@@ -445,7 +465,7 @@ parse_options(int argc, char **argv, str
 	case 'S':
 		set_command(&ce->cmd, CMD_SAVE);
 		break;
-	case '1':
+	case TAG_START_DAEMON:
 		set_command(&ce->cmd, CMD_STARTDAEMON);
 		if (!strcmp(optarg, "master"))
 			ce->daemon.state = IP_VS_STATE_MASTER;
@@ -453,7 +473,7 @@ parse_options(int argc, char **argv, str
 			ce->daemon.state = IP_VS_STATE_BACKUP;
 		else fail(2, "illegal start-daemon parameter specified");
 		break;
-	case '2':
+	case TAG_STOP_DAEMON:
 		set_command(&ce->cmd, CMD_STOPDAEMON);
 		if (!strcmp(optarg, "master"))
 			ce->daemon.state = IP_VS_STATE_MASTER;
@@ -568,7 +588,7 @@ parse_options(int argc, char **argv, str
 			set_option(options, OPT_NUMERIC);
 			*format |= FMT_NUMERIC;
 			break;
-		case '3':
+		case TAG_MCAST_INTERFACE:
 			set_option(options, OPT_MCAST);
 			strncpy(ce->daemon.mcast_ifn,
 				optarg, IP_VS_IFNAME_MAXLEN);
@@ -579,40 +599,40 @@ parse_options(int argc, char **argv, str
 			     string_to_number(optarg, 0, 255)) == -1)
 				fail(2, "illegal syncid specified");
 			break;
-		case '5':
+		case TAG_TIMEOUT:
 			set_option(options, OPT_TIMEOUT);
 			break;
-		case '6':
+		case TAG_DAEMON:
 			set_option(options, OPT_DAEMON);
 			break;
-		case '7':
+		case TAG_STATS:
 			set_option(options, OPT_STATS);
 			*format |= FMT_STATS;
 			break;
-		case '8':
+		case TAG_RATE:
 			set_option(options, OPT_RATE);
 			*format |= FMT_RATE;
 			break;
-		case '9':
+		case TAG_THRESHOLDS:
 			set_option(options, OPT_THRESHOLDS);
 			*format |= FMT_THRESHOLDS;
 			break;
-		case 'P':
+		case TAG_PERSISTENTCONN:
 			set_option(options, OPT_PERSISTENTCONN);
 			*format |= FMT_PERSISTENTCONN;
 			break;
-		case '0':
+		case TAG_NO_SORT:
 			set_option(options, OPT_NOSORT	);
 			*format |= FMT_NOSORT;
 			break;
-		case 'o':
+		case TAG_SORT:
 			/* Sort is the default, this is a no-op for compatibility */
 			break;
 		case 'X':
 			set_option(options, OPT_EXACT);
 			*format |= FMT_EXACT;
 			break;
-		case '%':
+		case '6':
 			if (ce->svc.fwmark) {
 				ce->svc.af = AF_INET6;
 				ce->svc.netmask = 128;

