From: Julius Volz <julius.volz@gmail.com>
Subject: [PATCH] IPVS: Remove supports_ipv6 scheduler flag
Date: Tue, 4 Nov 2008 01:58:26 +0100
Message-ID: <20081104005826.GA28967@cydonia.lan>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:mime-version:content-type:content-disposition:user-agent;
        bh=KVxmqJ4Onpv8yB6bmdlGbq0/XiqqRqZLxv0SHzOwRdw=;
        b=vAiIYsojab9R8DMNp6i5is1vtdX+Q6fyo+Xq9W0x5KGSR26ReoZCp6wehMVOLBR32C
         ZM9gfMa9qhbPhuLBjRkasieJTmAiWPq2kJczl089KfuM3wwJJ473FSzL4LkOw5g1xV4A
         55+aJxIiJlHZ7RviTZZV5TcWd/sIruZqbRUWA=
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au

Remove the 'supports_ipv6' scheduler flag since all schedulers now
support IPv6.

Signed-off-by: Julius Volz <julius.volz@gmail.com>
---
 include/net/ip_vs.h              |    3 ---
 net/netfilter/ipvs/ip_vs_ctl.c   |   24 ++++++------------------
 net/netfilter/ipvs/ip_vs_dh.c    |    3 ---
 net/netfilter/ipvs/ip_vs_lblc.c  |    3 ---
 net/netfilter/ipvs/ip_vs_lblcr.c |    3 ---
 net/netfilter/ipvs/ip_vs_lc.c    |    3 ---
 net/netfilter/ipvs/ip_vs_nq.c    |    3 ---
 net/netfilter/ipvs/ip_vs_rr.c    |    3 ---
 net/netfilter/ipvs/ip_vs_sed.c   |    3 ---
 net/netfilter/ipvs/ip_vs_sh.c    |    3 ---
 net/netfilter/ipvs/ip_vs_wlc.c   |    3 ---
 net/netfilter/ipvs/ip_vs_wrr.c   |    3 ---
 12 files changed, 6 insertions(+), 51 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index fc63353..8f6abf4 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -503,9 +503,6 @@ struct ip_vs_scheduler {
 	char			*name;		/* scheduler name */
 	atomic_t		refcnt;		/* reference counter */
 	struct module		*module;	/* THIS_MODULE/NULL */
-#ifdef CONFIG_IP_VS_IPV6
-	int			supports_ipv6;	/* scheduler has IPv6 support */
-#endif
 
 	/* scheduler initializing service */
 	int (*init_service)(struct ip_vs_service *svc);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 98e0a65..d0ccdaf 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1168,15 +1168,9 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
 	}
 
 #ifdef CONFIG_IP_VS_IPV6
-	if (u->af == AF_INET6) {
-		if (!sched->supports_ipv6) {
-			ret = -EAFNOSUPPORT;
-			goto out_err;
-		}
-		if ((u->netmask < 1) || (u->netmask > 128)) {
-			ret = -EINVAL;
-			goto out_err;
-		}
+	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
+		ret = -EINVAL;
+		goto out_err;
 	}
 #endif
 
@@ -1272,15 +1266,9 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 	old_sched = sched;
 
 #ifdef CONFIG_IP_VS_IPV6
-	if (u->af == AF_INET6) {
-		if (!sched->supports_ipv6) {
-			ret = -EAFNOSUPPORT;
-			goto out;
-		}
-		if ((u->netmask < 1) || (u->netmask > 128)) {
-			ret = -EINVAL;
-			goto out;
-		}
+	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
+		ret = -EINVAL;
+		goto out;
 	}
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index d8258e0..a9dac74 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -243,9 +243,6 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_dh_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
 	.update_service =	ip_vs_dh_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 135a594..4256cfa 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -534,9 +534,6 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblc_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
 	.schedule =		ip_vs_lblc_schedule,
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 4d6534a..321b49f 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -735,9 +735,6 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblcr_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
 	.schedule =		ip_vs_lblcr_schedule,
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index b69f808..51912ca 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -81,9 +81,6 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lc_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.schedule =		ip_vs_lc_schedule,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index 9a2d803..6758ad2 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -116,9 +116,6 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_nq_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.schedule =		ip_vs_nq_schedule,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index a22195f..8fb51c1 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -89,9 +89,6 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.init_service =		ip_vs_rr_init_svc,
 	.update_service =	ip_vs_rr_update_svc,
 	.schedule =		ip_vs_rr_schedule,
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 7d2f22f..691a6a0 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -118,9 +118,6 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_sed_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.schedule =		ip_vs_sed_schedule,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 4074ccf..0e53955 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -240,9 +240,6 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list	 =		LIST_HEAD_INIT(ip_vs_sh_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
 	.update_service =	ip_vs_sh_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index 8c596e7..57b452b 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -106,9 +106,6 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_wlc_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.schedule =		ip_vs_wlc_schedule,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 7ea92fe..2f618dc 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -213,9 +213,6 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_wrr_scheduler.n_list),
-#ifdef CONFIG_IP_VS_IPV6
-	.supports_ipv6 =	1,
-#endif
 	.init_service =		ip_vs_wrr_init_svc,
 	.done_service =		ip_vs_wrr_done_svc,
 	.update_service =	ip_vs_wrr_update_svc,
-- 
1.5.3.7


