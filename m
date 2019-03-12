From: Jacky Hu <hengqing.hu@gmail.com>
Subject: [PATCH] ipvsadm: allow tunneling with gue encapsulation
Date: Tue, 12 Mar 2019 15:09:20 +0800
Message-ID: <20190312070920.21406-1-hengqing.hu@gmail.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
	h=from:to:cc:subject:date:message-id:mime-version
	:content-transfer-encoding;
	bh=A2BvQzDiJ3Glu6hr+LbYfVsvcr3s6Qvm4Vs/GWh5DZI=;
	b=kEZacS47te0DEoiJfFcu417bGVUSko/iXCxIp9gJe85EvvTpmdOrnTS8rHfegRWqY8
	jlQlTfzD8ZMO9qmVCHHV+uEU7hwUQN+O0NdsS8/Vatfhp2E+5wYfnn+0t5lLjoM/2Br9
	sdZw/nfN2NO3t47z7Km5cFPbrhnH5Bw6VdtXT3mnw5RQboaiEIkvdIhlnpqAD6E651Vp
	PdR8ZDUA6CWx/B+Ugb//AFx6Ki4t7t0cf8QHeGKkeflg1fluYpmT2JnhXbasxn+fJD5M
	WGN2UipqnFOMbxX1TfbLDPRTQKl8al2NnGjv/la2GgpKYX9f7V7gVWgXXd67DI97jLu5
	3Iig==
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

Added the following two options:
--gue-port with adding and editing destinations for tunneling servers.
--gue with listing services.

Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
---
 ipvsadm.c         | 109 +++++++++++++++++++++++++++++++++++++---------
 libipvs/ip_vs.h   |  16 +++++++
 libipvs/libipvs.c |   3 +-
 3 files changed, 106 insertions(+), 22 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 0cb2b68..a3d77d1 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -187,7 +187,9 @@ static const char* cmdnames[] = {
 #define OPT_MCAST_PORT		0x02000000
 #define OPT_MCAST_TTL		0x04000000
 #define OPT_SYNC_MAXLEN	0x08000000
-#define NUMBER_OF_OPT		28
+#define OPT_GUE_PORT	0x10000000
+#define OPT_GUE	0x20000000
+#define NUMBER_OF_OPT		30
 
 static const char* optnames[] = {
 	"numeric",
@@ -218,6 +220,8 @@ static const char* optnames[] = {
 	"mcast-port",
 	"mcast-ttl",
 	"sync-maxlen",
+	"gue-port",
+	"gue",
 };
 
 /*
@@ -230,21 +234,21 @@ static const char* optnames[] = {
  */
 static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 {
-	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe  -b   grp  port ttl  size */
-/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', 'x', 'x', 'x', 'x'},
-/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', 'x', 'x', 'x', 'x'},
-/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', ' ', ' ', ' ', ' '},
-/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe  -b   grp  port ttl  size  gue-port  gue */
+/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' '},
+/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x'},
+/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x'},
+/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', ' ', ' ', ' ', ' ', 'x', 'x'},
+/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
 };
 
 /* printing format flags */
@@ -257,6 +261,7 @@ static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 #define FMT_PERSISTENTCONN	0x0020
 #define FMT_NOSORT		0x0040
 #define FMT_EXACT		0x0080
+#define FMT_GUE		0x0100
 
 #define SERVICE_NONE		0x0000
 #define SERVICE_ADDR		0x0001
@@ -300,6 +305,8 @@ enum {
 	TAG_MCAST_PORT,
 	TAG_MCAST_TTL,
 	TAG_SYNC_MAXLEN,
+	TAG_GUE_PORT,
+	TAG_GUE,
 };
 
 /* various parsing helpers & parsing functions */
@@ -419,6 +426,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 	      unsigned int *options, unsigned int *format)
 {
 	int c, parse;
+	u_int16_t gue_port;
 	poptContext context;
 	char *optarg = NULL, sched_flags_arg[128];
 	struct poptOption options_table[] = {
@@ -495,6 +503,9 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		  TAG_MCAST_TTL, NULL, NULL },
 		{ "sync-maxlen", '\0', POPT_ARG_STRING, &optarg,
 		  TAG_SYNC_MAXLEN, NULL, NULL },
+		{ "gue-port", '\0', POPT_ARG_STRING, &optarg, TAG_GUE_PORT,
+		  NULL, NULL },
+		{ "gue", '\0', POPT_ARG_NONE, NULL, TAG_GUE, NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -773,6 +784,23 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 				fail(2, "illegal sync-maxlen specified");
 			ce->daemon.sync_maxlen = parse;
 			break;
+		case TAG_GUE_PORT:
+			set_option(options, OPT_GUE_PORT);
+			parse = string_to_number(optarg, 1, 65535);
+			if (parse == -1)
+				fail(2, "illegal gue port specified");
+			gue_port = (u_int16_t) parse;
+			ce->dest.conn_flags = (
+					(gue_port & 0xFFFE) << 16 |
+					(gue_port & 1) << 14 |
+					IP_VS_CONN_F_GUE |
+					ce->dest.conn_flags
+			);
+			break;
+		case TAG_GUE:
+			set_option(options, OPT_GUE);
+			*format |= FMT_GUE;
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -847,6 +875,7 @@ static int process_options(int argc, char **argv, int reading_stdin)
 	struct ipvs_command_entry ce;
 	unsigned int options = OPT_NONE;
 	unsigned int format = FMT_NONE;
+	unsigned int fwd_method;
 	int result = 0;
 
 	memset(&ce, 0, sizeof(struct ipvs_command_entry));
@@ -883,6 +912,8 @@ static int process_options(int argc, char **argv, int reading_stdin)
 	if (ce.cmd == CMD_STARTDAEMON && strlen(ce.daemon.mcast_ifn) == 0)
 		strcpy(ce.daemon.mcast_ifn, DEF_MCAST_IFN);
 
+	fwd_method = ce.dest.conn_flags & IP_VS_CONN_F_FWD_MASK;
+
 	if (ce.cmd == CMD_ADDDEST || ce.cmd == CMD_EDITDEST) {
 		/*
 		 * The destination port must be equal to the service port
@@ -890,15 +921,21 @@ static int process_options(int argc, char **argv, int reading_stdin)
 		 * Don't worry about this if fwmark is used.
 		 */
 		if (!ce.svc.fwmark &&
-		    (ce.dest.conn_flags == IP_VS_CONN_F_TUNNEL
-		     || ce.dest.conn_flags == IP_VS_CONN_F_DROUTE))
+		    (fwd_method == IP_VS_CONN_F_TUNNEL
+		     || fwd_method == IP_VS_CONN_F_DROUTE))
 			ce.dest.port = ce.svc.port;
 
 		/* Tunneling allows different address family */
 		if (ce.dest.af != ce.svc.af &&
-		    ce.dest.conn_flags != IP_VS_CONN_F_TUNNEL)
+		    fwd_method != IP_VS_CONN_F_TUNNEL)
 			fail(2, "Different address family is allowed only "
 			     "for tunneling servers");
+
+		/* Only tunneling allows gue encapsulation */
+		if ((options & OPT_GUE_PORT) &&
+		    fwd_method != IP_VS_CONN_F_TUNNEL)
+			fail(2,
+			     "GUE encapsulation is allowed only for tunneling servers");
 	}
 
 	switch (ce.cmd) {
@@ -1301,6 +1338,7 @@ static void usage_exit(const char *program, const int exit_status)
 		"  --gatewaying   -g                   gatewaying (direct routing) (default)\n"
 		"  --ipip         -i                   ipip encapsulation (tunneling)\n"
 		"  --masquerading -m                   masquerading (NAT)\n"
+		"  --gue-port      port                enable gue encapsulation with destination port\n"
 		"  --weight       -w weight            capacity of real server\n"
 		"  --u-threshold  -x uthreshold        upper threshold of connections\n"
 		"  --l-threshold  -y lthreshold        lower threshold of connections\n"
@@ -1312,6 +1350,7 @@ static void usage_exit(const char *program, const int exit_status)
 		"  --exact                             expand numbers (display exact values)\n"
 		"  --thresholds                        output of thresholds information\n"
 		"  --persistent-conn                   output of persistent connection info\n"
+		"  --gue                               output of gue encapsulation info (destination port)\n"
 		"  --nosort                            disable sorting output of service/server entries\n"
 		"  --sort                              does nothing, for backwards compatibility\n"
 		"  --ops          -o                   one-packet scheduling\n"
@@ -1548,6 +1587,14 @@ static inline char *fwd_name(unsigned flags)
 	return fwd;
 }
 
+static inline u_int16_t fwd_gue_port(unsigned int flags)
+{
+	u_int16_t gue_port;
+
+	gue_port = ((flags >> 16) & 0xFFFE) | ((flags >> 14) & 1);
+	return gue_port;
+}
+
 static inline char *fwd_switch(unsigned flags)
 {
 	char *swt = NULL;
@@ -1641,6 +1688,9 @@ static void print_title(unsigned int format)
 		       "  -> RemoteAddress:Port\n",
 		       "Prot LocalAddress:Port",
 		       "Weight", "PersistConn", "ActiveConn", "InActConn");
+	else if ((format & FMT_GUE))
+		printf("Prot LocalAddress:Port Scheduler Flags\n"
+		       "  -> RemoteAddress:Port           Forward GUE   Weight ActiveConn InActConn\n");
 	else if (!(format & FMT_RULE))
 		printf("Prot LocalAddress:Port Scheduler Flags\n"
 		       "  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn\n");
@@ -1778,8 +1828,20 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			dname[28] = '\0';
 
 		if (format & FMT_RULE) {
-			printf("-a %s -r %s %s -w %d\n", svc_name, dname,
-			       fwd_switch(e->conn_flags), e->weight);
+			if (e->conn_flags & IP_VS_CONN_F_GUE) {
+				printf("-a %s -r %s %s -w %d --gue-port %d\n",
+				       svc_name,
+				       dname,
+				       fwd_switch(e->conn_flags),
+				       e->weight,
+				       fwd_gue_port(e->conn_flags));
+			} else {
+				printf("-a %s -r %s %s -w %d\n",
+				       svc_name,
+				       dname,
+				       fwd_switch(e->conn_flags),
+				       e->weight);
+			}
 		} else if (format & FMT_STATS) {
 			printf("  -> %-28s", dname);
 			print_largenum(e->stats64.conns, format);
@@ -1804,6 +1866,11 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			printf("  -> %-28s %-9u %-11u %-10u %-10u\n", dname,
 			       e->weight, e->persistconns,
 			       e->activeconns, e->inactconns);
+		} else if (format & FMT_GUE) {
+			printf("  -> %-28s %-7s %-5d %-6d %-10u %-10u\n",
+			       dname, fwd_name(e->conn_flags),
+			       fwd_gue_port(e->conn_flags),
+			       e->weight, e->activeconns, e->inactconns);
 		} else
 			printf("  -> %-28s %-7s %-6d %-10u %-10u\n",
 			       dname, fwd_name(e->conn_flags),
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index ad0141c..6c7f6ee 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -101,6 +101,22 @@
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
+/* tunneling with gue */
+#define IP_VS_CONN_F_GUE	0x0008
+
+/* gue destination port bit 0 */
+#define IP_VS_CONN_F_GUE_PORT_LSB	0x4000
+
+/* gue destination port bit 1-15 */
+#define IP_VS_CONN_F_GUE_PORT_MSB	0xFFFFE0000
+
+/* Connection flags from destination that can be changed by user space */
+#define IP_VS_CONN_F_DEST_MASK (IP_VS_CONN_F_FWD_MASK | \
+				IP_VS_CONN_F_GUE | \
+				IP_VS_CONN_F_GUE_PORT_MSB | \
+				IP_VS_CONN_F_GUE_PORT_LSB | \
+				0)
+
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_PENAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 9be7700..a2d0018 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -388,7 +388,8 @@ static int ipvs_nl_fill_dest_attr(struct nl_msg *msg, ipvs_dest_t *dst)
 	NLA_PUT_U16(msg, IPVS_DEST_ATTR_ADDR_FAMILY, dst->af);
 	NLA_PUT(msg, IPVS_DEST_ATTR_ADDR, sizeof(dst->addr), &(dst->addr));
 	NLA_PUT_U16(msg, IPVS_DEST_ATTR_PORT, dst->port);
-	NLA_PUT_U32(msg, IPVS_DEST_ATTR_FWD_METHOD, dst->conn_flags & IP_VS_CONN_F_FWD_MASK);
+	NLA_PUT_U32(msg, IPVS_DEST_ATTR_FWD_METHOD,
+		    dst->conn_flags & IP_VS_CONN_F_DEST_MASK);
 	NLA_PUT_U32(msg, IPVS_DEST_ATTR_WEIGHT, dst->weight);
 	NLA_PUT_U32(msg, IPVS_DEST_ATTR_U_THRESH, dst->u_threshold);
 	NLA_PUT_U32(msg, IPVS_DEST_ATTR_L_THRESH, dst->l_threshold);
-- 
2.21.0

