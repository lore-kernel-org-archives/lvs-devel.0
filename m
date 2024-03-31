Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CAA0144D30;
	Sun, 31 Mar 2024 14:07:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711894063; cv=none; b=NZJtMU4jITnut20pr/F6y77gdlgaVbrodD48xKk5JQDJNbKcpUVk6yfLXej2jlpTk957axJxBNCnRX0xwE4jXX+6JVavyChFlE50oBL5btIU6GY5SurURS251/dcaO628PZxjWPqAsfYmcH9z8dFGg7HZtu/WLSIZa8pDnbfci8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711894063; c=relaxed/simple;
	bh=jv7eOvnR7mv4cxWZ2ZjV6Fs/smgbMR5HpXr46XzVUKI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qrODIsn8y8ziiChEVR79mRykC0fecb0TpeMbQT2hipfnm6/hiG89kba82IBQUWTegPaZUhJxsJehs4yXccGf/g6VpOUNGFSBCnPOynOl1b9Gjwp0Hdn3iO4E2BDEfNsbyAU8w2F1qqdH/XlQO0kFXBZxr9REcD8LcgNXnGhkoU4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=BpCES0t8; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="BpCES0t8"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 829D931DEE;
	Sun, 31 Mar 2024 17:07:39 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS id 78B7C31E2D;
	Sun, 31 Mar 2024 17:07:36 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id BF7B39036B2;
	Sun, 31 Mar 2024 17:07:04 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1711894024; bh=jv7eOvnR7mv4cxWZ2ZjV6Fs/smgbMR5HpXr46XzVUKI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BpCES0t8QK2ISzD6v0ZoqyLR8nmG/XMs/2pwe+w7+7b6KvCpKRnKp1phVZXjb0IuT
	 /9aKeh3iVi2wXsMtQ0Nzzj1MEYz9RyhPSIMxTKQIJi06w+U3KkaG5FGESMWM+/TQfw
	 RHmHW0sYL0LB6uZp6+c6nlkXIU/iOPAyQZQjJ01o=
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 42VE440q077696;
	Sun, 31 Mar 2024 17:04:04 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.17.1/8.17.1/Submit) id 42VE44bM077695;
	Sun, 31 Mar 2024 17:04:04 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv3 net-next 02/14] ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table per netns
Date: Sun, 31 Mar 2024 17:03:49 +0300
Message-ID: <20240331140401.77657-3-ja@ssi.bg>
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

From: Jiejian Wu <jiejian@linux.alibaba.com>

Current ipvs uses one global mutex "__ip_vs_mutex" to keep the global
"ip_vs_svc_table" and "ip_vs_svc_fwm_table" safe. But when there are
tens of thousands of services from different netns in the table, it
takes a long time to look up the table, for example, using "ipvsadm
-ln" from different netns simultaneously.

We make "ip_vs_svc_table" and "ip_vs_svc_fwm_table" per netns, and we
add "service_mutex" per netns to keep these two tables safe instead of
the global "__ip_vs_mutex" in current version. To this end, looking up
services from different netns simultaneously will not get stuck,
shortening the time consumption in large-scale deployment. It can be
reproduced using the simple scripts below.

init.sh: #!/bin/bash
for((i=1;i<=4;i++));do
        ip netns add ns$i
        ip netns exec ns$i ip link set dev lo up
        ip netns exec ns$i sh add-services.sh
done

add-services.sh: #!/bin/bash
for((i=0;i<30000;i++)); do
        ipvsadm -A  -t 10.10.10.10:$((80+$i)) -s rr
done

runtest.sh: #!/bin/bash
for((i=1;i<4;i++));do
        ip netns exec ns$i ipvsadm -ln > /dev/null &
done
ip netns exec ns4 ipvsadm -ln > /dev/null

Run "sh init.sh" to initiate the network environment. Then run "time
./runtest.sh" to evaluate the time consumption. Our testbed is a 4-core
Intel Xeon ECS. The result of the original version is around 8 seconds,
while the result of the modified version is only 0.8 seconds.

Signed-off-by: Jiejian Wu <jiejian@linux.alibaba.com>
Co-developed-by: Dust Li <dust.li@linux.alibaba.com>
Signed-off-by: Dust Li <dust.li@linux.alibaba.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h            |  13 +++
 net/netfilter/ipvs/ip_vs_ctl.c | 167 ++++++++++++++-------------------
 net/netfilter/ipvs/ip_vs_est.c |  18 ++--
 3 files changed, 94 insertions(+), 104 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index ff406ef4fd4a..68e562bc9df2 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -33,6 +33,12 @@
 
 #define IP_VS_HDR_INVERSE	1
 #define IP_VS_HDR_ICMP		2
+/*
+ *	Hash table: for virtual service lookups
+ */
+#define IP_VS_SVC_TAB_BITS 8
+#define IP_VS_SVC_TAB_SIZE BIT(IP_VS_SVC_TAB_BITS)
+#define IP_VS_SVC_TAB_MASK (IP_VS_SVC_TAB_SIZE - 1)
 
 /* Generic access of ipvs struct */
 static inline struct netns_ipvs *net_ipvs(struct net* net)
@@ -1041,6 +1047,13 @@ struct netns_ipvs {
 	 */
 	unsigned int		mixed_address_family_dests;
 	unsigned int		hooks_afmask;	/* &1=AF_INET, &2=AF_INET6 */
+
+	/* the service mutex that protect svc_table and svc_fwm_table */
+	struct mutex service_mutex;
+	/* the service table hashed by <protocol, addr, port> */
+	struct hlist_head svc_table[IP_VS_SVC_TAB_SIZE];
+	/* the service table hashed by fwmark */
+	struct hlist_head svc_fwm_table[IP_VS_SVC_TAB_SIZE];
 };
 
 #define DEFAULT_SYNC_THRESHOLD	3
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 143a341bbc0a..7189bf6bd371 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -49,7 +49,7 @@
 
 MODULE_ALIAS_GENL_FAMILY(IPVS_GENL_NAME);
 
-DEFINE_MUTEX(__ip_vs_mutex); /* Serialize configuration with sockopt/netlink */
+static struct lock_class_key __ipvs_service_key;
 
 /* sysctl variables */
 
@@ -294,17 +294,6 @@ ip_vs_use_count_dec(void)
 }
 
 
-/*
- *	Hash table: for virtual service lookups
- */
-#define IP_VS_SVC_TAB_BITS 8
-#define IP_VS_SVC_TAB_SIZE (1 << IP_VS_SVC_TAB_BITS)
-#define IP_VS_SVC_TAB_MASK (IP_VS_SVC_TAB_SIZE - 1)
-
-/* the service table hashed by <protocol, addr, port> */
-static struct hlist_head ip_vs_svc_table[IP_VS_SVC_TAB_SIZE];
-/* the service table hashed by fwmark */
-static struct hlist_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
 
 
 /*
@@ -339,8 +328,8 @@ static inline unsigned int ip_vs_svc_fwm_hashkey(struct netns_ipvs *ipvs, __u32
 }
 
 /*
- *	Hashes a service in the ip_vs_svc_table by <netns,proto,addr,port>
- *	or in the ip_vs_svc_fwm_table by fwmark.
+ *	Hashes a service in the svc_table by <netns,proto,addr,port>
+ *	or in the svc_fwm_table by fwmark.
  *	Should be called with locked tables.
  */
 static int ip_vs_svc_hash(struct ip_vs_service *svc)
@@ -355,17 +344,17 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 
 	if (svc->fwmark == 0) {
 		/*
-		 *  Hash it by <netns,protocol,addr,port> in ip_vs_svc_table
+		 *  Hash it by <netns,protocol,addr,port> in svc_table
 		 */
 		hash = ip_vs_svc_hashkey(svc->ipvs, svc->af, svc->protocol,
 					 &svc->addr, svc->port);
-		hlist_add_head_rcu(&svc->s_list, &ip_vs_svc_table[hash]);
+		hlist_add_head_rcu(&svc->s_list, &svc->ipvs->svc_table[hash]);
 	} else {
 		/*
 		 *  Hash it by fwmark in svc_fwm_table
 		 */
 		hash = ip_vs_svc_fwm_hashkey(svc->ipvs, svc->fwmark);
-		hlist_add_head_rcu(&svc->f_list, &ip_vs_svc_fwm_table[hash]);
+		hlist_add_head_rcu(&svc->f_list, &svc->ipvs->svc_fwm_table[hash]);
 	}
 
 	svc->flags |= IP_VS_SVC_F_HASHED;
@@ -414,12 +403,9 @@ __ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u16 protocol,
 	/* Check for "full" addressed entries */
 	hash = ip_vs_svc_hashkey(ipvs, af, protocol, vaddr, vport);
 
-	hlist_for_each_entry_rcu(svc, &ip_vs_svc_table[hash], s_list) {
-		if ((svc->af == af)
-		    && ip_vs_addr_equal(af, &svc->addr, vaddr)
-		    && (svc->port == vport)
-		    && (svc->protocol == protocol)
-		    && (svc->ipvs == ipvs)) {
+	hlist_for_each_entry_rcu(svc, &ipvs->svc_table[hash], s_list) {
+		if (svc->af == af && ip_vs_addr_equal(af, &svc->addr, vaddr) &&
+		    svc->port == vport && svc->protocol == protocol) {
 			/* HIT */
 			return svc;
 		}
@@ -441,9 +427,8 @@ __ip_vs_svc_fwm_find(struct netns_ipvs *ipvs, int af, __u32 fwmark)
 	/* Check for fwmark addressed entries */
 	hash = ip_vs_svc_fwm_hashkey(ipvs, fwmark);
 
-	hlist_for_each_entry_rcu(svc, &ip_vs_svc_fwm_table[hash], f_list) {
-		if (svc->fwmark == fwmark && svc->af == af
-		    && (svc->ipvs == ipvs)) {
+	hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[hash], f_list) {
+		if (svc->fwmark == fwmark && svc->af == af) {
 			/* HIT */
 			return svc;
 		}
@@ -1701,10 +1686,9 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 	 * Flush the service table hashed by <netns,protocol,addr,port>
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_safe(svc, n, &ip_vs_svc_table[idx],
+		hlist_for_each_entry_safe(svc, n, &ipvs->svc_table[idx],
 					  s_list) {
-			if (svc->ipvs == ipvs)
-				ip_vs_unlink_service(svc, cleanup);
+			ip_vs_unlink_service(svc, cleanup);
 		}
 	}
 
@@ -1712,10 +1696,9 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
 	 * Flush the service table hashed by fwmark
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_safe(svc, n, &ip_vs_svc_fwm_table[idx],
+		hlist_for_each_entry_safe(svc, n, &ipvs->svc_fwm_table[idx],
 					  f_list) {
-			if (svc->ipvs == ipvs)
-				ip_vs_unlink_service(svc, cleanup);
+			ip_vs_unlink_service(svc, cleanup);
 		}
 	}
 
@@ -1732,12 +1715,12 @@ void ip_vs_service_nets_cleanup(struct list_head *net_list)
 	struct net *net;
 
 	/* Check for "full" addressed entries */
-	mutex_lock(&__ip_vs_mutex);
 	list_for_each_entry(net, net_list, exit_list) {
 		ipvs = net_ipvs(net);
+		mutex_lock(&ipvs->service_mutex);
 		ip_vs_flush(ipvs, true);
+		mutex_unlock(&ipvs->service_mutex);
 	}
-	mutex_unlock(&__ip_vs_mutex);
 }
 
 /* Put all references for device (dst_cache) */
@@ -1775,25 +1758,20 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	if (event != NETDEV_DOWN || !ipvs)
 		return NOTIFY_DONE;
 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
-			if (svc->ipvs == ipvs) {
-				list_for_each_entry(dest, &svc->destinations,
-						    n_list) {
-					ip_vs_forget_dev(dest, dev);
-				}
+		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
+			list_for_each_entry(dest, &svc->destinations,
+					    n_list) {
+				ip_vs_forget_dev(dest, dev);
 			}
 		}
 
-		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
-			if (svc->ipvs == ipvs) {
-				list_for_each_entry(dest, &svc->destinations,
-						    n_list) {
-					ip_vs_forget_dev(dest, dev);
-				}
+		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
+			list_for_each_entry(dest, &svc->destinations,
+					    n_list) {
+				ip_vs_forget_dev(dest, dev);
 			}
-
 		}
 	}
 
@@ -1802,7 +1780,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 		ip_vs_forget_dev(dest, dev);
 	}
 	spin_unlock_bh(&ipvs->dest_trash_lock);
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	return NOTIFY_DONE;
 }
 
@@ -1826,16 +1804,14 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
 	struct ip_vs_service *svc;
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
-			if (svc->ipvs == ipvs)
-				ip_vs_zero_service(svc);
+		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
+			ip_vs_zero_service(svc);
 		}
 	}
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
-			if (svc->ipvs == ipvs)
-				ip_vs_zero_service(svc);
+		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
+			ip_vs_zero_service(svc);
 		}
 	}
 
@@ -2306,9 +2282,9 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 
 	/* look in hash by protocol */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_rcu(svc, &ip_vs_svc_table[idx], s_list) {
-			if ((svc->ipvs == ipvs) && pos-- == 0) {
-				iter->table = ip_vs_svc_table;
+		hlist_for_each_entry_rcu(svc, &ipvs->svc_table[idx], s_list) {
+			if (pos-- == 0) {
+				iter->table = ipvs->svc_table;
 				iter->bucket = idx;
 				return svc;
 			}
@@ -2317,10 +2293,10 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 
 	/* keep looking in fwmark */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry_rcu(svc, &ip_vs_svc_fwm_table[idx],
+		hlist_for_each_entry_rcu(svc, &ipvs->svc_fwm_table[idx],
 					 f_list) {
-			if ((svc->ipvs == ipvs) && pos-- == 0) {
-				iter->table = ip_vs_svc_fwm_table;
+			if (pos-- == 0) {
+				iter->table = ipvs->svc_fwm_table;
 				iter->bucket = idx;
 				return svc;
 			}
@@ -2343,6 +2319,8 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct hlist_node *e;
 	struct ip_vs_iter *iter;
 	struct ip_vs_service *svc;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
@@ -2351,7 +2329,7 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	svc = v;
 	iter = seq->private;
 
-	if (iter->table == ip_vs_svc_table) {
+	if (iter->table == ipvs->svc_table) {
 		/* next service in table hashed by protocol */
 		e = rcu_dereference(hlist_next_rcu(&svc->s_list));
 		if (e)
@@ -2359,13 +2337,13 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 		while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
 			hlist_for_each_entry_rcu(svc,
-						 &ip_vs_svc_table[iter->bucket],
+						 &ipvs->svc_table[iter->bucket],
 						 s_list) {
 				return svc;
 			}
 		}
 
-		iter->table = ip_vs_svc_fwm_table;
+		iter->table = ipvs->svc_fwm_table;
 		iter->bucket = -1;
 		goto scan_fwmark;
 	}
@@ -2378,7 +2356,7 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
  scan_fwmark:
 	while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
 		hlist_for_each_entry_rcu(svc,
-					 &ip_vs_svc_fwm_table[iter->bucket],
+					 &ipvs->svc_fwm_table[iter->bucket],
 					 f_list)
 			return svc;
 	}
@@ -2414,7 +2392,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 
 		if (svc->ipvs != ipvs)
 			return 0;
-		if (iter->table == ip_vs_svc_table) {
+		if (iter->table == ipvs->svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (svc->af == AF_INET6)
 				seq_printf(seq, "%s  [%pI6]:%04X %s ",
@@ -2736,7 +2714,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, sockptr_t ptr, unsigned int len)
 		return ret;
 	}
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 	if (cmd == IP_VS_SO_SET_FLUSH) {
 		/* Flush the virtual service */
 		ret = ip_vs_flush(ipvs, false);
@@ -2833,7 +2811,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, sockptr_t ptr, unsigned int len)
 	}
 
   out_unlock:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	return ret;
 }
 
@@ -2871,9 +2849,9 @@ __ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 	int ret = 0;
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
 			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET || (svc->ipvs != ipvs))
+			if (svc->af != AF_INET)
 				continue;
 
 			if (count >= get->num_services)
@@ -2890,9 +2868,9 @@ __ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 	}
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
 			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET || (svc->ipvs != ipvs))
+			if (svc->af != AF_INET)
 				continue;
 
 			if (count >= get->num_services)
@@ -3061,7 +3039,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		return ret;
 	}
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 	switch (cmd) {
 	case IP_VS_SO_GET_VERSION:
 	{
@@ -3160,7 +3138,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	}
 
 out:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	return ret;
 }
 
@@ -3395,10 +3373,10 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
-			if (++idx <= start || (svc->ipvs != ipvs))
+		hlist_for_each_entry(svc, &ipvs->svc_table[i], s_list) {
+			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
 				idx--;
@@ -3408,8 +3386,8 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[i], f_list) {
-			if (++idx <= start || (svc->ipvs != ipvs))
+		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[i], f_list) {
+			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
 				idx--;
@@ -3419,7 +3397,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 nla_put_failure:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	cb->args[0] = idx;
 
 	return skb->len;
@@ -3608,7 +3586,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 
 	/* Try to find the service for which to dump destinations */
 	if (nlmsg_parse_deprecated(cb->nlh, GENL_HDRLEN, attrs, IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy, cb->extack))
@@ -3633,7 +3611,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	cb->args[0] = idx;
 
 out_err:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 
 	return skb->len;
 }
@@ -3919,7 +3897,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 
 	cmd = info->genlhdr->cmd;
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 
 	if (cmd == IPVS_CMD_FLUSH) {
 		ret = ip_vs_flush(ipvs, false);
@@ -4031,7 +4009,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	}
 
 out:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 
 	return ret;
 }
@@ -4061,7 +4039,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 
 	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
 	if (reply == NULL)
@@ -4129,7 +4107,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 out_err:
 	nlmsg_free(msg);
 out:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 
 	return ret;
 }
@@ -4246,6 +4224,7 @@ static struct genl_family ip_vs_genl_family __ro_after_init = {
 	.small_ops	= ip_vs_genl_ops,
 	.n_small_ops	= ARRAY_SIZE(ip_vs_genl_ops),
 	.resv_start_op	= IPVS_CMD_FLUSH + 1,
+	.parallel_ops	= 1,
 };
 
 static int __init ip_vs_genl_register(void)
@@ -4419,6 +4398,13 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
 	int ret = -ENOMEM;
 	int idx;
 
+	/* Initialize service_mutex, svc_table, svc_fwm_table per netns */
+	__mutex_init(&ipvs->service_mutex, "ipvs->service_mutex", &__ipvs_service_key);
+	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
+		INIT_HLIST_HEAD(&ipvs->svc_table[idx]);
+		INIT_HLIST_HEAD(&ipvs->svc_fwm_table[idx]);
+	}
+
 	/* Initialize rs_table */
 	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
 		INIT_HLIST_HEAD(&ipvs->rs_table[idx]);
@@ -4523,17 +4509,8 @@ void ip_vs_unregister_nl_ioctl(void)
 
 int __init ip_vs_control_init(void)
 {
-	int idx;
 	int ret;
 
-	/* Initialize svc_table, ip_vs_svc_fwm_table */
-	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		INIT_HLIST_HEAD(&ip_vs_svc_table[idx]);
-		INIT_HLIST_HEAD(&ip_vs_svc_fwm_table[idx]);
-	}
-
-	smp_wmb();	/* Do we really need it now ? */
-
 	ret = register_netdevice_notifier(&ip_vs_dst_notifier);
 	if (ret < 0)
 		return ret;
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index f821ad2e19b3..5f717cecb13d 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -602,7 +602,7 @@ static void ip_vs_est_drain_temp_list(struct netns_ipvs *ipvs)
 	while (1) {
 		int max = 16;
 
-		mutex_lock(&__ip_vs_mutex);
+		mutex_lock(&ipvs->service_mutex);
 
 		while (max-- > 0) {
 			est = hlist_entry_safe(ipvs->est_temp_list.first,
@@ -622,12 +622,12 @@ static void ip_vs_est_drain_temp_list(struct netns_ipvs *ipvs)
 			}
 			goto unlock;
 		}
-		mutex_unlock(&__ip_vs_mutex);
+		mutex_unlock(&ipvs->service_mutex);
 		cond_resched();
 	}
 
 unlock:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 }
 
 /* Calculate limits for all kthreads */
@@ -647,9 +647,9 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 	u64 val;
 
 	INIT_HLIST_HEAD(&chain);
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 	kd = ipvs->est_kt_arr[0];
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	s = kd ? kd->calc_stats : NULL;
 	if (!s)
 		goto out;
@@ -748,7 +748,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	if (!ip_vs_est_calc_limits(ipvs, &chain_max))
 		return;
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 
 	/* Stop all other tasks, so that we can immediately move the
 	 * estimators to est_temp_list without RCU grace period
@@ -815,9 +815,9 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 		/* Give chance estimators to be added (to est_temp_list)
 		 * and deleted (releasing kthread contexts)
 		 */
-		mutex_unlock(&__ip_vs_mutex);
+		mutex_unlock(&ipvs->service_mutex);
 		cond_resched();
-		mutex_lock(&__ip_vs_mutex);
+		mutex_lock(&ipvs->service_mutex);
 
 		/* Current kt released ? */
 		if (id >= ipvs->est_kt_count)
@@ -893,7 +893,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	mutex_unlock(&ipvs->est_mutex);
 
 unlock:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 }
 
 void ip_vs_zero_estimator(struct ip_vs_stats *stats)
-- 
2.44.0


