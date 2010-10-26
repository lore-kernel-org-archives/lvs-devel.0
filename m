From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 3/4] IPVS: Adding Version 1 receive capability
Date: Tue, 26 Oct 2010 13:00:22 +0200
Message-ID: <1288090823-31135-3-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Functionality improvements
 * flags  changed from 16 to 32 bits
 * fwmark added (32 bits)
 * timeout added (32 bits)
 * pe data added (Variable length)
 * IPv6 capabilities (3x16 bytes for addr.)
 * Version and type in every conn msg.

ip_vs_process_message() now handles Version 1 messages
and will call ip_vs_process_message_v0() for version 0 messages.

ip_vs_proc_conn() is common for both version, and handles the update of
connection hash.

ip_vs_conn_fill_param_sync()    - Version 1 messages only
ip_vs_conn_fill_param_sync_v0() - Version 0 messages only

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |  436 ++++++++++++++++++++++++++++-----------
 1 files changed, 318 insertions(+), 118 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index da8a6cd..2d2d5c9 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -414,54 +414,173 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 	if (cp->control)
 		ip_vs_sync_conn(cp->control);
 }
-
+/*
+ * fill_param used for proto version 0
+ */
 static inline int
-ip_vs_conn_fill_param_sync(int af, int protocol,
-			   const union nf_inet_addr *caddr, __be16 cport,
-			   const union nf_inet_addr *vaddr, __be16 vport,
+ip_vs_conn_fill_param_sync_v0(int af, struct ip_vs_sync_conn_v0 *sc,
 			   struct ip_vs_conn_param *p)
 {
-	/* XXX: Need to take into account persistence engine */
-	ip_vs_conn_fill_param(af, protocol, caddr, cport, vaddr, vport, 0, p);
+	ip_vs_conn_fill_param(af, sc->protocol,
+			   (const union nf_inet_addr *)&sc->caddr,
+			   sc->cport,
+			   (const union nf_inet_addr *)&sc->vaddr,
+			   sc->vport, 0, p);
+	return 0;
+}
+/*
+ *  fill_param used by version 1
+ */
+static inline int
+ip_vs_conn_fill_param_sync(int af, union ip_vs_sync_conn *sc,
+			   struct ip_vs_conn_param *p, char *pe_data,
+			   int pe_data_len, char *pe_name)
+{
+#ifdef CONFIG_IP_VS_IPV6
+	if ( af == AF_INET6 )
+		ip_vs_conn_fill_param(af, sc->v6.protocol,
+				   (const union nf_inet_addr *)&sc->v6.caddr,
+				   sc->v6.cport,
+				   (const union nf_inet_addr *)&sc->v6.vaddr,
+				   sc->v6.vport, ntohl(sc->v6.fwmark), p);
+	else
+#endif
+		ip_vs_conn_fill_param(af, sc->v4.protocol,
+				   (const union nf_inet_addr *)&sc->v4.caddr,
+				   sc->v4.cport,
+				   (const union nf_inet_addr *)&sc->v4.vaddr,
+				   sc->v4.vport, ntohl(sc->v4.fwmark), p);
+	if (sc->v4.fwmark)
+		IP_VS_DBG(10, "%s(), fwmark=%d\n", __func__, ntohl(sc->v4.fwmark));
+	/* Handle pe data */
+	if (pe_data_len && pe_data ) {
+		IP_VS_DBG(10, "%s() pe_data=%s\n", __func__, pe_data);
+		p->pe_data = kmalloc(pe_data_len, GFP_ATOMIC);
+		if (!p->pe_data)
+			return -ENOMEM;
+		memcpy(p->pe_data, pe_data, pe_data_len);
+
+		if (pe_name) {
+			p->pe = ip_vs_pe_get(pe_name);
+			IP_VS_DBG(10, "%s() pe_name=%s\n", __func__, pe_name);
+		}
+
+	}
 	return 0;
 }
 
 /*
- *      Process received multicast message and create the corresponding
- *      ip_vs_conn entries.
+ *  Connection Add / Update.
+ *  Common for version 0 and 1 reception of backup messages.
  */
-static void ip_vs_process_message(const char *buffer, const size_t buflen)
+static void ip_vs_proc_conn(struct ip_vs_conn_param *param,  unsigned flags,
+		            unsigned state, unsigned protocol, unsigned type,
+		            const union nf_inet_addr *daddr, __be16 dport,
+		            unsigned long	timeout,
+		            struct ip_vs_sync_conn_options *opt,
+		            struct ip_vs_protocol *pp )
+{
+	struct ip_vs_dest *dest;
+	struct ip_vs_conn *cp;
+
+
+	if (!(flags & IP_VS_CONN_F_TEMPLATE))
+		cp = ip_vs_conn_in_get(param);
+	else
+		cp = ip_vs_ct_in_get(param);
+	if (!cp) {
+		/*
+		 * Find the appropriate destination for the connection.
+		 * If it is not found the connection will remain unbound
+		 * but still handled.
+		 */
+		dest = ip_vs_find_dest(type, daddr, dport, param->vaddr,
+				       param->vport, protocol, param->fwmark);
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
+		cp = ip_vs_conn_new(param, daddr, dport, flags, dest);
+		if (dest)
+			atomic_dec(&dest->refcnt);
+		if (!cp) {
+			pr_err("ip_vs_conn_new failed\n");
+			return;
+		}
+	} else if (!cp->dest) {
+		dest = ip_vs_try_bind_dest(cp);
+		if (dest)
+			atomic_dec(&dest->refcnt);
+	} else if ((cp->dest) && (cp->protocol == IPPROTO_TCP) &&
+		   (cp->state != state)) {
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
+		   (cp->state != state)) {
+		dest = cp->dest;
+		if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
+		     (state != IP_VS_SCTP_S_ESTABLISHED)) {
+		    atomic_dec(&dest->activeconns);
+		    atomic_inc(&dest->inactconns);
+		    cp->flags &= ~IP_VS_CONN_F_INACTIVE;
+		}
+	}
+
+	if (opt)
+		memcpy(&cp->in_seq, opt, sizeof(*opt));
+	atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
+	cp->state = state;
+	cp->old_state = cp->state;
+	/*
+	 * For old messages style
+	 *  - Not possible to recover the right timeout for templates
+	 *  - can not find the right fwmark
+	 *    virtual service. If needed, we can do it for
+	 *    non-fwmark persistent services.
+	 * New messages style
+	 *  - No problem.
+	 */
+	if (timeout)
+		cp->timeout = timeout;
+	else if (!(flags & IP_VS_CONN_F_TEMPLATE) && pp->timeout_table)
+		cp->timeout = pp->timeout_table[state];
+	else
+		cp->timeout = (3*60*HZ);
+	ip_vs_conn_put(cp);
+}
+
+/*
+ *  Process received multicast message for Version 0
+ */
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
@@ -508,103 +627,184 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 			}
 		}
 
-		{
-			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
-					      (union nf_inet_addr *)&s->caddr,
-					      s->cport,
-					      (union nf_inet_addr *)&s->vaddr,
-					      s->vport, &param)) {
-				pr_err("ip_vs_conn_fill_param_sync failed");
-				return;
-			}
-			if (!(flags & IP_VS_CONN_F_TEMPLATE))
-				cp = ip_vs_conn_in_get(&param);
-			else
-				cp = ip_vs_ct_in_get(&param);
+		if (ip_vs_conn_fill_param_sync_v0(AF_INET, s, &param)) {
+			pr_err("ip_vs_conn_fill_param_sync failed");
+			return;
 		}
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
+		/* Send timeout as Zero */
+		ip_vs_proc_conn(&param, flags, state, s-> protocol, AF_INET,
+				(union nf_inet_addr *)&s->daddr, s->dport,
+				0, opt, pp );
+
+	}
+}
+
+/*
+ *      Process received multicast message and create the corresponding
+ *      ip_vs_conn entries.
+ *      Handles Version 0 & 1
+ */
+static void ip_vs_process_message(const char *buffer, const size_t buflen)
+{
+	struct ip_vs_sync_mesg_v2 *m2 = (struct ip_vs_sync_mesg_v2 *)buffer;
+	union  ip_vs_sync_conn *s;
+	struct ip_vs_sync_conn_options *opt;
+	struct ip_vs_protocol *pp;
+	struct ip_vs_conn_param param;
+	char *p;
+	int i, af, nr_conns;
+
+	if (buflen < sizeof(struct ip_vs_sync_mesg)) {
+		IP_VS_ERR_RL("sync message header too short\n");
+		return;
+	}
+
+	/* Convert size back to host byte order */
+	m2->size = ntohs(m2->size);
+
+	if (buflen != m2->size) {
+		IP_VS_ERR_RL("bogus sync message size\n");
+		return;
+	}
+
+	/* SyncID sanity check */
+	if (ip_vs_backup_syncid != 0 && m2->syncid != ip_vs_backup_syncid) {
+		IP_VS_DBG(7, "Ignoring incoming msg with syncid = %d\n",
+			  m2->syncid);
+		return;
+	}
+	/* Prepare ptrs for version 1 or 2 message */
+	if ( m2->version==SYNC_PROTO_VER && m2->reserverd==0 && m2->spare==0) {
+	       p = (char *)buffer + sizeof(struct ip_vs_sync_mesg_v2);
+	       nr_conns = m2->nr_conns;
+	       IP_VS_DBG(7, "%s Message v 1, %d bytes with %d conns\n",
+			 __func__, m2->size & SVER_MASK, m2->nr_conns);
+	} else {
+		/* Old type of message */
+		ip_vs_process_message_v0(buffer, buflen);
+		return;
+	}
+
+	for (i=0; i<nr_conns; i++) {
+		__u32 flags;
+		unsigned state, size;
+
+		s = (union ip_vs_sync_conn *) p;
+		size = ntohs(s->v4.ver_size) & SVER_MASK;
+
+		if (p + size  > buffer+buflen) {
+			IP_VS_ERR_RL("bogus conn/size in sync message\n");
+			return;
+		}
+		if (ntohs( s->v4.ver_size) >> SVER_SHIFT) {
+			IP_VS_ERR_RL("Unknown version %d in sync message\n",
+					ntohs( s->v4.ver_size) >> SVER_SHIFT);
+			return;
+		}
+
+		if (s->v6.type == STYPE_INET6 || s->v6.type == STYPE_PE_6 ) {
+			af = AF_INET6;
+			p += sizeof(struct ip_vs_sync_v6);
+		} else {
+			af = AF_INET;
+			p += sizeof(struct ip_vs_sync_v4);
+		}
+		flags = ntohl(s->v4.flags) | IP_VS_CONN_F_SYNC;
+		state = ntohs(s->v4.state);
+
+		if (p > buffer+buflen) {
+			IP_VS_ERR_RL("bogus conn in sync message\n");
+			return;
+		}
+		flags &= ~IP_VS_CONN_F_HASHED;
+		if (flags & IP_VS_CONN_F_SEQ_MASK) {
+			opt = (struct ip_vs_sync_conn_options *)p;
+			p += sizeof(struct ip_vs_sync_conn_options);
+			if (p > buffer+buflen) {
+				IP_VS_ERR_RL("bogus conn options in sync message\n");
+				return;
 			}
-			cp = ip_vs_conn_new(&param,
-					    (union nf_inet_addr *)&s->daddr,
-					    s->dport, flags, dest);
-			if (dest)
-				atomic_dec(&dest->refcnt);
-			if (!cp) {
-				pr_err("ip_vs_conn_new failed\n");
+		} else
+			opt = NULL;
+		/* p  should be pointing at optional pe_data_len */
+		if ( s->v4.type == STYPE_PE_4 || s->v4.type == STYPE_PE_6) {
+			IP_VS_DBG(10, "Sync() Persistence data rec. len %d/%d\n",
+				       *p, *(p+1));
+			/* Check pe_xx_len fields  */
+			if ( (( (char*)s + size  )
+			       < (p + *p + *(p+1)))
+			     || (*p > IP_VS_PEDATA_MAXLEN)
+			     || (*(p+1) > IP_VS_PENAME_MAXLEN+1) ) {
+				IP_VS_ERR_RL("bogus size vs pe_len in sync message\n");
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
+		}
+
+		if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
+			pp = ip_vs_proto_get(s->v4.protocol);
+			if (!pp) {
+				IP_VS_ERR_RL("Unsupported protocol %u in sync msg\n",
+					s->v4.protocol);
+				continue;
+			}
+			if (state >= pp->num_states) {
+				IP_VS_DBG(2, "Invalid %s state %u in sync msg\n",
+					pp->name, state);
+				continue;
 			}
-		} else if ((cp->dest) && (cp->protocol == IPPROTO_SCTP) &&
-			   (cp->state != state)) {
-			dest = cp->dest;
-			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
-			     (state != IP_VS_SCTP_S_ESTABLISHED)) {
-			    atomic_dec(&dest->activeconns);
-			    atomic_inc(&dest->inactconns);
-			    cp->flags &= ~IP_VS_CONN_F_INACTIVE;
+		} else {
+			/* protocol in templates is not used for state/timeout */
+			pp = NULL;
+			if (state > 0) {
+				IP_VS_DBG(2, "Invalid template state %u in sync msg\n",
+					state);
+				state = 0;
 			}
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
+		if (s->v4.type == STYPE_PE_4 || s->v6.type == STYPE_PE_6) {
+			char *pe_data, *pe_name;
+			unsigned pe_data_len;
+			unsigned pe_name_len;
+
+			pe_data_len = *(p++);
+			pe_name_len = *(p++);
+			pe_data = p;
+			pe_name = pe_name_len ? p+pe_data_len : 0;
+			IP_VS_DBG(10, "Sync() pe_data_len:%d, pe_name_len:%d\n",
+					pe_data_len, pe_name_len);
+			if (ip_vs_conn_fill_param_sync(af, s, &param, pe_data,
+						       pe_data_len, pe_name)) {
+				pr_err("ip_vs_conn_fill_param_sync failed");
+				return;
+			}
+		} else
+			if (ip_vs_conn_fill_param_sync(af, s, &param,
+					               NULL, 0, NULL)) {
+				pr_err("ip_vs_conn_fill_param_sync failed");
+				return;
+			}
+		/* If only IPv4, just silent skip IPv6 */
+		if ( af == AF_INET )
+			ip_vs_proc_conn(&param, flags, state, s->v4.protocol,
+					af,
+					(union nf_inet_addr *)&s->v4.daddr,
+				        s->v4.dport, ntohl(s->v4.timeout),
+				        opt, pp);
+#ifdef CONFIG_IP_VS_IPV6
 		else
-			cp->timeout = (3*60*HZ);
-		ip_vs_conn_put(cp);
-	}
+			ip_vs_proc_conn(&param, flags, state, s->v6.protocol,
+					af,
+					(union nf_inet_addr *)&s->v6.daddr,
+					s->v6.dport, ntohl(s->v6.timeout),
+					opt, pp);
+#else
+		else
+			IP_VS_DBG(2,"IPv6 sync message received, and IPVS is not compiled for IPv6\n");
+#endif
+		p = (char *)s + size;
+	} /* End of for(...) */
 }
 
