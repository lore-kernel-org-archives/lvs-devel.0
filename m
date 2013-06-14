From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Fri, 14 Jun 2013 12:47:11 +0100
Message-ID: <20130614114711.GB31800@eldamar.org.uk>
References: <20130524151408.GM264@eldamar.org.uk>
 <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
 <20130607081252.GC11902@eldamar.org.uk>
 <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk>
 <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg>
 <20130612141018.GC29327@eldamar.org.uk>
 <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
 <20130613141804.GB31356@eldamar.org.uk>
 <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> --sched-flags sh-fallback,sh-port

Updated ipvsadm patch below.  I've kept -b for now: there are no long
options in ipvsadm -S output, and I think it would be nice to keep it
that way.

diff --git a/ipvsadm.8 b/ipvsadm.8
index 001ae74..9a9e9b3 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -37,7 +37,7 @@ ipvsadm \- Linux Virtual Server administration
 .SH SYNOPSIS
 .B ipvsadm -A|E -t|u|f \fIservice-address\fP [-s \fIscheduler\fP]
 .ti 15
-.B [-p [\fItimeout\fP]] [-M \fInetmask\fP]
+.B [-p [\fItimeout\fP]] [-M \fInetmask\fP] [-b \fIsched-flags\fP]
 .br
 .B ipvsadm -D -t|u|f \fIservice-address\fP
 .br
@@ -248,6 +248,9 @@ addresses.
 .sp
 \fBsh\fR - Source Hashing: assigns jobs to servers through looking up
 a statically assigned hash table by their source IP addresses.
+This scheduler has two flags: sh-fallback, which enables fallback to a
+different server if the selected server was unavailable, and sh-port,
+which adds the source port number to the hash computation.
 .sp
 \fBsed\fR - Shortest Expected Delay: assigns an incoming job to the
 server with the shortest expected delay. The expected delay that the
@@ -286,6 +289,11 @@ resolve problems with non-persistent cache clusters on the client side.
 IPv6 netmasks should be specified as a prefix length between 1 and 128.
 The default prefix length is 128.
 .TP
+.B -b, --sched-flags \fIsched-flags\fP
+Set scheduler flags for this virtual server.  \fIsched-flags\fP is a
+comma-separated list of flags.  See the scheduler descriptions for
+valid scheduler flags.
+.TP
 .B -r, --real-server \fIserver-address\fP
 Real server that an associated request for service may be assigned to.
 The \fIserver-address\fP is the \fIhost\fP address of a real server,
diff --git a/ipvsadm.c b/ipvsadm.c
index 0197515..9679cf7 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -182,7 +182,8 @@ static const char* cmdnames[] = {
 #define OPT_EXACT		0x100000
 #define OPT_ONEPACKET		0x200000
 #define OPT_PERSISTENCE_ENGINE  0x400000
-#define NUMBER_OF_OPT		23
+#define OPT_SCHED_FLAGS		0x800000
+#define NUMBER_OF_OPT		24
 
 static const char* optnames[] = {
 	"numeric",
@@ -207,7 +208,7 @@ static const char* optnames[] = {
 	"syncid",
 	"exact",
 	"ops",
-	"pe",
+	"pe"
 };
 
 /*
@@ -220,21 +221,21 @@ static const char* optnames[] = {
  */
 static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 {
-	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe */
-/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' '},
-/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' '},
-/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x'},
-/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x'},
-/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x'},
-/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe  -b */
+/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' '},
+/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' '},
+/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x'},
+/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x'},
+/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x'},
+/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
 };
 
 /* printing format flags */
@@ -285,6 +286,7 @@ enum {
 	TAG_SORT,
 	TAG_NO_SORT,
 	TAG_PERSISTENCE_ENGINE,
+	TAG_SCHED_FLAGS
 };
 
 /* various parsing helpers & parsing functions */
@@ -363,7 +365,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 {
 	int c, parse;
 	poptContext context;
-	char *optarg=NULL;
+	char *optarg=NULL, *flag;
 	struct poptOption options_table[] = {
 		{ "add-service", 'A', POPT_ARG_NONE, NULL, 'A', NULL, NULL },
 		{ "edit-service", 'E', POPT_ARG_NONE, NULL, 'E', NULL, NULL },
@@ -426,6 +428,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		{ "ops", 'o', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
 		{ "pe", '\0', POPT_ARG_STRING, &optarg, TAG_PERSISTENCE_ENGINE,
 		  NULL, NULL },
+		{ "sched-flags", 'b', POPT_ARG_STRING, &optarg, 'b', NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -656,6 +659,25 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			set_option(options, OPT_PERSISTENCE_ENGINE);
 			strncpy(ce->svc.pe_name, optarg, IP_VS_PENAME_MAXLEN);
 			break;
+		case 'b':
+			set_option(options, OPT_SCHED_FLAGS);
+			ce->svc.flags &= ~(IP_VS_SVC_F_SCHED1 | IP_VS_SVC_F_SCHED2 | IP_VS_SVC_F_SCHED3);
+			flag = strtok(optarg, ",");
+			do {
+				if (!strcmp(flag, "flag-1"))
+					ce->svc.flags |= IP_VS_SVC_F_SCHED1;
+				else if (!strcmp(flag, "flag-2"))
+					ce->svc.flags |= IP_VS_SVC_F_SCHED2;
+				else if (!strcmp(flag, "flag-3"))
+					ce->svc.flags |= IP_VS_SVC_F_SCHED3;
+				else if (!strcmp(flag, "sh-fallback"))
+					ce->svc.flags |= IP_VS_SVC_F_SCHED_SH_FALLBACK;
+				else if (!strcmp(flag, "sh-port"))
+					ce->svc.flags |= IP_VS_SVC_F_SCHED_SH_PORT;
+				else
+					fail(2, "invalid scheduler flag `%s'", flag);
+			} while ((flag = strtok(NULL, ",")) != NULL);
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -1070,7 +1092,7 @@ static void usage_exit(const char *program, const int exit_status)
 	version(stream);
 	fprintf(stream,
 		"Usage:\n"
-		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine]\n"
+		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine] [-b sched-flags]\n"
 		"  %s -D -t|u|f service-address\n"
 		"  %s -C\n"
 		"  %s -R\n"
@@ -1139,7 +1161,8 @@ static void usage_exit(const char *program, const int exit_status)
 		"  --nosort                            disable sorting output of service/server entries\n"
 		"  --sort                              does nothing, for backwards compatibility\n"
 		"  --ops          -o                   one-packet scheduling\n"
-		"  --numeric      -n                   numeric output of addresses and ports\n",
+		"  --numeric      -n                   numeric output of addresses and ports\n"
+		"  --sched-flags  -b flags             scheduler flags (comma-separated)\n",
 		DEF_SCHED);
 
 	exit(exit_status);
@@ -1396,6 +1419,27 @@ static void print_largenum(unsigned long long i, unsigned int format)
 		printf("%8lluT", i / 1000000000000ULL);
 }
 
+static void print_sched_flags(ipvs_service_entry_t *se) {
+	char flags[64] = "";
+
+	if (!strcmp(se->sched_name, "sh")) {
+		if (se->flags & IP_VS_SVC_F_SCHED_SH_FALLBACK)
+			strcat(flags, "sh-fallback,");
+		if (se->flags & IP_VS_SVC_F_SCHED_SH_PORT)
+			strcat(flags, "sh-port,");
+	} else {
+		if (se->flags & IP_VS_SVC_F_SCHED1)
+			strcat(flags, "flag-1,");
+		if (se->flags & IP_VS_SVC_F_SCHED2)
+			strcat(flags, "flag-2,");
+		if (se->flags & IP_VS_SVC_F_SCHED3)
+			strcat(flags, "flag-3,");
+	}
+
+	flags[strlen(flags)-1] = '\0';
+
+	printf("%s", flags);
+}
 
 static void print_title(unsigned int format)
 {
@@ -1488,6 +1532,10 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			printf(" pe %s", se->pe_name);
 		if (se->flags & IP_VS_SVC_F_ONEPACKET)
 			printf(" -o");
+		if (se->flags & (IP_VS_SVC_F_SCHED1 | IP_VS_SVC_F_SCHED2 | IP_VS_SVC_F_SCHED3)) {
+			printf(" -b ");
+			print_sched_flags(se);
+		}
 	} else if (format & FMT_STATS) {
 		printf("%-33s", svc_name);
 		print_largenum(se->stats.conns, format);
@@ -1504,6 +1552,11 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 		print_largenum(se->stats.outbps, format);
 	} else {
 		printf("%s %s", svc_name, se->sched_name);
+		if (se->flags & (IP_VS_SVC_F_SCHED1 | IP_VS_SVC_F_SCHED2 | IP_VS_SVC_F_SCHED3)) {
+			printf(" (");
+			print_sched_flags(se);
+			printf(")");
+		}
 		if (se->flags & IP_VS_SVC_F_PERSISTENT) {
 			printf(" persistent %u", se->timeout);
 			if (se->af == AF_INET)
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index 5e1d544..4db14ff 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -29,6 +29,13 @@
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
 #define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
+#define IP_VS_SVC_F_SCHED1	0x0008		/* scheduler flag 1 */
+#define IP_VS_SVC_F_SCHED2	0x0010		/* scheduler flag 2 */
+#define IP_VS_SVC_F_SCHED3	0x0020		/* scheduler flag 3 */
+
+#define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
+#define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
+
 
 /*
  *      IPVS sync daemon states


Alex

