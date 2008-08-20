From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 19/24] IPVS: Add IPv6 support flag to schedulers
Date: Wed, 20 Aug 2008 18:15:26 +0200
Message-ID: <1219248931-15064-20-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248944; bh=OADuAmSAUd9oB1beW6PbQzDGXAw=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=fiftwJi7OenvfTMBZX77QwT/YCtBivKs5eE50N9x
	SlKx7nF+dkVfHueApKm56kSzgBc43/1YK2lJzy94uRKa2w==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Add 'supports_ipv6' flag to struct ip_vs_scheduler to indicate whether a
scheduler supports IPv6. Set the flag to 1 in schedulers that work with
IPv6, 0 otherwise. This flag is checked in a later patch while trying to
add a service with a specific scheduler.

Signed-off-by: Julius Volz <juliusv@google.com>

 11 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 28880e4..144bcd5 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -521,6 +521,9 @@ struct ip_vs_scheduler {
 	char			*name;		/* scheduler name */
 	atomic_t		refcnt;		/* reference counter */
 	struct module		*module;	/* THIS_MODULE/NULL */
+#ifdef CONFIG_IP_VS_IPV6
+	int			supports_ipv6;	/* scheduler has IPv6 support */
+#endif
 
 	/* scheduler initializing service */
 	int (*init_service)(struct ip_vs_service *svc);
diff --git a/net/ipv4/ipvs/ip_vs_dh.c b/net/ipv4/ipvs/ip_vs_dh.c
index fa66824..bb0d426 100644
--- a/net/ipv4/ipvs/ip_vs_dh.c
+++ b/net/ipv4/ipvs/ip_vs_dh.c
@@ -234,6 +234,9 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_dh_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
 	.update_service =	ip_vs_dh_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index 7a6a319..5c37b73 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -540,6 +540,9 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
 	.update_service =	ip_vs_lblc_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index c234e73..5ee5588 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -729,6 +729,9 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblcr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
 	.update_service =	ip_vs_lblcr_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index b8670ec..d59fe8f 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -101,6 +101,9 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_lc_init_svc,
 	.done_service =		ip_vs_lc_done_svc,
 	.update_service =	ip_vs_lc_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index af277bc..0d3fff1 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -138,6 +138,9 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_nq_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_nq_init_svc,
 	.done_service =		ip_vs_nq_done_svc,
 	.update_service =	ip_vs_nq_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
index 358110d..cf41544 100644
--- a/net/ipv4/ipvs/ip_vs_rr.c
+++ b/net/ipv4/ipvs/ip_vs_rr.c
@@ -95,6 +95,9 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_rr_init_svc,
 	.done_service =		ip_vs_rr_done_svc,
 	.update_service =	ip_vs_rr_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index 33d93b0..446d660 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -139,6 +139,9 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_sed_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_sed_init_svc,
 	.done_service =		ip_vs_sed_done_svc,
 	.update_service =	ip_vs_sed_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_sh.c b/net/ipv4/ipvs/ip_vs_sh.c
index 7b979e2..12f9ccc 100644
--- a/net/ipv4/ipvs/ip_vs_sh.c
+++ b/net/ipv4/ipvs/ip_vs_sh.c
@@ -231,6 +231,9 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list	 =		LIST_HEAD_INIT(ip_vs_sh_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
 	.update_service =	ip_vs_sh_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 76e3339..6d66459 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -127,6 +127,9 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_wlc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_wlc_init_svc,
 	.done_service =		ip_vs_wlc_done_svc,
 	.update_service =	ip_vs_wlc_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 2f618dc..7ea92fe 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -213,6 +213,9 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_wrr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_wrr_init_svc,
 	.done_service =		ip_vs_wrr_done_svc,
 	.update_service =	ip_vs_wrr_update_svc,
-- 
1.5.4.5

