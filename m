From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 2/2] [PATCH 2/2] Add support for persistence engines.
Date: Fri, 01 Oct 2010 23:40:43 +0900
Message-ID: <20101001144126.611487702@akiko.akashicho.tokyo.vergenet.net>
References: <20101001144041.414393254@akiko.akashicho.tokyo.vergenet.net>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline; filename=0002-Add-support-for-persistence-engines.patch
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

This adds the --pe [engine] option to the -A and -E commands
which allows a persistence engine to be associated with a virtual service.
The absence of --pe sets no persistence engine.

The --pe option only works when ipvsadm is compiled to use netlink
for user-space/kernel communication.

This patch also allows the --persistent-conn option to be given to the -L
command, which will list persistence engine data, if any is present, when
listing connections (and persistence templates).

At this time the only (proposed) persistence engine is sip.

Signed-off-by: Simon Horman <horms@verge.net.au>

---

v0.4
* Fix indentation of --pe help text

v2
* Only display pe_data if it is present

Index: github.com/Makefile
===================================================================
--- github.com.orig/Makefile	2010-10-01 22:58:26.000000000 +0900
+++ github.com/Makefile	2010-10-01 23:00:10.000000000 +0900
@@ -29,6 +29,7 @@ NAME		= ipvsadm
 VERSION		= $(shell cat VERSION)
 RELEASE		= 1
 SCHEDULERS	= "$(shell cat SCHEDULERS)"
+PE_LIST		= "$(shell cat PERSISTENCE_ENGINES)"
 PROGROOT	= $(shell basename `pwd`)
 ARCH		= $(shell uname -m)
 RPMSOURCEDIR	= $(shell rpm --eval '%_sourcedir')
@@ -83,7 +84,7 @@ ifneq (0,$(HAVE_NL))
 LIBS		+= -lnl
 endif
 DEFINES		= -DVERSION=\"$(VERSION)\" -DSCHEDULERS=\"$(SCHEDULERS)\" \
-		  $(POPT_DEFINE)
+		  -DPE_LIST=\"$(PE_LIST)\" $(POPT_DEFINE)
 DEFINES		+= $(shell if [ ! -f ../ip_vs.h ]; then	\
 		     echo "-DHAVE_NET_IP_VS_H"; fi;)
 
Index: github.com/PERSISTENCE_ENGINES
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ github.com/PERSISTENCE_ENGINES	2010-10-01 23:00:10.000000000 +0900
@@ -0,0 +1 @@
+sip
Index: github.com/ipvsadm.8
===================================================================
--- github.com.orig/ipvsadm.8	2010-09-26 22:07:58.000000000 +0900
+++ github.com/ipvsadm.8	2010-10-01 23:00:10.000000000 +0900
@@ -391,6 +391,10 @@ with this option will display the persis
 information of each server in service listing. The persistent
 connection is used to forward the actual connections from the same
 client/network to the same server.
+.sp
+The \fIlist\fP command with the -c, --connection option and this option
+will include persistence engine data, if any is present, when listing
+connections.
 .TP
 .B --sort
 Sort the list of virtual services and real servers. The virtual
Index: github.com/ipvsadm.c
===================================================================
--- github.com.orig/ipvsadm.c	2010-10-01 23:00:09.000000000 +0900
+++ github.com/ipvsadm.c	2010-10-01 23:00:20.000000000 +0900
@@ -181,13 +181,15 @@ static const char* cmdnames[] = {
 #define OPT_SYNCID		0x080000
 #define OPT_EXACT		0x100000
 #define OPT_ONEPACKET		0x200000
-#define NUMBER_OF_OPT		22
+#define OPT_PERSISTENCE_ENGINE  0x400000
+#define NUMBER_OF_OPT		23
 
 static const char* optnames[] = {
 	"numeric",
 	"connection",
 	"service-address",
 	"scheduler",
+	"pe",
 	"persistent",
 	"netmask",
 	"real-server",
@@ -282,6 +284,7 @@ enum {
 	TAG_PERSISTENTCONN,
 	TAG_SORT,
 	TAG_NO_SORT,
+	TAG_PERSISTENCE_ENGINE,
 };
 
 /* various parsing helpers & parsing functions */
@@ -421,6 +424,8 @@ parse_options(int argc, char **argv, str
 		{ "exact", 'X', POPT_ARG_NONE, NULL, 'X', NULL, NULL },
 		{ "ipv6", '6', POPT_ARG_NONE, NULL, '6', NULL, NULL },
 		{ "ops", 'o', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
+		{ "pe", '\0', POPT_ARG_STRING, &optarg, TAG_PERSISTENCE_ENGINE,
+		  NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -647,6 +652,10 @@ parse_options(int argc, char **argv, str
 			set_option(options, OPT_ONEPACKET);
 			ce->svc.flags |= IP_VS_SVC_F_ONEPACKET;
 			break;
+		case TAG_PERSISTENCE_ENGINE:
+			set_option(options, OPT_PERSISTENCE_ENGINE);
+			strncpy(ce->svc.pe_name, optarg, IP_VS_PENAME_MAXLEN);
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -763,9 +772,10 @@ static int process_options(int argc, cha
 
 	switch (ce.cmd) {
 	case CMD_LIST:
-		if (options & (OPT_CONNECTION|OPT_TIMEOUT|OPT_DAEMON) &&
-		    options & (OPT_STATS|OPT_PERSISTENTCONN|
-			       OPT_RATE|OPT_THRESHOLDS))
+		if ((options & (OPT_CONNECTION|OPT_TIMEOUT|OPT_DAEMON) &&
+		     options & (OPT_STATS|OPT_RATE|OPT_THRESHOLDS)) ||
+		    (options & (OPT_TIMEOUT|OPT_DAEMON) &&
+		     options & OPT_PERSISTENTCONN))
 			fail(2, "options conflicts in the list command");
 
 		if (options & OPT_CONNECTION)
@@ -1060,7 +1070,7 @@ static void usage_exit(const char *progr
 	version(stream);
 	fprintf(stream,
 		"Usage:\n"
-		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask]\n"
+		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine]\n"
 		"  %s -D -t|u|f service-address\n"
 		"  %s -C\n"
 		"  %s -R\n"
@@ -1105,6 +1115,8 @@ static void usage_exit(const char *progr
 		"  --ipv6         -6                   fwmark entry uses IPv6\n"
 		"  --scheduler    -s scheduler         one of " SCHEDULERS ",\n"
 		"                                      the default scheduler is %s.\n"
+		"  --pe            engine              alternate persistence engine may be " PE_LIST ",\n"
+		"                                      not set by default.\n"
 		"  --persistent   -p [timeout]         persistent service\n"
 		"  --netmask      -M netmask           persistent granularity mask\n"
 		"  --real-server  -r server-address    server-address is host (and port)\n"
@@ -1225,6 +1237,8 @@ static void print_conn(char *buf, unsign
 	char            state[16];
 	unsigned int    expires;
 	unsigned short  af = AF_INET;
+	char		pe_name[IP_VS_PENAME_MAXLEN];
+	char		pe_data[IP_VS_PEDATA_MAXLEN];
 
 	int n;
 	char temp1[INET6_ADDRSTRLEN], temp2[INET6_ADDRSTRLEN], temp3[INET6_ADDRSTRLEN];
@@ -1232,9 +1246,10 @@ static void print_conn(char *buf, unsign
 	unsigned int	minutes, seconds;
 	char		expire_str[12];
 
-	if ((n = sscanf(buf, "%s %s %hX %s %hX %s %hX %s %d",
+	if ((n = sscanf(buf, "%s %s %hX %s %hX %s %hX %s %d %s %s",
 			protocol, temp1, &cport, temp2, &vport,
-			temp3, &dport, state, &expires)) == -1)
+			temp3, &dport, state, &expires,
+			pe_name, pe_data)) == -1)
 		exit(1);
 
 	if (strcmp(protocol, "TCP") == 0)
@@ -1268,8 +1283,13 @@ static void print_conn(char *buf, unsign
 	minutes = expires / 60;
 	sprintf(expire_str, "%02d:%02d", minutes, seconds);
 
-	printf("%-3s %-6s %-11s %-18s %-18s %s\n",
-	       protocol, expire_str, state, cname, vname, dname);
+	if (format & FMT_PERSISTENTCONN && n == 11)
+		printf("%-3s %-6s %-11s %-18s %-18s %-16s %-18s %s\n",
+		       protocol, expire_str, state, cname, vname, dname,
+		       pe_name, pe_data);
+	else
+		printf("%-3s %-6s %-11s %-18s %-18s %s\n",
+		       protocol, expire_str, state, cname, vname, dname);
 
 	free(cname);
 	free(vname);
@@ -1295,8 +1315,13 @@ void list_conn(unsigned int format)
 		exit(1);
 	}
 	printf("IPVS connection entries\n");
-	printf("pro expire %-11s %-18s %-18s %s\n",
-	       "state", "source", "virtual", "destination");
+	if (format & FMT_PERSISTENTCONN)
+		printf("pro expire %-11s %-18s %-18s %-18s %-16s %s\n",
+		       "state", "source", "virtual", "destination",
+		       "pe name", "pe_data");
+	else
+		printf("pro expire %-11s %-18s %-18s %s\n",
+		       "state", "source", "virtual", "destination");
 
 	/*
 	 * Print the VS information according to the format
@@ -1459,6 +1484,8 @@ print_service_entry(ipvs_service_entry_t
 					printf(" -M %i", se->netmask);
 				}
 		}
+		if (se->pe_name[0])
+			printf(" pe %s", se->pe_name);
 		if (se->flags & IP_VS_SVC_F_ONEPACKET)
 			printf(" ops");
 	} else if (format & FMT_STATS) {
@@ -1488,6 +1515,8 @@ print_service_entry(ipvs_service_entry_t
 			if (se->af == AF_INET6)
 				if (se->netmask != 128)
 					printf(" mask %i", se->netmask);
+			if (se->pe_name[0])
+				printf(" pe %s", se->pe_name);
 			if (se->flags & IP_VS_SVC_F_ONEPACKET)
 				printf(" ops");
 		}
Index: github.com/libipvs/ip_vs.h
===================================================================
--- github.com.orig/libipvs/ip_vs.h	2010-09-26 22:07:58.000000000 +0900
+++ github.com/libipvs/ip_vs.h	2010-10-01 23:00:10.000000000 +0900
@@ -92,8 +92,11 @@
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
 #define IP_VS_SCHEDNAME_MAXLEN	16
+#define IP_VS_PENAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
 
+#define IP_VS_PEDATA_MAXLEN	255
+
 union nf_inet_addr {
         __u32           all[4];
         __be32          ip;
@@ -134,6 +137,7 @@ struct ip_vs_service_user {
 	__be32			netmask;	/* persistent netmask */
 	u_int16_t		af;
 	union nf_inet_addr	addr;
+	char			pe_name[IP_VS_PENAME_MAXLEN];
 };
 
 struct ip_vs_dest_kern {
@@ -240,6 +244,7 @@ struct ip_vs_service_entry {
 
 	u_int16_t		af;
 	union nf_inet_addr	addr;
+	char			pe_name[IP_VS_PENAME_MAXLEN];
 
 };
 
@@ -429,6 +434,9 @@ enum {
 	IPVS_SVC_ATTR_NETMASK,		/* persistent netmask */
 
 	IPVS_SVC_ATTR_STATS,		/* nested attribute for service stats */
+
+	IPVS_SVC_ATTR_PE_NAME,		/* name of scheduler */
+
 	__IPVS_SVC_ATTR_MAX,
 };
 
Index: github.com/libipvs/libipvs.c
===================================================================
--- github.com.orig/libipvs/libipvs.c	2010-09-26 22:07:58.000000000 +0900
+++ github.com/libipvs/libipvs.c	2010-10-01 23:00:10.000000000 +0900
@@ -40,6 +40,15 @@ static int family, try_nl = 1;
 	{ errno = EAFNOSUPPORT; return ret; }			\
 	s->__addr_v4 = s->addr.ip;				\
 
+#define CHECK_PE(s, ret) if (s->pe_name)			\
+	{ errno = EAFNOSUPPORT; return ret; }
+
+#define CHECK_COMPAT_DEST(s, ret) CHECK_IPV4(s, ret)
+
+#define CHECK_COMPAT_SVC(s, ret)				\
+	CHECK_IPV4(s, ret);					\
+	CHECK_PE(s, ret);
+
 #ifdef LIBIPVS_USE_NL
 struct nl_msg *ipvs_nl_message(int cmd, int flags)
 {
@@ -218,6 +227,8 @@ static int ipvs_nl_fill_service_attr(str
 	}
 
 	NLA_PUT_STRING(msg, IPVS_SVC_ATTR_SCHED_NAME, svc->sched_name);
+	if (svc->pe_name)
+		NLA_PUT_STRING(msg, IPVS_SVC_ATTR_PE_NAME, svc->pe_name);
 	NLA_PUT(msg, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
 	NLA_PUT_U32(msg, IPVS_SVC_ATTR_TIMEOUT, svc->timeout);
 	NLA_PUT_U32(msg, IPVS_SVC_ATTR_NETMASK, svc->netmask);
@@ -245,7 +256,7 @@ int ipvs_add_service(ipvs_service_t *svc
 	}
 #endif
 
-	CHECK_IPV4(svc, -1);
+	CHECK_COMPAT_SVC(svc, -1);
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_ADD, (char *)svc,
 			  sizeof(struct ip_vs_service_kern));
 }
@@ -265,7 +276,7 @@ int ipvs_update_service(ipvs_service_t *
 		return ipvs_nl_send_message(msg, ipvs_nl_noop_cb, NULL);
 	}
 #endif
-	CHECK_IPV4(svc, -1);
+	CHECK_COMPAT_SVC(svc, -1);
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_EDIT, (char *)svc,
 			  sizeof(struct ip_vs_service_kern));
 }
@@ -285,7 +296,7 @@ int ipvs_del_service(ipvs_service_t *svc
 		return ipvs_nl_send_message(msg, ipvs_nl_noop_cb, NULL);
 	}
 #endif
-	CHECK_IPV4(svc, -1);
+	CHECK_COMPAT_SVC(svc, -1);
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_DEL, (char *)svc,
 			  sizeof(struct ip_vs_service_kern));
 }
@@ -310,7 +321,7 @@ int ipvs_zero_service(ipvs_service_t *sv
 		return ipvs_nl_send_message(msg, ipvs_nl_noop_cb, NULL);
 	}
 #endif
-	CHECK_IPV4(svc, -1);
+	CHECK_COMPAT_SVC(svc, -1);
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_ZERO, (char *)svc,
 			  sizeof(struct ip_vs_service_kern));
 }
@@ -360,8 +371,8 @@ nla_put_failure:
 	}
 #endif
 
-	CHECK_IPV4(svc, -1);
-	CHECK_IPV4(dest, -1);
+	CHECK_COMPAT_SVC(svc, -1);
+	CHECK_COMPAT_DEST(dest, -1);
 	memcpy(&svcdest.svc, svc, sizeof(svcdest.svc));
 	memcpy(&svcdest.dest, dest, sizeof(svcdest.dest));
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_ADDDEST,
@@ -389,8 +400,8 @@ nla_put_failure:
 		return -1;
 	}
 #endif
-	CHECK_IPV4(svc, -1);
-	CHECK_IPV4(dest, -1);
+	CHECK_COMPAT_SVC(svc, -1);
+	CHECK_COMPAT_DEST(dest, -1);
 	memcpy(&svcdest.svc, svc, sizeof(svcdest.svc));
 	memcpy(&svcdest.dest, dest, sizeof(svcdest.dest));
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_EDITDEST,
@@ -419,8 +430,8 @@ nla_put_failure:
 	}
 #endif
 
-	CHECK_IPV4(svc, -1);
-	CHECK_IPV4(dest, -1);
+	CHECK_COMPAT_SVC(svc, -1);
+	CHECK_COMPAT_DEST(dest, -1);
 	memcpy(&svcdest.svc, svc, sizeof(svcdest.svc));
 	memcpy(&svcdest.dest, dest, sizeof(svcdest.dest));
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_DELDEST,
@@ -593,6 +604,11 @@ static int ipvs_services_parse_cb(struct
 		nla_get_string(svc_attrs[IPVS_SVC_ATTR_SCHED_NAME]),
 		IP_VS_SCHEDNAME_MAXLEN);
 
+	if (svc_attrs[IPVS_SVC_ATTR_PE_NAME])
+		strncpy(get->entrytable[i].pe_name,
+			nla_get_string(svc_attrs[IPVS_SVC_ATTR_PE_NAME]),
+			IP_VS_PENAME_MAXLEN);
+
 	get->entrytable[i].netmask = nla_get_u32(svc_attrs[IPVS_SVC_ATTR_NETMASK]);
 	get->entrytable[i].timeout = nla_get_u32(svc_attrs[IPVS_SVC_ATTR_TIMEOUT]);
 	nla_memcpy(&flags, svc_attrs[IPVS_SVC_ATTR_FLAGS], sizeof(flags));
@@ -937,7 +953,8 @@ ipvs_get_service_err2:
 	}
 #endif
 
-	CHECK_IPV4(svc, NULL);
+	CHECK_COMPAT_SVC(svc, NULL);
+	CHECK_PE(svc, NULL);
 	if (getsockopt(sockfd, IPPROTO_IP, IP_VS_SO_GET_SERVICE,
 		       (char *)svc, &len)) {
 		free(svc);
@@ -945,6 +962,7 @@ ipvs_get_service_err2:
 	}
 	svc->af = AF_INET;
 	svc->addr.ip = svc->__addr_v4;
+	svc->pe_name[0] = '\0';
 	return svc;
 }
 
@@ -1086,9 +1104,9 @@ const char *ipvs_strerror(int err)
 		const char *message;
 	} table [] = {
 		{ ipvs_add_service, EEXIST, "Service already exists" },
-		{ ipvs_add_service, ENOENT, "Scheduler not found" },
+		{ ipvs_add_service, ENOENT, "Scheduler or persistence engine not found" },
 		{ ipvs_update_service, ESRCH, "No such service" },
-		{ ipvs_update_service, ENOENT, "Scheduler not found" },
+		{ ipvs_update_service, ENOENT, "Scheduler or persistence engine not found" },
 		{ ipvs_del_service, ESRCH, "No such service" },
 		{ ipvs_zero_service, ESRCH, "No such service" },
 		{ ipvs_add_dest, ESRCH, "Service not defined" },

