From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 23/25] IPVS: Activate IPv6 Netfilter hooks
Date: Mon,  1 Sep 2008 14:56:20 +0200
Message-ID: <1220273782-19901-24-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273824; bh=9Pbxdj6KqLeRlmf3cpAwJEEkzoE=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=ZSXudUnJO2l3tihCv4sfhvFxpoNNcL4VCRw9VN5K
	vgsDn9DFN2PuQ585Uj1NmHJtBwN25v16+DtwJEpWvtNyrw==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Register the previously defined or adapted netfilter hook functions for
IPv6 as PF_INET6 hooks.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 141454d..6f5d534 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1410,6 +1410,43 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.hooknum        = NF_INET_POST_ROUTING,
 		.priority       = NF_IP_PRI_NAT_SRC-1,
 	},
+#ifdef CONFIG_IP_VS_IPV6
+	/* After packet filtering, forward packet through VS/DR, VS/TUN,
+	 * or VS/NAT(change destination), so that filtering rules can be
+	 * applied to IPVS. */
+	{
+		.hook		= ip_vs_in,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_LOCAL_IN,
+		.priority       = 100,
+	},
+	/* After packet filtering, change source only for VS/NAT */
+	{
+		.hook		= ip_vs_out,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 100,
+	},
+	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
+	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
+	{
+		.hook		= ip_vs_forward_icmp_v6,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_FORWARD,
+		.priority       = 99,
+	},
+	/* Before the netfilter connection tracking, exit from POST_ROUTING */
+	{
+		.hook		= ip_vs_post_routing,
+		.owner		= THIS_MODULE,
+		.pf		= PF_INET6,
+		.hooknum        = NF_INET_POST_ROUTING,
+		.priority       = NF_IP6_PRI_NAT_SRC-1,
+	},
+#endif
 };
 
 
-- 
1.5.4.5

