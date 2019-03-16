From: Jacky Hu <hengqing.hu@gmail.com>
Subject: [PATCH v2] ipvsadm: allow tunneling with gue
	encapsulation
Date: Sat, 16 Mar 2019 14:07:08 +0800
Message-ID: <20190316060708.4774-1-hengqing.hu@gmail.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
	h=from:to:cc:subject:date:message-id:mime-version
	:content-transfer-encoding;
	bh=Nt1Y817UL92knoSEz16mttWRUrCoxipo9NXWi1e3I4w=;
	b=Rzz97hH4+tNznUZ+egLclCzBKib3EyiOxHkwr2gvvzy++cNy5Y38qwc4N03Dcjc013
	KzD5H0PrmqfKlDW288/iDIwpbrj5tQUvrMyZSurAeaxVhXRH/95mh9kkRsb7O/MCQ5RZ
	ZlyicDSm6/7leE4dUieUz/ShMNEGwsaYvifkeTh+9dlgeUNOt1x7gOiyGNLRLWVA2GQu
	a0lf4jbnCjubovyWyUhL/mC0IN6Ndg75nxO7teAzbngPtM0Fb11aQ20UIBQrA7OZU9Rp
	ERM+tz4eIR1wwa2nG91DFOwMeiXHj84oBEADufeAVzY7KCW2dPXsnkgbrc+gqUd4/Hue
	z/lw==
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

Added the following options:
--tun-type with adding and editing destinations for tunneling servers.
--tun-port with adding and editing destinations for tunneling servers.
--tun-info with listing services.

Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
---
 Makefile          |   2 +-
 ipvsadm.c         | 256 ++++++++++++++++++++++++++++++++++++++++++----
 libipvs/ip_vs.h   |  27 +++++
 libipvs/libipvs.c |  10 ++
 4 files changed, 272 insertions(+), 23 deletions(-)

diff --git a/Makefile b/Makefile
index 91a2991..63c4389 100644
--- a/Makefile
+++ b/Makefile
@@ -63,7 +63,7 @@ RPMBUILD = $(shell				\
 	fi )
 
 OBJS		= ipvsadm.o config_stream.o dynamic_array.o
-LIBS		= -lpopt
+LIBS		= -lpopt -lm
 ifneq (0,$(HAVE_NL))
 LIBS		+= $(shell \
 		if which pkg-config > /dev/null 2>&1; then \
diff --git a/ipvsadm.c b/ipvsadm.c
index 0cb2b68..2ff4171 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -105,6 +105,7 @@
 #include <sys/param.h>
 #include <sys/wait.h>           /* For waitpid */
 #include <arpa/inet.h>
+#include <math.h>
 
 #include <net/if.h>
 #include <netinet/ip_icmp.h>
@@ -187,7 +188,10 @@ static const char* cmdnames[] = {
 #define OPT_MCAST_PORT		0x02000000
 #define OPT_MCAST_TTL		0x04000000
 #define OPT_SYNC_MAXLEN	0x08000000
-#define NUMBER_OF_OPT		28
+#define OPT_TUN_INFO		0x10000000
+#define OPT_TUN_TYPE		0x20000000
+#define OPT_TUN_PORT		0x40000000
+#define NUMBER_OF_OPT		31
 
 static const char* optnames[] = {
 	"numeric",
@@ -218,6 +222,9 @@ static const char* optnames[] = {
 	"mcast-port",
 	"mcast-ttl",
 	"sync-maxlen",
+	"tun-info",
+	"tun-type",
+	"tun-port",
 };
 
 /*
@@ -230,21 +237,48 @@ static const char* optnames[] = {
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
+	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe  -b   grp  port ttl  size  tun-info  tun-type  tun-port */
+/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x'},
+/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' '},
+/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' '},
+/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', ' ', ' ', ' ', ' ', 'x', 'x', 'x'},
+/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+};
+
+static const char * const tunnames[] = {
+	"ipip",
+	"gue",
+};
+
+static const unsigned int tunopts[] = {
+	OPT_TUN_PORT,
+};
+
+#define NUMBER_OF_TUN_OPT		1
+#define NA				"n/a"
+
+/*
+ * Table of legal combinations of tunnel types and options.
+ * Key:
+ *  '+'  compulsory
+ *  'x'  illegal
+ *  '1'  exclusive (only one '1' option can be supplied)
+ *  ' '  optional
+ */
+static const char
+tunnel_types_v_options[IP_VS_CONN_F_TUNNEL_TYPE_MAX][NUMBER_OF_TUN_OPT] = {
+	/* tun-port */
+/* ipip */ {'x'},
+/* gue */  {'+'},
 };
 
 /* printing format flags */
@@ -257,6 +291,7 @@ static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 #define FMT_PERSISTENTCONN	0x0020
 #define FMT_NOSORT		0x0040
 #define FMT_EXACT		0x0080
+#define FMT_TUN_INFO		0x0100
 
 #define SERVICE_NONE		0x0000
 #define SERVICE_ADDR		0x0001
@@ -265,6 +300,9 @@ static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 /* default scheduler */
 #define DEF_SCHED		"wlc"
 
+/* default tunnel type */
+#define DEF_TUNNEL_TYPE	"ipip"
+
 /* default multicast interface name */
 #define DEF_MCAST_IFN		"eth0"
 
@@ -300,6 +338,9 @@ enum {
 	TAG_MCAST_PORT,
 	TAG_MCAST_TTL,
 	TAG_SYNC_MAXLEN,
+	TAG_TUN_INFO,
+	TAG_TUN_TYPE,
+	TAG_TUN_PORT,
 };
 
 /* various parsing helpers & parsing functions */
@@ -318,12 +359,16 @@ static int parse_netmask(char *buf, u_int32_t *addr);
 static int parse_timeout(char *buf, int min, int max);
 static unsigned int parse_fwmark(char *buf);
 static unsigned int parse_sched_flags(const char *sched, char *optarg);
+static unsigned int parse_tun_type(const char *name);
 
 /* check the options based on the commands_v_options table */
 static void generic_opt_check(int command, int options);
 static void set_command(int *cmd, const int newcmd);
 static void set_option(unsigned int *options, unsigned int option);
 
+/* check the options based on the tunnel_types_v_options table */
+static void tunnel_opt_check(int tun_type, int options);
+
 static void tryhelp_exit(const char *program, const int exit_status);
 static void usage_exit(const char *program, const int exit_status);
 static void version_exit(int exit_status);
@@ -495,6 +540,12 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		  TAG_MCAST_TTL, NULL, NULL },
 		{ "sync-maxlen", '\0', POPT_ARG_STRING, &optarg,
 		  TAG_SYNC_MAXLEN, NULL, NULL },
+		{ "tun-info", '\0', POPT_ARG_NONE, NULL, TAG_TUN_INFO,
+		  NULL, NULL },
+		{ "tun-type", '\0', POPT_ARG_STRING, &optarg, TAG_TUN_TYPE,
+		  NULL, NULL },
+		{ "tun-port", '\0', POPT_ARG_STRING, &optarg, TAG_TUN_PORT,
+		  NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -773,6 +824,24 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 				fail(2, "illegal sync-maxlen specified");
 			ce->daemon.sync_maxlen = parse;
 			break;
+		case TAG_TUN_INFO:
+			set_option(options, OPT_TUN_INFO);
+			*format |= FMT_TUN_INFO;
+			break;
+		case TAG_TUN_TYPE:
+			set_option(options, OPT_TUN_TYPE);
+			parse = parse_tun_type(optarg);
+			if (parse == -1)
+				fail(2, "illegal tunnel type specified");
+			ce->dest.tun_type = parse;
+			break;
+		case TAG_TUN_PORT:
+			set_option(options, OPT_TUN_PORT);
+			parse = string_to_number(optarg, 1, 65535);
+			if (parse == -1)
+				fail(2, "illegal tunnel port specified");
+			ce->dest.tun_port = parse;
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -847,12 +916,17 @@ static int process_options(int argc, char **argv, int reading_stdin)
 	struct ipvs_command_entry ce;
 	unsigned int options = OPT_NONE;
 	unsigned int format = FMT_NONE;
+	unsigned int fwd_method;
 	int result = 0;
 
 	memset(&ce, 0, sizeof(struct ipvs_command_entry));
 	ce.cmd = CMD_NONE;
 	/* Set the default weight 1 */
 	ce.dest.weight = 1;
+	/* Set the default tunnel type 0(ipip) */
+	ce.dest.tun_type = 0;
+	/* Set the default tunnel port 0(n/a) */
+	ce.dest.tun_port = 0;
 	/* Set direct routing as default forwarding method */
 	ce.dest.conn_flags = IP_VS_CONN_F_DROUTE;
 	/* Set the default persistent granularity to /32 mask */
@@ -883,6 +957,8 @@ static int process_options(int argc, char **argv, int reading_stdin)
 	if (ce.cmd == CMD_STARTDAEMON && strlen(ce.daemon.mcast_ifn) == 0)
 		strcpy(ce.daemon.mcast_ifn, DEF_MCAST_IFN);
 
+	fwd_method = ce.dest.conn_flags & IP_VS_CONN_F_FWD_MASK;
+
 	if (ce.cmd == CMD_ADDDEST || ce.cmd == CMD_EDITDEST) {
 		/*
 		 * The destination port must be equal to the service port
@@ -890,15 +966,23 @@ static int process_options(int argc, char **argv, int reading_stdin)
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
+		/* Only tunneling allows encapsulation details */
+		if ((options & (OPT_TUN_TYPE|OPT_TUN_PORT)) &&
+		    fwd_method != IP_VS_CONN_F_TUNNEL)
+			fail(2,
+			     "Encapsulation details are allowed only for tunneling servers");
+
+		tunnel_opt_check(ce.dest.tun_type, options);
 	}
 
 	switch (ce.cmd) {
@@ -1163,6 +1247,20 @@ static unsigned int parse_sched_flags(const char *sched, char *optarg)
 	return flags;
 }
 
+static unsigned int parse_tun_type(const char *tun_type)
+{
+	unsigned int type = -1;
+
+	if (!strcmp(tun_type, "ipip"))
+		type = IP_VS_CONN_F_TUNNEL_TYPE_IPIP;
+	else if (!strcmp(tun_type, "gue"))
+		type = IP_VS_CONN_F_TUNNEL_TYPE_GUE;
+	else
+		type = -1;
+
+	return type;
+}
+
 static void
 generic_opt_check(int command, int options)
 {
@@ -1197,6 +1295,41 @@ generic_opt_check(int command, int options)
 	}
 }
 
+static void
+tunnel_opt_check(int tun_type, int options)
+{
+	int i, j, k;
+	int last = 0, count = 0;
+
+	/* Check that tunnel types are valid with options. */
+	i = tun_type;
+
+	for (j = 0; j < NUMBER_OF_TUN_OPT; j++) {
+		k = log(tunopts[j]) / log(2);
+		if (!(options & (1<<k))) {
+			if (tunnel_types_v_options[i][j] == '+')
+				fail(2, "You need to supply the '%s' "
+				     "option for the '%s' tunnel type",
+				     optnames[k], tunnames[i]);
+		} else {
+			if (tunnel_types_v_options[i][j] == 'x')
+				fail(2, "Illegal '%s' option with "
+				     "the '%s' tunnel type",
+				     optnames[k], tunnames[i]);
+			if (tunnel_types_v_options[i][j] == '1') {
+				count++;
+				if (count == 1) {
+					last = k;
+					continue;
+				}
+				fail(2, "The option '%s' conflicts with the "
+				     "'%s' option in the '%s' tunnel type",
+				     optnames[k], optnames[last], tunnames[i]);
+			}
+		}
+	}
+}
+
 static inline const char *
 opt2name(int option)
 {
@@ -1301,6 +1434,9 @@ static void usage_exit(const char *program, const int exit_status)
 		"  --gatewaying   -g                   gatewaying (direct routing) (default)\n"
 		"  --ipip         -i                   ipip encapsulation (tunneling)\n"
 		"  --masquerading -m                   masquerading (NAT)\n"
+		"  --tun-type      type                one of ipip|gue,\n"
+		"                                      the default tunnel type is %s.\n"
+		"  --tun-port      port                tunnel destination port\n"
 		"  --weight       -w weight            capacity of real server\n"
 		"  --u-threshold  -x uthreshold        upper threshold of connections\n"
 		"  --l-threshold  -y lthreshold        lower threshold of connections\n"
@@ -1312,12 +1448,13 @@ static void usage_exit(const char *program, const int exit_status)
 		"  --exact                             expand numbers (display exact values)\n"
 		"  --thresholds                        output of thresholds information\n"
 		"  --persistent-conn                   output of persistent connection info\n"
+		"  --tun-info                          output of tunnel information\n"
 		"  --nosort                            disable sorting output of service/server entries\n"
 		"  --sort                              does nothing, for backwards compatibility\n"
 		"  --ops          -o                   one-packet scheduling\n"
 		"  --numeric      -n                   numeric output of addresses and ports\n"
 		"  --sched-flags  -b flags             scheduler flags (comma-separated)\n",
-		DEF_SCHED);
+		DEF_SCHED, DEF_TUNNEL_TYPE);
 
 	fprintf(stream,
 		"Daemon Options:\n"
@@ -1565,6 +1702,46 @@ static inline char *fwd_switch(unsigned flags)
 }
 
 
+static inline char *fwd_tun_type(ipvs_dest_entry_t *e)
+{
+	char *type = malloc(8);
+
+	if (!type)
+		return NA;
+
+	switch (e->conn_flags & IP_VS_CONN_F_FWD_MASK) {
+	case IP_VS_CONN_F_TUNNEL:
+		snprintf(type, 8, "%s", tunnames[e->tun_type]); break;
+	default:
+		snprintf(type, 8, "%s", NA); break;
+	}
+	return type;
+}
+
+
+static inline char *fwd_tun_port(ipvs_dest_entry_t *e)
+{
+	char *port = malloc(8);
+
+	if (!port)
+		return NA;
+
+	switch (e->conn_flags & IP_VS_CONN_F_FWD_MASK) {
+	case IP_VS_CONN_F_TUNNEL:
+		switch (e->tun_type) {
+		case IP_VS_CONN_F_TUNNEL_TYPE_IPIP:
+			snprintf(port, 8, "%s", NA); break;
+		default:
+			snprintf(port, 8, "%d", e->tun_port); break;
+		}
+		break;
+	default:
+		snprintf(port, 8, "%s", NA); break;
+	}
+	return port;
+}
+
+
 static void print_largenum(unsigned long long i, unsigned int format)
 {
 	if (format & FMT_EXACT) {
@@ -1641,6 +1818,9 @@ static void print_title(unsigned int format)
 		       "  -> RemoteAddress:Port\n",
 		       "Prot LocalAddress:Port",
 		       "Weight", "PersistConn", "ActiveConn", "InActConn");
+	else if ((format & FMT_TUN_INFO))
+		printf("Prot LocalAddress:Port Scheduler Flags\n"
+		       "  -> RemoteAddress:Port           Forward TunType TunPort Weight ActiveConn InActConn\n");
 	else if (!(format & FMT_RULE))
 		printf("Prot LocalAddress:Port Scheduler Flags\n"
 		       "  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn\n");
@@ -1768,6 +1948,7 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 	for (i = 0; i < d->num_dests; i++) {
 		char *dname;
 		ipvs_dest_entry_t *e = &d->entrytable[i];
+		unsigned int fwd_method = e->conn_flags & IP_VS_CONN_F_FWD_MASK;
 
 		if (!(dname = addrport_to_anyname(e->af, &(e->addr), ntohs(e->port),
 						  se->protocol, format))) {
@@ -1778,8 +1959,33 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			dname[28] = '\0';
 
 		if (format & FMT_RULE) {
-			printf("-a %s -r %s %s -w %d\n", svc_name, dname,
-			       fwd_switch(e->conn_flags), e->weight);
+			if (fwd_method == IP_VS_CONN_F_TUNNEL) {
+				switch (e->tun_type) {
+				case IP_VS_CONN_F_TUNNEL_TYPE_GUE:
+				printf("-a %s -r %s %s -w %d --tun-type %s --tun-port %d\n",
+				       svc_name,
+				       dname,
+				       fwd_switch(e->conn_flags),
+				       e->weight,
+				       tunnames[e->tun_type],
+				       e->tun_port);
+				break;
+				case IP_VS_CONN_F_TUNNEL_TYPE_IPIP:
+				printf("-a %s -r %s %s -w %d --tun-type %s\n",
+				       svc_name,
+				       dname,
+				       fwd_switch(e->conn_flags),
+				       e->weight,
+				       tunnames[e->tun_type]);
+				break;
+				}
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
@@ -1804,6 +2010,12 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			printf("  -> %-28s %-9u %-11u %-10u %-10u\n", dname,
 			       e->weight, e->persistconns,
 			       e->activeconns, e->inactconns);
+		} else if (format & FMT_TUN_INFO) {
+			printf("  -> %-28s %-7s %-7s %-7s %-6d %-10u %-10u\n",
+			       dname, fwd_name(e->conn_flags),
+			       fwd_tun_type(e),
+			       fwd_tun_port(e),
+			       e->weight, e->activeconns, e->inactconns);
 		} else
 			printf("  -> %-28s %-7s %-6d %-10u %-10u\n",
 			       dname, fwd_name(e->conn_flags),
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index ad0141c..209e9a4 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -107,6 +107,13 @@
 
 #define IP_VS_PEDATA_MAXLEN	255
 
+/* Tunnel types */
+enum {
+	IP_VS_CONN_F_TUNNEL_TYPE_IPIP = 0,	/* IPIP */
+	IP_VS_CONN_F_TUNNEL_TYPE_GUE,		/* GUE */
+	IP_VS_CONN_F_TUNNEL_TYPE_MAX,
+};
+
 union nf_inet_addr {
         __u32           all[4];
         __be32          ip;
@@ -162,6 +169,10 @@ struct ip_vs_dest_kern {
 	/* thresholds for active connections */
 	u_int32_t		u_threshold;	/* upper threshold */
 	u_int32_t		l_threshold;	/* lower threshold */
+
+	/* tunnel info */
+	u_int16_t		tun_type;	/* tunnel type */
+	__be16			tun_port;	/* tunnel port */
 };
 
 struct ip_vs_dest_user {
@@ -178,6 +189,10 @@ struct ip_vs_dest_user {
 	u_int32_t		l_threshold;	/* lower threshold */
 	u_int16_t		af;
 	union nf_inet_addr	addr;
+
+	/* tunnel info */
+	u_int16_t		tun_type;	/* tunnel type */
+	__be16			tun_port;	/* tunnel port */
 };
 
 /*
@@ -291,6 +306,10 @@ struct ip_vs_dest_entry_kern {
 
 	/* statistics */
 	struct ip_vs_stats_user stats;
+
+	/* tunnel info */
+	u_int16_t		tun_type;	/* tunnel type */
+	__be16			tun_port;	/* tunnel port */
 };
 
 struct ip_vs_dest_entry {
@@ -313,6 +332,10 @@ struct ip_vs_dest_entry {
 
 	/* statistics, 64-bit */
 	struct ip_vs_stats64	stats64;
+
+	/* tunnel info */
+	u_int16_t		tun_type;	/* tunnel type */
+	__be16			tun_port;	/* tunnel port */
 };
 
 /* The argument to IP_VS_SO_GET_DESTS */
@@ -527,6 +550,10 @@ enum {
 
 	IPVS_DEST_ATTR_STATS64,		/* nested attribute for dest stats */
 
+	IPVS_DEST_ATTR_TUN_TYPE,	/* tunnel type */
+
+	IPVS_DEST_ATTR_TUN_PORT,	/* tunnel port */
+
 	__IPVS_DEST_ATTR_MAX,
 };
 
diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 9be7700..d3cadaa 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -390,6 +390,8 @@ static int ipvs_nl_fill_dest_attr(struct nl_msg *msg, ipvs_dest_t *dst)
 	NLA_PUT_U16(msg, IPVS_DEST_ATTR_PORT, dst->port);
 	NLA_PUT_U32(msg, IPVS_DEST_ATTR_FWD_METHOD, dst->conn_flags & IP_VS_CONN_F_FWD_MASK);
 	NLA_PUT_U32(msg, IPVS_DEST_ATTR_WEIGHT, dst->weight);
+	NLA_PUT_U8(msg, IPVS_DEST_ATTR_TUN_TYPE, dst->tun_type);
+	NLA_PUT_U16(msg, IPVS_DEST_ATTR_TUN_PORT, dst->tun_port);
 	NLA_PUT_U32(msg, IPVS_DEST_ATTR_U_THRESH, dst->u_threshold);
 	NLA_PUT_U32(msg, IPVS_DEST_ATTR_L_THRESH, dst->l_threshold);
 
@@ -856,6 +858,8 @@ static int ipvs_dests_parse_cb(struct nl_msg *msg, void *arg)
 	struct nlattr *attrs[IPVS_CMD_ATTR_MAX + 1];
 	struct nlattr *dest_attrs[IPVS_DEST_ATTR_MAX + 1];
 	struct nlattr *attr_addr_family = NULL;
+	struct nlattr *attr_tun_type = NULL;
+	struct nlattr *attr_tun_port = NULL;
 	struct ip_vs_get_dests **dp = (struct ip_vs_get_dests **)arg;
 	struct ip_vs_get_dests *d = (struct ip_vs_get_dests *)*dp;
 	int i = d->num_dests;
@@ -888,6 +892,12 @@ static int ipvs_dests_parse_cb(struct nl_msg *msg, void *arg)
 	d->entrytable[i].port = nla_get_u16(dest_attrs[IPVS_DEST_ATTR_PORT]);
 	d->entrytable[i].conn_flags = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_FWD_METHOD]);
 	d->entrytable[i].weight = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_WEIGHT]);
+	attr_tun_type = dest_attrs[IPVS_DEST_ATTR_TUN_TYPE];
+	if (attr_tun_type)
+		d->entrytable[i].tun_type = nla_get_u8(attr_tun_type);
+	attr_tun_port = dest_attrs[IPVS_DEST_ATTR_TUN_PORT];
+	if (attr_tun_port)
+		d->entrytable[i].tun_port = nla_get_u16(attr_tun_port);
 	d->entrytable[i].u_threshold = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_U_THRESH]);
 	d->entrytable[i].l_threshold = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_L_THRESH]);
 	d->entrytable[i].activeconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_ACTIVE_CONNS]);
-- 
2.21.0

