From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 7/8] IPVS: Backup, Change sending to Version 1 format
Date: Thu, 25 Nov 2010 10:46:57 +0900
Message-ID: <1290649618-18955-8-git-send-email-horms@verge.net.au>
References: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

Enable sending and removal of version 0 sending
Affected functions,

ip_vs_sync_buff_create()
ip_vs_sync_conn()

ip_vs_core.c removal of IPv4 check.

*v5
 Just check cp->pe_data_len in ip_vs_sync_conn
 Check if padding needed before adding a new sync_conn
 to the buffer, i.e. avoid sending padding at the end.

*v4
 moved sanity check and pe_name_len after sloop.
 use cp->pe instead of cp->dest->svc->pe
 real length in each sync_conn, not padded length
 however total size of a sync_msg includes padding.

*v3
 Sending ip_vs_sync_conn_options in network order.
 Sending Templates for ONE_PACKET conn.
 Renaming of ip_vs_sync_mesg to ip_vs_sync_mesg_v0

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |   13 ++-
 net/netfilter/ipvs/ip_vs_sync.c |  189 ++++++++++++++++++++++++++++++---------
 3 files changed, 156 insertions(+), 48 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4069484..a715f3d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -919,7 +919,7 @@ extern char ip_vs_master_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 extern char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 extern int start_sync_thread(int state, char *mcast_ifn, __u8 syncid);
 extern int stop_sync_thread(int state);
-extern void ip_vs_sync_conn(const struct ip_vs_conn *cp);
+extern void ip_vs_sync_conn(struct ip_vs_conn *cp);
 
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 3445da6..5287771 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1560,9 +1560,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 *
 	 * Sync connection if it is about to close to
 	 * encorage the standby servers to update the connections timeout
+	 *
+	 * For ONE_PKT let ip_vs_sync_conn() do the filter work.
 	 */
-	pkts = atomic_add_return(1, &cp->in_pkts);
-	if (af == AF_INET && (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		pkts = sysctl_ip_vs_sync_threshold[0];
+	else
+		pkts = atomic_add_return(1, &cp->in_pkts);
+
+	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    cp->protocol == IPPROTO_SCTP) {
 		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
 			(pkts % sysctl_ip_vs_sync_threshold[1]
@@ -1577,8 +1583,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 
 	/* Keep this block last: TCP and others with pp->num_states <= 1 */
-	else if (af == AF_INET &&
-	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	else if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
 	      (pkts % sysctl_ip_vs_sync_threshold[1]
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index e071508..df5abf0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -226,7 +226,7 @@ struct ip_vs_sync_thread_data {
 #define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
 
 /* Version 0 header */
-struct ip_vs_sync_mesg {
+struct ip_vs_sync_mesg_v0 {
 	__u8                    nr_conns;
 	__u8                    syncid;
 	__u16                   size;
@@ -235,7 +235,7 @@ struct ip_vs_sync_mesg {
 };
 
 /* Version 1 header */
-struct ip_vs_sync_mesg_v2 {
+struct ip_vs_sync_mesg {
 	__u8			reserved;	/* must be zero */
 	__u8			syncid;
 	__u16			size;
@@ -299,6 +299,17 @@ static void ntoh_seq(struct ip_vs_seq *no, struct ip_vs_seq *ho)
 	ho->previous_delta = get_unaligned_be32(&no->previous_delta);
 }
 
+/*
+ * Copy of struct ip_vs_seq
+ * From Aligned host order to unaligned network order
+ */
+static void hton_seq(struct ip_vs_seq *ho, struct ip_vs_seq *no)
+{
+	put_unaligned_be32(ho->init_seq, &no->init_seq);
+	put_unaligned_be32(ho->delta, &no->delta);
+	put_unaligned_be32(ho->previous_delta, &no->previous_delta);
+}
+
 static inline struct ip_vs_sync_buff *sb_dequeue(void)
 {
 	struct ip_vs_sync_buff *sb;
@@ -317,6 +328,9 @@ static inline struct ip_vs_sync_buff *sb_dequeue(void)
 	return sb;
 }
 
+/*
+ * Create a new sync buffer for Version 1 proto.
+ */
 static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create(void)
 {
 	struct ip_vs_sync_buff *sb;
@@ -328,11 +342,15 @@ static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create(void)
 		kfree(sb);
 		return NULL;
 	}
-	sb->mesg->nr_conns = 0;
+	sb->mesg->reserved = 0;  /* old nr_conns i.e. must be zeo now */
+	sb->mesg->version = SYNC_PROTO_VER;
 	sb->mesg->syncid = ip_vs_master_syncid;
-	sb->mesg->size = 4;
-	sb->head = (unsigned char *)sb->mesg + 4;
+	sb->mesg->size = sizeof(struct ip_vs_sync_mesg);
+	sb->mesg->nr_conns = 0;
+	sb->mesg->spare = 0;
+	sb->head = (unsigned char *)sb->mesg + sizeof(struct ip_vs_sync_mesg);
 	sb->end = (unsigned char *)sb->mesg + sync_send_mesg_maxlen;
+
 	sb->firstuse = jiffies;
 	return sb;
 }
@@ -373,18 +391,60 @@ get_curr_sync_buff(unsigned long time)
 	return sb;
 }
 
-
 /*
  *      Add an ip_vs_conn information into the current sync_buff.
  *      Called by ip_vs_in.
+ *      Sending Version 1 messages
  */
-void ip_vs_sync_conn(const struct ip_vs_conn *cp)
+void ip_vs_sync_conn(struct ip_vs_conn *cp)
 {
 	struct ip_vs_sync_mesg *m;
-	struct ip_vs_sync_conn_v0 *s;
-	int len;
+	union ip_vs_sync_conn *s;
+	__u8 *p;
+	unsigned int len, pe_name_len, pad;
+
+	/* Do not sync ONE PACKET */
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		goto control;
+sloop:
+	/* Sanity checks */
+	pe_name_len = 0;
+	if (cp->pe_data_len) {
+		if (!cp->pe_data || !cp->dest) {
+			IP_VS_ERR_RL("SYNC, connection pe_data invalid\n");
+			return;
+		}
+		pe_name_len = strnlen(cp->pe->name, IP_VS_PENAME_MAXLEN);
+	}
 
 	spin_lock(&curr_sb_lock);
+
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		len = sizeof(struct ip_vs_sync_v6);
+	else
+#endif
+		len = sizeof(struct ip_vs_sync_v4);
+
+	if (cp->flags & IP_VS_CONN_F_SEQ_MASK)
+		len += sizeof(struct ip_vs_sync_conn_options) + 2;
+
+	if (cp->pe_data_len)
+		len += cp->pe_data_len + 2;	/* + Param hdr field */
+	if (pe_name_len)
+		len += pe_name_len + 2;
+
+	/* check if there is a space for this one  */
+	pad = 0;
+	if (curr_sb) {
+		pad = (4 - (size_t)curr_sb->head) & 3;
+		if (curr_sb->head + len + pad > curr_sb->end) {
+			sb_queue_tail(curr_sb);
+			curr_sb = NULL;
+			pad = 0;
+		}
+	}
+
 	if (!curr_sb) {
 		if (!(curr_sb=ip_vs_sync_buff_create())) {
 			spin_unlock(&curr_sb_lock);
@@ -393,41 +453,84 @@ void ip_vs_sync_conn(const struct ip_vs_conn *cp)
 		}
 	}
 
-	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
-		SIMPLE_CONN_SIZE;
 	m = curr_sb->mesg;
-	s = (struct ip_vs_sync_conn_v0 *)curr_sb->head;
-
-	/* copy members */
-	s->protocol = cp->protocol;
-	s->cport = cp->cport;
-	s->vport = cp->vport;
-	s->dport = cp->dport;
-	s->caddr = cp->caddr.ip;
-	s->vaddr = cp->vaddr.ip;
-	s->daddr = cp->daddr.ip;
-	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
-	s->state = htons(cp->state);
-	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
-		struct ip_vs_sync_conn_options *opt =
-			(struct ip_vs_sync_conn_options *)&s[1];
-		memcpy(opt, &cp->in_seq, sizeof(*opt));
-	}
-
+	p = curr_sb->head;
+	curr_sb->head += pad + len;
+	m->size += pad + len;
+	/* Add ev. padding from prev. sync_conn */
+	while (pad--)
+		*(p++) = 0;
+
+	s = (union ip_vs_sync_conn *)p;
+
+	/* Set message type  & copy members */
+	s->v4.type = (cp->af == AF_INET6 ? STYPE_F_INET6 : 0);
+	s->v4.ver_size = htons(len & SVER_MASK);	/* Version 0 */
+	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);
+	s->v4.state = htons(cp->state);
+	s->v4.protocol = cp->protocol;
+	s->v4.cport = cp->cport;
+	s->v4.vport = cp->vport;
+	s->v4.dport = cp->dport;
+	s->v4.fwmark = htonl(cp->fwmark);
+	s->v4.timeout = htonl(cp->timeout / HZ);
 	m->nr_conns++;
-	m->size += len;
-	curr_sb->head += len;
 
-	/* check if there is a space for next one */
-	if (curr_sb->head+FULL_CONN_SIZE > curr_sb->end) {
-		sb_queue_tail(curr_sb);
-		curr_sb = NULL;
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6) {
+		p += sizeof(struct ip_vs_sync_v6);
+		ipv6_addr_copy(&s->v6.caddr, &cp->caddr.in6);
+		ipv6_addr_copy(&s->v6.vaddr, &cp->vaddr.in6);
+		ipv6_addr_copy(&s->v6.daddr, &cp->daddr.in6);
+	} else
+#endif
+	{
+		p += sizeof(struct ip_vs_sync_v4);	/* options ptr */
+		s->v4.caddr = cp->caddr.ip;
+		s->v4.vaddr = cp->vaddr.ip;
+		s->v4.daddr = cp->daddr.ip;
+	}
+	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
+		*(p++) = IPVS_OPT_SEQ_DATA;
+		*(p++) = sizeof(struct ip_vs_sync_conn_options);
+		hton_seq((struct ip_vs_seq *)p, &cp->in_seq);
+		p += sizeof(struct ip_vs_seq);
+		hton_seq((struct ip_vs_seq *)p, &cp->out_seq);
+		p += sizeof(struct ip_vs_seq);
 	}
+	/* Handle pe data */
+	if (cp->pe_data_len && cp->pe_data) {
+		*(p++) = IPVS_OPT_PE_DATA;
+		*(p++) = cp->pe_data_len;
+		memcpy(p, cp->pe_data, cp->pe_data_len);
+		p += cp->pe_data_len;
+		if (pe_name_len) {
+			/* Add PE_NAME */
+			*(p++) = IPVS_OPT_PE_NAME;
+			*(p++) = pe_name_len;
+			memcpy(p, cp->pe->name, pe_name_len);
+			p += pe_name_len;
+		}
+	}
+
 	spin_unlock(&curr_sb_lock);
 
+control:
 	/* synchronize its controller if it has */
-	if (cp->control)
-		ip_vs_sync_conn(cp->control);
+	cp = cp->control;
+	if (!cp)
+		return;
+	/*
+	 * Reduce sync rate for templates
+	 * i.e only increment in_pkts for Templates.
+	 */
+	if (cp->flags & IP_VS_CONN_F_TEMPLATE) {
+		int pkts = atomic_add_return(1, &cp->in_pkts);
+
+		if (pkts % sysctl_ip_vs_sync_threshold[1] != 1)
+			return;
+	}
+	goto sloop;
 }
 
 /*
@@ -596,7 +699,7 @@ static void ip_vs_proc_conn(struct ip_vs_conn_param *param,  unsigned flags,
  */
 static void ip_vs_process_message_v0(const char *buffer, const size_t buflen)
 {
-	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
+	struct ip_vs_sync_mesg_v0 *m = (struct ip_vs_sync_mesg_v0 *)buffer;
 	struct ip_vs_sync_conn_v0 *s;
 	struct ip_vs_sync_conn_options *opt;
 	struct ip_vs_protocol *pp;
@@ -604,7 +707,7 @@ static void ip_vs_process_message_v0(const char *buffer, const size_t buflen)
 	char *p;
 	int i;
 
-	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg);
+	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg_v0);
 	for (i=0; i<m->nr_conns; i++) {
 		unsigned flags, state;
 
@@ -848,11 +951,11 @@ out:
  */
 static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
 {
-	struct ip_vs_sync_mesg_v2 *m2 = (struct ip_vs_sync_mesg_v2 *)buffer;
+	struct ip_vs_sync_mesg *m2 = (struct ip_vs_sync_mesg *)buffer;
 	__u8 *p, *msg_end;
-	unsigned int i, nr_conns;
+	int i, nr_conns;
 
-	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
+	if (buflen < sizeof(struct ip_vs_sync_mesg_v0)) {
 		IP_VS_DBG(2, "BACKUP, message header too short\n");
 		return;
 	}
@@ -872,7 +975,7 @@ static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
 	if ((m2->version == SYNC_PROTO_VER) && (m2->reserved == 0)
 	    && (m2->spare == 0)) {
 
-		msg_end = buffer + sizeof(struct ip_vs_sync_mesg_v2);
+		msg_end = buffer + sizeof(struct ip_vs_sync_mesg);
 		nr_conns = m2->nr_conns;
 
 		for (i=0; i<nr_conns; i++) {
-- 
1.7.2.3

