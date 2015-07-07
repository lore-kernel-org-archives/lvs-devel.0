From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH ipvsadm RFC] ipvsadm: new attributes for sync daemon
Date: Tue,  7 Jul 2015 22:14:46 +0300
Message-ID: <1436296486-5668-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Phillip Moore <pdm@pobox.com>, lvs-users@linuxvirtualserver.org

Add support for --sync-maxlen, --mcast-group, --mcast-port and
--mcast-ttl options for the --start-daemon command.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 ipvsadm.8                 |  55 ++++++++++++++-----
 ipvsadm.c                 | 137 +++++++++++++++++++++++++++++++++++++---------
 libipvs/ip_vs.h           |  31 +++++++++++
 libipvs/ip_vs_nl_policy.c |   6 ++
 libipvs/libipvs.c         |  71 ++++++++++++++++++++++--
 5 files changed, 256 insertions(+), 44 deletions(-)

 Patch is for ipvsadm from git, use:
 git clone git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git
 cd ipvsadm/ && make

diff --git a/ipvsadm.8 b/ipvsadm.8
index 3df3b83..dad1712 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -59,7 +59,7 @@ ipvsadm \- Linux Virtual Server administration
 .br
 .B ipvsadm --set \fItcp\fP \fItcpfin\fP \fIudp\fP
 .br
-.B ipvsadm --start-daemon \fIstate\fP [--mcast-interface \fIinterface\fP]
+.B ipvsadm --start-daemon \fIstate\fP [daemon-options]
 .ti 15
 .B [--syncid \fIsyncid\fP]
 .br
@@ -167,7 +167,7 @@ balancer fails, a backup load balancer will takeover, and it has state
 of almost all connections, so that almost all established connections
 can continue to access the service.
 .PP
-The sync daemon currently only supports IPv4 connections.
+The sync daemon supports IPv4 and IPv6 connections.
 .TP
 .B --stop-daemon
 Stop the connection synchronization daemon.
@@ -359,18 +359,6 @@ connections drops below its lower connection threshold. If
 will receive new connections when the number of its connections drops
 below three forth of its upper connection threshold.
 .TP
-.B --mcast-interface \fIinterface\fP
-Specify the multicast interface that the sync master daemon sends
-outgoing multicasts through, or the sync backup daemon listens to for
-multicasts.
-.TP
-.B --syncid \fIsyncid\fP
-Specify the \fIsyncid\fP that the sync master daemon fills in the
-SyncID header while sending multicast messages, or the sync backup
-daemon uses to filter out multicast messages not matched with the
-SyncID value. The valid values of \fIsyncid\fP are 0 through to
-255. The default is 0, which means no filtering at all.
-.TP
 .B -c, --connection
 Connection output. The \fIlist\fP command with this option will list
 current IPVS connections.
@@ -438,6 +426,45 @@ One-packet scheduling.
 Used in conjunction with a UDP virtual service or
 a fwmark virtual service that handles only UDP packets.
 All connections are created such that they only schedule one packet.
+.SS PARAMETERS FOR SYNCHRONIZATION DAEMON
+The --start-daemon requires zero or more of the following
+parameters.
+.TP
+.B --syncid \fIsyncid\fP
+Specify the \fIsyncid\fP that the sync master daemon fills in the
+SyncID header while sending multicast messages, or the sync backup
+daemon uses to filter out multicast messages not matched with the
+SyncID value. The valid values of \fIsyncid\fP are 0 through to
+255. The default is 0, which means no filtering at all.
+.TP
+.B --sync-maxlen \fIlength\fP
+Specify the desired length of sync messages (UDP payload size).
+It is expected that backup server will use value not less than
+the used value in master server.
+The valid values of \fIlength\fP are in the 1 .. (65535 - 20 - 8)
+range but the kernel ensures a space for at least one sync message.
+If value is lower than MTU the sync messages will be fragmented by
+IP layer.
+The default value is derived from the MTU value when daemon is started
+but master daemon will not default to value above 1500 for compatibility
+reasons.
+.TP
+.B --mcast-interface \fIinterface\fP
+Specify the multicast interface that the sync master daemon sends
+outgoing multicasts through, or the sync backup daemon listens to for
+multicasts.
+.TP
+.B --mcast-group \fIaddress\fP
+Specify IPv4 or IPv6 multicast address for the sync messages.
+The default value is 224.0.0.81.
+.TP
+.B --mcast-port \fIport\fP
+Specify the UDP port for sync messages.
+The default value is 8848.
+.TP
+.B --mcast-ttl \fIttl\fP
+Specify the TTL value for sync messages (1 .. 255).
+The default value is 1.
 .SH EXAMPLE 1 - Simple Virtual Service
 The following commands configure a Linux Director to distribute
 incoming requests addressed to port 80 on 207.175.44.110 equally to
diff --git a/ipvsadm.c b/ipvsadm.c
index ff1601e..4d1e86e 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -183,7 +183,11 @@ static const char* cmdnames[] = {
 #define OPT_ONEPACKET		0x200000
 #define OPT_PERSISTENCE_ENGINE  0x400000
 #define OPT_SCHED_FLAGS		0x800000
-#define NUMBER_OF_OPT		24
+#define OPT_MCAST_GROUP		0x01000000
+#define OPT_MCAST_PORT		0x02000000
+#define OPT_MCAST_TTL		0x04000000
+#define OPT_SYNC_MAXLEN	0x08000000
+#define NUMBER_OF_OPT		28
 
 static const char* optnames[] = {
 	"numeric",
@@ -210,6 +214,10 @@ static const char* optnames[] = {
 	"ops",
 	"pe",
 	"sched-flags",
+	"mcast-group",
+	"mcast-port",
+	"mcast-ttl",
+	"sync-maxlen",
 };
 
 /*
@@ -222,21 +230,21 @@ static const char* optnames[] = {
  */
 static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 {
-	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe  -b */
-/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' '},
-/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' '},
-/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x'},
-/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x'},
-/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x'},
-/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe  -b   grp  port ttl  size */
+/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', 'x', 'x', 'x', 'x'},
+/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', 'x', 'x', 'x', 'x'},
+/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', ' ', ' ', ' ', ' '},
+/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
 };
 
 /* printing format flags */
@@ -288,6 +296,10 @@ enum {
 	TAG_NO_SORT,
 	TAG_PERSISTENCE_ENGINE,
 	TAG_SCTP_SERVICE,
+	TAG_MCAST_GROUP,
+	TAG_MCAST_PORT,
+	TAG_MCAST_TTL,
+	TAG_SYNC_MAXLEN,
 };
 
 /* various parsing helpers & parsing functions */
@@ -475,6 +487,14 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		  NULL, NULL },
 		{ "sched-flags", 'b', POPT_ARG_STRING, &optarg, 'b',
 		  NULL, NULL },
+		{ "mcast-group", '\0', POPT_ARG_STRING, &optarg,
+		  TAG_MCAST_GROUP, NULL, NULL },
+		{ "mcast-port", '\0', POPT_ARG_STRING, &optarg,
+		  TAG_MCAST_PORT, NULL, NULL },
+		{ "mcast-ttl", '\0', POPT_ARG_STRING, &optarg,
+		  TAG_MCAST_TTL, NULL, NULL },
+		{ "sync-maxlen", '\0', POPT_ARG_STRING, &optarg,
+		  TAG_SYNC_MAXLEN, NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -712,6 +732,47 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			snprintf(sched_flags_arg, sizeof(sched_flags_arg),
 				"%s", optarg);
 			break;
+		case TAG_MCAST_GROUP:
+			set_option(options, OPT_MCAST_GROUP);
+			if (strchr(optarg, ':')) {
+				if (inet_pton(AF_INET6, optarg,
+					      &ce->daemon.mcast_group) <= 0 ||
+				    !IN6_IS_ADDR_MULTICAST(
+				     &ce->daemon.mcast_group.in6))
+					fail(2, "invalid IPv6 mcast-group `%s'",
+					     optarg);
+				ce->daemon.mcast_af = AF_INET6;
+			} else {
+				if (inet_pton(AF_INET, optarg,
+					      &ce->daemon.mcast_group) <= 0 ||
+				    !IN_MULTICAST(ntohl(
+						  ce->daemon.mcast_group.ip)))
+					fail(2, "invalid IPv4 mcast-group `%s'",
+					     optarg);
+				ce->daemon.mcast_af = AF_INET;
+			}
+			break;
+		case TAG_MCAST_PORT:
+			set_option(options, OPT_MCAST_PORT);
+			parse = string_to_number(optarg, 1, 65535);
+			if (parse == -1)
+				fail(2, "illegal mcast-port specified");
+			ce->daemon.mcast_port = parse;
+			break;
+		case TAG_MCAST_TTL:
+			set_option(options, OPT_MCAST_TTL);
+			parse = string_to_number(optarg, 1, 255);
+			if (parse == -1)
+				fail(2, "illegal mcast-ttl specified");
+			ce->daemon.mcast_ttl = parse;
+			break;
+		case TAG_SYNC_MAXLEN:
+			set_option(options, OPT_SYNC_MAXLEN);
+			parse = string_to_number(optarg, 1, 65535 - 20 - 8);
+			if (parse == -1)
+				fail(2, "illegal sync-maxlen specified");
+			ce->daemon.sync_maxlen = parse;
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -1182,8 +1243,8 @@ static void usage_exit(const char *program, const int exit_status)
 		"  %s -L|l [virtual-service] [options]\n"
 		"  %s -Z [virtual-service]\n"
 		"  %s --set tcp tcpfin udp\n"
-		"  %s --start-daemon state [--mcast-interface interface] [--syncid sid]\n"
-		"  %s --stop-daemon state\n"
+		"  %s --start-daemon {master|backup} [daemon-options]\n"
+		"  %s --stop-daemon {master|backup}\n"
 		"  %s -h\n\n",
 		program, program, program,
 		program, program, program, program, program,
@@ -1233,8 +1294,6 @@ static void usage_exit(const char *program, const int exit_status)
 		"  --weight       -w weight            capacity of real server\n"
 		"  --u-threshold  -x uthreshold        upper threshold of connections\n"
 		"  --l-threshold  -y lthreshold        lower threshold of connections\n"
-		"  --mcast-interface interface         multicast interface for connection sync\n"
-		"  --syncid sid                        syncid for connection sync (default=255)\n"
 		"  --connection   -c                   output of current IPVS connections\n"
 		"  --timeout                           output of timeout (tcp tcpfin udp)\n"
 		"  --daemon                            output of daemon information\n"
@@ -1250,6 +1309,16 @@ static void usage_exit(const char *program, const int exit_status)
 		"  --sched-flags  -b flags             scheduler flags (comma-separated)\n",
 		DEF_SCHED);
 
+	fprintf(stream,
+		"Daemon Options:\n"
+		"  --syncid sid                        syncid for connection sync (default=255)\n"
+		"  --sync-maxlen length                Max sync message length (default=1472)\n"
+		"  --mcast-interface interface         multicast interface for connection sync\n"
+		"  --mcast-group address               IPv4/IPv6 group (default=224.0.0.81)\n"
+		"  --mcast-port port                   UDP port (default=8848)\n"
+		"  --mcast-ttl ttl                     Multicast TTL (default=1)\n"
+		);
+
 	exit(exit_status);
 }
 
@@ -1793,12 +1862,30 @@ static void list_daemon(void)
 		exit(1);
 
 	for (i = 0; i < 2; i++) {
+		char *type;
+
 		if (u[i].state & IP_VS_STATE_MASTER)
-			printf("master sync daemon (mcast=%s, syncid=%d)\n",
-			       u[i].mcast_ifn, u[i].syncid);
-		if (u[i].state & IP_VS_STATE_BACKUP)
-			printf("backup sync daemon (mcast=%s, syncid=%d)\n",
-			       u[i].mcast_ifn, u[i].syncid);
+			type = "master";
+		else if (u[i].state & IP_VS_STATE_BACKUP)
+			type = "backup";
+		else
+			continue;
+		printf("%s sync daemon (mcast=%s, syncid=%d",
+		       type, u[i].mcast_ifn, u[i].syncid);
+		if (u[i].sync_maxlen)
+			printf(", maxlen=%u", u[i].sync_maxlen);
+		if (u[i].mcast_af != AF_UNSPEC) {
+			char addr[INET6_ADDRSTRLEN];
+
+			if (inet_ntop(u[i].mcast_af, &u[i].mcast_group,
+				      addr, sizeof(addr)))
+				printf(", group=%s", addr);
+		}
+		if (u[i].mcast_port)
+			printf(", port=%u", u[i].mcast_port);
+		if (u[i].mcast_ttl)
+			printf(", ttl=%u", u[i].mcast_ttl);
+		printf(")\n");
 	}
 	free(u);
 }
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index 5a42a0c..f855cc6 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -348,6 +348,17 @@ struct ip_vs_timeout_user {
 
 
 /* The argument to IP_VS_SO_GET_DAEMON */
+struct ip_vs_daemon_kern {
+	/* sync daemon state (master/backup) */
+	int			state;
+
+	/* multicast interface name */
+	char			mcast_ifn[IP_VS_IFNAME_MAXLEN];
+
+	/* SyncID we belong to */
+	int			syncid;
+};
+
 struct ip_vs_daemon_user {
 	/* sync daemon state (master/backup) */
 	int			state;
@@ -357,6 +368,21 @@ struct ip_vs_daemon_user {
 
 	/* SyncID we belong to */
 	int			syncid;
+
+	/* UDP Payload Size */
+	int			sync_maxlen;
+
+	/* Multicast Port (base) */
+	u_int16_t		mcast_port;
+
+	/* Multicast TTL */
+	u_int16_t		mcast_ttl;
+
+	/* Multicast Address Family */
+	u_int16_t		mcast_af;
+
+	/* Multicast Address */
+	union nf_inet_addr	mcast_group;
 };
 
 
@@ -488,6 +514,11 @@ enum {
 	IPVS_DAEMON_ATTR_STATE,		/* sync daemon state (master/backup) */
 	IPVS_DAEMON_ATTR_MCAST_IFN,	/* multicast interface name */
 	IPVS_DAEMON_ATTR_SYNC_ID,	/* SyncID we belong to */
+	IPVS_DAEMON_ATTR_SYNC_MAXLEN,	/* UDP Payload Size */
+	IPVS_DAEMON_ATTR_MCAST_GROUP,	/* IPv4 Multicast Address */
+	IPVS_DAEMON_ATTR_MCAST_GROUP6,	/* IPv6 Multicast Address */
+	IPVS_DAEMON_ATTR_MCAST_PORT,	/* Multicast Port (base) */
+	IPVS_DAEMON_ATTR_MCAST_TTL,	/* Multicast TTL */
 	__IPVS_DAEMON_ATTR_MAX,
 };
 
diff --git a/libipvs/ip_vs_nl_policy.c b/libipvs/ip_vs_nl_policy.c
index c80083e..2d65224 100644
--- a/libipvs/ip_vs_nl_policy.c
+++ b/libipvs/ip_vs_nl_policy.c
@@ -65,6 +65,12 @@ struct nla_policy ipvs_daemon_policy[IPVS_DAEMON_ATTR_MAX + 1] = {
 	[IPVS_DAEMON_ATTR_MCAST_IFN]	= { .type = NLA_STRING,
 					    .maxlen = IP_VS_IFNAME_MAXLEN },
 	[IPVS_DAEMON_ATTR_SYNC_ID]	= { .type = NLA_U32 },
+	[IPVS_DAEMON_ATTR_SYNC_MAXLEN]	= { .type = NLA_U16 },
+	[IPVS_DAEMON_ATTR_MCAST_GROUP]	= { .type = NLA_U32 },
+	[IPVS_DAEMON_ATTR_MCAST_GROUP6]	= { .type = NLA_UNSPEC,
+					    .maxlen = sizeof(struct in6_addr) },
+	[IPVS_DAEMON_ATTR_MCAST_PORT]	= { .type = NLA_U16 },
+	[IPVS_DAEMON_ATTR_MCAST_TTL]	= { .type = NLA_U8 },
 };
 
 #endif /* LIBIPVS_USE_NL */
diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 0bfb428..614001d 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -485,6 +485,8 @@ nla_put_failure:
 
 int ipvs_start_daemon(ipvs_daemon_t *dm)
 {
+	struct ip_vs_daemon_kern dmk;
+
 	ipvs_func = ipvs_start_daemon;
 #ifdef LIBIPVS_USE_NL
 	if (try_nl) {
@@ -499,6 +501,22 @@ int ipvs_start_daemon(ipvs_daemon_t *dm)
 		NLA_PUT_U32(msg, IPVS_DAEMON_ATTR_STATE, dm->state);
 		NLA_PUT_STRING(msg, IPVS_DAEMON_ATTR_MCAST_IFN, dm->mcast_ifn);
 		NLA_PUT_U32(msg, IPVS_DAEMON_ATTR_SYNC_ID, dm->syncid);
+		if (dm->sync_maxlen)
+			NLA_PUT_U16(msg, IPVS_DAEMON_ATTR_SYNC_MAXLEN,
+				    dm->sync_maxlen);
+		if (dm->mcast_port)
+			NLA_PUT_U16(msg, IPVS_DAEMON_ATTR_MCAST_PORT,
+				    dm->mcast_port);
+		if (dm->mcast_ttl)
+			NLA_PUT_U8(msg, IPVS_DAEMON_ATTR_MCAST_TTL,
+				   dm->mcast_ttl);
+		if (AF_INET6 == dm->mcast_af)
+			NLA_PUT(msg, IPVS_DAEMON_ATTR_MCAST_GROUP6,
+				sizeof(dm->mcast_group.in6),
+				&dm->mcast_group.in6);
+		else if (AF_INET == dm->mcast_af)
+			NLA_PUT_U32(msg, IPVS_DAEMON_ATTR_MCAST_GROUP,
+				    dm->mcast_group.ip);
 
 		nla_nest_end(msg, nl_daemon);
 
@@ -509,13 +527,19 @@ nla_put_failure:
 		return -1;
 	}
 #endif
+	memset(&dmk, 0, sizeof(dmk));
+	dmk.state = dm->state;
+	strcpy(dmk.mcast_ifn, dm->mcast_ifn);
+	dmk.syncid = dm->syncid;
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_STARTDAEMON,
-			  (char *)dm, sizeof(*dm));
+			  (char *)&dmk, sizeof(dmk));
 }
 
 
 int ipvs_stop_daemon(ipvs_daemon_t *dm)
 {
+	struct ip_vs_daemon_kern dmk;
+
 	ipvs_func = ipvs_stop_daemon;
 #ifdef LIBIPVS_USE_NL
 	if (try_nl) {
@@ -540,8 +564,10 @@ nla_put_failure:
 		return -1;
 	}
 #endif
+	memset(&dmk, 0, sizeof(dmk));
+	dmk.state = dm->state;
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_STOPDAEMON,
-			  (char *)dm, sizeof(*dm));
+			  (char *)&dmk, sizeof(dmk));
 }
 
 #ifdef LIBIPVS_USE_NL
@@ -1065,6 +1091,7 @@ static int ipvs_daemon_parse_cb(struct nl_msg *msg, void *arg)
 	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
 	struct nlattr *daemon_attrs[IPVS_DAEMON_ATTR_MAX + 1];
 	ipvs_daemon_t *u = (ipvs_daemon_t *)arg;
+	struct nlattr *a;
 	int i = 0;
 
 	/* We may get two daemons.  If we've already got one, this is the second */
@@ -1089,26 +1116,54 @@ static int ipvs_daemon_parse_cb(struct nl_msg *msg, void *arg)
 		IP_VS_IFNAME_MAXLEN);
 	u[i].syncid = nla_get_u32(daemon_attrs[IPVS_DAEMON_ATTR_SYNC_ID]);
 
+	a = daemon_attrs[IPVS_DAEMON_ATTR_SYNC_MAXLEN];
+	if (a)
+		u[i].sync_maxlen = nla_get_u16(a);
+
+	a = daemon_attrs[IPVS_DAEMON_ATTR_MCAST_PORT];
+	if (a)
+		u[i].mcast_port = nla_get_u16(a);
+
+	a = daemon_attrs[IPVS_DAEMON_ATTR_MCAST_TTL];
+	if (a)
+		u[i].mcast_ttl = nla_get_u8(a);
+
+	a = daemon_attrs[IPVS_DAEMON_ATTR_MCAST_GROUP];
+	if (a) {
+		u[i].mcast_af = AF_INET;
+		u[i].mcast_group.ip = nla_get_u32(a);
+	} else {
+		a = daemon_attrs[IPVS_DAEMON_ATTR_MCAST_GROUP6];
+		if (a) {
+			u[i].mcast_af = AF_INET6;
+			memcpy(&u[i].mcast_group.in6, nla_data(a),
+			       sizeof(u[i].mcast_group.in6));
+		}
+	}
+
 	return NL_OK;
 }
 #endif
 
 ipvs_daemon_t *ipvs_get_daemon(void)
 {
+	struct ip_vs_daemon_kern dmk[2];
 	ipvs_daemon_t *u;
 	socklen_t len;
+	int i;
 
 	/* note that we need to get the info about two possible
 	   daemons, master and backup. */
 	len = sizeof(*u) * 2;
-	if (!(u = malloc(len)))
+	u = calloc(len, 1);
+	if (!u)
 		return NULL;
 
 	ipvs_func = ipvs_get_daemon;
 #ifdef LIBIPVS_USE_NL
 	if (try_nl) {
 		struct nl_msg *msg;
-		memset(u, 0, len);
+
 		msg = ipvs_nl_message(IPVS_CMD_GET_DAEMON, NLM_F_DUMP);
 		if (msg && (ipvs_nl_send_message(msg, ipvs_daemon_parse_cb, u) == 0))
 			return u;
@@ -1117,10 +1172,16 @@ ipvs_daemon_t *ipvs_get_daemon(void)
 		return NULL;
 	}
 #endif
-	if (getsockopt(sockfd, IPPROTO_IP, IP_VS_SO_GET_DAEMON, (char *)u, &len)) {
+	if (getsockopt(sockfd, IPPROTO_IP, IP_VS_SO_GET_DAEMON, (char *)dmk,
+		       &len)) {
 		free(u);
 		return NULL;
 	}
+	for (i = 0; i < 2; i++) {
+		u[i].state = dmk[i].state;
+		strncpy(u[i].mcast_ifn, dmk[i].mcast_ifn, IP_VS_IFNAME_MAXLEN);
+		u[i].syncid = dmk[i].syncid;
+	}
 	return u;
 }
 
-- 
1.9.3

