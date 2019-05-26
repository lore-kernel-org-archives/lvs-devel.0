From: Jacky Hu <hengqing.hu@gmail.com>
Subject: [PATCH v6 1/2] ipvsadm: convert options to unsigned
	long long
Date: Sun, 26 May 2019 14:50:38 +0800
Message-ID: <20190526065038.17067-1-hengqing.hu@gmail.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
	h=from:to:cc:subject:date:message-id:mime-version
	:content-transfer-encoding;
	bh=EO4WccddSt8lmeNZLwjpw+XWgflqd90tyuQMt1T6tdA=;
	b=aV3Fb1Zli8UHXREa2P1JExZr/I55NBhOk1a1gwCBV+au1Xjccv+hCYKvuSJ8NIgeXy
	POexPf+g8jA7li4HYvrFh+1D/c4s2QTkKT1gqqX66JwWNp3qlCI5RJoZ2LP2vwTL8LtA
	cKRWTvWQVHgxmllhAXXZ0vsmWu9Xz5uw4kX4wsJoVIwvf9UsWKIVQkF86zKmtBn/pKz6
	7bgO1EIaEGTVMGtTe0GT/lSJPDEbE5rALlJYXedtIOPq5ov4DnsMws5XH8SaX10JT+YA
	cPwta9aHw9LgUHqzuKYE89ijbSMMdKP+dciOpAtTl99dMwotjBGKHJrDJqSFb2vMJsNv
	LRxg==
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: hengqing.hu@gmail.com
Cc: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org, horms@verge.net.au, jacky.hu@walmart.com, brouer@redhat.com, jason.niesz@walmart.com

To allow up to 64 options to be specified.
Add calculated logarithm constants for existing options.
Remove opt2name function to avoid recalculation.

Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
---
v6->v5:
  1) split the patch into two:
     - ipvsadm: convert options to unsigned long long
     - ipvsadm: allow tunneling with gue encapsulation
  2) do not mix static and dynamic allocation in fwd_tun_info
  3) use correct nla_get/put function for tun_flags
  4) fixed || style
  5) use correct return value for parse_tun_type

v5->v4:
  1) add checksum support for gue encapsulation

v4->v3:
  1) removed changes to setsockopt interface
  2) use correct nla_get/put function for tun_port

v3->v2:
  1) added missing break statements to a few switch cases

v2->v1:
  1) pass tun_type and tun_port as new optional parameters
     instead of a few bits in existing conn_flags parameters

 ipvsadm.c | 117 ++++++++++++++++++++++++++++++++----------------------
 1 file changed, 69 insertions(+), 48 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 0cb2b68..9e7a448 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -189,6 +189,35 @@ static const char* cmdnames[] = {
 #define OPT_SYNC_MAXLEN	0x08000000
 #define NUMBER_OF_OPT		28
 
+#define OPTC_NUMERIC		0
+#define OPTC_CONNECTION		1
+#define OPTC_SERVICE		2
+#define OPTC_SCHEDULER		3
+#define OPTC_PERSISTENT		4
+#define OPTC_NETMASK		5
+#define OPTC_SERVER		6
+#define OPTC_FORWARD		7
+#define OPTC_WEIGHT		8
+#define OPTC_UTHRESHOLD		9
+#define OPTC_LTHRESHOLD		10
+#define OPTC_MCAST		11
+#define OPTC_TIMEOUT		12
+#define OPTC_DAEMON		13
+#define OPTC_STATS		14
+#define OPTC_RATE		15
+#define OPTC_THRESHOLDS		16
+#define OPTC_PERSISTENTCONN	17
+#define OPTC_NOSORT		18
+#define OPTC_SYNCID		19
+#define OPTC_EXACT		20
+#define OPTC_ONEPACKET		21
+#define OPTC_PERSISTENCE_ENGINE	22
+#define OPTC_SCHED_FLAGS	23
+#define OPTC_MCAST_GROUP	24
+#define OPTC_MCAST_PORT		25
+#define OPTC_MCAST_TTL		26
+#define OPTC_SYNC_MAXLEN	27
+
 static const char* optnames[] = {
 	"numeric",
 	"connection",
@@ -320,9 +349,9 @@ static unsigned int parse_fwmark(char *buf);
 static unsigned int parse_sched_flags(const char *sched, char *optarg);
 
 /* check the options based on the commands_v_options table */
-static void generic_opt_check(int command, int options);
+static void generic_opt_check(int command, unsigned long long options);
 static void set_command(int *cmd, const int newcmd);
-static void set_option(unsigned int *options, unsigned int option);
+static void set_option(unsigned long long *options, int optc);
 
 static void tryhelp_exit(const char *program, const int exit_status);
 static void usage_exit(const char *program, const int exit_status);
@@ -416,7 +445,7 @@ static char *protocol_name(int proto)
 
 static int
 parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
-	      unsigned int *options, unsigned int *format)
+	      unsigned long long *options, unsigned int *format)
 {
 	int c, parse;
 	poptContext context;
@@ -575,7 +604,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		case 't':
 		case 'u':
 		case TAG_SCTP_SERVICE:
-			set_option(options, OPT_SERVICE);
+			set_option(options, OPTC_SERVICE);
 			ce->svc.protocol = option_to_protocol(c);
 			parse = parse_service(optarg, &ce->svc);
 			if (!(parse & SERVICE_ADDR))
@@ -583,7 +612,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 				     "address[:port] specified");
 			break;
 		case 'f':
-			set_option(options, OPT_SERVICE);
+			set_option(options, OPTC_SERVICE);
 			/*
 			 * Set protocol to a sane values, even
 			 * though it is not used
@@ -593,18 +622,18 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			ce->svc.fwmark = parse_fwmark(optarg);
 			break;
 		case 's':
-			set_option(options, OPT_SCHEDULER);
+			set_option(options, OPTC_SCHEDULER);
 			strncpy(ce->svc.sched_name,
 				optarg, IP_VS_SCHEDNAME_MAXLEN - 1);
 			break;
 		case 'p':
-			set_option(options, OPT_PERSISTENT);
+			set_option(options, OPTC_PERSISTENT);
 			ce->svc.flags |= IP_VS_SVC_F_PERSISTENT;
 			ce->svc.timeout =
 				parse_timeout(optarg, 1, MAX_TIMEOUT);
 			break;
 		case 'M':
-			set_option(options, OPT_NETMASK);
+			set_option(options, OPTC_NETMASK);
 			if (ce->svc.af != AF_INET6) {
 				parse = parse_netmask(optarg, &ce->svc.netmask);
 				if (parse != 1)
@@ -617,7 +646,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			}
 			break;
 		case 'r':
-			set_option(options, OPT_SERVER);
+			set_option(options, OPTC_SERVER);
 			ipvs_service_t t_dest = ce->svc;
 			parse = parse_service(optarg, &t_dest);
 			ce->dest.af = t_dest.af;
@@ -631,84 +660,84 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 				ce->dest.port = ce->svc.port;
 			break;
 		case 'i':
-			set_option(options, OPT_FORWARD);
+			set_option(options, OPTC_FORWARD);
 			ce->dest.conn_flags = IP_VS_CONN_F_TUNNEL;
 			break;
 		case 'g':
-			set_option(options, OPT_FORWARD);
+			set_option(options, OPTC_FORWARD);
 			ce->dest.conn_flags = IP_VS_CONN_F_DROUTE;
 			break;
 		case 'm':
-			set_option(options, OPT_FORWARD);
+			set_option(options, OPTC_FORWARD);
 			ce->dest.conn_flags = IP_VS_CONN_F_MASQ;
 			break;
 		case 'w':
-			set_option(options, OPT_WEIGHT);
+			set_option(options, OPTC_WEIGHT);
 			if ((ce->dest.weight =
 			     string_to_number(optarg, 0, 65535)) == -1)
 				fail(2, "illegal weight specified");
 			break;
 		case 'x':
-			set_option(options, OPT_UTHRESHOLD);
+			set_option(options, OPTC_UTHRESHOLD);
 			if ((ce->dest.u_threshold =
 			     string_to_number(optarg, 0, INT_MAX)) == -1)
 				fail(2, "illegal u_threshold specified");
 			break;
 		case 'y':
-			set_option(options, OPT_LTHRESHOLD);
+			set_option(options, OPTC_LTHRESHOLD);
 			if ((ce->dest.l_threshold =
 			     string_to_number(optarg, 0, INT_MAX)) == -1)
 				fail(2, "illegal l_threshold specified");
 			break;
 		case 'c':
-			set_option(options, OPT_CONNECTION);
+			set_option(options, OPTC_CONNECTION);
 			break;
 		case 'n':
-			set_option(options, OPT_NUMERIC);
+			set_option(options, OPTC_NUMERIC);
 			*format |= FMT_NUMERIC;
 			break;
 		case TAG_MCAST_INTERFACE:
-			set_option(options, OPT_MCAST);
+			set_option(options, OPTC_MCAST);
 			strncpy(ce->daemon.mcast_ifn,
 				optarg, IP_VS_IFNAME_MAXLEN - 1);
 			break;
 		case 'I':
-			set_option(options, OPT_SYNCID);
+			set_option(options, OPTC_SYNCID);
 			if ((ce->daemon.syncid =
 			     string_to_number(optarg, 0, 255)) == -1)
 				fail(2, "illegal syncid specified");
 			break;
 		case TAG_TIMEOUT:
-			set_option(options, OPT_TIMEOUT);
+			set_option(options, OPTC_TIMEOUT);
 			break;
 		case TAG_DAEMON:
-			set_option(options, OPT_DAEMON);
+			set_option(options, OPTC_DAEMON);
 			break;
 		case TAG_STATS:
-			set_option(options, OPT_STATS);
+			set_option(options, OPTC_STATS);
 			*format |= FMT_STATS;
 			break;
 		case TAG_RATE:
-			set_option(options, OPT_RATE);
+			set_option(options, OPTC_RATE);
 			*format |= FMT_RATE;
 			break;
 		case TAG_THRESHOLDS:
-			set_option(options, OPT_THRESHOLDS);
+			set_option(options, OPTC_THRESHOLDS);
 			*format |= FMT_THRESHOLDS;
 			break;
 		case TAG_PERSISTENTCONN:
-			set_option(options, OPT_PERSISTENTCONN);
+			set_option(options, OPTC_PERSISTENTCONN);
 			*format |= FMT_PERSISTENTCONN;
 			break;
 		case TAG_NO_SORT:
-			set_option(options, OPT_NOSORT	);
+			set_option(options, OPTC_NOSORT);
 			*format |= FMT_NOSORT;
 			break;
 		case TAG_SORT:
 			/* Sort is the default, this is a no-op for compatibility */
 			break;
 		case 'X':
-			set_option(options, OPT_EXACT);
+			set_option(options, OPTC_EXACT);
 			*format |= FMT_EXACT;
 			break;
 		case '6':
@@ -720,20 +749,20 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			}
 			break;
 		case 'o':
-			set_option(options, OPT_ONEPACKET);
+			set_option(options, OPTC_ONEPACKET);
 			ce->svc.flags |= IP_VS_SVC_F_ONEPACKET;
 			break;
 		case TAG_PERSISTENCE_ENGINE:
-			set_option(options, OPT_PERSISTENCE_ENGINE);
+			set_option(options, OPTC_PERSISTENCE_ENGINE);
 			strncpy(ce->svc.pe_name, optarg, IP_VS_PENAME_MAXLEN);
 			break;
 		case 'b':
-			set_option(options, OPT_SCHED_FLAGS);
+			set_option(options, OPTC_SCHED_FLAGS);
 			snprintf(sched_flags_arg, sizeof(sched_flags_arg),
 				"%s", optarg);
 			break;
 		case TAG_MCAST_GROUP:
-			set_option(options, OPT_MCAST_GROUP);
+			set_option(options, OPTC_MCAST_GROUP);
 			if (strchr(optarg, ':')) {
 				if (inet_pton(AF_INET6, optarg,
 					      &ce->daemon.mcast_group) <= 0 ||
@@ -753,21 +782,21 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			}
 			break;
 		case TAG_MCAST_PORT:
-			set_option(options, OPT_MCAST_PORT);
+			set_option(options, OPTC_MCAST_PORT);
 			parse = string_to_number(optarg, 1, 65535);
 			if (parse == -1)
 				fail(2, "illegal mcast-port specified");
 			ce->daemon.mcast_port = parse;
 			break;
 		case TAG_MCAST_TTL:
-			set_option(options, OPT_MCAST_TTL);
+			set_option(options, OPTC_MCAST_TTL);
 			parse = string_to_number(optarg, 1, 255);
 			if (parse == -1)
 				fail(2, "illegal mcast-ttl specified");
 			ce->daemon.mcast_ttl = parse;
 			break;
 		case TAG_SYNC_MAXLEN:
-			set_option(options, OPT_SYNC_MAXLEN);
+			set_option(options, OPTC_SYNC_MAXLEN);
 			parse = string_to_number(optarg, 1, 65535 - 20 - 8);
 			if (parse == -1)
 				fail(2, "illegal sync-maxlen specified");
@@ -845,7 +874,7 @@ static int restore_table(int argc, char **argv, int reading_stdin)
 static int process_options(int argc, char **argv, int reading_stdin)
 {
 	struct ipvs_command_entry ce;
-	unsigned int options = OPT_NONE;
+	unsigned long long options = OPT_NONE;
 	unsigned int format = FMT_NONE;
 	int result = 0;
 
@@ -1164,7 +1193,7 @@ static unsigned int parse_sched_flags(const char *sched, char *optarg)
 }
 
 static void
-generic_opt_check(int command, int options)
+generic_opt_check(int command, unsigned long long options)
 {
 	int i, j;
 	int last = 0, count = 0;
@@ -1173,7 +1202,7 @@ generic_opt_check(int command, int options)
 	i = command - CMD_NONE -1;
 
 	for (j = 0; j < NUMBER_OF_OPT; j++) {
-		if (!(options & (1<<j))) {
+		if (!(options & (1ULL<<j))) {
 			if (commands_v_options[i][j] == '+')
 				fail(2, "You need to supply the '%s' "
 				     "option for the '%s' command",
@@ -1197,15 +1226,6 @@ generic_opt_check(int command, int options)
 	}
 }
 
-static inline const char *
-opt2name(int option)
-{
-	const char **ptr;
-	for (ptr = optnames; option > 1; option >>= 1, ptr++);
-
-	return *ptr;
-}
-
 static void
 set_command(int *cmd, const int newcmd)
 {
@@ -1215,10 +1235,11 @@ set_command(int *cmd, const int newcmd)
 }
 
 static void
-set_option(unsigned int *options, unsigned int option)
+set_option(unsigned long long *options, int optc)
 {
+	unsigned long long option = 1ULL<<optc;
 	if (*options & option)
-		fail(2, "multiple '%s' options specified", opt2name(option));
+		fail(2, "multiple '%s' options specified", optnames[optc]);
 	*options |= option;
 }
 
-- 
2.21.0

