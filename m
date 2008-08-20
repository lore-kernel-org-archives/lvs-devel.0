From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 22/24] IPVS: Add IPv6 support to genetlink interface
Date: Wed, 20 Aug 2008 18:15:29 +0200
Message-ID: <1219248931-15064-23-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248947; bh=Fl0nvkWkpSy90R1QlYiDaBSxWpg=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=hypnhrPRtrgthfz4odD5M3Z3JSkCWB77rGDwdI/B
	D14GpYFwpXEUl8eS/nWUYkhkJzjo1ehjTyxCAGNFSwVbQw==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Allow adding IPv6 services in genetlink interface.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 73150ce..f2caf56 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -2565,7 +2565,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	if (!nl_service)
 		return -EMSGSIZE;
 
-	NLA_PUT_U16(skb, IPVS_SVC_ATTR_AF, AF_INET);
+	NLA_PUT_U16(skb, IPVS_SVC_ATTR_AF, svc->af);
 
 	if (svc->fwmark) {
 		NLA_PUT_U32(skb, IPVS_SVC_ATTR_FWMARK, svc->fwmark);
@@ -2671,8 +2671,12 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user *usvc,
 	if (!(nla_af && (nla_fwmark || (nla_port && nla_protocol && nla_addr))))
 		return -EINVAL;
 
-	/* For now, only support IPv4 */
-	if (nla_get_u16(nla_af) != AF_INET)
+	usvc->af = nla_get_u16(nla_af);
+#ifdef CONFIG_IP_VS_IPV6
+	if (usvc->af != AF_INET && usvc->af != AF_INET6)
+#else
+	if (usvc->af != AF_INET)
+#endif
 		return -EAFNOSUPPORT;
 
 	if (nla_fwmark) {
-- 
1.5.4.5

