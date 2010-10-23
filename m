From: Simon Horman <horms@verge.net.au>
Subject: [patch 7/9] IPVS: Allow parsing of ip_vs_sync_mesg_v2 messages
Date: Sun, 24 Oct 2010 00:26:33 +0900
Message-ID: <20101023153022.082444497@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sync-ip_vs_process_message-v2.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

This is a prototype of the v2 protocol that includes persistence engine
data synchronisation but not other features such as IPv6 service
synchronisation that are planned for inclusion in the full version of v2.

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-10-15 08:17:20.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-10-15 08:28:32.000000000 +0900
@@ -151,6 +151,10 @@ struct ip_vs_sync_mesg_v2 {
 	/* ip_vs_sync_conn entries start here */
 };
 
+#define SYNC_MSG_STR_ALIGN_BYTES 4
+#define SYNC_MSG_STR_ALIGN(_n_) \
+	(((_n_)+(SYNC_MSG_STR_ALIGN_BYTES-1))&~(SYNC_MSG_STR_ALIGN_BYTES-1))
+
 #define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
 
 /* the maximum length of sync (sending/receiving) message */
@@ -332,10 +336,28 @@ static inline int
 ip_vs_conn_fill_param_sync(int af, int protocol,
 			   const union nf_inet_addr *caddr, __be16 cport,
 			   const union nf_inet_addr *vaddr, __be16 vport,
+			   const char *pe_name, const char *pe_data,
 			   struct ip_vs_conn_param *p)
 {
 	/* XXX: Need to take into account persistence engine */
 	ip_vs_conn_fill_param(af, protocol, caddr, cport, vaddr, vport, p);
+
+	if (pe_data && pe_name) {
+		p->pe_data = kstrdup(pe_data, GFP_KERNEL);
+		if (!p->pe_data) {
+			IP_VS_ERR_RL("can't allocate memory for persistence engine data\n");
+			return -ENOMEM;
+		}
+
+		p->pe = ip_vs_pe_getbyname(pe_name);
+		if (p->pe == NULL) {
+			IP_VS_ERR_RL("persistence engine module ip_vs_pe_%s "
+				     "not found\n", pe_name);
+			kfree(p->pe_data);
+			return -ENOENT;
+		}
+	}
+
 	return 0;
 }
 
@@ -345,13 +367,16 @@ ip_vs_conn_fill_param_sync(int af, int p
  */
 static void ip_vs_process_message(char *buffer, const size_t buflen)
 {
-	struct ip_vs_sync_mesg_v1 *m = (struct ip_vs_sync_mesg_v1 *)buffer;
+	struct ip_vs_sync_mesg_v1 *m_v1 = (struct ip_vs_sync_mesg_v1 *)buffer;
+	struct ip_vs_sync_mesg_v2 *m_v2 = (struct ip_vs_sync_mesg_v2 *)buffer;
 	struct ip_vs_sync_conn *s;
 	struct ip_vs_sync_conn_options *opt;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn_param param;
+	__u8 version = 1;
+	size_t size;
 	char *p;
 	int i;
 
@@ -361,23 +386,36 @@ static void ip_vs_process_message(char *
 	}
 
 	/* Convert size back to host byte order */
-	m->size = ntohs(m->size);
-
-	if (buflen != m->size) {
+	size = m_v1->size = ntohs(m_v1->size);
+	if (m_v1->size == 0) {
+		if (buflen < sizeof(struct ip_vs_sync_mesg_v2)) {
+			IP_VS_ERR_RL("sync message v2 header too short\n");
+			return;
+		}
+		size = m_v2->size = ntohs(m_v2->size);
+		version = m_v2->version;
+		if (version != 2) {
+			IP_VS_DBG(7, "Ignoring incoming msg with version = %d\n",
+				  version);
+			return;
+		}
+	}
+	if (buflen != size) {
 		IP_VS_ERR_RL("bogus sync message size\n");
 		return;
 	}
 
 	/* SyncID sanity check */
-	if (ip_vs_backup_syncid != 0 && m->syncid != ip_vs_backup_syncid) {
+	if (ip_vs_backup_syncid != 0 && m_v1->syncid != ip_vs_backup_syncid) {
 		IP_VS_DBG(7, "Ignoring incoming msg with syncid = %d\n",
-			  m->syncid);
+			  m_v1->syncid);
 		return;
 	}
 
 	p = (char *)buffer + SYNC_MESG_V1_HEADER_LEN;
-	for (i=0; i<m->nr_conns; i++) {
+	for (i = 0; i < m_v1->nr_conns; i++) {
 		unsigned flags, state;
+		char *pe_name = NULL, *pe_data = NULL;
 
 		if (p + SIMPLE_CONN_SIZE > buffer+buflen) {
 			IP_VS_ERR_RL("bogus conn in sync message\n");
@@ -421,13 +459,58 @@ static void ip_vs_process_message(char *
 			}
 		}
 
+		if (flags & IP_VS_CONN_PE && version == 2) {
+			__u16 pe_name_len, pe_data_len;
+
+			flags &= ~IP_VS_CONN_PE;
+
+			if (p + (sizeof(__u16) + SYNC_MSG_STR_ALIGN_BYTES) * 2 >
+			    buffer + buflen) {
+				IP_VS_ERR_RL("bogus persistence engine in sync message\n");
+				return;
+			}
+
+			memcpy(&pe_name_len, p, sizeof(pe_name_len));
+			pe_name_len = ntohs(pe_name_len);
+			p += sizeof(pe_name_len);
+			if (pe_name_len > IP_VS_PENAME_MAXLEN) {
+				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_name length > IP_VS_PENAME_MAXLEN (%u > %u)\n",
+					     pe_name_len, IP_VS_PENAME_MAXLEN);
+				return;
+			}
+
+			memcpy(&pe_data_len, p, sizeof(pe_data_len));
+			pe_data_len = ntohs(pe_data_len);
+			p += sizeof(pe_data_len);
+			if (pe_data_len > IP_VS_PENAME_MAXLEN) {
+				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_name length > IP_VS_PENAME_MAXLEN (%u > %u)\n",
+					     pe_data_len, IP_VS_PENAME_MAXLEN);
+				return;
+			}
+
+			pe_name = p;
+			if (pe_name[pe_name_len + 1] != '\0') {
+				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_name is not nul terminated\n");
+				return;
+			}
+			p += SYNC_MSG_STR_ALIGN(pe_name_len);
+
+			pe_data = p;
+			if (pe_data[pe_data_len + 1] != '\0') {
+				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_data is not nul terminated\n");
+				return;
+			}
+			p += SYNC_MSG_STR_ALIGN(pe_data_len);
+		}
+
 		if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
 					       (union nf_inet_addr *)&s->caddr,
 					       s->cport,
 					       (union nf_inet_addr *)&s->vaddr,
-					       s->vport, &param)) {
-			pr_err("ip_vs_conn_fill_param_sync failed");
-			return;
+					       s->vport, pe_name, pe_data,
+					       &param)) {
+			IP_VS_ERR_RL("Unsupported persistence engine %s in sync msg\n", pe_name);
+			continue;
 		}
 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			cp = ip_vs_conn_in_get(&param);
@@ -464,6 +547,7 @@ static void ip_vs_process_message(char *
 				atomic_dec(&dest->refcnt);
 			if (!cp) {
 				pr_err("ip_vs_conn_new failed\n");
+				ip_vs_pe_put(param.pe);
 				return;
 			}
 		} else if (!cp->dest) {
@@ -512,6 +596,7 @@ static void ip_vs_process_message(char *
 		else
 			cp->timeout = (3*60*HZ);
 		ip_vs_conn_put(cp);
+		ip_vs_pe_put(param.pe);
 	}
 }
 
Index: lvs-test-2.6/include/linux/ip_vs.h
===================================================================
--- lvs-test-2.6.orig/include/linux/ip_vs.h	2010-10-15 08:17:11.000000000 +0900
+++ lvs-test-2.6/include/linux/ip_vs.h	2010-10-15 08:17:23.000000000 +0900
@@ -88,6 +88,7 @@
 #define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
+#define IP_VS_CONN_PE		0x4000		/* persistene engine in use */
 
 /* Flags that are not sent to backup server start from bit 16 */
 #define IP_VS_CONN_F_NFCT	(1 << 16)	/* use netfilter conntrack */

