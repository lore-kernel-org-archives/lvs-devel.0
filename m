From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 24/24] IPVS: Allow adding IPv6 services from userspace
Date: Tue,  2 Sep 2008 15:55:55 +0200
Message-ID: <1220363755-9854-25-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363768; bh=PLdNh+1+bz9nOOxR74RDJ+L0uN0=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=Cb1MUsVSHNsYX+OfDCfhazlRJALkHyKVRbTl4Z2E
	00M0uzK8QHQxB+w8NafOJuIKDyLYDcuRyWuI2ewQgKEt9Q==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Allow adding IPv6 services through the genetlink interface and add checks
to see if the chosen scheduler is supported with IPv6 and whether the
supplied prefix length is sane. Make sure the service count exported via
the sockopt interface only counts IPv4 services.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 6dbc527..7f89c58 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1177,6 +1177,19 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 		goto out_mod_dec;
 	}
 
+#ifdef CONFIG_IP_VS_IPV6
+	if (u->af == AF_INET6) {
+		if (!sched->supports_ipv6) {
+			ret = -EAFNOSUPPORT;
+			goto out_err;
+		}
+		if ((u->netmask < 1) || (u->netmask > 128)) {
+			ret = -EINVAL;
+			goto out_err;
+		}
+	}
+#endif
+
 	svc = kzalloc(sizeof(struct ip_vs_service), GFP_ATOMIC);
 	if (svc == NULL) {
 		IP_VS_DBG(1, "ip_vs_add_service: kmalloc failed.\n");
@@ -1214,7 +1227,10 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 		atomic_inc(&ip_vs_nullsvc_counter);
 
 	ip_vs_new_estimator(&svc->stats);
-	ip_vs_num_services++;
+
+	/* Count only IPv4 services for old get/setsockopt interface */
+	if (svc->af == AF_INET)
+		ip_vs_num_services++;
 
 	/* Hash the service into the service table */
 	write_lock_bh(&__ip_vs_svc_lock);
@@ -1265,6 +1281,19 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	}
 	old_sched = sched;
 
+#ifdef CONFIG_IP_VS_IPV6
+	if (u->af == AF_INET6) {
+		if (!sched->supports_ipv6) {
+			ret = EAFNOSUPPORT;
+			goto out;
+		}
+		if ((u->netmask < 1) || (u->netmask > 128)) {
+			ret = EINVAL;
+			goto out;
+		}
+	}
+#endif
+
 	write_lock_bh(&__ip_vs_svc_lock);
 
 	/*
@@ -1329,7 +1358,10 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
 
-	ip_vs_num_services--;
+	/* Count only IPv4 services for old get/setsockopt interface */
+	if (svc->af == AF_INET)
+		ip_vs_num_services--;
+
 	ip_vs_kill_estimator(&svc->stats);
 
 	/* Unbind scheduler */
@@ -2212,6 +2244,10 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+			/* Only expose IPv4 entries to old interface */
+			if (svc->af != AF_INET)
+				continue;
+
 			if (count >= get->num_services)
 				goto out;
 			memset(&entry, 0, sizeof(entry));
@@ -2227,6 +2263,10 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+			/* Only expose IPv4 entries to old interface */
+			if (svc->af != AF_INET)
+				continue;
+
 			if (count >= get->num_services)
 				goto out;
 			memset(&entry, 0, sizeof(entry));
@@ -2584,7 +2624,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	if (!nl_service)
 		return -EMSGSIZE;
 
-	NLA_PUT_U16(skb, IPVS_SVC_ATTR_AF, AF_INET);
+	NLA_PUT_U16(skb, IPVS_SVC_ATTR_AF, svc->af);
 
 	if (svc->fwmark) {
 		NLA_PUT_U32(skb, IPVS_SVC_ATTR_FWMARK, svc->fwmark);
@@ -2691,8 +2731,11 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 		return -EINVAL;
 
 	usvc->af = nla_get_u16(nla_af);
-	/* For now, only support IPv4 */
-	if (nla_get_u16(nla_af) != AF_INET)
+#ifdef CONFIG_IP_VS_IPV6
+	if (usvc->af != AF_INET && usvc->af != AF_INET6)
+#else
+	if (usvc->af != AF_INET)
+#endif
 		return -EAFNOSUPPORT;
 
 	if (nla_fwmark) {
-- 
1.5.4.5

