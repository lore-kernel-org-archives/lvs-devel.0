Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9305226B761;
	Sun, 19 Oct 2025 16:02:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760889749; cv=none; b=tQvLPE3AmDxEwvBXtXhMjgZFzEIWfHgizWUqZ1UmsWIDUn9taZZGGjOayGx5/c2JOzqjRUjWR+KnID1Y7FjiNz8ze3xfv3PkVejC7wqWKbSFrCoxrPsGYX7VLISbRqL5hnTKqdABvhHKEPx/7r2MTN8PCMqGXQm/17xfsuL3kPA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760889749; c=relaxed/simple;
	bh=W+sRHGLQQHcKKXY8TT4ifiHAlkJd3YRK7NpFMWwYeRM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UF5IEhntk3tEePbCYJl1lCbf9kVI/WtBgVMdAKmgJd1ftgeIUm5ogreQk+kv8sYJzBs1nTEkDqRQcszXnMVWa9Y7kEBhX0KK4TQV6+Ho2cy21LJyCIReGIDjZra250s/+Fy67TSIH5zycv4hPhMPUfbVIkI5WrREGCQMtaIJpVE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=X01RaDij; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="X01RaDij"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 928D721EF5;
	Sun, 19 Oct 2025 19:01:16 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=qPC6mN6VCTGV6xSc2sLdMzw7M7iW0Xdlr9GazO4JSw0=; b=X01RaDijLwrq
	/Q7kd/YQ4hlHZfax7AThte6HKWwTJ4bccAViVchsdtP9bv1rE+FUQxgDbLakITH5
	wXz89lJGd7J+32kAkK+AwuyWJPj4Agh/nskdmep1FPqSnwN05o0jb24twY24KMQN
	k7TLXpyD4+I13wpIBzi+gya5V+y+YSVQQQ2pyxCmIroTNTZrEKt3Aers5fUfy1Kg
	hgCdlsKNlTVnienMvuMaC4C7RBMN/U3zetAMbPZ+yxVmN8MxiubRDECyOfnKIhxt
	fGDrVXx+ogtse0PWCimiDygyUpKIIXBEOmvhMp2h5E52c1ZrWuEeDOtwOPQye2bK
	FIoPYwO4uisQGleXwphXOn6Dg54kTtlvZ96S6j4Vlpp2EcfPSotGy0lQEOLNdWK2
	P9nr6vOUkkJbSfJ3Wq2CAmv2K4xilstU14JuMDA/kpNkH3OzYzHmEbQcN+SaoqPO
	u0UhfSLz5x8kSNsVw91uX10soMfAQg7gdux5LKBzTMXv/qvsvnwuEqAc+u5yp0Hw
	5EYvIfqOAQKFm2+CTph2D0UZ0wabr10Dto7PBpx/2/YOwPYjGokMjsRCkLd0tLAZ
	3xFT+v5AglPsEWCw06DslouxdzHHRc6cQ9MKgmPd+7xqqFquyZOT0504Xo8mphDQ
	pWQZq4HkH+vD1qu8naoxMeFJhYyOqKE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 19 Oct 2025 19:01:13 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 0EC6E64EA9;
	Sun, 19 Oct 2025 19:01:13 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 59JFveqs067657;
	Sun, 19 Oct 2025 18:57:40 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 59JFveU2067656;
	Sun, 19 Oct 2025 18:57:40 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv6 net-next 02/14] ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table per netns
Date: Sun, 19 Oct 2025 18:56:59 +0300
Message-ID: <20251019155711.67609-3-ja@ssi.bg>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20251019155711.67609-1-ja@ssi.bg>
References: <20251019155711.67609-1-ja@ssi.bg>
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
index 29a36709e7f3..074a204ec6db 100644
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
index 4c8fa22be88a..2fb9034b4f53 100644
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
@@ -1702,10 +1687,9 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
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
 
@@ -1713,10 +1697,9 @@ static int ip_vs_flush(struct netns_ipvs *ipvs, bool cleanup)
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
 
@@ -1733,12 +1716,12 @@ void ip_vs_service_nets_cleanup(struct list_head *net_list)
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
@@ -1776,25 +1759,20 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
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
 
@@ -1803,7 +1781,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 		ip_vs_forget_dev(dest, dev);
 	}
 	spin_unlock_bh(&ipvs->dest_trash_lock);
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	return NOTIFY_DONE;
 }
 
@@ -1827,16 +1805,14 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
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
 
@@ -2307,9 +2283,9 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 
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
@@ -2318,10 +2294,10 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 
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
@@ -2344,6 +2320,8 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct hlist_node *e;
 	struct ip_vs_iter *iter;
 	struct ip_vs_service *svc;
+	struct net *net = seq_file_net(seq);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
@@ -2352,7 +2330,7 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	svc = v;
 	iter = seq->private;
 
-	if (iter->table == ip_vs_svc_table) {
+	if (iter->table == ipvs->svc_table) {
 		/* next service in table hashed by protocol */
 		e = rcu_dereference(hlist_next_rcu(&svc->s_list));
 		if (e)
@@ -2360,13 +2338,13 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
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
@@ -2379,7 +2357,7 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
  scan_fwmark:
 	while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
 		hlist_for_each_entry_rcu(svc,
-					 &ip_vs_svc_fwm_table[iter->bucket],
+					 &ipvs->svc_fwm_table[iter->bucket],
 					 f_list)
 			return svc;
 	}
@@ -2415,7 +2393,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 
 		if (svc->ipvs != ipvs)
 			return 0;
-		if (iter->table == ip_vs_svc_table) {
+		if (iter->table == ipvs->svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (svc->af == AF_INET6)
 				seq_printf(seq, "%s  [%pI6]:%04X %s ",
@@ -2737,7 +2715,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, sockptr_t ptr, unsigned int len)
 		return ret;
 	}
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 	if (cmd == IP_VS_SO_SET_FLUSH) {
 		/* Flush the virtual service */
 		ret = ip_vs_flush(ipvs, false);
@@ -2834,7 +2812,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, sockptr_t ptr, unsigned int len)
 	}
 
   out_unlock:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	return ret;
 }
 
@@ -2872,9 +2850,9 @@ __ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 	int ret = 0;
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+		hlist_for_each_entry(svc, &ipvs->svc_table[idx], s_list) {
 			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET || (svc->ipvs != ipvs))
+			if (svc->af != AF_INET)
 				continue;
 
 			if (count >= get->num_services)
@@ -2891,9 +2869,9 @@ __ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 	}
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[idx], f_list) {
 			/* Only expose IPv4 entries to old interface */
-			if (svc->af != AF_INET || (svc->ipvs != ipvs))
+			if (svc->af != AF_INET)
 				continue;
 
 			if (count >= get->num_services)
@@ -3062,7 +3040,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		return ret;
 	}
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 	switch (cmd) {
 	case IP_VS_SO_GET_VERSION:
 	{
@@ -3161,7 +3139,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	}
 
 out:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	return ret;
 }
 
@@ -3396,10 +3374,10 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
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
@@ -3409,8 +3387,8 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
-		hlist_for_each_entry(svc, &ip_vs_svc_fwm_table[i], f_list) {
-			if (++idx <= start || (svc->ipvs != ipvs))
+		hlist_for_each_entry(svc, &ipvs->svc_fwm_table[i], f_list) {
+			if (++idx <= start)
 				continue;
 			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
 				idx--;
@@ -3420,7 +3398,7 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	}
 
 nla_put_failure:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 	cb->args[0] = idx;
 
 	return skb->len;
@@ -3609,7 +3587,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	struct net *net = sock_net(skb->sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 
 	/* Try to find the service for which to dump destinations */
 	if (nlmsg_parse_deprecated(cb->nlh, GENL_HDRLEN, attrs, IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy, cb->extack))
@@ -3634,7 +3612,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	cb->args[0] = idx;
 
 out_err:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 
 	return skb->len;
 }
@@ -3917,7 +3895,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 
 	cmd = info->genlhdr->cmd;
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 
 	if (cmd == IPVS_CMD_FLUSH) {
 		ret = ip_vs_flush(ipvs, false);
@@ -4029,7 +4007,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	}
 
 out:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 
 	return ret;
 }
@@ -4059,7 +4037,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 
 	reply = genlmsg_put_reply(msg, info, &ip_vs_genl_family, 0, reply_cmd);
 	if (reply == NULL)
@@ -4127,7 +4105,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 out_err:
 	nlmsg_free(msg);
 out:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 
 	return ret;
 }
@@ -4244,6 +4222,7 @@ static struct genl_family ip_vs_genl_family __ro_after_init = {
 	.small_ops	= ip_vs_genl_ops,
 	.n_small_ops	= ARRAY_SIZE(ip_vs_genl_ops),
 	.resv_start_op	= IPVS_CMD_FLUSH + 1,
+	.parallel_ops	= 1,
 };
 
 static int __init ip_vs_genl_register(void)
@@ -4426,6 +4405,13 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
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
@@ -4530,17 +4516,8 @@ void ip_vs_unregister_nl_ioctl(void)
 
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
index 93a925f1ed9b..c194f026bf69 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -603,7 +603,7 @@ static void ip_vs_est_drain_temp_list(struct netns_ipvs *ipvs)
 	while (1) {
 		int max = 16;
 
-		mutex_lock(&__ip_vs_mutex);
+		mutex_lock(&ipvs->service_mutex);
 
 		while (max-- > 0) {
 			est = hlist_entry_safe(ipvs->est_temp_list.first,
@@ -623,12 +623,12 @@ static void ip_vs_est_drain_temp_list(struct netns_ipvs *ipvs)
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
@@ -648,9 +648,9 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
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
@@ -749,7 +749,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	if (!ip_vs_est_calc_limits(ipvs, &chain_max))
 		return;
 
-	mutex_lock(&__ip_vs_mutex);
+	mutex_lock(&ipvs->service_mutex);
 
 	/* Stop all other tasks, so that we can immediately move the
 	 * estimators to est_temp_list without RCU grace period
@@ -816,9 +816,9 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
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
@@ -894,7 +894,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
 	mutex_unlock(&ipvs->est_mutex);
 
 unlock:
-	mutex_unlock(&__ip_vs_mutex);
+	mutex_unlock(&ipvs->service_mutex);
 }
 
 void ip_vs_zero_estimator(struct ip_vs_stats *stats)
-- 
2.51.0


