From: Hannes Eder <heder@google.com>
Subject: [PATCH v2 2/2] IPVS: use pr_err and friends instead of IP_VS_ERR and
	friends
Date: Tue, 28 Jul 2009 22:35:57 +0200
Message-ID: <20090728203554.7654.29628.stgit@jazzy.zrh.corp.google.com>
References: <20090728203414.7654.73236.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248813481; bh=dGv/jnnVJyCZjxxxPdG38uAWYfM=;
	h=DomainKey-Signature:Subject:To:From:Cc:Date:Message-ID:
	 In-Reply-To:References:User-Agent:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=B839sLis3HOnciyLM6
	gftVuXiFR5rRj2hVEurDawAUrnW8059Tkdy/Kp1TS05ypPX19e4lChL7FJ8NQ18dtYn
	g==
In-Reply-To: <20090728203414.7654.73236.stgit@jazzy.zrh.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>

Since pr_err and friends is used instead of printk there is not point
in keeping IP_VS_ERR and friends.

Signed-off-by: Hannes Eder <heder@google.com>

 include/net/ip_vs.h              |    3 --
 net/netfilter/ipvs/ip_vs_conn.c  |   12 ++++----
 net/netfilter/ipvs/ip_vs_core.c  |   22 +++++++--------
 net/netfilter/ipvs/ip_vs_ctl.c   |   56 +++++++++++++++++++-------------------
 net/netfilter/ipvs/ip_vs_dh.c    |    2 +
 net/netfilter/ipvs/ip_vs_ftp.c   |    4 +--
 net/netfilter/ipvs/ip_vs_lblc.c  |    4 +--
 net/netfilter/ipvs/ip_vs_lblcr.c |    6 ++--
 net/netfilter/ipvs/ip_vs_proto.c |    2 +
 net/netfilter/ipvs/ip_vs_sched.c |   36 ++++++++++++------------
 net/netfilter/ipvs/ip_vs_sh.c    |    2 +
 net/netfilter/ipvs/ip_vs_sync.c  |   46 ++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_wrr.c   |    2 +
 13 files changed, 97 insertions(+), 100 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b0bd782..582ac56 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -150,9 +150,6 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 #endif
 
 #define IP_VS_BUG() BUG()
-#define IP_VS_ERR(msg...) pr_err(msg)
-#define IP_VS_INFO(msg...) pr_info(msg)
-#define IP_VS_WARNING(msg...) pr_warning(msg)
 #define IP_VS_ERR_RL(msg...)						\
 	do {								\
 		if (net_ratelimit())					\
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index e613745..6d9b855 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -154,8 +154,8 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 		atomic_inc(&cp->refcnt);
 		ret = 1;
 	} else {
-		IP_VS_ERR("ip_vs_conn_hash(): request for already hashed, "
-			  "called from %p\n", __builtin_return_address(0));
+		pr_err("ip_vs_conn_hash(): request for already hashed, "
+		       "called from %p\n", __builtin_return_address(0));
 		ret = 0;
 	}
 
@@ -1087,10 +1087,10 @@ int __init ip_vs_conn_init(void)
 		return -ENOMEM;
 	}
 
-	IP_VS_INFO("Connection hash table configured "
-		   "(size=%d, memory=%ldKbytes)\n",
-		   IP_VS_CONN_TAB_SIZE,
-		   (long)(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head))/1024);
+	pr_info("Connection hash table configured "
+		"(size=%d, memory=%ldKbytes)\n",
+		IP_VS_CONN_TAB_SIZE,
+		(long)(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head))/1024);
 	IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
 		  sizeof(struct ip_vs_conn));
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 6811dca..ad29e41 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -391,9 +391,9 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	 */
 	if (!svc->fwmark && pptr[1] != svc->port) {
 		if (!svc->port)
-			IP_VS_ERR("Schedule: port zero only supported "
-				  "in persistent services, "
-				  "check your ipvs configuration\n");
+			pr_err("Schedule: port zero only supported "
+			       "in persistent services, "
+			       "check your ipvs configuration\n");
 		return NULL;
 	}
 
@@ -667,8 +667,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 	unsigned int verdict = NF_DROP;
 
 	if (IP_VS_FWD_METHOD(cp) != 0) {
-		IP_VS_ERR("shouldn't reach here, because the box is on the "
-			  "half connection in the tun/dr module.\n");
+		pr_err("shouldn't reach here, because the box is on the "
+		       "half connection in the tun/dr module.\n");
 	}
 
 	/* Ensure the checksum is correct */
@@ -1490,7 +1490,7 @@ static int __init ip_vs_init(void)
 
 	ret = ip_vs_control_init();
 	if (ret < 0) {
-		IP_VS_ERR("can't setup control.\n");
+		pr_err("can't setup control.\n");
 		goto cleanup_estimator;
 	}
 
@@ -1498,23 +1498,23 @@ static int __init ip_vs_init(void)
 
 	ret = ip_vs_app_init();
 	if (ret < 0) {
-		IP_VS_ERR("can't setup application helper.\n");
+		pr_err("can't setup application helper.\n");
 		goto cleanup_protocol;
 	}
 
 	ret = ip_vs_conn_init();
 	if (ret < 0) {
-		IP_VS_ERR("can't setup connection table.\n");
+		pr_err("can't setup connection table.\n");
 		goto cleanup_app;
 	}
 
 	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	if (ret < 0) {
-		IP_VS_ERR("can't register hooks.\n");
+		pr_err("can't register hooks.\n");
 		goto cleanup_conn;
 	}
 
-	IP_VS_INFO("ipvs loaded.\n");
+	pr_info("ipvs loaded.\n");
 	return ret;
 
   cleanup_conn:
@@ -1537,7 +1537,7 @@ static void __exit ip_vs_cleanup(void)
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
 	ip_vs_estimator_cleanup();
-	IP_VS_INFO("ipvs unloaded.\n");
+	pr_info("ipvs unloaded.\n");
 }
 
 module_init(ip_vs_init);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 83a7ab6..965adc9 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -343,8 +343,8 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 	unsigned hash;
 
 	if (svc->flags & IP_VS_SVC_F_HASHED) {
-		IP_VS_ERR("ip_vs_svc_hash(): request for already hashed, "
-			  "called from %p\n", __builtin_return_address(0));
+		pr_err("ip_vs_svc_hash(): request for already hashed, "
+		       "called from %p\n", __builtin_return_address(0));
 		return 0;
 	}
 
@@ -377,8 +377,8 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 static int ip_vs_svc_unhash(struct ip_vs_service *svc)
 {
 	if (!(svc->flags & IP_VS_SVC_F_HASHED)) {
-		IP_VS_ERR("ip_vs_svc_unhash(): request for unhash flagged, "
-			  "called from %p\n", __builtin_return_address(0));
+		pr_err("ip_vs_svc_unhash(): request for unhash flagged, "
+		       "called from %p\n", __builtin_return_address(0));
 		return 0;
 	}
 
@@ -844,7 +844,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 
 	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_ATOMIC);
 	if (dest == NULL) {
-		IP_VS_ERR("ip_vs_new_dest: kmalloc failed.\n");
+		pr_err("ip_vs_new_dest: kmalloc failed.\n");
 		return -ENOMEM;
 	}
 
@@ -888,13 +888,13 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	EnterFunction(2);
 
 	if (udest->weight < 0) {
-		IP_VS_ERR("ip_vs_add_dest(): server weight less than zero\n");
+		pr_err("ip_vs_add_dest(): server weight less than zero\n");
 		return -ERANGE;
 	}
 
 	if (udest->l_threshold > udest->u_threshold) {
-		IP_VS_ERR("ip_vs_add_dest(): lower threshold is higher than "
-			  "upper threshold\n");
+		pr_err("ip_vs_add_dest(): lower threshold is higher than "
+		       "upper threshold\n");
 		return -ERANGE;
 	}
 
@@ -1000,13 +1000,13 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	EnterFunction(2);
 
 	if (udest->weight < 0) {
-		IP_VS_ERR("ip_vs_edit_dest(): server weight less than zero\n");
+		pr_err("ip_vs_edit_dest(): server weight less than zero\n");
 		return -ERANGE;
 	}
 
 	if (udest->l_threshold > udest->u_threshold) {
-		IP_VS_ERR("ip_vs_edit_dest(): lower threshold is higher than "
-			  "upper threshold\n");
+		pr_err("ip_vs_edit_dest(): lower threshold is higher than "
+		       "upper threshold\n");
 		return -ERANGE;
 	}
 
@@ -1164,8 +1164,8 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	/* Lookup the scheduler by 'u->sched_name' */
 	sched = ip_vs_scheduler_get(u->sched_name);
 	if (sched == NULL) {
-		IP_VS_INFO("Scheduler module ip_vs_%s not found\n",
-			   u->sched_name);
+		pr_info("Scheduler module ip_vs_%s not found\n",
+			u->sched_name);
 		ret = -ENOENT;
 		goto out_mod_dec;
 	}
@@ -1262,8 +1262,8 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	 */
 	sched = ip_vs_scheduler_get(u->sched_name);
 	if (sched == NULL) {
-		IP_VS_INFO("Scheduler module ip_vs_%s not found\n",
-			   u->sched_name);
+		pr_info("Scheduler module ip_vs_%s not found\n",
+			u->sched_name);
 		return -ENOENT;
 	}
 	old_sched = sched;
@@ -2094,8 +2094,8 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		return -EPERM;
 
 	if (len != set_arglen[SET_CMDID(cmd)]) {
-		IP_VS_ERR("set_ctl: len %u != %u\n",
-			  len, set_arglen[SET_CMDID(cmd)]);
+		pr_err("set_ctl: len %u != %u\n",
+		       len, set_arglen[SET_CMDID(cmd)]);
 		return -EINVAL;
 	}
 
@@ -2146,9 +2146,9 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	/* Check for valid protocol: TCP or UDP, even for fwmark!=0 */
 	if (usvc.protocol != IPPROTO_TCP && usvc.protocol != IPPROTO_UDP) {
-		IP_VS_ERR("set_ctl: invalid protocol: %d %pI4:%d %s\n",
-			  usvc.protocol, &usvc.addr.ip,
-			  ntohs(usvc.port), usvc.sched_name);
+		pr_err("set_ctl: invalid protocol: %d %pI4:%d %s\n",
+		       usvc.protocol, &usvc.addr.ip,
+		       ntohs(usvc.port), usvc.sched_name);
 		ret = -EFAULT;
 		goto out_unlock;
 	}
@@ -2373,8 +2373,8 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		return -EPERM;
 
 	if (*len < get_arglen[GET_CMDID(cmd)]) {
-		IP_VS_ERR("get_ctl: len %u < %u\n",
-			  *len, get_arglen[GET_CMDID(cmd)]);
+		pr_err("get_ctl: len %u < %u\n",
+		       *len, get_arglen[GET_CMDID(cmd)]);
 		return -EINVAL;
 	}
 
@@ -2419,7 +2419,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		size = sizeof(*get) +
 			sizeof(struct ip_vs_service_entry) * get->num_services;
 		if (*len != size) {
-			IP_VS_ERR("length: %u != %u\n", *len, size);
+			pr_err("length: %u != %u\n", *len, size);
 			ret = -EINVAL;
 			goto out;
 		}
@@ -2459,7 +2459,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		size = sizeof(*get) +
 			sizeof(struct ip_vs_dest_entry) * get->num_dests;
 		if (*len != size) {
-			IP_VS_ERR("length: %u != %u\n", *len, size);
+			pr_err("length: %u != %u\n", *len, size);
 			ret = -EINVAL;
 			goto out;
 		}
@@ -3187,7 +3187,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	else if (cmd == IPVS_CMD_GET_CONFIG)
 		reply_cmd = IPVS_CMD_SET_CONFIG;
 	else {
-		IP_VS_ERR("unknown Generic Netlink command\n");
+		pr_err("unknown Generic Netlink command\n");
 		return -EINVAL;
 	}
 
@@ -3252,7 +3252,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
 	goto out;
 
 nla_put_failure:
-	IP_VS_ERR("not enough space in Netlink message\n");
+	pr_err("not enough space in Netlink message\n");
 	ret = -EMSGSIZE;
 
 out_err:
@@ -3397,13 +3397,13 @@ int __init ip_vs_control_init(void)
 
 	ret = nf_register_sockopt(&ip_vs_sockopts);
 	if (ret) {
-		IP_VS_ERR("cannot register sockopt.\n");
+		pr_err("cannot register sockopt.\n");
 		return ret;
 	}
 
 	ret = ip_vs_genl_register();
 	if (ret) {
-		IP_VS_ERR("cannot register Generic Netlink interface.\n");
+		pr_err("cannot register Generic Netlink interface.\n");
 		nf_unregister_sockopt(&ip_vs_sockopts);
 		return ret;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index d0c0594..3510b8a 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -150,7 +150,7 @@ static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
 	tbl = kmalloc(sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE,
 		      GFP_ATOMIC);
 	if (tbl == NULL) {
-		IP_VS_ERR("ip_vs_dh_init_svc(): no memory\n");
+		pr_err("ip_vs_dh_init_svc(): no memory\n");
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 9c16a3f..33e2c79 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -385,8 +385,8 @@ static int __init ip_vs_ftp_init(void)
 		ret = register_ip_vs_app_inc(app, app->protocol, ports[i]);
 		if (ret)
 			break;
-		IP_VS_INFO("%s: loaded support on port[%d] = %d\n",
-			   app->name, i, ports[i]);
+		pr_info("%s: loaded support on port[%d] = %d\n",
+			app->name, i, ports[i]);
 	}
 
 	if (ret)
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 66f625b..930eda7 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -205,7 +205,7 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
 		if (!en) {
-			IP_VS_ERR("ip_vs_lblc_new(): no memory\n");
+			pr_err("ip_vs_lblc_new(): no memory\n");
 			return NULL;
 		}
 
@@ -338,7 +338,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	 */
 	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
 	if (tbl == NULL) {
-		IP_VS_ERR("ip_vs_lblc_init_svc(): no memory\n");
+		pr_err("ip_vs_lblc_init_svc(): no memory\n");
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 63cca2b..4b3e7f6 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -111,7 +111,7 @@ ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
 
 	e = kmalloc(sizeof(*e), GFP_ATOMIC);
 	if (e == NULL) {
-		IP_VS_ERR("ip_vs_dest_set_insert(): no memory\n");
+		pr_err("ip_vs_dest_set_insert(): no memory\n");
 		return NULL;
 	}
 
@@ -380,7 +380,7 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
 		if (!en) {
-			IP_VS_ERR("ip_vs_lblcr_new(): no memory\n");
+			pr_err("ip_vs_lblcr_new(): no memory\n");
 			return NULL;
 		}
 
@@ -514,7 +514,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	 */
 	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
 	if (tbl == NULL) {
-		IP_VS_ERR("ip_vs_lblcr_init_svc(): no memory\n");
+		pr_err("ip_vs_lblcr_init_svc(): no memory\n");
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index a95bc40..85c8892 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -262,7 +262,7 @@ int __init ip_vs_protocol_init(void)
 #ifdef CONFIG_IP_VS_PROTO_ESP
 	REGISTER_PROTOCOL(&ip_vs_protocol_esp);
 #endif
-	IP_VS_INFO("Registered protocols (%s)\n", &protocols[2]);
+	pr_info("Registered protocols (%s)\n", &protocols[2]);
 
 	return 0;
 }
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index 87bc5ea..727e412 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -47,11 +47,11 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 	int ret;
 
 	if (svc == NULL) {
-		IP_VS_ERR("ip_vs_bind_scheduler(): svc arg NULL\n");
+		pr_err("ip_vs_bind_scheduler(): svc arg NULL\n");
 		return -EINVAL;
 	}
 	if (scheduler == NULL) {
-		IP_VS_ERR("ip_vs_bind_scheduler(): scheduler arg NULL\n");
+		pr_err("ip_vs_bind_scheduler(): scheduler arg NULL\n");
 		return -EINVAL;
 	}
 
@@ -60,7 +60,7 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
 	if (scheduler->init_service) {
 		ret = scheduler->init_service(svc);
 		if (ret) {
-			IP_VS_ERR("ip_vs_bind_scheduler(): init error\n");
+			pr_err("ip_vs_bind_scheduler(): init error\n");
 			return ret;
 		}
 	}
@@ -77,19 +77,19 @@ int ip_vs_unbind_scheduler(struct ip_vs_service *svc)
 	struct ip_vs_scheduler *sched;
 
 	if (svc == NULL) {
-		IP_VS_ERR("ip_vs_unbind_scheduler(): svc arg NULL\n");
+		pr_err("ip_vs_unbind_scheduler(): svc arg NULL\n");
 		return -EINVAL;
 	}
 
 	sched = svc->scheduler;
 	if (sched == NULL) {
-		IP_VS_ERR("ip_vs_unbind_scheduler(): svc isn't bound\n");
+		pr_err("ip_vs_unbind_scheduler(): svc isn't bound\n");
 		return -EINVAL;
 	}
 
 	if (sched->done_service) {
 		if (sched->done_service(svc) != 0) {
-			IP_VS_ERR("ip_vs_unbind_scheduler(): done error\n");
+			pr_err("ip_vs_unbind_scheduler(): done error\n");
 			return -EINVAL;
 		}
 	}
@@ -173,12 +173,12 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	struct ip_vs_scheduler *sched;
 
 	if (!scheduler) {
-		IP_VS_ERR("register_ip_vs_scheduler(): NULL arg\n");
+		pr_err("register_ip_vs_scheduler(): NULL arg\n");
 		return -EINVAL;
 	}
 
 	if (!scheduler->name) {
-		IP_VS_ERR("register_ip_vs_scheduler(): NULL scheduler_name\n");
+		pr_err("register_ip_vs_scheduler(): NULL scheduler_name\n");
 		return -EINVAL;
 	}
 
@@ -190,8 +190,8 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	if (!list_empty(&scheduler->n_list)) {
 		write_unlock_bh(&__ip_vs_sched_lock);
 		ip_vs_use_count_dec();
-		IP_VS_ERR("register_ip_vs_scheduler(): [%s] scheduler "
-			  "already linked\n", scheduler->name);
+		pr_err("register_ip_vs_scheduler(): [%s] scheduler "
+		       "already linked\n", scheduler->name);
 		return -EINVAL;
 	}
 
@@ -203,9 +203,9 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 		if (strcmp(scheduler->name, sched->name) == 0) {
 			write_unlock_bh(&__ip_vs_sched_lock);
 			ip_vs_use_count_dec();
-			IP_VS_ERR("register_ip_vs_scheduler(): [%s] scheduler "
-					"already existed in the system\n",
-					scheduler->name);
+			pr_err("register_ip_vs_scheduler(): [%s] scheduler "
+			       "already existed in the system\n",
+			       scheduler->name);
 			return -EINVAL;
 		}
 	}
@@ -215,7 +215,7 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	list_add(&scheduler->n_list, &ip_vs_schedulers);
 	write_unlock_bh(&__ip_vs_sched_lock);
 
-	IP_VS_INFO("[%s] scheduler registered.\n", scheduler->name);
+	pr_info("[%s] scheduler registered.\n", scheduler->name);
 
 	return 0;
 }
@@ -227,15 +227,15 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 {
 	if (!scheduler) {
-		IP_VS_ERR( "unregister_ip_vs_scheduler(): NULL arg\n");
+		pr_err("unregister_ip_vs_scheduler(): NULL arg\n");
 		return -EINVAL;
 	}
 
 	write_lock_bh(&__ip_vs_sched_lock);
 	if (list_empty(&scheduler->n_list)) {
 		write_unlock_bh(&__ip_vs_sched_lock);
-		IP_VS_ERR("unregister_ip_vs_scheduler(): [%s] scheduler "
-			  "is not in the list. failed\n", scheduler->name);
+		pr_err("unregister_ip_vs_scheduler(): [%s] scheduler "
+		       "is not in the list. failed\n", scheduler->name);
 		return -EINVAL;
 	}
 
@@ -248,7 +248,7 @@ int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	/* decrease the module use count */
 	ip_vs_use_count_dec();
 
-	IP_VS_INFO("[%s] scheduler unregistered.\n", scheduler->name);
+	pr_info("[%s] scheduler unregistered.\n", scheduler->name);
 
 	return 0;
 }
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index fb4d2d2..f7c7ffa 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -147,7 +147,7 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 	tbl = kmalloc(sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE,
 		      GFP_ATOMIC);
 	if (tbl == NULL) {
-		IP_VS_ERR("ip_vs_sh_init_svc(): no memory\n");
+		pr_err("ip_vs_sh_init_svc(): no memory\n");
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index cc04c99..018af17 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -246,7 +246,7 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 	if (!curr_sb) {
 		if (!(curr_sb=ip_vs_sync_buff_create())) {
 			spin_unlock(&curr_sb_lock);
-			IP_VS_ERR("ip_vs_sync_buff_create failed.\n");
+			pr_err("ip_vs_sync_buff_create failed.\n");
 			return;
 		}
 	}
@@ -412,7 +412,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 			if (dest)
 				atomic_dec(&dest->refcnt);
 			if (!cp) {
-				IP_VS_ERR("ip_vs_conn_new failed\n");
+				pr_err("ip_vs_conn_new failed\n");
 				return;
 			}
 		} else if (!cp->dest) {
@@ -580,8 +580,8 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
 
 	addr = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
 	if (!addr)
-		IP_VS_ERR("You probably need to specify IP address on "
-			  "multicast interface.\n");
+		pr_err("You probably need to specify IP address on "
+		       "multicast interface.\n");
 
 	IP_VS_DBG(7, "binding socket with (%s) %pI4\n",
 		  ifname, &addr);
@@ -605,13 +605,13 @@ static struct socket * make_send_sock(void)
 	/* First create a socket */
 	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
-		IP_VS_ERR("Error during creation of socket; terminating\n");
+		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
 
 	result = set_mcast_if(sock->sk, ip_vs_master_mcast_ifn);
 	if (result < 0) {
-		IP_VS_ERR("Error setting outbound mcast interface\n");
+		pr_err("Error setting outbound mcast interface\n");
 		goto error;
 	}
 
@@ -620,14 +620,14 @@ static struct socket * make_send_sock(void)
 
 	result = bind_mcastif_addr(sock, ip_vs_master_mcast_ifn);
 	if (result < 0) {
-		IP_VS_ERR("Error binding address of the mcast interface\n");
+		pr_err("Error binding address of the mcast interface\n");
 		goto error;
 	}
 
 	result = sock->ops->connect(sock, (struct sockaddr *) &mcast_addr,
 			sizeof(struct sockaddr), 0);
 	if (result < 0) {
-		IP_VS_ERR("Error connecting to the multicast addr\n");
+		pr_err("Error connecting to the multicast addr\n");
 		goto error;
 	}
 
@@ -650,7 +650,7 @@ static struct socket * make_receive_sock(void)
 	/* First create a socket */
 	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
 	if (result < 0) {
-		IP_VS_ERR("Error during creation of socket; terminating\n");
+		pr_err("Error during creation of socket; terminating\n");
 		return ERR_PTR(result);
 	}
 
@@ -660,7 +660,7 @@ static struct socket * make_receive_sock(void)
 	result = sock->ops->bind(sock, (struct sockaddr *) &mcast_addr,
 			sizeof(struct sockaddr));
 	if (result < 0) {
-		IP_VS_ERR("Error binding to the multicast addr\n");
+		pr_err("Error binding to the multicast addr\n");
 		goto error;
 	}
 
@@ -669,7 +669,7 @@ static struct socket * make_receive_sock(void)
 			(struct in_addr *) &mcast_addr.sin_addr,
 			ip_vs_backup_mcast_ifn);
 	if (result < 0) {
-		IP_VS_ERR("Error joining to the multicast group\n");
+		pr_err("Error joining to the multicast group\n");
 		goto error;
 	}
 
@@ -709,7 +709,7 @@ ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
 	msg->size = htons(msg->size);
 
 	if (ip_vs_send_async(sock, (char *)msg, msize) != msize)
-		IP_VS_ERR("ip_vs_send_async error\n");
+		pr_err("ip_vs_send_async error\n");
 }
 
 static int
@@ -740,9 +740,9 @@ static int sync_thread_master(void *data)
 	struct ip_vs_sync_thread_data *tinfo = data;
 	struct ip_vs_sync_buff *sb;
 
-	IP_VS_INFO("sync thread started: state = MASTER, mcast_ifn = %s, "
-		   "syncid = %d\n",
-		   ip_vs_master_mcast_ifn, ip_vs_master_syncid);
+	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
+		"syncid = %d\n",
+		ip_vs_master_mcast_ifn, ip_vs_master_syncid);
 
 	while (!kthread_should_stop()) {
 		while ((sb = sb_dequeue())) {
@@ -783,9 +783,9 @@ static int sync_thread_backup(void *data)
 	struct ip_vs_sync_thread_data *tinfo = data;
 	int len;
 
-	IP_VS_INFO("sync thread started: state = BACKUP, mcast_ifn = %s, "
-		   "syncid = %d\n",
-		   ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
+	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
+		"syncid = %d\n",
+		ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*tinfo->sock->sk->sk_sleep,
@@ -797,7 +797,7 @@ static int sync_thread_backup(void *data)
 			len = ip_vs_receive(tinfo->sock, tinfo->buf,
 					sync_recv_mesg_maxlen);
 			if (len <= 0) {
-				IP_VS_ERR("receiving message error\n");
+				pr_err("receiving message error\n");
 				break;
 			}
 
@@ -910,8 +910,8 @@ int stop_sync_thread(int state)
 		if (!sync_master_thread)
 			return -ESRCH;
 
-		IP_VS_INFO("stopping master sync thread %d ...\n",
-			   task_pid_nr(sync_master_thread));
+		pr_info("stopping master sync thread %d ...\n",
+			task_pid_nr(sync_master_thread));
 
 		/*
 		 * The lock synchronizes with sb_queue_tail(), so that we don't
@@ -928,8 +928,8 @@ int stop_sync_thread(int state)
 		if (!sync_backup_thread)
 			return -ESRCH;
 
-		IP_VS_INFO("stopping backup sync thread %d ...\n",
-			   task_pid_nr(sync_backup_thread));
+		pr_info("stopping backup sync thread %d ...\n",
+			task_pid_nr(sync_backup_thread));
 
 		ip_vs_sync_state &= ~IP_VS_STATE_BACKUP;
 		kthread_stop(sync_backup_thread);
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index c39ebb6..86772f2 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -97,7 +97,7 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 	 */
 	mark = kmalloc(sizeof(struct ip_vs_wrr_mark), GFP_ATOMIC);
 	if (mark == NULL) {
-		IP_VS_ERR("ip_vs_wrr_init_svc(): no memory\n");
+		pr_err("ip_vs_wrr_init_svc(): no memory\n");
 		return -ENOMEM;
 	}
 	mark->cl = &svc->destinations;

