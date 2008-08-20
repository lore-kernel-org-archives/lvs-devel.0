From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 20/24] IPVS: Add validity checks when adding/editing v6 services
Date: Wed, 20 Aug 2008 18:15:27 +0200
Message-ID: <1219248931-15064-21-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248946; bh=JhkzYqUzYLsBbpxw4itANRvnit0=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=JB2ul42i67P0EW9WI6MzzsJaWMhDsON3KvA+TLEV
	dyRpQAgIdsvtbcIusEAHJiN4kutpxMcauGqeDrhTtZvZNQ==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Check to see if the specified scheduler is supported with IPv6 and whether
the supplied prefix length is valid.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 6127a97..39ab7dc 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1160,6 +1160,19 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
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
@@ -1247,6 +1260,19 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user *u)
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
-- 
1.5.4.5

