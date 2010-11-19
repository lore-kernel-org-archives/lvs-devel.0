From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v6 PATCH 6/8] IPVS: Backup, Adding Version 1 receive capability
Date: Fri, 19 Nov 2010 14:25:12 +0100
Message-ID: <1290173114-732-6-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

Functionality improvements
 * flags  changed from 16 to 32 bits
 * fwmark added (32 bits)
 * timeout in sec. added (32 bits)
 * pe data added (Variable length)
 * IPv6 capabilities (3x16 bytes for addr.)
 * Version and type in every conn msg.

ip_vs_process_message() now handles Version 1 messages
and will call ip_vs_process_message_v0() for version 0 messages.

ip_vs_proc_conn() is common for both version, and handles the update of
connection hash.

ip_vs_conn_fill_param_sync()    - Version 1 messages only
ip_vs_conn_fill_param_sync_v0() - Version 0 messages only

*v4
 get_unaligned_be32, used.
 in ip_vs_conn_fill_param_sync():
 - when pe_name_len is 0 and pe_data_len != 0 (return 1)
 - put p->pe when alloc fails.
 - __u8 used instead of char.
 formatting,
 some minor corrections according to Julians review.
 Change sync_conn length to exclude padding.

*v3
 formatting...
 timeout checked against MAX_SCHEDULE_TIMEOUT
 ip_vs_conn_fill_param_sync_v0 removed.
 Incl. Patch "IPVS: buffer argument to ip_vs_process_message() should not be const"
 msgEnd renamed to msg_end
 removal of fault SVER_MASK in m2->size & SVER_MASK
 kmalloc(pe_data_len, GFP_ATOMIC); leakage stopped
 Version 1 struct ip_vs_seq in network order.
 Rework of Debug/Error messages, BACKUP for Rx SYNC for Tx
 and Debug level <= 3 only errors and >= 7 misc debugging
 Process of V1 messages slitted.

*v2
 A new option format added as with opt, opt-len, data
 as a general way to add options to a conn entry.
 timeout is now in seconds
 fwmark is not in ip_vs_conn_param any more.
 Mask for flags received by backup.
 Basically all changes implements Julians comments.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/linux/ip_vs.h           |    8 +
 include/net/ip_vs.h             |    1 +
 net/netfilter/ipvs/ip_vs_pe.c   |    5 +-
 net/netfilter/ipvs/ip_vs_sync.c |  549 ++++++++++++++++++++++++++++++---------
 4 files changed, 440 insertions(+), 123 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 5f43a3b..4deb383 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -89,6 +89,14 @@
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
 
+#define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
+				  IP_VS_CONN_F_NOOUTPUT | \
+				  IP_VS_CONN_F_INACTIVE | \
+				  IP_VS_CONN_F_SEQ_MASK | \
+				  IP_VS_CONN_F_NO_CPORT | \
+				  IP_VS_CONN_F_TEMPLATE \
+				 )
+
 /* Flags that are not sent to backup server start from bit 16 */
 #define IP_VS_CONN_F_NFCT	(1 << 16)	/* use netfilter conntrack */
 
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 890f01c..4069484 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -817,6 +817,7 @@ void ip_vs_unbind_pe(struct ip_vs_service *svc);
 int register_ip_vs_pe(struct ip_vs_pe *pe);
 int unregister_ip_vs_pe(struct ip_vs_pe *pe);
 struct ip_vs_pe *ip_vs_pe_getbyname(const char *name);
+struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name);
 
 static inline void ip_vs_pe_get(const struct ip_vs_pe *pe)
 {
diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
index e99f920..5cf859c 100644
--- a/net/netfilter/ipvs/ip_vs_pe.c
+++ b/net/netfilter/ipvs/ip_vs_pe.c
@@ -29,12 +29,11 @@ void ip_vs_unbind_pe(struct ip_vs_service *svc)
 }
 
 /* Get pe in the pe list by name */
-static struct ip_vs_pe *
-__ip_vs_pe_getbyname(const char *pe_name)
+struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name)
 {
 	struct ip_vs_pe *pe;
 
-	IP_VS_DBG(2, "%s(): pe_name \"%s\"\n", __func__,
+	IP_VS_DBG(10, "%s(): pe_name \"%s\"\n", __func__,
 		  pe_name);
 
 	spin_lock_bh(&ip_vs_pe_lock);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 566482f..e071508 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -35,6 +35,8 @@
 #include <linux/wait.h>
 #include <linux/kernel.h>
 
+#include <asm/unaligned.h>		/* Used for ntoh_seq and hton_seq */
+
 #include <net/ip.h>
 #include <net/sock.h>
 
@@ -286,6 +288,16 @@ static struct sockaddr_in mcast_addr = {
 	.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
 };
 
+/*
+ * Copy of struct ip_vs_seq
+ * From unaligned network order to aligned host order
+ */
+static void ntoh_seq(struct ip_vs_seq *no, struct ip_vs_seq *ho)
+{
+	ho->init_seq       = get_unaligned_be32(&no->init_seq);
+	ho->delta          = get_unaligned_be32(&no->delta);
+	ho->previous_delta = get_unaligned_be32(&no->previous_delta);
+}
 
 static inline struct ip_vs_sync_buff *sb_dequeue(void)
 {
@@ -418,59 +430,186 @@ void ip_vs_sync_conn(const struct ip_vs_conn *cp)
 		ip_vs_sync_conn(cp->control);
 }
 
+/*
+ *  fill_param used by version 1
+ */
 static inline int
-ip_vs_conn_fill_param_sync(int af, int protocol,
-			   const union nf_inet_addr *caddr, __be16 cport,
-			   const union nf_inet_addr *vaddr, __be16 vport,
-			   struct ip_vs_conn_param *p)
+ip_vs_conn_fill_param_sync(int af, union ip_vs_sync_conn *sc,
+			   struct ip_vs_conn_param *p,
+			   __u8 *pe_data, unsigned int pe_data_len,
+			   __u8 *pe_name, unsigned int pe_name_len)
 {
-	/* XXX: Need to take into account persistence engine */
-	ip_vs_conn_fill_param(af, protocol, caddr, cport, vaddr, vport, p);
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		ip_vs_conn_fill_param(af, sc->v6.protocol,
+				      (const union nf_inet_addr *)&sc->v6.caddr,
+				      sc->v6.cport,
+				      (const union nf_inet_addr *)&sc->v6.vaddr,
+				      sc->v6.vport, p);
+	else
+#endif
+		ip_vs_conn_fill_param(af, sc->v4.protocol,
+				      (const union nf_inet_addr *)&sc->v4.caddr,
+				      sc->v4.cport,
+				      (const union nf_inet_addr *)&sc->v4.vaddr,
+				      sc->v4.vport, p);
+	/* Handle pe data */
+	if (pe_data_len) {
+		if (pe_name_len) {
+			char buff[IP_VS_PENAME_MAXLEN+1];
+
+			memcpy(buff, pe_name, pe_name_len);
+			buff[pe_name_len]=0;
+			p->pe = __ip_vs_pe_getbyname(buff);
+			if (!p->pe) {
+				IP_VS_DBG(3, "BACKUP, no %s engine found/loaded\n", buff);
+				return 1;
+			}
+		} else {
+			IP_VS_ERR_RL("BACKUP, Invalid PE parameters\n");
+			return 1;
+		}
+
+		p->pe_data = kmalloc(pe_data_len, GFP_ATOMIC);
+		if (!p->pe_data) {
+			if (p->pe->module)
+				module_put(p->pe->module);
+			return -ENOMEM;
+		}
+		memcpy(p->pe_data, pe_data, pe_data_len);
+		p->pe_data_len = pe_data_len;
+	}
 	return 0;
 }
 
 /*
- *      Process received multicast message and create the corresponding
- *      ip_vs_conn entries.
+ *  Connection Add / Update.
+ *  Common for version 0 and 1 reception of backup sync_conns.
+ *  Param: ...
+ *         timeout is in sec.
+ */
+static void ip_vs_proc_conn(struct ip_vs_conn_param *param,  unsigned flags,
+			    unsigned state, unsigned protocol, unsigned type,
+			    const union nf_inet_addr *daddr, __be16 dport,
+			    unsigned long timeout, __u32 fwmark,
+			    struct ip_vs_sync_conn_options *opt,
+			    struct ip_vs_protocol *pp)
+{
+	struct ip_vs_dest *dest;
+	struct ip_vs_conn *cp;
+
+
+	if (!(flags & IP_VS_CONN_F_TEMPLATE))
+		cp = ip_vs_conn_in_get(param);
+	else
+		cp = ip_vs_ct_in_get(param);
+
+	if (cp && param->pe_data) 	/* Free pe_data */
+		kfree(param->pe_data);
+	if (!cp) {
+		/*
+		 * Find the appropriate destination for the connection.
+		 * If it is not found the connection will remain unbound
+		 * but still handled.
+		 */
+		dest = ip_vs_find_dest(type, daddr, dport, param->vaddr,
+				       param->vport, protocol, fwmark);
+
+		/*  Set the approprite ativity flag */
+		if (protocol == IPPROTO_TCP) {
+			if (state != IP_VS_TCP_S_ESTABLISHED)
+				flags |= IP_VS_CONN_F_INACTIVE;
+			else
+				flags &= ~IP_VS_CONN_F_INACTIVE;
+		} else if (protocol == IPPROTO_SCTP) {
+			if (state != IP_VS_SCTP_S_ESTABLISHED)
+				flags |= IP_VS_CONN_F_INACTIVE;
+			else
+				flags &= ~IP_VS_CONN_F_INACTIVE;
+		}
+		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
+		if (dest)
+			atomic_dec(&dest->refcnt);
+		if (!cp) {
+			if (param->pe_data)
+				kfree(param->pe_data);
+			IP_VS_DBG(2, "BACKUP, add new conn. failed\n");
+			return;
+		}
+	} else if (!cp->dest) {
+		dest = ip_vs_try_bind_dest(cp);
+		if (dest)
+			atomic_dec(&dest->refcnt);
+	} else if ((cp->dest) && (cp->protocol == IPPROTO_TCP) &&
+		(cp->state != state)) {
+		/* update active/inactive flag for the connection */
+		dest = cp->dest;
+		if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
+			(state != IP_VS_TCP_S_ESTABLISHED)) {
+			atomic_dec(&dest->activeconns);
+			atomic_inc(&dest->inactconns);
+			cp->flags |= IP_VS_CONN_F_INACTIVE;
+		} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
+			(state == IP_VS_TCP_S_ESTABLISHED)) {
+			atomic_inc(&dest->activeconns);
+			atomic_dec(&dest->inactconns);
+			cp->flags &= ~IP_VS_CONN_F_INACTIVE;
+		}
+	} else if ((cp->dest) && (cp->protocol == IPPROTO_SCTP) &&
+		(cp->state != state)) {
+		dest = cp->dest;
+		if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
+		(state != IP_VS_SCTP_S_ESTABLISHED)) {
+			atomic_dec(&dest->activeconns);
+			atomic_inc(&dest->inactconns);
+			cp->flags &= ~IP_VS_CONN_F_INACTIVE;
+		}
+	}
+
+	if (opt)
+		memcpy(&cp->in_seq, opt, sizeof(*opt));
+	atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
+	cp->state = state;
+	cp->old_state = cp->state;
+	/*
+	 * For Ver 0 messages style
+	 *  - Not possible to recover the right timeout for templates
+	 *  - can not find the right fwmark
+	 *    virtual service. If needed, we can do it for
+	 *    non-fwmark persistent services.
+	 * Ver 1 messages style.
+	 *  - No problem.
+	 */
+	if (timeout) {
+		if (timeout > MAX_SCHEDULE_TIMEOUT / HZ)
+			timeout = MAX_SCHEDULE_TIMEOUT / HZ;
+		cp->timeout = timeout*HZ;
+	} else if (!(flags & IP_VS_CONN_F_TEMPLATE) && pp->timeout_table)
+		cp->timeout = pp->timeout_table[state];
+	else
+		cp->timeout = (3*60*HZ);
+	ip_vs_conn_put(cp);
+}
+
+/*
+ *  Process received multicast message for Version 0
  */
-static void ip_vs_process_message(char *buffer, const size_t buflen)
+static void ip_vs_process_message_v0(const char *buffer, const size_t buflen)
 {
 	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
 	struct ip_vs_sync_conn_v0 *s;
 	struct ip_vs_sync_conn_options *opt;
-	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
-	struct ip_vs_dest *dest;
 	struct ip_vs_conn_param param;
 	char *p;
 	int i;
 
-	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
-		IP_VS_ERR_RL("sync message header too short\n");
-		return;
-	}
-
-	/* Convert size back to host byte order */
-	m->size = ntohs(m->size);
-
-	if (buflen != m->size) {
-		IP_VS_ERR_RL("bogus sync message size\n");
-		return;
-	}
-
-	/* SyncID sanity check */
-	if (ip_vs_backup_syncid != 0 && m->syncid != ip_vs_backup_syncid) {
-		IP_VS_DBG(7, "Ignoring incoming msg with syncid = %d\n",
-			  m->syncid);
-		return;
-	}
-
 	p = (char *)buffer + sizeof(struct ip_vs_sync_mesg);
 	for (i=0; i<m->nr_conns; i++) {
 		unsigned flags, state;
 
 		if (p + SIMPLE_CONN_SIZE > buffer+buflen) {
-			IP_VS_ERR_RL("bogus conn in sync message\n");
+			IP_VS_ERR_RL("BACKUP v0, bogus conn\n");
 			return;
 		}
 		s = (struct ip_vs_sync_conn_v0 *) p;
@@ -480,7 +619,7 @@ static void ip_vs_process_message(char *buffer, const size_t buflen)
 			opt = (struct ip_vs_sync_conn_options *)&s[1];
 			p += FULL_CONN_SIZE;
 			if (p > buffer+buflen) {
-				IP_VS_ERR_RL("bogus conn options in sync message\n");
+				IP_VS_ERR_RL("BACKUP v0, Dropping buffer bogus conn options\n");
 				return;
 			}
 		} else {
@@ -492,12 +631,12 @@ static void ip_vs_process_message(char *buffer, const size_t buflen)
 		if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
 			pp = ip_vs_proto_get(s->protocol);
 			if (!pp) {
-				IP_VS_ERR_RL("Unsupported protocol %u in sync msg\n",
+				IP_VS_DBG(2, "BACKUP v0, Unsupported protocol %u\n",
 					s->protocol);
 				continue;
 			}
 			if (state >= pp->num_states) {
-				IP_VS_DBG(2, "Invalid %s state %u in sync msg\n",
+				IP_VS_DBG(2, "BACKUP v0, Invalid %s state %u\n",
 					pp->name, state);
 				continue;
 			}
@@ -505,103 +644,273 @@ static void ip_vs_process_message(char *buffer, const size_t buflen)
 			/* protocol in templates is not used for state/timeout */
 			pp = NULL;
 			if (state > 0) {
-				IP_VS_DBG(2, "Invalid template state %u in sync msg\n",
+				IP_VS_DBG(2, "BACKUP v0, Invalid template state %u\n",
 					state);
 				state = 0;
 			}
 		}
 
-		if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
-					       (union nf_inet_addr *)&s->caddr,
-					       s->cport,
-					       (union nf_inet_addr *)&s->vaddr,
-					       s->vport, &param)) {
-			pr_err("ip_vs_conn_fill_param_sync failed");
-			return;
+		ip_vs_conn_fill_param(AF_INET, s->protocol,
+				      (const union nf_inet_addr *)&s->caddr,
+				      s->cport,
+				      (const union nf_inet_addr *)&s->vaddr,
+				      s->vport, &param);
+
+		/* Send timeout as Zero */
+		ip_vs_proc_conn(&param, flags, state, s->protocol, AF_INET,
+				(union nf_inet_addr *)&s->daddr, s->dport,
+				0, 0, opt, pp);
+	}
+}
+
+/*
+ * Handle options
+ */
+static inline int ip_vs_proc_seqopt(__u8 *p, unsigned int plen,
+				    __u32 *opt_flags,
+				    struct ip_vs_sync_conn_options *opt)
+{
+	struct ip_vs_sync_conn_options *topt;
+
+	topt = (struct ip_vs_sync_conn_options *)p;
+
+	if (plen != sizeof(struct ip_vs_sync_conn_options)) {
+		IP_VS_DBG(2, "BACKUP, bogus conn options length\n");
+		return -EINVAL;
+	}
+	if (*opt_flags & IPVS_OPT_F_SEQ_DATA) {
+		IP_VS_DBG(2, "BACKUP, conn options found twice\n");
+		return -EINVAL;
+	}
+	ntoh_seq(&topt->in_seq, &opt->in_seq);
+	ntoh_seq(&topt->out_seq, &opt->out_seq);
+	*opt_flags |= IPVS_OPT_F_SEQ_DATA;
+	return 0;
+}
+
+static int ip_vs_proc_str(__u8 *p, unsigned int plen, unsigned int *data_len,
+			  __u8 **data, unsigned int maxlen,
+			  __u32 *opt_flags, __u32 flag)
+{
+	if (plen > maxlen) {
+		IP_VS_DBG(2, "BACKUP, bogus par.data len > %d\n", maxlen);
+		return -EINVAL;
+	}
+	if (*opt_flags & flag) {
+		IP_VS_DBG(2, "BACKUP, Par.data found twice 0x%x\n", flag);
+		return -EINVAL;
+	}
+	*data_len = plen;
+	*data = p;
+	*opt_flags |= flag;
+	return 0;
+}
+/*
+ *   Process a Version 1 sync. connection
+ */
+static inline int ip_vs_proc_sync_conn(__u8 *p, __u8 *msg_end)
+{
+	struct ip_vs_sync_conn_options opt;
+	union  ip_vs_sync_conn *s;
+	struct ip_vs_protocol *pp;
+	struct ip_vs_conn_param param;
+	__u32 flags;
+	unsigned int af, state, pe_data_len=0, pe_name_len=0;
+	__u8 *pe_data=NULL, *pe_name=NULL;
+	__u32 opt_flags=0;
+	int retc=0;
+
+	s = (union ip_vs_sync_conn *) p;
+
+	if (s->v6.type & STYPE_F_INET6) {
+#ifdef CONFIG_IP_VS_IPV6
+		af = AF_INET6;
+		p += sizeof(struct ip_vs_sync_v6);
+#else
+		IP_VS_DBG(3,"BACKUP, IPv6 msg received, and IPVS is not compiled for IPv6\n");
+		retc = 10;
+		goto out;
+#endif
+	} else if (!s->v4.type) {
+		af = AF_INET;
+		p += sizeof(struct ip_vs_sync_v4);
+	} else {
+		return -10;
+	}
+	if (p > msg_end)
+		return -20;
+
+	/* Process optional params check Type & Len. */
+	while (p < msg_end) {
+		int ptype;
+		int plen;
+
+		if (p+2 > msg_end)
+			return -30;
+		ptype = *(p++);
+		plen  = *(p++);
+
+		if (!plen || ((p + plen) > msg_end))
+			return -40;
+		/* Handle seq option  p = param data */
+		switch (ptype & ~IPVS_OPT_F_PARAM) {
+		case IPVS_OPT_SEQ_DATA:
+			if (ip_vs_proc_seqopt(p, plen, &opt_flags, &opt))
+				return -50;
+			break;
+
+		case IPVS_OPT_PE_DATA:
+			if (ip_vs_proc_str(p, plen, &pe_data_len, &pe_data,
+					   IP_VS_PEDATA_MAXLEN, &opt_flags,
+					   IPVS_OPT_F_PE_DATA))
+				return -60;
+			break;
+
+		case IPVS_OPT_PE_NAME:
+			if (ip_vs_proc_str(p, plen,&pe_name_len, &pe_name,
+					   IP_VS_PENAME_MAXLEN, &opt_flags,
+					   IPVS_OPT_F_PE_NAME))
+				return -70;
+			break;
+
+		default:
+			/* Param data mandatory ? */
+			if (!(ptype & IPVS_OPT_F_PARAM)) {
+				IP_VS_DBG(3, "BACKUP, Unknown mandatory param %d found\n",
+					  ptype & ~IPVS_OPT_F_PARAM);
+				retc = 20;
+				goto out;
+			}
 		}
-		if (!(flags & IP_VS_CONN_F_TEMPLATE))
-			cp = ip_vs_conn_in_get(&param);
-		else
-			cp = ip_vs_ct_in_get(&param);
-		if (!cp) {
-			/*
-			 * Find the appropriate destination for the connection.
-			 * If it is not found the connection will remain unbound
-			 * but still handled.
-			 */
-			dest = ip_vs_find_dest(AF_INET,
-					       (union nf_inet_addr *)&s->daddr,
-					       s->dport,
-					       (union nf_inet_addr *)&s->vaddr,
-					       s->vport,
-					       s->protocol, 0);
-			/*  Set the approprite ativity flag */
-			if (s->protocol == IPPROTO_TCP) {
-				if (state != IP_VS_TCP_S_ESTABLISHED)
-					flags |= IP_VS_CONN_F_INACTIVE;
-				else
-					flags &= ~IP_VS_CONN_F_INACTIVE;
-			} else if (s->protocol == IPPROTO_SCTP) {
-				if (state != IP_VS_SCTP_S_ESTABLISHED)
-					flags |= IP_VS_CONN_F_INACTIVE;
-				else
-					flags &= ~IP_VS_CONN_F_INACTIVE;
+		p += plen;  /* Next option */
+	}
+
+	/* Get flags and Mask off unsupported */
+	flags  = ntohl(s->v4.flags) & IP_VS_CONN_F_BACKUP_MASK;
+	flags |= IP_VS_CONN_F_SYNC;
+	state = ntohs(s->v4.state);
+
+	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
+		pp = ip_vs_proto_get(s->v4.protocol);
+		if (!pp) {
+			IP_VS_DBG(3,"BACKUP, Unsupported protocol %u\n",
+				s->v4.protocol);
+			retc = 30;
+			goto out;
+		}
+		if (state >= pp->num_states) {
+			IP_VS_DBG(3, "BACKUP, Invalid %s state %u\n",
+				pp->name, state);
+			retc = 40;
+			goto out;
+		}
+	} else {
+		/* protocol in templates is not used for state/timeout */
+		pp = NULL;
+		if (state > 0) {
+			IP_VS_DBG(3, "BACKUP, Invalid template state %u\n",
+				state);
+			state = 0;
+		}
+	}
+	if (ip_vs_conn_fill_param_sync(af, s, &param,
+					pe_data, pe_data_len,
+					pe_name, pe_name_len)) {
+		retc = 50;
+		goto out;
+	}
+	/* If only IPv4, just silent skip IPv6 */
+	if (af == AF_INET)
+		ip_vs_proc_conn(&param, flags, state, s->v4.protocol, af,
+				(union nf_inet_addr *)&s->v4.daddr, s->v4.dport,
+				ntohl(s->v4.timeout), ntohl(s->v4.fwmark),
+				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL),
+				pp);
+#ifdef CONFIG_IP_VS_IPV6
+	else
+		ip_vs_proc_conn(&param, flags, state, s->v6.protocol, af,
+				(union nf_inet_addr *)&s->v6.daddr, s->v6.dport,
+				ntohl(s->v6.timeout), ntohl(s->v6.fwmark),
+				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL),
+				pp);
+#endif
+	return 0;
+	/* Error exit */
+out:
+	IP_VS_DBG(2, "BACKUP, Single msg dropped err:%d\n", retc);
+	return retc;
+
+}
+/*
+ *      Process received multicast message and create the corresponding
+ *      ip_vs_conn entries.
+ *      Handles Version 0 & 1
+ */
+static void ip_vs_process_message(__u8 *buffer, const size_t buflen)
+{
+	struct ip_vs_sync_mesg_v2 *m2 = (struct ip_vs_sync_mesg_v2 *)buffer;
+	__u8 *p, *msg_end;
+	unsigned int i, nr_conns;
+
+	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
+		IP_VS_DBG(2, "BACKUP, message header too short\n");
+		return;
+	}
+	/* Convert size back to host byte order */
+	m2->size = ntohs(m2->size);
+
+	if (buflen != m2->size) {
+		IP_VS_DBG(2, "BACKUP, bogus message size\n");
+		return;
+	}
+	/* SyncID sanity check */
+	if (ip_vs_backup_syncid != 0 && m2->syncid != ip_vs_backup_syncid) {
+		IP_VS_DBG(7, "BACKUP, Ignoring syncid = %d\n", m2->syncid);
+		return;
+	}
+	/* Handle version 1  message */
+	if ((m2->version == SYNC_PROTO_VER) && (m2->reserved == 0)
+	    && (m2->spare == 0)) {
+
+		msg_end = buffer + sizeof(struct ip_vs_sync_mesg_v2);
+		nr_conns = m2->nr_conns;
+
+		for (i=0; i<nr_conns; i++) {
+			union ip_vs_sync_conn *s;
+			unsigned size;
+			int retc;
+
+			p = msg_end;
+			if (p + sizeof(s->v4) > buffer+buflen) {
+				IP_VS_ERR_RL("BACKUP, Dropping buffer, to small\n");
+				return;
 			}
-			cp = ip_vs_conn_new(&param,
-					    (union nf_inet_addr *)&s->daddr,
-					    s->dport, flags, dest, 0);
-			if (dest)
-				atomic_dec(&dest->refcnt);
-			if (!cp) {
-				pr_err("ip_vs_conn_new failed\n");
+			s = (union ip_vs_sync_conn *)p;
+			size = ntohs(s->v4.ver_size) & SVER_MASK;
+			msg_end = p + size;
+			/* Basic sanity checks */
+			if (msg_end  > buffer+buflen) {
+				IP_VS_ERR_RL("BACKUP, Dropping buffer, msg > buffer\n");
 				return;
 			}
-		} else if (!cp->dest) {
-			dest = ip_vs_try_bind_dest(cp);
-			if (dest)
-				atomic_dec(&dest->refcnt);
-		} else if ((cp->dest) && (cp->protocol == IPPROTO_TCP) &&
-			   (cp->state != state)) {
-			/* update active/inactive flag for the connection */
-			dest = cp->dest;
-			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
-				(state != IP_VS_TCP_S_ESTABLISHED)) {
-				atomic_dec(&dest->activeconns);
-				atomic_inc(&dest->inactconns);
-				cp->flags |= IP_VS_CONN_F_INACTIVE;
-			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
-				(state == IP_VS_TCP_S_ESTABLISHED)) {
-				atomic_inc(&dest->activeconns);
-				atomic_dec(&dest->inactconns);
-				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
+			if (ntohs(s->v4.ver_size) >> SVER_SHIFT) {
+				IP_VS_ERR_RL("BACKUP, Dropping buffer, Unknown version %d\n",
+					      ntohs(s->v4.ver_size) >> SVER_SHIFT);
+				return;
 			}
-		} else if ((cp->dest) && (cp->protocol == IPPROTO_SCTP) &&
-			   (cp->state != state)) {
-			dest = cp->dest;
-			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
-			     (state != IP_VS_SCTP_S_ESTABLISHED)) {
-			    atomic_dec(&dest->activeconns);
-			    atomic_inc(&dest->inactconns);
-			    cp->flags &= ~IP_VS_CONN_F_INACTIVE;
+			/* Process a single sync_conn */
+			if ((retc=ip_vs_proc_sync_conn(p, msg_end)) < 0) {
+				IP_VS_ERR_RL("BACKUP, Dropping buffer, Err: %d in decoding\n",
+					     retc);
+				return;
 			}
+			/* Make sure we have 32 bit alignment */
+			msg_end = p + ((size + 3) & ~3);
 		}
-
-		if (opt)
-			memcpy(&cp->in_seq, opt, sizeof(*opt));
-		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
-		cp->state = state;
-		cp->old_state = cp->state;
-		/*
-		 * We can not recover the right timeout for templates
-		 * in all cases, we can not find the right fwmark
-		 * virtual service. If needed, we can do it for
-		 * non-fwmark persistent services.
-		 */
-		if (!(flags & IP_VS_CONN_F_TEMPLATE) && pp->timeout_table)
-			cp->timeout = pp->timeout_table[state];
-		else
-			cp->timeout = (3*60*HZ);
-		ip_vs_conn_put(cp);
+	} else {
+		/* Old type of message */
+		ip_vs_process_message_v0(buffer, buflen);
+		return;
 	}
 }
 
-- 
1.7.2.3

