From: zhouxudong199 <zhouxudong8@huawei.com>
Subject: [PATCH] ipvs:clean code for ip_vs_sync.c
Date: Wed, 15 Jul 2020 12:18:39 +0000
Message-ID: <1594815519-37044-1-git-send-email-zhouxudong8@huawei.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, zhouxudong8@huawei.com, rose.chen@huawei.com


Signed-off-by:zhouxudong199 <zhouxudong8@huawei.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 605e0f6..885bab4 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1077,10 +1077,10 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn_param param;
 	__u32 flags;
-	unsigned int af, state, pe_data_len=0, pe_name_len=0;
-	__u8 *pe_data=NULL, *pe_name=NULL;
-	__u32 opt_flags=0;
-	int retc=0;
+	unsigned int af, state, pe_data_len = 0, pe_name_len = 0;
+	__u8 *pe_data = NULL, *pe_name = NULL;
+	__u32 opt_flags = 0;
+	int retc = 0;
 
 	s = (union ip_vs_sync_conn *) p;
 
@@ -1089,7 +1089,7 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
 		af = AF_INET6;
 		p += sizeof(struct ip_vs_sync_v6);
 #else
-		IP_VS_DBG(3,"BACKUP, IPv6 msg received, and IPVS is not compiled for IPv6\n");
+		IP_VS_DBG(3, "BACKUP, IPv6 msg received, and IPVS is not compiled for IPv6\n");
 		retc = 10;
 		goto out;
 #endif
@@ -1129,7 +1129,7 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
 			break;
 
 		case IPVS_OPT_PE_NAME:
-			if (ip_vs_proc_str(p, plen,&pe_name_len, &pe_name,
+			if (ip_vs_proc_str(p, plen, &pe_name_len, &pe_name,
 					   IP_VS_PENAME_MAXLEN, &opt_flags,
 					   IPVS_OPT_F_PE_NAME))
 				return -70;
@@ -1155,7 +1155,7 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
 	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
 		pp = ip_vs_proto_get(s->v4.protocol);
 		if (!pp) {
-			IP_VS_DBG(3,"BACKUP, Unsupported protocol %u\n",
+			IP_VS_DBG(3, "BACKUP, Unsupported protocol %u\n",
 				s->v4.protocol);
 			retc = 30;
 			goto out;
@@ -1232,7 +1232,7 @@ static void ip_vs_process_message(struct netns_ipvs *ipvs, __u8 *buffer,
 		msg_end = buffer + sizeof(struct ip_vs_sync_mesg);
 		nr_conns = m2->nr_conns;
 
-		for (i=0; i<nr_conns; i++) {
+		for (i=0; i < nr_conns; i++) {
 			union ip_vs_sync_conn *s;
 			unsigned int size;
 			int retc;
@@ -1444,7 +1444,7 @@ static int bind_mcastif_addr(struct socket *sock, struct net_device *dev)
 	sin.sin_addr.s_addr  = addr;
 	sin.sin_port         = 0;
 
-	return sock->ops->bind(sock, (struct sockaddr*)&sin, sizeof(sin));
+	return sock->ops->bind(sock, (struct sockaddr *)&sin, sizeof(sin));
 }
 
 static void get_mcast_sockaddr(union ipvs_sockaddr *sa, int *salen,
-- 
2.6.1.windows.1


