From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v3 08/14] ipvs: Use outer header in ip_vs_bypass_xmit_v6
Date: Tue, 25 Aug 2015 20:49:23 -0700
Message-ID: <1440560969-3511889-8-git-send-email-agartrell@fb.com>
References: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=QXiM7pXZxfCQdU4VOi0sF4gLhIaka6daOapj3LGtZlQ=;
 b=MuAB3lSR8FPR6rzvogUrZ7K9hjCc6VCjblvqme5HIJ3r4PL/AdDycO+lZ/iGVziybcNL
 rsC9FWwzmGvc/Pma+3/48KBIvXSYlrkD1Q+xRmGpWxbTSjKsXiKNOBGZYiQcg83O8Gip
 asn766vw89oD6peNMphJrBpUdS33RWu7iOA= 
In-Reply-To: <1440560969-3511889-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

The ip_vs_iphdr may refer to an internal header, so use the outer one
instead.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 9a26f2e..af5e9d3 100644
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

