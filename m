Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5745F144D2C;
	Sun, 31 Mar 2024 14:07:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711894054; cv=none; b=PUkuTC5zYQXZMzkGzshb/RytUdBrM94uUZRXEVaxK139ARC3060idu+ftgpmD6INIBxdbsw19H/RYklwpHLW7qWatrijCdm2A16KMj77u6iJO3R1W01+44LoFk9ZKUBoczenLdnleDUxFEqqBY/Y2gxueOO3d6eIJsr9leNIkCA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711894054; c=relaxed/simple;
	bh=4uxHx+A9h+UW7IO0gYJ2+FeESE6DtjYyHwNHt1qTE4U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bEjMTaqmqSSdoWCQKYBswmmfkTyWsk68ivI//F3A/Ik3vy1N0iJph1DtjKs7nVwm2K23Y/D83fHlH/gH24GvdwRLN4u9WQqsSfJ/bZmZUGAS9Kr6WulPXvHsAU35QGwbzuHcho0cirONoAc2iaN4B9hveLFwh1HrwmAV8l4PC4I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Plq1Kv6H; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Plq1Kv6H"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 9F1CE31E9B;
	Sun, 31 Mar 2024 17:07:30 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS id 6C3BB31E92;
	Sun, 31 Mar 2024 17:07:28 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 97633900FAA;
	Sun, 31 Mar 2024 17:07:04 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1711894024; bh=4uxHx+A9h+UW7IO0gYJ2+FeESE6DtjYyHwNHt1qTE4U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Plq1Kv6HQMuV9hSojP91IyyqoJS2RpjN+DT6IfVh2mkUCFbSbuY+aUN3PFJ5aN63n
	 +N7jqWckYDy60GD/VbK+lFAs9ix+OmZJhcfAhl3exLzwABbQJEtl2xpSZosS96C0qN
	 48K5HM7enWXmHpEaeeEXMM5iRAdps+mYFPltgDPc=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 42VE44ij077706;
	Sun, 31 Mar 2024 17:04:04 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.17.1/8.17.1/Submit) id 42VE44s5077703;
	Sun, 31 Mar 2024 17:04:04 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv3 net-next 04/14] ipvs: use single svc table
Date: Sun, 31 Mar 2024 17:03:51 +0300
Message-ID: <20240331140401.77657-5-ja@ssi.bg>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20240331140401.77657-1-ja@ssi.bg>
References: <20240331140401.77657-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fwmark based services and non-fwmark based services can be hashed
in same service table. This reduces the burden of working with two
tables.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            |   8 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 146 +++++----------------------------
 2 files changed, 22 insertions(+), 132 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 68e562bc9df2..b0a9f67a5c33 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -679,8 +679,7 @@ struct ip_vs_dest_user_kern {
  * forwarding entries.
  */
 struct ip_vs_service {
-	struct hlist_node	s_list;   /* for normal service table */
-	struct hlist_node	f_list;   /* for fwmark-based service table */
+	struct hlist_node	s_list;   /* node in service table */
 	atomic_t		refcnt;   /* reference counter */
 
 	u16			af;       /* address family */
@@ -1050,10 +1049,7 @@ struct netns_ipvs {
 
 	/* the service mutex that protect svc_table and svc_fwm_table */
 	struct mutex service_mutex;
-	/* the service table hashed by <protocol, addr, port> */
-	struct hlist_head svc_table[IP_VS_SVC_TAB_SIZE];
-	/* the service table hashed by fwmark */
-	struct hlist_head svc_fwm_table[IP_VS_SVC_TAB_SIZE];
+	struct hlist_head svc_table[IP_VS_SVC_TAB_SIZE];	/* Services */
 };
 
 #define DEFAULT_SYNC_THRESHOLD	3
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 268a71f6aa97..e325e5f9d37b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -329,7 +329,7 @@ static inline unsigned int ip_vs_svc_fwm_hashkey(struct netns_ipvs *ipvs, __u32
 
 /*
  *	Hashes a service in the svc_table by <netns,proto,addr,port>
- *	or in the svc_fwm_table by fwmark.
+ *	or by fwmark.
  *	Should be called with locked tables.
  */
 static int ip_vs_svc_hash(struct ip_vs_service *svc)
@@ -344,18 +344,17 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 
 	if (svc->fwmark == 0) {
 		/*
-		 *  Hash it by <netns,protocol,addr,port> in svc_table
+		 *  Hash it by <netns,protocol,addr,port>
 		 */
 		hash = ip_vs_svc_hashkey(svc->ipvs, svc->af, svc->protocol,
 					 &svc->addr, svc->port);
-		hlist_add_head_rcu(&svc->s_list, &svc->ipvs->svc_table[hash]);
 	} else {
 		/*
-		 *  Hash it by fwmark in svc_fwm_table
+		 *  Hash it by fwmark
 		 */
 		hash = ip_vs_svc_fwm_hashkey(svc->ipvs, svc->fwmark);
-		hlist_add_head_rcu(&svc->f_list, &svc->ipvs->svc_fwm_table[hash]);
 	}
+	hlist_add_head_rcu(&svc->s_list, &svc->ipvs->svc_table[hash]);
 
 	svc->flags |= IP_VS_SVC_F_HASHED;
 	/* increase its refcnt because it is referenced by the svc table */
@@ -365,7 +364,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 
 
 /*
- *	Unhashes a service from svc_table / svc_fwm_table.
+ *	Unhashes a service from svc_table.
  *	Should be called with locked tables.
  */
 static int ip_vs_svc_unhash(struct ip_vs_service *svc)
@@ -376,13 +375,8 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 		return 0;
 	}
 
-	if (svc->fwmark == 0) {
-		/* Remove it from the svc_table table */
-		hlist_del_rcu(&svc->s_list);
-	} else {
-		/* Remove it from the svc_fwm_table table */
-		hlist_del_rcu(&svc->f_list);
-	}
+	/* Remove it from svc_table */
+	hlist_del_rcu(&svc->s_list);
 
 	svc->flags &= ~IP_VS_SVC_F_HASHED;
 	atomic_dec(&svc->refcnt);
@@ -405,7 +399,8 @@ __ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u16 protocol,
 
 	hlist_for_each_entry_rcu(svc, &ipvs->svc_table[hash], s_list) {
 		if (svc->af == af && ip_vs_addr_equal(af, &svc->addr, vaddr) &&
-		    svc->port == vport && svc->protocol == protocol) {
+		    svc->port == vport && svc->protocol == protocol &&
+		    !svc->fwmark) {
 			/* HIT */
 			return svc;
 		}
@@ -427,7 +422,7 @@ __ip_vs_svc_fwm_find(struct netns_ipvs *ipvs, int af, __u32 fwmark)
 	/* Check for fwmark addressed entries */
 	hash = ip_vs_svc_fwm_hashkey(ipvs, fwmark);
 
-	hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[hash], f_list) {
+	hlist_for_each_entry_rcu(svc, &ipvs->svc_table[hash], s_list) {
 		if (svc->fwmark == fwmark && svc->af == af) {
 			/* HIT */
 			return svc;
@@ -1682,26 +1677,11 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 	struct ip_vs_service *svc;
 	struct hlist_node *n;
 
-	/*
-	 * Flush the service table hashed by <netns,protocol,addr,port>
-	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry_safe(svc, n, &ipvs->svc_table[idx],
-					  s_list) {
+					  s_list)
 			ip_vs_unlink_service(svc, cleanup);
-		}
 	}
-
-	/*
-	 * Flush the service table hashed by fwmark
-	 */
-	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_safe(svc, n, &ipvs->svc_fwm_table[idx],
-					  f_list) {
-			ip_vs_unlink_service(svc, cleanup);
-		}
-	}
-
 	return 0;
 }
 
@@ -1764,11 +1744,6 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 			list_for_each_entry_rcu(dest, &svc->destinations,
 						n_list)
 				ip_vs_forget_dev(dest, dev);
-
-		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[idx], f_list)
-			list_for_each_entry_rcu(dest, &svc->destinations,
-						n_list)
-				ip_vs_forget_dev(dest, dev);
 	}
 	rcu_read_unlock();
 
@@ -1802,15 +1777,8 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
 	struct ip_vs_service *svc;
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
+		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list)
 			ip_vs_zero_service(svc);
-		}
-	}
-
-	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
-			ip_vs_zero_service(svc);
-		}
 	}
 
 	ip_vs_zero_stats(&ipvs->tot_stats->s);
@@ -2246,7 +2214,6 @@ static struct ctl_table vs_vars[] = {
 
 struct ip_vs_iter {
 	struct seq_net_private p;  /* Do not move this, netns depends upon it*/
-	struct hlist_head *table;
 	int bucket;
 };
 
@@ -2269,7 +2236,6 @@ static inline const char *ip_vs_fwd_name(unsigned int flags)
 }
 
 
-/* Get the Nth entry in the two lists */
 static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 {
 	struct net *net = seq_file_net(seq);
@@ -2278,29 +2244,14 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 	int idx;
 	struct ip_vs_service *svc;
 
-	/* look in hash by protocol */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[idx], s_list) {
 			if (pos-- == 0) {
-				iter->table = ipvs->svc_table;
-				iter->bucket = idx;
-				return svc;
-			}
-		}
-	}
-
-	/* keep looking in fwmark */
-	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[idx],
-					 f_list) {
-			if (pos-- == 0) {
-				iter->table = ipvs->svc_fwm_table;
 				iter->bucket = idx;
 				return svc;
 			}
 		}
 	}
-
 	return NULL;
 }
 
@@ -2327,38 +2278,17 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	svc = v;
 	iter = seq->private;
 
-	if (iter->table == ipvs->svc_table) {
-		/* next service in table hashed by protocol */
-		e = rcu_dereference(hlist_next_rcu(&svc->s_list));
-		if (e)
-			return hlist_entry(e, struct ip_vs_service, s_list);
-
-		while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
-			hlist_for_each_entry_rcu(svc,
-						 &ipvs->svc_table[iter->bucket],
-						 s_list) {
-				return svc;
-			}
-		}
-
-		iter->table = ipvs->svc_fwm_table;
-		iter->bucket = -1;
-		goto scan_fwmark;
-	}
-
-	/* next service in hashed by fwmark */
-	e = rcu_dereference(hlist_next_rcu(&svc->f_list));
+	e = rcu_dereference(hlist_next_rcu(&svc->s_list));
 	if (e)
-		return hlist_entry(e, struct ip_vs_service, f_list);
+		return hlist_entry(e, struct ip_vs_service, s_list);
 
- scan_fwmark:
 	while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
 		hlist_for_each_entry_rcu(svc,
-					 &ipvs->svc_fwm_table[iter->bucket],
-					 f_list)
+					 &ipvs->svc_table[iter->bucket],
+					 s_list) {
 			return svc;
+		}
 	}
-
 	return NULL;
 }
 
@@ -2380,17 +2310,12 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		seq_puts(seq,
 			 "  -> RemoteAddress:Port Forward Weight ActiveConn InActConn\n");
 	} else {
-		struct net *net = seq_file_net(seq);
-		struct netns_ipvs *ipvs = net_ipvs(net);
 		const struct ip_vs_service *svc = v;
-		const struct ip_vs_iter *iter = seq->private;
 		const struct ip_vs_dest *dest;
 		struct ip_vs_scheduler *sched = rcu_dereference(svc->scheduler);
 		char *sched_name = sched ? sched->name : "none";
 
-		if (svc->ipvs != ipvs)
-			return 0;
-		if (iter->table == ipvs->svc_table) {
+		if (!svc->fwmark) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (svc->af == AF_INET6)
 				seq_printf(seq, "%s  [%pI6]:%04X %s ",
@@ -2865,24 +2790,6 @@ __ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 		}
 	}
 
-	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
-			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET)
-				continue;
-
-			if (count >= get->num_services)
-				goto out;
-			memset(&entry, 0, sizeof(entry));
-			ip_vs_copy_service(&entry, svc);
-			if (copy_to_user(&uptr->entrytable[count],
-					 &entry, sizeof(entry))) {
-				ret = -EFAULT;
-				goto out;
-			}
-			count++;
-		}
-	}
 out:
 	return ret;
 }
@@ -3383,17 +3290,6 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 		}
 	}
 
-	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[i], f_list) {
-			if (++idx <= start)
-				continue;
-			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
-				idx--;
-				goto nla_put_failure;
-			}
-		}
-	}
-
 nla_put_failure:
 	rcu_read_unlock();
 	cb->args[0] = idx;
@@ -4397,12 +4293,10 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 	int ret = -ENOMEM;
 	int idx;
 
-	/* Initialize service_mutex, svc_table, svc_fwm_table per netns */
+	/* Initialize service_mutex, svc_table per netns */
 	__mutex_init(&ipvs->service_mutex, "ipvs->service_mutex", &__ipvs_service_key);
-	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
+	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++)
 		INIT_HLIST_HEAD(&ipvs->svc_table[idx]);
-		INIT_HLIST_HEAD(&ipvs->svc_fwm_table[idx]);
-	}
 
 	/* Initialize rs_table */
 	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
-- 
2.44.0


