From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 21/24] IPVS: Only expose IPv4 entries through sockopt interface
Date: Wed, 20 Aug 2008 18:15:28 +0200
Message-ID: <1219248931-15064-22-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248957; bh=44IcMTfEW26l+XTE0YyeZR4uavw=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=UdEA4tDCCeCvR/jGnnkhBbKnPrL5Uw+A1DLT/HOg
	J23zUWroDhLKj7L4KxaapY50C7m08jhsALl4SSl+JFrmaA==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Do not expose v6 services via the old sockopt interface and only count v6
services in ip_vs_num_services (which is only used to report the count to
userspace in the old interface).

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 39ab7dc..73150ce 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1209,7 +1209,10 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
 		atomic_inc(&ip_vs_nullsvc_counter);
 
 	ip_vs_new_estimator(&svc->stats);
-	ip_vs_num_services++;
+
+	/* Count only IPv4 services for old get/setsockopt interface */
+	if (svc->af == AF_INET)
+		ip_vs_num_services++;
 
 	/* Hash the service into the service table */
 	write_lock_bh(&__ip_vs_svc_lock);
@@ -1337,7 +1340,10 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
 
-	ip_vs_num_services--;
+	/* Count only IPv4 services for old get/setsockopt interface */
+	if (svc->af == AF_INET)
+		ip_vs_num_services--;
+
 	ip_vs_kill_estimator(&svc->stats);
 
 	/* Unbind scheduler */
@@ -2182,8 +2188,13 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
+			/* Only expose IPv4 entries to old interface */
+			if (svc->af != AF_INET)
+				continue;
+
 			if (count >= get->num_services)
 				goto out;
+
 			memset(&entry, 0, sizeof(entry));
 			ip_vs_copy_service(&entry, svc);
 			if (copy_to_user(&uptr->entrytable[count],
@@ -2197,8 +2208,12 @@ __ip_vs_get_service_entries(const struct ip_vs_get_services *get,
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
 		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
+			if (svc->af != AF_INET)
+				continue;
+
 			if (count >= get->num_services)
 				goto out;
+
 			memset(&entry, 0, sizeof(entry));
 			ip_vs_copy_service(&entry, svc);
 			if (copy_to_user(&uptr->entrytable[count],
-- 
1.5.4.5

