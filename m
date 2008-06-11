From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 11/26] IPVS: Add supports_ipv6 flag to schedulers.
Date: Wed, 11 Jun 2008 19:11:54 +0200
Message-ID: <1213204329-10973-12-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204337; bh=yGsfN6i6J5fd2NPuAJ7aO8gImqg=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=lODU5gP+s91HhkDyzy+t4iPaHc9yF9ROF+4XCS7M
	URAWJKbSS91CYQfz5KxlYcs/1pAo51blwDN+T3hd6nG8gg==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Add supports_ipv6 flag to struct ip_vs_scheduler to indicate whether a
scheduler supports IPv6. Set the flag to 1 in schedulers that work with
IPv6, 0 otherwise.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 11 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a6e7438..2ab5d59 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -687,6 +687,9 @@ struct ip_vs_scheduler {
 	char			*name;		/* scheduler name */
 	atomic_t		refcnt;		/* reference counter */
 	struct module		*module;	/* THIS_MODULE/NULL */
+#ifdef CONFIG_IP_VS_IPV6
+	int			supports_ipv6;	/* scheduler has IPv6 support */
+#endif
 
 	/* scheduler initializing service */
 	int (*init_service)(struct ip_vs_service *svc);
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index dcf5d46..25a0ac6 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -235,6 +235,9 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.name =			"dh",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
 	.update_service =	ip_vs_dh_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 3888642..55c2417 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -541,6 +541,9 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.name =			"lblc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
 	.update_service =	ip_vs_lblc_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index daa260e..5b94f5f 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -730,6 +730,9 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.name =			"lblcr",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
 	.update_service =	ip_vs_lblcr_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index e1214d1..d64b17f 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -107,6 +107,9 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 	.name =			"lc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_lc_init_svc,
 	.done_service =		ip_vs_lc_done_svc,
 	.update_service =	ip_vs_lc_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index 5de2e34..aaa6321 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -146,6 +146,9 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 	.name =			"nq",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_nq_init_svc,
 	.done_service =		ip_vs_nq_done_svc,
 	.update_service =	ip_vs_nq_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 433f8a9..3f78cc8 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -96,6 +96,9 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.name =			"rr",			/* name */
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_rr_init_svc,
 	.done_service =		ip_vs_rr_done_svc,
 	.update_service =	ip_vs_rr_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index e7bc810..99995cf 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -147,6 +147,9 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 	.name =			"sed",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_sed_init_svc,
 	.done_service =		ip_vs_sed_done_svc,
 	.update_service =	ip_vs_sed_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 1b25b00..49ef452 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -232,6 +232,9 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.name =			"sh",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
 	.update_service =	ip_vs_sh_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index ff003a7..88f571b 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -135,6 +135,9 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 	.name =			"wlc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_wlc_init_svc,
 	.done_service =		ip_vs_wlc_done_svc,
 	.update_service =	ip_vs_wlc_update_svc,
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 3f61ab2..1bc4aad 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -221,6 +221,9 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 	.name =			"wrr",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_wrr_init_svc,
 	.done_service =		ip_vs_wrr_done_svc,
 	.update_service =	ip_vs_wrr_update_svc,
-- 
1.5.3.6

