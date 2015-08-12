From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 07/12] ipvs: Use outer header in ip_vs_bypass_xmit_v6
Date: Wed, 12 Aug 2015 13:47:05 -0700
Message-ID: <1439412430-1702375-8-git-send-email-agartrell@fb.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=7b2q55GHhXfyhjMkR0Jb/wGRTeYhEg90CjCQW6jFecE=;
 b=Cm2mDnxZ0bN71ZFfIgA9S2NEjCPnOw+ZH7OMCBZW/smKC51v1pwTiP+70Tpi0aJJY0ip
 YXgmH++bh7oGrk9V7xClw/iFUu7uzTBQYuYAznOptyICFO2k9SwpT94KHPwSSObfINIZ
 qCtgCTmtuRGYwWXgQ9iQxc1Wq7eWhMSMfwg= 
In-Reply-To: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, alexgartrell@gmail.com, Alex Gartrell <agartrell@fb.com>

The ip_vs_iphdr may refer to an internal header, so use the outer one
instead.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 258a0b0..7691738 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -656,10 +656,12 @@ int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		     struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt_v6(cp->af, skb, NULL, &ipvsh->daddr.in6, NULL,
+	if (__ip_vs_get_out_rt_v6(cp->af, skb, NULL, &iph->daddr, NULL,
 				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
 		goto tx_error;
 
-- 
Alex Gartrell <agartrell@fb.com>

