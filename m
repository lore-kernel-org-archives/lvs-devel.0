From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 34/34] ipvs: do not disable bh for long time
Date: Fri, 29 Mar 2013 13:11:51 +0900
Message-ID: <1364530311-11512-35-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

We used a global BH disable in LOCAL_OUT hook.
Add _bh suffix to all places that need it and remove
the disabling from LOCAL_OUT and sync code.

Functions like ip_defrag need protection from
BH, so add it. As for nf_nat_mangle_tcp_packet, it needs
RCU lock.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_app.c        |    4 ++--
 net/netfilter/ipvs/ip_vs_conn.c       |   30 +++++++++++++-------------
 net/netfilter/ipvs/ip_vs_core.c       |   37 +++++++--------------------------
 net/netfilter/ipvs/ip_vs_ftp.c        |    2 ++
 net/netfilter/ipvs/ip_vs_lblc.c       |    4 ++--
 net/netfilter/ipvs/ip_vs_lblcr.c      |   12 +++++------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    4 ++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |    8 +++----
 net/netfilter/ipvs/ip_vs_rr.c         |    6 +++---
 net/netfilter/ipvs/ip_vs_sync.c       |   24 +++++++++------------
 net/netfilter/ipvs/ip_vs_wrr.c        |    4 ++--
 net/netfilter/ipvs/ip_vs_xmit.c       |   16 +++++++-------
 12 files changed, 64 insertions(+), 87 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index a956030..dfd7b65 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -352,14 +352,14 @@ static inline void vs_seq_update(struct ip_vs_conn *cp, struct ip_vs_seq *vseq,
 				 unsigned int flag, __u32 seq, int diff)
 {
 	/* spinlock is to keep updating cp->flags atomic */
-	spin_lock(&cp->lock);
+	spin_lock_bh(&cp->lock);
 	if (!(cp->flags & flag) || after(seq, vseq->init_seq)) {
 		vseq->previous_delta = vseq->delta;
 		vseq->delta += diff;
 		vseq->init_seq = seq;
 		cp->flags |= flag;
 	}
-	spin_unlock(&cp->lock);
+	spin_unlock_bh(&cp->lock);
 }
 
 static inline int app_tcp_pkt_out(struct ip_vs_conn *cp, struct sk_buff *skb,
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 54de340..de64758 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -86,14 +86,14 @@ struct ip_vs_aligned_lock
 static struct ip_vs_aligned_lock
 __ip_vs_conntbl_lock_array[CT_LOCKARRAY_SIZE] __cacheline_aligned;
 
-static inline void ct_write_lock(unsigned int key)
+static inline void ct_write_lock_bh(unsigned int key)
 {
-	spin_lock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
+	spin_lock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
-static inline void ct_write_unlock(unsigned int key)
+static inline void ct_write_unlock_bh(unsigned int key)
 {
-	spin_unlock(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
+	spin_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
 
@@ -167,7 +167,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	/* Hash by protocol, client address and port */
 	hash = ip_vs_conn_hashkey_conn(cp);
 
-	ct_write_lock(hash);
+	ct_write_lock_bh(hash);
 	spin_lock(&cp->lock);
 
 	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
@@ -182,7 +182,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	}
 
 	spin_unlock(&cp->lock);
-	ct_write_unlock(hash);
+	ct_write_unlock_bh(hash);
 
 	return ret;
 }
@@ -200,7 +200,7 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 	/* unhash it and decrease its reference counter */
 	hash = ip_vs_conn_hashkey_conn(cp);
 
-	ct_write_lock(hash);
+	ct_write_lock_bh(hash);
 	spin_lock(&cp->lock);
 
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
@@ -212,7 +212,7 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 		ret = 0;
 
 	spin_unlock(&cp->lock);
-	ct_write_unlock(hash);
+	ct_write_unlock_bh(hash);
 
 	return ret;
 }
@@ -227,7 +227,7 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 
 	hash = ip_vs_conn_hashkey_conn(cp);
 
-	ct_write_lock(hash);
+	ct_write_lock_bh(hash);
 	spin_lock(&cp->lock);
 
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
@@ -242,7 +242,7 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 		ret = atomic_read(&cp->refcnt) ? false : true;
 
 	spin_unlock(&cp->lock);
-	ct_write_unlock(hash);
+	ct_write_unlock_bh(hash);
 
 	return ret;
 }
@@ -462,13 +462,13 @@ void ip_vs_conn_put(struct ip_vs_conn *cp)
 void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport)
 {
 	if (ip_vs_conn_unhash(cp)) {
-		spin_lock(&cp->lock);
+		spin_lock_bh(&cp->lock);
 		if (cp->flags & IP_VS_CONN_F_NO_CPORT) {
 			atomic_dec(&ip_vs_conn_no_cport_cnt);
 			cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
 			cp->cport = cport;
 		}
-		spin_unlock(&cp->lock);
+		spin_unlock_bh(&cp->lock);
 
 		/* hash on new dport */
 		ip_vs_conn_hash(cp);
@@ -622,9 +622,9 @@ void ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	if (dest) {
 		struct ip_vs_proto_data *pd;
 
-		spin_lock(&cp->lock);
+		spin_lock_bh(&cp->lock);
 		if (cp->dest) {
-			spin_unlock(&cp->lock);
+			spin_unlock_bh(&cp->lock);
 			rcu_read_unlock();
 			return;
 		}
@@ -635,7 +635,7 @@ void ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 			ip_vs_unbind_app(cp);
 
 		ip_vs_bind_dest(cp, dest);
-		spin_unlock(&cp->lock);
+		spin_unlock_bh(&cp->lock);
 
 		/* Update its packet transmitter */
 		cp->packet_xmit = NULL;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 79df3c6..f26fe33 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -638,8 +638,11 @@ static inline enum ip_defrag_users ip_vs_defrag_user(unsigned int hooknum)
 
 static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 {
-	int err = ip_defrag(skb, user);
+	int err;
 
+	local_bh_disable();
+	err = ip_defrag(skb, user);
+	local_bh_enable();
 	if (!err)
 		ip_send_check(ip_hdr(skb));
 
@@ -1217,13 +1220,7 @@ ip_vs_local_reply4(unsigned int hooknum, struct sk_buff *skb,
 		   const struct net_device *in, const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
 {
-	unsigned int verdict;
-
-	/* Disable BH in LOCAL_OUT until all places are fixed */
-	local_bh_disable();
-	verdict = ip_vs_out(hooknum, skb, AF_INET);
-	local_bh_enable();
-	return verdict;
+	return ip_vs_out(hooknum, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1250,13 +1247,7 @@ ip_vs_local_reply6(unsigned int hooknum, struct sk_buff *skb,
 		   const struct net_device *in, const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
 {
-	unsigned int verdict;
-
-	/* Disable BH in LOCAL_OUT until all places are fixed */
-	local_bh_disable();
-	verdict = ip_vs_out(hooknum, skb, AF_INET6);
-	local_bh_enable();
-	return verdict;
+	return ip_vs_out(hooknum, skb, AF_INET6);
 }
 
 #endif
@@ -1714,13 +1705,7 @@ ip_vs_local_request4(unsigned int hooknum, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
 		     int (*okfn)(struct sk_buff *))
 {
-	unsigned int verdict;
-
-	/* Disable BH in LOCAL_OUT until all places are fixed */
-	local_bh_disable();
-	verdict = ip_vs_in(hooknum, skb, AF_INET);
-	local_bh_enable();
-	return verdict;
+	return ip_vs_in(hooknum, skb, AF_INET);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -1779,13 +1764,7 @@ ip_vs_local_request6(unsigned int hooknum, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
 		     int (*okfn)(struct sk_buff *))
 {
-	unsigned int verdict;
-
-	/* Disable BH in LOCAL_OUT until all places are fixed */
-	local_bh_disable();
-	verdict = ip_vs_in(hooknum, skb, AF_INET6);
-	local_bh_enable();
-	return verdict;
+	return ip_vs_in(hooknum, skb, AF_INET6);
 }
 
 #endif
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 7f90825..77c1732 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -267,10 +267,12 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 			 * hopefully it will succeed on the retransmitted
 			 * packet.
 			 */
+			rcu_read_lock();
 			ret = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
 						       iph->ihl * 4,
 						       start-data, end-start,
 						       buf, buf_len);
+			rcu_read_unlock();
 			if (ret) {
 				ip_vs_nfct_expect_related(skb, ct, n_cp,
 							  IPPROTO_TCP, 0, 0);
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index d8e5238..b2cc252 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -527,10 +527,10 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
-	spin_lock(&svc->sched_lock);
+	spin_lock_bh(&svc->sched_lock);
 	if (!tbl->dead)
 		ip_vs_lblc_new(tbl, &iph.daddr, dest);
-	spin_unlock(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLC: destination IP address %s --> server %s:%d\n",
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 041b7cc..feb9656 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -678,7 +678,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		if (atomic_read(&en->set.size) > 1 &&
 		    time_after(jiffies, en->set.lastmod +
 				sysctl_lblcr_expiration(svc))) {
-			spin_lock(&svc->sched_lock);
+			spin_lock_bh(&svc->sched_lock);
 			if (atomic_read(&en->set.size) > 1) {
 				struct ip_vs_dest *m;
 
@@ -686,7 +686,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 				if (m)
 					ip_vs_dest_set_erase(&en->set, m);
 			}
-			spin_unlock(&svc->sched_lock);
+			spin_unlock_bh(&svc->sched_lock);
 		}
 
 		/* If the destination is not overloaded, use it */
@@ -701,10 +701,10 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		}
 
 		/* Update our cache entry */
-		spin_lock(&svc->sched_lock);
+		spin_lock_bh(&svc->sched_lock);
 		if (!tbl->dead)
 			ip_vs_dest_set_insert(&en->set, dest, true);
-		spin_unlock(&svc->sched_lock);
+		spin_unlock_bh(&svc->sched_lock);
 		goto out;
 	}
 
@@ -716,10 +716,10 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	}
 
 	/* If we fail to create a cache entry, we'll just use the valid dest */
-	spin_lock(&svc->sched_lock);
+	spin_lock_bh(&svc->sched_lock);
 	if (!tbl->dead)
 		ip_vs_lblcr_new(tbl, &iph.daddr, dest);
-	spin_unlock(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 4de5176..6e14a7b 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -994,9 +994,9 @@ static void
 sctp_state_transition(struct ip_vs_conn *cp, int direction,
 		const struct sk_buff *skb, struct ip_vs_proto_data *pd)
 {
-	spin_lock(&cp->lock);
+	spin_lock_bh(&cp->lock);
 	set_sctp_state(pd, cp, direction, skb);
-	spin_unlock(&cp->lock);
+	spin_unlock_bh(&cp->lock);
 }
 
 static inline __u16 sctp_app_hashkey(__be16 port)
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 7de3342..50a1594 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -557,9 +557,9 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 	if (th == NULL)
 		return;
 
-	spin_lock(&cp->lock);
+	spin_lock_bh(&cp->lock);
 	set_tcp_state(pd, cp, direction, th);
-	spin_unlock(&cp->lock);
+	spin_unlock_bh(&cp->lock);
 }
 
 static inline __u16 tcp_app_hashkey(__be16 port)
@@ -655,11 +655,11 @@ void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp)
 {
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
 
-	spin_lock(&cp->lock);
+	spin_lock_bh(&cp->lock);
 	cp->state = IP_VS_TCP_S_LISTEN;
 	cp->timeout = (pd ? pd->timeout_table[IP_VS_TCP_S_LISTEN]
 			   : tcp_timeouts[IP_VS_TCP_S_LISTEN]);
-	spin_unlock(&cp->lock);
+	spin_unlock_bh(&cp->lock);
 }
 
 /* ---------------------------------------------
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 749c98a..c35986c 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -63,7 +63,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
-	spin_lock(&svc->sched_lock);
+	spin_lock_bh(&svc->sched_lock);
 	p = (struct list_head *) svc->sched_data;
 	last = dest = list_entry(p, struct ip_vs_dest, n_list);
 
@@ -85,13 +85,13 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	} while (pass < 2 && p != &svc->destinations);
 
 stop:
-	spin_unlock(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 	ip_vs_scheduler_err(svc, "no destination available");
 	return NULL;
 
   out:
 	svc->sched_data = &dest->n_list;
-	spin_unlock(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 	IP_VS_DBG_BUF(6, "RR: server %s:%u "
 		      "activeconns %d refcnt %d weight %d\n",
 		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port),
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 9724174..8e57077 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -531,9 +531,9 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
 		return;
 
-	spin_lock(&ipvs->sync_buff_lock);
+	spin_lock_bh(&ipvs->sync_buff_lock);
 	if (!(ipvs->sync_state & IP_VS_STATE_MASTER)) {
-		spin_unlock(&ipvs->sync_buff_lock);
+		spin_unlock_bh(&ipvs->sync_buff_lock);
 		return;
 	}
 
@@ -552,7 +552,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 	if (!buff) {
 		buff = ip_vs_sync_buff_create_v0(ipvs);
 		if (!buff) {
-			spin_unlock(&ipvs->sync_buff_lock);
+			spin_unlock_bh(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
 			return;
 		}
@@ -590,7 +590,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 		sb_queue_tail(ipvs, ms);
 		ms->sync_buff = NULL;
 	}
-	spin_unlock(&ipvs->sync_buff_lock);
+	spin_unlock_bh(&ipvs->sync_buff_lock);
 
 	/* synchronize its controller if it has */
 	cp = cp->control;
@@ -641,9 +641,9 @@ sloop:
 		pe_name_len = strnlen(cp->pe->name, IP_VS_PENAME_MAXLEN);
 	}
 
-	spin_lock(&ipvs->sync_buff_lock);
+	spin_lock_bh(&ipvs->sync_buff_lock);
 	if (!(ipvs->sync_state & IP_VS_STATE_MASTER)) {
-		spin_unlock(&ipvs->sync_buff_lock);
+		spin_unlock_bh(&ipvs->sync_buff_lock);
 		return;
 	}
 
@@ -683,7 +683,7 @@ sloop:
 	if (!buff) {
 		buff = ip_vs_sync_buff_create(ipvs);
 		if (!buff) {
-			spin_unlock(&ipvs->sync_buff_lock);
+			spin_unlock_bh(&ipvs->sync_buff_lock);
 			pr_err("ip_vs_sync_buff_create failed.\n");
 			return;
 		}
@@ -750,7 +750,7 @@ sloop:
 		}
 	}
 
-	spin_unlock(&ipvs->sync_buff_lock);
+	spin_unlock_bh(&ipvs->sync_buff_lock);
 
 control:
 	/* synchronize its controller if it has */
@@ -843,7 +843,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		kfree(param->pe_data);
 
 		dest = cp->dest;
-		spin_lock(&cp->lock);
+		spin_lock_bh(&cp->lock);
 		if ((cp->flags ^ flags) & IP_VS_CONN_F_INACTIVE &&
 		    !(flags & IP_VS_CONN_F_TEMPLATE) && dest) {
 			if (flags & IP_VS_CONN_F_INACTIVE) {
@@ -857,7 +857,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		flags &= IP_VS_CONN_F_BACKUP_UPD_MASK;
 		flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
 		cp->flags = flags;
-		spin_unlock(&cp->lock);
+		spin_unlock_bh(&cp->lock);
 		if (!dest)
 			ip_vs_try_bind_dest(cp);
 	} else {
@@ -1689,11 +1689,7 @@ static int sync_thread_backup(void *data)
 				break;
 			}
 
-			/* disable bottom half, because it accesses the data
-			   shared by softirq while getting/creating conns */
-			local_bh_disable();
 			ip_vs_process_message(tinfo->net, tinfo->buf, len);
-			local_bh_enable();
 		}
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 32c646e..0e68555 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -170,7 +170,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 
 	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
 
-	spin_lock(&svc->sched_lock);
+	spin_lock_bh(&svc->sched_lock);
 	dest = mark->cl;
 	/* No available dests? */
 	if (mark->mw == 0)
@@ -222,7 +222,7 @@ found:
 	mark->cl = dest;
 
   out:
-	spin_unlock(&svc->sched_lock);
+	spin_unlock_bh(&svc->sched_lock);
 	return dest;
 
 err_noavail:
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 3db7889..b75ff64 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -177,22 +177,22 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 			rt = (struct rtable *) dest_dst->dst_cache;
 		else {
 			dest_dst = ip_vs_dest_dst_alloc();
-			spin_lock(&dest->dst_lock);
+			spin_lock_bh(&dest->dst_lock);
 			if (!dest_dst) {
 				__ip_vs_dst_set(dest, NULL, NULL, 0);
-				spin_unlock(&dest->dst_lock);
+				spin_unlock_bh(&dest->dst_lock);
 				goto err_unreach;
 			}
 			rt = do_output_route4(net, dest->addr.ip, rt_mode,
 					      &dest_dst->dst_saddr.ip);
 			if (!rt) {
 				__ip_vs_dst_set(dest, NULL, NULL, 0);
-				spin_unlock(&dest->dst_lock);
+				spin_unlock_bh(&dest->dst_lock);
 				ip_vs_dest_dst_free(dest_dst);
 				goto err_unreach;
 			}
 			__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
-			spin_unlock(&dest->dst_lock);
+			spin_unlock_bh(&dest->dst_lock);
 			IP_VS_DBG(10, "new dst %pI4, src %pI4, refcnt=%d\n",
 				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
 				  atomic_read(&rt->dst.__refcnt));
@@ -358,10 +358,10 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 			u32 cookie;
 
 			dest_dst = ip_vs_dest_dst_alloc();
-			spin_lock(&dest->dst_lock);
+			spin_lock_bh(&dest->dst_lock);
 			if (!dest_dst) {
 				__ip_vs_dst_set(dest, NULL, NULL, 0);
-				spin_unlock(&dest->dst_lock);
+				spin_unlock_bh(&dest->dst_lock);
 				goto err_unreach;
 			}
 			dst = __ip_vs_route_output_v6(net, &dest->addr.in6,
@@ -369,14 +369,14 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 						      do_xfrm);
 			if (!dst) {
 				__ip_vs_dst_set(dest, NULL, NULL, 0);
-				spin_unlock(&dest->dst_lock);
+				spin_unlock_bh(&dest->dst_lock);
 				ip_vs_dest_dst_free(dest_dst);
 				goto err_unreach;
 			}
 			rt = (struct rt6_info *) dst;
 			cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 			__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
-			spin_unlock(&dest->dst_lock);
+			spin_unlock_bh(&dest->dst_lock);
 			IP_VS_DBG(10, "new dst %pI6, src %pI6, refcnt=%d\n",
 				  &dest->addr.in6, &dest_dst->dst_saddr.in6,
 				  atomic_read(&rt->dst.__refcnt));
-- 
1.7.10.4
