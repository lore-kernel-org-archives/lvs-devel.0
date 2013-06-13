From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Thu, 13 Jun 2013 15:18:04 +0100
Message-ID: <20130613141804.GB31356@eldamar.org.uk>
References: <20130524120935.GL264@eldamar.org.uk>
 <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
 <20130524151408.GM264@eldamar.org.uk>
 <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
 <20130607081252.GC11902@eldamar.org.uk>
 <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk>
 <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg>
 <20130612141018.GC29327@eldamar.org.uk>
 <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

I've patched ipvsadm and fixed up the kernel patch.

For the ipvsadm option, I've used (-b|--sched-flags) 123.  I don't
particularly like this style, but I wanted something working for
testing.

I'm using ip_vs_fill_iph_skb for now (if the flag is set), until I hear
back from you.

When you're happy with the patches, I can open the discussion up to the
users mailing list.

Kernel patch:

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index a245377..81af9b2 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -20,6 +20,9 @@
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
 #define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
+#define IP_VS_SVC_F_SCHED1	0x0008		/* scheduler flag 1 */
+#define IP_VS_SVC_F_SCHED2	0x0010		/* scheduler flag 2 */
+#define IP_VS_SVC_F_SCHED3	0x0020		/* scheduler flag 3 */
 
 /*
  *      Destination Server Flags
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 0df269d..f9de4d2 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -48,6 +48,10 @@
 
 #include <net/ip_vs.h>
 
+#include <net/tcp.h>
+#include <linux/udp.h>
+#include <linux/sctp.h>
+
 
 /*
  *      IPVS SH bucket
@@ -74,7 +78,9 @@ struct ip_vs_sh_state {
 /*
  *	Returns hash value for IPVS SH entry
  */
-static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
+static inline unsigned int ip_vs_sh_hashkey(int af,
+	const union nf_inet_addr *addr, __be16 port,
+	unsigned int offset)
 {
 	__be32 addr_fold = addr->ip;
 
@@ -83,7 +89,8 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	return (ntohl(addr_fold)*2654435761UL) & IP_VS_SH_TAB_MASK;
+	return (offset + (ntohs(port) + ntohl(addr_fold))*2654435761UL) &
+		IP_VS_SH_TAB_MASK;
 }
 
 
@@ -91,9 +98,11 @@ static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *ad
  *      Get ip_vs_dest associated with supplied parameters.
  */
 static inline struct ip_vs_dest *
-ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr)
+ip_vs_sh_get(int af, struct ip_vs_sh_state *s, const union nf_inet_addr *addr,
+	__be16 port, unsigned int offset)
 {
-	return rcu_dereference(s->buckets[ip_vs_sh_hashkey(af, addr)].dest);
+	return rcu_dereference(
+		s->buckets[ip_vs_sh_hashkey(af, addr, port, offset)].dest);
 }
 
 
@@ -224,6 +233,50 @@ static inline int is_overloaded(struct ip_vs_dest *dest)
 
 
 /*
+ *	Helper function to determine if server is unavailable
+ */
+static inline int
+is_unavailable(struct ip_vs_dest *dest)
+{
+	return (!dest ||
+		atomic_read(&dest->weight) <= 0 ||
+		is_overloaded(dest));
+}
+
+
+/*
+ *	Helper function to get port number
+ */
+static inline __be16
+ip_vs_sh_get_port(const struct sk_buff *skb, struct ip_vs_iphdr *iph)
+{
+	__be16 port;
+	struct tcphdr _tcph, *th;
+	struct udphdr _udph, *uh;
+	sctp_sctphdr_t _sctph, *sh;
+
+	switch (iph->protocol) {
+	case IPPROTO_TCP:
+		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
+		port = th->source;
+		break;
+	case IPPROTO_UDP:
+		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
+		port = uh->source;
+		break;
+	case IPPROTO_SCTP:
+		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
+		port = sh->source;
+		break;
+	default:
+		port = 0;
+	}
+
+	return port;
+}
+
+
+/*
  *      Source Hashing scheduling
  */
 static struct ip_vs_dest *
@@ -232,21 +285,45 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	struct ip_vs_dest *dest;
 	struct ip_vs_sh_state *s;
 	struct ip_vs_iphdr iph;
-
-	ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
+	__be16 port;
+	unsigned int offset;
+	bool found;
 
 	IP_VS_DBG(6, "ip_vs_sh_schedule(): Scheduling...\n");
 
+	if (svc->flags & IP_VS_SVC_F_SCHED1) {
+		ip_vs_fill_iph_skb(svc->af, skb, &iph);
+		port = ip_vs_sh_get_port(skb, &iph);
+	} else {
+		ip_vs_fill_iph_addr_only(svc->af, skb, &iph);
+		port = 0;
+	}
+
 	s = (struct ip_vs_sh_state *) svc->sched_data;
-	dest = ip_vs_sh_get(svc->af, s, &iph.saddr);
-	if (!dest
-	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
-	    || atomic_read(&dest->weight) <= 0
-	    || is_overloaded(dest)) {
+	if (svc->flags & IP_VS_SVC_F_SCHED2) {
+		found = false;
+		for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
+			dest = ip_vs_sh_get(svc->af, s, &iph.saddr,
+				port, offset);
+			if (is_unavailable(dest))
+				IP_VS_DBG_BUF(6, "SH: selected unavailable "
+					"server %s:%d (offset %d)",
+					IP_VS_DBG_ADDR(svc->af, &dest->addr),
+					ntohs(dest->port),
+					offset);
+			else
+				goto found_dest;
+		}
+	} else {
+		dest = ip_vs_sh_get(svc->af, s, &iph.saddr, port, 0);
+		found = true;
+	}
+	if (!found || is_unavailable(dest)) {
 		ip_vs_scheduler_err(svc, "no destination available");
 		return NULL;
 	}
 
+ found_dest:
 	IP_VS_DBG_BUF(6, "SH: source IP address %s --> server %s:%d\n",
 		      IP_VS_DBG_ADDR(svc->af, &iph.saddr),
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr),

ipvsadm patch:

diff --git a/ipvsadm.8 b/ipvsadm.8
index 001ae74..e24f5d0 100644
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
+Scheduler flag 1 makes the scheduler include the source port in the
+hash; flag 2 makes the scheduler find a different server when a
+client is directed to a server of weight 0.
 .sp
 \fBsed\fR - Shortest Expected Delay: assigns an incoming job to the
 server with the shortest expected delay. The expected delay that the
@@ -286,6 +289,11 @@ resolve problems with non-persistent cache clusters on the client side.
 IPv6 netmasks should be specified as a prefix length between 1 and 128.
 The default prefix length is 128.
 .TP
+.B -b, --sched-flags \fIsched-flags\fP
+Set scheduler flags for this virtual server.  The \fIsched-flags\fP is
+a string of numbers (1, 2, or 3) which specify which scheduler flags to
+set.  The function of the flags is scheduler-specific.
+.TP
 .B -r, --real-server \fIserver-address\fP
 Real server that an associated request for service may be assigned to.
 The \fIserver-address\fP is the \fIhost\fP address of a real server,
diff --git a/ipvsadm.c b/ipvsadm.c
index 0197515..878734e 100644
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
@@ -208,6 +209,7 @@ static const char* optnames[] = {
 	"exact",
 	"ops",
 	"pe",
+	"sched-flags"
 };
 
 /*
@@ -220,21 +222,21 @@ static const char* optnames[] = {
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
+	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe  scf */
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
@@ -426,6 +428,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		{ "ops", 'o', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
 		{ "pe", '\0', POPT_ARG_STRING, &optarg, TAG_PERSISTENCE_ENGINE,
 		  NULL, NULL },
+		{ "sched-flags", 'b', POPT_ARG_STRING, &optarg, 'b', NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -656,6 +659,24 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			set_option(options, OPT_PERSISTENCE_ENGINE);
 			strncpy(ce->svc.pe_name, optarg, IP_VS_PENAME_MAXLEN);
 			break;
+		case 'b':
+			set_option(options, OPT_SCHED_FLAGS);
+			ce->svc.flags &= ~(IP_VS_SVC_F_SCHED1 | IP_VS_SVC_F_SCHED2 | IP_VS_SVC_F_SCHED3);
+			for(; *optarg != '\0'; optarg++)
+				switch (*optarg - '0') {
+				case 1:
+					ce->svc.flags |= IP_VS_SVC_F_SCHED1;
+					break;
+				case 2:
+					ce->svc.flags |= IP_VS_SVC_F_SCHED2;
+					break;
+				case 3:
+					ce->svc.flags |= IP_VS_SVC_F_SCHED3;
+					break;
+				default:
+					fail(2, "invalid scheduler flag specified");
+				}
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -1070,7 +1091,7 @@ static void usage_exit(const char *program, const int exit_status)
 	version(stream);
 	fprintf(stream,
 		"Usage:\n"
-		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine]\n"
+		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine] [-b scheduler_flags]\n"
 		"  %s -D -t|u|f service-address\n"
 		"  %s -C\n"
 		"  %s -R\n"
@@ -1139,7 +1160,8 @@ static void usage_exit(const char *program, const int exit_status)
 		"  --nosort                            disable sorting output of service/server entries\n"
 		"  --sort                              does nothing, for backwards compatibility\n"
 		"  --ops          -o                   one-packet scheduling\n"
-		"  --numeric      -n                   numeric output of addresses and ports\n",
+		"  --numeric      -n                   numeric output of addresses and ports\n"
+		"  --sched-flags  -b flags             scheduler flags\n",
 		DEF_SCHED);
 
 	exit(exit_status);
@@ -1488,6 +1510,15 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			printf(" pe %s", se->pe_name);
 		if (se->flags & IP_VS_SVC_F_ONEPACKET)
 			printf(" -o");
+		if (se->flags & (IP_VS_SVC_F_SCHED1 | IP_VS_SVC_F_SCHED2 | IP_VS_SVC_F_SCHED3)) {
+			printf(" -b ");
+			if (se->flags & IP_VS_SVC_F_SCHED1)
+				printf("1");
+			if (se->flags & IP_VS_SVC_F_SCHED2)
+				printf("2");
+			if (se->flags & IP_VS_SVC_F_SCHED3)
+				printf("3");
+		}
 	} else if (format & FMT_STATS) {
 		printf("%-33s", svc_name);
 		print_largenum(se->stats.conns, format);
@@ -1520,6 +1551,15 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 		}
 		if (se->flags & IP_VS_SVC_F_ONEPACKET)
 			printf(" ops");
+		if (se->flags & (IP_VS_SVC_F_SCHED1 | IP_VS_SVC_F_SCHED2 | IP_VS_SVC_F_SCHED3)) {
+			printf(" sfl ");
+			if (se->flags & IP_VS_SVC_F_SCHED1)
+				printf("1");
+			if (se->flags & IP_VS_SVC_F_SCHED2)
+				printf("2");
+			if (se->flags & IP_VS_SVC_F_SCHED3)
+				printf("3");
+		}
 	}
 	printf("\n");
 
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index 5e1d544..33b0115 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -29,6 +29,10 @@
 #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
 #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
 #define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
+#define IP_VS_SVC_F_SCHED1	0x0008		/* scheduler flag 1 */
+#define IP_VS_SVC_F_SCHED2	0x0010		/* scheduler flag 2 */
+#define IP_VS_SVC_F_SCHED3	0x0020		/* scheduler flag 3 */
+
 
 /*
  *      IPVS sync daemon states


Alex

