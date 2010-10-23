From: Simon Horman <horms@verge.net.au>
Subject: [patch 9/9] IPVS: Send v2 synchronisation packets
Date: Sun, 24 Oct 2010 00:26:35 +0900
Message-ID: <20101023153023.175167001@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sync-ip_vs_sync_conn-v2.patch
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
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 23:35:26.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 23:36:48.000000000 +0900
@@ -166,7 +166,7 @@ struct ip_vs_sync_buff {
 	unsigned long           firstuse;
 
 	/* pointers for the message data */
-	struct ip_vs_sync_mesg_v1 *mesg;
+	struct ip_vs_sync_mesg_v2 *mesg;
 	unsigned char           *head;
 	unsigned char           *end;
 };
@@ -230,12 +230,16 @@ static inline struct ip_vs_sync_buff * i
 		kfree(sb);
 		return NULL;
 	}
+
+	memset(sb->mesg, 0, SYNC_MESG_V2_HEADER_LEN);
 	sb->mesg->nr_conns = 0;
 	sb->mesg->syncid = ip_vs_master_syncid;
-	sb->mesg->size = SYNC_MESG_V1_HEADER_LEN;
-	sb->head = (unsigned char *)sb->mesg + SYNC_MESG_V1_HEADER_LEN;
+	sb->mesg->size = SYNC_MESG_V2_HEADER_LEN;
+	sb->mesg->version = 2;
+	sb->head = (unsigned char *)sb->mesg + SYNC_MESG_V2_HEADER_LEN;
 	sb->end = (unsigned char *)sb->mesg + sync_send_mesg_maxlen;
 	sb->firstuse = jiffies;
+
 	return sb;
 }
 
@@ -282,17 +286,35 @@ get_curr_sync_buff(unsigned long time)
  */
 void ip_vs_sync_conn(const struct ip_vs_conn *cp)
 {
-	struct ip_vs_sync_mesg_v1 *m;
+	struct ip_vs_sync_mesg_v2 *m;
 	struct ip_vs_sync_conn *s;
-	int len;
+	__u16 flags = cp->flags;
+	int len, pe_len = 0;
+	size_t pe_name_len = 0;
 
 	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
 		SIMPLE_CONN_SIZE;
 
+	if (cp->pe_data_len) {
+		if (!cp->dest) {
+			IP_VS_ERR_RL("connection has pe_data_len but no dest, can't sychronise\n");
+			return;
+		}
+		if (!cp->pe_data) {
+			IP_VS_ERR_RL("connection has pe_data_len but no pe_data, can't sychronise\n");
+			return;
+		}
+		flags |= IP_VS_CONN_PE;
+		pe_name_len = strlen(cp->dest->svc->pe->name) + 1;
+		pe_len = sizeof(__u16) * 2 +
+			SYNC_MSG_STR_ALIGN(pe_name_len) +
+			SYNC_MSG_STR_ALIGN(cp->pe_data_len);
+	}
+
 	spin_lock(&curr_sb_lock);
 
 	/* check if there is a enough space */
-	if (curr_sb && curr_sb->head + len > curr_sb->end) {
+	if (curr_sb && curr_sb->head + len + pe_len) {
 		sb_queue_tail(curr_sb);
 		curr_sb = NULL;
 	}
@@ -315,7 +337,7 @@ void ip_vs_sync_conn(const struct ip_vs_
 	s->caddr = cp->caddr.ip;
 	s->vaddr = cp->vaddr.ip;
 	s->daddr = cp->daddr.ip;
-	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
+	s->flags = htons(flags & ~IP_VS_CONN_F_HASHED);
 	s->state = htons(cp->state);
 	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
 		struct ip_vs_sync_conn_options *opt =
@@ -327,6 +349,32 @@ void ip_vs_sync_conn(const struct ip_vs_
 	m->size += len;
 	curr_sb->head += len;
 
+	if (cp->pe_data_len) {
+		__u16 l;
+
+		l = pe_name_len;
+		l = htons(l);
+		memcpy(curr_sb->head, &l, sizeof(l));
+		m->size += sizeof(l);
+		curr_sb->head += sizeof(l);
+
+		l = cp->pe_data_len;
+		l = htons(l);
+		memcpy(curr_sb->head, &l, sizeof(l));
+		m->size += sizeof(l);
+		curr_sb->head += sizeof(l);
+
+		memset(curr_sb->head, 0, SYNC_MSG_STR_ALIGN(pe_name_len));
+		memcpy(curr_sb->head, cp->dest->svc->pe->name, pe_name_len);
+		m->size += SYNC_MSG_STR_ALIGN(pe_name_len);
+		curr_sb->head += SYNC_MSG_STR_ALIGN(pe_name_len);
+
+		memset(curr_sb->head, 0, SYNC_MSG_STR_ALIGN(cp->pe_data_len));
+		memcpy(curr_sb->head, cp->pe_data, cp->pe_data_len);
+		m->size += SYNC_MSG_STR_ALIGN(cp->pe_data_len);
+		curr_sb->head += SYNC_MSG_STR_ALIGN(cp->pe_data_len);
+	}
+
 	spin_unlock(&curr_sb_lock);
 
 	/* synchronize its controller if it has */
@@ -339,7 +387,7 @@ ip_vs_conn_fill_param_sync(int af, int p
 			   const union nf_inet_addr *caddr, __be16 cport,
 			   const union nf_inet_addr *vaddr, __be16 vport,
 			   const char *pe_name, const char *pe_data,
-			   struct ip_vs_conn_param *p)
+			   __u8 pe_data_len, struct ip_vs_conn_param *p)
 {
 	/* XXX: Need to take into account persistence engine */
 	ip_vs_conn_fill_param(af, protocol, caddr, cport, vaddr, vport, p);
@@ -350,6 +398,7 @@ ip_vs_conn_fill_param_sync(int af, int p
 			IP_VS_ERR_RL("can't allocate memory for persistence engine data\n");
 			return -ENOMEM;
 		}
+		p->pe_data_len = pe_data_len;
 
 		p->pe = ip_vs_pe_get(pe_name);
 		if (p->pe == NULL) {
@@ -377,6 +426,7 @@ static void ip_vs_process_message(char *
 	struct ip_vs_protocol *pp;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn_param param;
+	__u16 pe_name_len, pe_data_len;
 	__u8 version = 1;
 	size_t size;
 	char *p;
@@ -414,7 +464,11 @@ static void ip_vs_process_message(char *
 		return;
 	}
 
-	p = (char *)buffer + SYNC_MESG_V1_HEADER_LEN;
+	p = (char *)buffer;
+	if (version == 1)
+		p += SYNC_MESG_V1_HEADER_LEN;
+	else
+		p += SYNC_MESG_V2_HEADER_LEN;
 	for (i = 0; i < m_v1->nr_conns; i++) {
 		unsigned flags, state;
 		char *pe_name = NULL, *pe_data = NULL;
@@ -462,46 +516,50 @@ static void ip_vs_process_message(char *
 		}
 
 		if (flags & IP_VS_CONN_PE && version == 2) {
-			__u16 pe_name_len, pe_data_len;
-
 			flags &= ~IP_VS_CONN_PE;
 
 			if (p + (sizeof(__u16) + SYNC_MSG_STR_ALIGN_BYTES) * 2 >
 			    buffer + buflen) {
-				IP_VS_ERR_RL("bogus persistence engine in sync message\n");
+				IP_VS_ERR_RL("bogus persistence engine in sync message: data is less than the minimum length\n");
 				return;
 			}
 
 			memcpy(&pe_name_len, p, sizeof(pe_name_len));
 			pe_name_len = ntohs(pe_name_len);
 			p += sizeof(pe_name_len);
-			if (pe_name_len > IP_VS_PENAME_MAXLEN) {
-				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_name length > IP_VS_PENAME_MAXLEN (%u > %u)\n",
-					     pe_name_len, IP_VS_PENAME_MAXLEN);
+			if (pe_name_len > IP_VS_PENAME_MAXLEN + 1) {
+				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_name length > IP_VS_PENAME_MAXLEN + 1 (%u > %u)\n",
+					     pe_name_len,
+					     IP_VS_PENAME_MAXLEN + 1);
+				return;
+			}
+			if (pe_name_len < 1) {
+				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_name length < 1 (%u < 1)\n", pe_name_len);
 				return;
 			}
 
 			memcpy(&pe_data_len, p, sizeof(pe_data_len));
 			pe_data_len = ntohs(pe_data_len);
 			p += sizeof(pe_data_len);
-			if (pe_data_len > IP_VS_PENAME_MAXLEN) {
-				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_name length > IP_VS_PENAME_MAXLEN (%u > %u)\n",
-					     pe_data_len, IP_VS_PENAME_MAXLEN);
+			if (pe_data_len > IP_VS_PEDATA_MAXLEN) {
+				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_data length > IP_VS_PEDATA_MAXLEN (%u > %u)\n",
+					     pe_data_len, IP_VS_PEDATA_MAXLEN);
+				return;
+			}
+
+			if (p + pe_name_len + pe_data_len > buffer + buflen) {
+				IP_VS_ERR_RL("bogus persistence engine in sync message: length missmatch\n");
 				return;
 			}
 
 			pe_name = p;
-			if (pe_name[pe_name_len + 1] != '\0') {
+			if (pe_name[pe_name_len - 1] != '\0') {
 				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_name is not nul terminated\n");
 				return;
 			}
 			p += SYNC_MSG_STR_ALIGN(pe_name_len);
 
 			pe_data = p;
-			if (pe_data[pe_data_len + 1] != '\0') {
-				IP_VS_ERR_RL("bogus persistence engine in sync message: pe_data is not nul terminated\n");
-				return;
-			}
 			p += SYNC_MSG_STR_ALIGN(pe_data_len);
 		}
 
@@ -510,7 +568,7 @@ static void ip_vs_process_message(char *
 					       s->cport,
 					       (union nf_inet_addr *)&s->vaddr,
 					       s->vport, pe_name, pe_data,
-					       &param)) {
+					       pe_data_len, &param)) {
 			IP_VS_ERR_RL("Unsupported persistence engine %s in sync msg\n", pe_name);
 			continue;
 		}
@@ -846,7 +904,7 @@ ip_vs_send_async(struct socket *sock, co
 }
 
 static void
-ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg_v1 *msg)
+ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg_v2 *msg)
 {
 	int msize;
 

