From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 4/4] IPVS: Change sending to Version 1 format
Date: Tue, 26 Oct 2010 13:00:23 +0200
Message-ID: <1288090823-31135-4-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

This patch finalize this patch series with sending
Affected functions,

ip_vs_sync_buff_create()
ip_vs_sync_conn()

ip_vs_core.c removal of IPv4 check.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_core.c |    6 +-
 net/netfilter/ipvs/ip_vs_sync.c |  139 +++++++++++++++++++++++++++++----------
 2 files changed, 108 insertions(+), 37 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 61abf39..8e37c5f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1536,9 +1536,10 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 *
 	 * Sync connection if it is about to close to
 	 * encorage the standby servers to update the connections timeout
+	 * IPv6 is supported now
 	 */
 	pkts = atomic_add_return(1, &cp->in_pkts);
-	if (af == AF_INET && (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    cp->protocol == IPPROTO_SCTP) {
 		if ((cp->state == IP_VS_SCTP_S_ESTABLISHED &&
 			(pkts % sysctl_ip_vs_sync_threshold[1]
@@ -1553,8 +1554,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	}
 
 	/* Keep this block last: TCP and others with pp->num_states <= 1 */
-	else if (af == AF_INET &&
-	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	else if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
 	      (pkts % sysctl_ip_vs_sync_threshold[1]
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2d2d5c9..9fc2b45 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -249,9 +249,9 @@ struct ip_vs_sync_buff {
 	unsigned long           firstuse;
 
 	/* pointers for the message data */
-	struct ip_vs_sync_mesg  *mesg;
-	unsigned char           *head;
-	unsigned char           *end;
+	struct ip_vs_sync_mesg_v2 *mesg;
+	unsigned char             *head;
+	unsigned char             *end;
 };
 
 
@@ -302,6 +302,9 @@ static inline struct ip_vs_sync_buff *sb_dequeue(void)
 	return sb;
 }
 
+/*
+ * Create a new sync buffer for Version 1 proto.
+ */
 static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create(void)
 {
 	struct ip_vs_sync_buff *sb;
@@ -313,11 +316,15 @@ static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create(void)
 		kfree(sb);
 		return NULL;
 	}
-	sb->mesg->nr_conns = 0;
+	sb->mesg->reserverd = 0; /* old nr_conns i.e. must be zeo now */
+	sb->mesg->version = SYNC_PROTO_VER;
 	sb->mesg->syncid = ip_vs_master_syncid;
-	sb->mesg->size = 4;
-	sb->head = (unsigned char *)sb->mesg + 4;
+	sb->mesg->size = sizeof(struct ip_vs_sync_mesg_v2);
+	sb->mesg->nr_conns = 0;
+	sb->mesg->spare = 0;
+	sb->head = (unsigned char *)sb->mesg + sizeof(struct ip_vs_sync_mesg_v2);
 	sb->end = (unsigned char *)sb->mesg + sync_send_mesg_maxlen;
+
 	sb->firstuse = jiffies;
 	return sb;
 }
@@ -362,14 +369,47 @@ get_curr_sync_buff(unsigned long time)
 /*
  *      Add an ip_vs_conn information into the current sync_buff.
  *      Called by ip_vs_in.
+ *      Sending Version 1 messages
  */
 void ip_vs_sync_conn(struct ip_vs_conn *cp)
 {
-	struct ip_vs_sync_mesg *m;
-	struct ip_vs_sync_conn_v0 *s;
-	int len;
+	struct ip_vs_sync_mesg_v2 *m;
+	union ip_vs_sync_conn *s;
+	char *p;
+	int len, pe_name_len = 0;
+
+	/* Sanity checks */
+	if (cp->pe_data_len && (!cp->pe_data || !cp->dest)) {
+		IP_VS_ERR_RL("connection pe_data invalid\n");
+		return;
+	}
+	/* Add space for terminating \0 */
+	if (cp->pe_data_len && cp->dest->svc && cp->dest->svc->pe
+	     && cp->dest->svc->pe->name )
+		pe_name_len = strnlen(cp->dest->svc->pe->name,
+				      IP_VS_PENAME_MAXLEN) + 1;
 
 	spin_lock(&curr_sb_lock);
+#ifdef CONFIG_IP_VS_IPV6
+	/* Assumption,if not configured for IPv6 no packets should enter here */
+	if (cp->af == AF_INET6)
+		len = sizeof(struct ip_vs_sync_v6);
+	else
+#endif
+		len = sizeof(struct ip_vs_sync_v4);
+
+	if (cp->flags & IP_VS_CONN_F_SEQ_MASK)
+		len += sizeof(struct ip_vs_sync_conn_options);
+
+	/* 32 bit alignment */
+	len += (cp->pe_data_len + pe_name_len + 3) & 0xfc;
+
+	/* check if there is a space for this one */
+	if (curr_sb && (curr_sb->head+len > curr_sb->end) ) {
+		sb_queue_tail(curr_sb);
+		curr_sb = NULL;
+	}
+
 	if (!curr_sb) {
 		if (!(curr_sb=ip_vs_sync_buff_create())) {
 			spin_unlock(&curr_sb_lock);
@@ -378,42 +418,72 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 		}
 	}
 
-	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
-		SIMPLE_CONN_SIZE;
+
 	m = curr_sb->mesg;
-	s = (struct ip_vs_sync_conn_v0 *)curr_sb->head;
+	s = (union ip_vs_sync_conn *)curr_sb->head;
+	p = (char *)s;
 
+	/* Set message type */
+	if (cp->pe_data_len)
+		s->v4.type = (cp->af == AF_INET6 ? STYPE_PE_6 : STYPE_PE_4);
+	else
+		s->v4.type = (cp->af == AF_INET6 ? STYPE_INET6 : STYPE_INET4);
 	/* copy members */
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
+	s->v4.ver_size = htons(len & SVER_MASK);	/* Version=0 */
+	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);
+	s->v4.state = htons(cp->state);
+	s->v4.protocol = cp->protocol;
+	s->v4.cport = cp->cport;
+	s->v4.vport = cp->vport;
+	s->v4.dport = cp->dport;
+	s->v4.fwmark = htonl(cp->fwmark);
+	s->v4.timeout = htonl(cp->timeout);
 	m->nr_conns++;
-	m->size += len;
-	curr_sb->head += len;
 
-	/* check if there is a space for next one */
-	if (curr_sb->head+FULL_CONN_SIZE > curr_sb->end) {
-		sb_queue_tail(curr_sb);
-		curr_sb = NULL;
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6 ) {
+		p += sizeof(struct ip_vs_sync_v6);
+		ipv6_addr_copy(&s->v6.caddr, &cp->caddr.in6);
+		ipv6_addr_copy(&s->v6.vaddr, &cp->vaddr.in6);
+		ipv6_addr_copy(&s->v6.daddr, &cp->daddr.in6);
+		if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
+			memcpy(p, &cp->in_seq,
+			       sizeof(struct ip_vs_sync_conn_options));
+			p += sizeof(struct ip_vs_sync_conn_options);
+		}
+	} else
+#endif
+	{
+		p += sizeof(struct ip_vs_sync_v4);	/* options ptr */
+		s->v4.caddr = cp->caddr.ip;
+		s->v4.vaddr = cp->vaddr.ip;
+		s->v4.daddr = cp->daddr.ip;
+		if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
+			memcpy(p, &cp->in_seq,
+			       sizeof(struct ip_vs_sync_conn_options));
+			p += sizeof(struct ip_vs_sync_conn_options);
+		}
 	}
+	/* Handle pe data */
+	if (cp->pe_data_len && cp->pe_data) {
+		*(p++)=cp->pe_data_len;
+		*(p++)=pe_name_len;
+		memcpy(p, cp->pe_data,
+		       cp->pe_data_len);
+		p += cp->pe_data_len;
+		if (pe_name_len)
+			memcpy(p, cp->dest->svc->pe->name, pe_name_len);
+	}
+        m->size += len;
+        curr_sb->head += len;
+
 	spin_unlock(&curr_sb_lock);
 
 	/* synchronize its controller if it has */
 	if (cp->control)
 		ip_vs_sync_conn(cp->control);
 }
+
 /*
  * fill_param used for proto version 0
  */
@@ -428,6 +498,7 @@ ip_vs_conn_fill_param_sync_v0(int af, struct ip_vs_sync_conn_v0 *sc,
 			   sc->vport, 0, p);
 	return 0;
 }
+
 /*
  *  fill_param used by version 1
  */
@@ -1048,7 +1119,7 @@ ip_vs_send_async(struct socket *sock, const char *buffer, const size_t length)
 }
 
 static void
-ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
+ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg_v2 *msg)
 {
 	int msize;
 
-- 
1.6.0.2

