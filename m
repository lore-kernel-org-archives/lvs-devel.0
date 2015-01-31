From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvsadm: add SCTP support
Date: Sat, 31 Jan 2015 10:41:08 +0200
Message-ID: <1422693668-25736-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, overcastsky.zhao@gmail.com

SCTP support in kernel is from 2.6.34 but ipvsadm
restricts users to fwmark-based virtual services.

* Add option --sctp-service to specify the virtual service

* Update man page to use virtual-service and the new option

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 ipvsadm.8 |  30 +++++++++++--------
 ipvsadm.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 98 insertions(+), 32 deletions(-)

diff --git a/ipvsadm.8 b/ipvsadm.8
index 9a9e9b3..3df3b83 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -35,11 +35,11 @@
 .SH NAME
 ipvsadm \- Linux Virtual Server administration
 .SH SYNOPSIS
-.B ipvsadm -A|E -t|u|f \fIservice-address\fP [-s \fIscheduler\fP]
+.B ipvsadm -A|E \fIvirtual-service\fP [-s \fIscheduler\fP]
 .ti 15
 .B [-p [\fItimeout\fP]] [-M \fInetmask\fP] [-b \fIsched-flags\fP]
 .br
-.B ipvsadm -D -t|u|f \fIservice-address\fP
+.B ipvsadm -D \fIvirtual-service\fP
 .br
 .B ipvsadm -C
 .br
@@ -47,15 +47,15 @@ ipvsadm \- Linux Virtual Server administration
 .br
 .B ipvsadm -S [-n]
 .br
-.B ipvsadm -a|e -t|u|f \fIservice-address\fP -r \fIserver-address\fP
+.B ipvsadm -a|e \fIvirtual-service\fP -r \fIserver-address\fP
 .ti 15
 .B [-g|i|m] [-w \fIweight\fP] [-x \fIupper\fP] [-y \fIlower\fP]
 .br
-.B ipvsadm -d -t|u|f \fIservice-address\fP -r \fIserver-address\fP
+.B ipvsadm -d \fIvirtual-service\fP -r \fIserver-address\fP
 .br
-.B ipvsadm -L|l [options]
+.B ipvsadm -L|l [\fIvirtual-service\fP] [options]
 .br
-.B ipvsadm -Z [-t|u|f \fIservice-address\fP]
+.B ipvsadm -Z [\fIvirtual-service\fP]
 .br
 .B ipvsadm --set \fItcp\fP \fItcpfin\fP \fIudp\fP
 .br
@@ -72,7 +72,7 @@ server table in the Linux kernel. The Linux Virtual Server can be used
 to build scalable network services based on a cluster of two or more
 nodes. The active node of the cluster redirects service requests to a
 collection of server hosts that will actually perform the
-services. Supported features include two protocols (TCP and UDP),
+services. Supported features include three protocols (TCP, UDP and SCTP),
 three packet-forwarding methods (NAT, tunneling, and direct routing),
 and eight load balancing algorithms (round robin, weighted round
 robin, least-connection, weighted least-connection, locality-based
@@ -81,11 +81,11 @@ destination-hashing, and source-hashing).
 .PP
 The command has two basic formats for execution:
 .TP
-.B ipvsadm \fICOMMAND\fP [\fIprotocol\fP] \fIservice-address\fP
+.B ipvsadm \fICOMMAND\fP \fIvirtual-service\fP
 .ti 15
 .B [\fIscheduling-method\fP] [\fIpersistence options\fP]
 .TP
-.B ipvsadm \fIcommand\fP [\fIprotocol\fP] \fIservice-address\fP
+.B ipvsadm \fIcommand\fP \fIvirtual-service\fP
 .ti 15
 .B \fIserver-address\fP [\fIpacket-forwarding-method\fP]
 .ti 15
@@ -174,9 +174,8 @@ Stop the connection synchronization daemon.
 .TP
 \fB-h, --help\fR
 Display a description of the command syntax.
-.SS PARAMETERS
-The commands above accept or require zero or more of the following
-parameters.
+.SS virtual-service
+Specifies the virtual service based on protocol/addr/port or firewall mark.
 .TP
 .B -t, --tcp-service \fIservice-address\fP
 Use TCP service. The \fIservice-address\fP is of the form
@@ -191,6 +190,10 @@ wild-card port, that is connections will be accepted to any port.
 Use UDP service. See the -t|--tcp-service for the description of  the
 \fIservice-address\fP.
 .TP
+.B --sctp-service \fIservice-address\fP
+Use SCTP service. See the -t|--tcp-service for the description of the
+\fIservice-address\fP.
+.TP
 .B -f, --fwmark-service \fIinteger\fP
 Use a firewall-mark, an integer value greater than zero, to denote a
 virtual service instead of an address, port and protocol (UDP or
@@ -206,6 +209,9 @@ single virtual service. This is useful for both simplifying
 configuration if a large number of virtual services are required and
 grouping persistence across what would otherwise be multiple virtual
 services.
+.SS PARAMETERS
+The commands above accept or require zero or more of the following
+parameters.
 .TP
 .B -s, --scheduler \fIscheduling-method\fP
 \fIscheduling-method\fP  Algorithm for allocating TCP connections and
diff --git a/ipvsadm.c b/ipvsadm.c
index a33ecfa..1669634 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -287,6 +287,7 @@ enum {
 	TAG_SORT,
 	TAG_NO_SORT,
 	TAG_PERSISTENCE_ENGINE,
+	TAG_SCTP_SERVICE,
 };
 
 /* various parsing helpers & parsing functions */
@@ -359,6 +360,47 @@ int main(int argc, char **argv)
 	return result;
 }
 
+static int option_to_protocol(int opt)
+{
+	switch (opt) {
+	case 't':
+		return IPPROTO_TCP;
+	case 'u':
+		return IPPROTO_UDP;
+	case TAG_SCTP_SERVICE:
+		return IPPROTO_SCTP;
+	default:
+		return IPPROTO_IP;
+	}
+}
+
+static char *option_from_protocol(int proto)
+{
+	switch (proto) {
+	case IPPROTO_TCP:
+		return "-t";
+	case IPPROTO_UDP:
+		return "-u";
+	case IPPROTO_SCTP:
+		return "--sctp-service";
+	default:
+		return NULL;
+	}
+}
+
+static char *protocol_name(int proto)
+{
+	switch (proto) {
+	case IPPROTO_TCP:
+		return "TCP";
+	case IPPROTO_UDP:
+		return "UDP";
+	case IPPROTO_SCTP:
+		return "SCTP";
+	default:
+		return "?";
+	}
+}
 
 static int
 parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
@@ -391,6 +433,8 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		  NULL, NULL },
 		{ "udp-service", 'u', POPT_ARG_STRING, &optarg, 'u',
 		  NULL, NULL },
+		{ "sctp-service", '\0', POPT_ARG_STRING, &optarg,
+		  TAG_SCTP_SERVICE, NULL, NULL },
 		{ "fwmark-service", 'f', POPT_ARG_STRING, &optarg, 'f',
 		  NULL, NULL },
 		{ "scheduler", 's', POPT_ARG_STRING, &optarg, 's', NULL, NULL },
@@ -510,9 +554,9 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		switch (c) {
 		case 't':
 		case 'u':
+		case TAG_SCTP_SERVICE:
 			set_option(options, OPT_SERVICE);
-			ce->svc.protocol =
-				(c=='t' ? IPPROTO_TCP : IPPROTO_UDP);
+			ce->svc.protocol = option_to_protocol(c);
 			parse = parse_service(optarg, &ce->svc);
 			if (!(parse & SERVICE_ADDR))
 				fail(2, "illegal virtual server "
@@ -1128,15 +1172,15 @@ static void usage_exit(const char *program, const int exit_status)
 	version(stream);
 	fprintf(stream,
 		"Usage:\n"
-		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine] [-b sched-flags]\n"
-		"  %s -D -t|u|f service-address\n"
+		"  %s -A|E virtual-service [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine] [-b sched-flags]\n"
+		"  %s -D virtual-service\n"
 		"  %s -C\n"
 		"  %s -R\n"
 		"  %s -S [-n]\n"
-		"  %s -a|e -t|u|f service-address -r server-address [options]\n"
-		"  %s -d -t|u|f service-address -r server-address\n"
-		"  %s -L|l [options]\n"
-		"  %s -Z [-t|u|f service-address]\n"
+		"  %s -a|e virtual-service -r server-address [options]\n"
+		"  %s -d virtual-service -r server-address\n"
+		"  %s -L|l [virtual-service] [options]\n"
+		"  %s -Z [virtual-service]\n"
 		"  %s --set tcp tcpfin udp\n"
 		"  %s --start-daemon state [--mcast-interface interface] [--syncid sid]\n"
 		"  %s --stop-daemon state\n"
@@ -1166,10 +1210,15 @@ static void usage_exit(const char *program, const int exit_status)
 		);
 
 	fprintf(stream,
+		"virtual-service:\n"
+		"  --tcp-service|-t  service-address   service-address is host[:port]\n"
+		"  --udp-service|-u  service-address   service-address is host[:port]\n"
+		"  --sctp-service    service-address   service-address is host[:port]\n"
+		"  --fwmark-service|-f fwmark          fwmark is an integer greater than zero\n"
+		"\n");
+
+	fprintf(stream,
 		"Options:\n"
-		"  --tcp-service  -t service-address   service-address is host[:port]\n"
-		"  --udp-service  -u service-address   service-address is host[:port]\n"
-		"  --fwmark-service  -f fwmark         fwmark is an integer greater than zero\n"
 		"  --ipv6         -6                   fwmark entry uses IPv6\n"
 		"  --scheduler    -s scheduler         one of " SCHEDULERS ",\n"
 		"                                      the default scheduler is %s.\n"
@@ -1316,6 +1365,8 @@ static void print_conn(char *buf, unsigned int format)
 		proto = IPPROTO_TCP;
 	else if (strcmp(protocol, "UDP") == 0)
 		proto = IPPROTO_UDP;
+	else if (strcmp(protocol, "SCTP") == 0)
+		proto = IPPROTO_SCTP;
 	else
 		proto = 0;
 
@@ -1518,7 +1569,7 @@ static void
 print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 {
 	struct ip_vs_get_dests *d;
-	char svc_name[64];
+	char svc_name[1024];
 	int i;
 
 	if (!(d = ipvs_get_dests(se))) {
@@ -1543,14 +1594,17 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 		if (!(vname = addrport_to_anyname(se->af, &se->addr, ntohs(se->port),
 						  se->protocol, format)))
 			fail(2, "addrport_to_anyname: %s", strerror(errno));
-		if (format & FMT_RULE)
-			sprintf(svc_name, "%s %s",
-				se->protocol==IPPROTO_TCP?"-t":"-u",
-				vname);
-		else {
-			sprintf(svc_name, "%s  %s",
-				se->protocol==IPPROTO_TCP?"TCP":"UDP",
-				vname);
+		if (format & FMT_RULE) {
+			char *stype = option_from_protocol(se->protocol) ? :
+				      "--xxx-service";
+
+			snprintf(svc_name, sizeof(svc_name), "%s %s",
+				 stype, vname);
+		} else {
+			char *stype = protocol_name(se->protocol);
+
+			snprintf(svc_name, sizeof(svc_name), "%-4s %s",
+				 stype, vname);
 			if (se->af != AF_INET6)
 				svc_name[33] = '\0';
 		}
@@ -1806,6 +1860,9 @@ int service_to_port(const char *name, unsigned short proto)
 	else if (proto == IPPROTO_UDP
 		 && (service = getservbyname(name, "udp")) != NULL)
 		return ntohs((unsigned short) service->s_port);
+	else if (proto == IPPROTO_SCTP
+		 && (service = getservbyname(name, "sctp")) != NULL)
+		return ntohs((unsigned short) service->s_port);
 	else
 		return -1;
 }
@@ -1821,6 +1878,9 @@ static char * port_to_service(unsigned short port, unsigned short proto)
 	else if (proto == IPPROTO_UDP &&
 		 (service = getservbyport(htons(port), "udp")) != NULL)
 		return service->s_name;
+	else if (proto == IPPROTO_SCTP &&
+		 (service = getservbyport(htons(port), "sctp")) != NULL)
+		return service->s_name;
 	else
 		return (char *) NULL;
 }
-- 
1.9.3

