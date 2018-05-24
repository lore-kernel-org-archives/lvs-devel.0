From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] libipvs: fix some buffer sizes
Date: Thu, 24 May 2018 23:37:45 +0300
Message-ID: <20180524203745.25950-1-ja@ssi.bg>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
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
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Simon Horman <horms@verge.net.au>

Size or length? Here is the answer:

- IP_VS_SCHEDNAME_MAXLEN and IP_VS_IFNAME_MAXLEN are sizes
because they are used in kernel structures exported to user
space for the old setsockopt interface. We can not change
these structures in the kernel.

- IP_VS_PENAME_MAXLEN and IP_VS_PEDATA_MAXLEN are max lengths
because they are not exported to the old interface.

As result:
- buffers should have space for NUL terminator
- strncpy should use sizeof(buffer) - 1 as max length

As we change the libipvs structures, their users should be
recompiled.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 ipvsadm.c         | 8 ++++----
 libipvs/ip_vs.h   | 4 ++--
 libipvs/libipvs.c | 7 ++++---
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 1a28d72..7695006 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -595,7 +595,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		case 's':
 			set_option(options, OPT_SCHEDULER);
 			strncpy(ce->svc.sched_name,
-				optarg, IP_VS_SCHEDNAME_MAXLEN);
+				optarg, IP_VS_SCHEDNAME_MAXLEN - 1);
 			break;
 		case 'p':
 			set_option(options, OPT_PERSISTENT);
@@ -670,7 +670,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		case TAG_MCAST_INTERFACE:
 			set_option(options, OPT_MCAST);
 			strncpy(ce->daemon.mcast_ifn,
-				optarg, IP_VS_IFNAME_MAXLEN);
+				optarg, IP_VS_IFNAME_MAXLEN - 1);
 			break;
 		case 'I':
 			set_option(options, OPT_SYNCID);
@@ -1415,8 +1415,8 @@ static void print_conn(char *buf, unsigned int format)
 	unsigned int    expires;
 	unsigned short  af = AF_INET;
 	unsigned short  daf = AF_INET;
-	char		pe_name[IP_VS_PENAME_MAXLEN];
-	char		pe_data[IP_VS_PEDATA_MAXLEN];
+	char		pe_name[IP_VS_PENAME_MAXLEN + 1];
+	char		pe_data[IP_VS_PEDATA_MAXLEN + 1];
 
 	int n;
 	char temp1[INET6_ADDRSTRLEN], temp2[INET6_ADDRSTRLEN], temp3[INET6_ADDRSTRLEN];
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index 774ff96..e57d55a 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -144,7 +144,7 @@ struct ip_vs_service_user {
 	__be32			netmask;	/* persistent netmask */
 	u_int16_t		af;
 	union nf_inet_addr	addr;
-	char			pe_name[IP_VS_PENAME_MAXLEN];
+	char			pe_name[IP_VS_PENAME_MAXLEN + 1];
 };
 
 struct ip_vs_dest_kern {
@@ -267,7 +267,7 @@ struct ip_vs_service_entry {
 
 	u_int16_t		af;
 	union nf_inet_addr	addr;
-	char			pe_name[IP_VS_PENAME_MAXLEN];
+	char			pe_name[IP_VS_PENAME_MAXLEN + 1];
 
 	/* statistics, 64-bit */
 	struct ip_vs_stats64	stats64;
diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index a843243..9be7700 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -719,7 +719,7 @@ static int ipvs_services_parse_cb(struct nl_msg *msg, void *arg)
 
 	strncpy(get->entrytable[i].sched_name,
 		nla_get_string(svc_attrs[IPVS_SVC_ATTR_SCHED_NAME]),
-		IP_VS_SCHEDNAME_MAXLEN);
+		IP_VS_SCHEDNAME_MAXLEN - 1);
 
 	if (svc_attrs[IPVS_SVC_ATTR_PE_NAME])
 		strncpy(get->entrytable[i].pe_name,
@@ -1199,7 +1199,7 @@ static int ipvs_daemon_parse_cb(struct nl_msg *msg, void *arg)
 	u[i].state = nla_get_u32(daemon_attrs[IPVS_DAEMON_ATTR_STATE]);
 	strncpy(u[i].mcast_ifn,
 		nla_get_string(daemon_attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
-		IP_VS_IFNAME_MAXLEN);
+		IP_VS_IFNAME_MAXLEN - 1);
 	u[i].syncid = nla_get_u32(daemon_attrs[IPVS_DAEMON_ATTR_SYNC_ID]);
 
 	a = daemon_attrs[IPVS_DAEMON_ATTR_SYNC_MAXLEN];
@@ -1265,7 +1265,8 @@ ipvs_daemon_t *ipvs_get_daemon(void)
 	}
 	for (i = 0; i < 2; i++) {
 		u[i].state = dmk[i].state;
-		strncpy(u[i].mcast_ifn, dmk[i].mcast_ifn, IP_VS_IFNAME_MAXLEN);
+		strncpy(u[i].mcast_ifn, dmk[i].mcast_ifn,
+			IP_VS_IFNAME_MAXLEN - 1);
 		u[i].syncid = dmk[i].syncid;
 	}
 	return u;
-- 
2.9.5

