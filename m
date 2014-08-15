From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 08/18] ipvs: Only do ip_hdr operations in *out_rt when skb_af is AF_INET
Date: Thu, 14 Aug 2014 20:23:31 -0700
Message-ID: <1408073021-24007-9-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=8FDx7gCKOzXD1rLhNXQL5bRo47A6TG1j7Un0GlRLZO0=;
 b=PmoFclb3h9l22t90HZdAG94jKINHmaAHD1QwsziQhYATVSNBsQ54mEIzJYxZNgZfw1tr
 oKNEL0BUXeRkoG2SBebgtAY4uArtb6KPZTEI5EKyFGxRe3FVC9H4solQpB1pZvw9cJEz
 SWR07noqLwkRoHZxHSReMTDwojiXfC0PIJY= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

We can no longer count on always being able to access a v4 ip header, so
just drop the local variable and use ip_hdr only when skb_af is AF_INET.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 193ad01..7990641 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -228,8 +228,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_dest_dst *dest_dst;
 	struct rtable *rt;			/* Route to the other host */
-	struct iphdr *iph;
-	__be16 df;
+	__be16 df = 0;
 	int mtu;
 	int local, noref = 1;
 
@@ -284,7 +283,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		IP_VS_DBG_RL("We are crossing local and non-local addresses\n");
 		goto err_put;
 	}
-	iph = ip_hdr(skb);
 
 	if (unlikely(local)) {
 		/* skb to local stack, preserve old route */
@@ -295,7 +293,8 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 
 	if (likely(!(rt_mode & IP_VS_RT_MODE_TUNNEL))) {
 		mtu = dst_mtu(&rt->dst);
-		df = iph->frag_off & htons(IP_DF);
+		if (skb_af == AF_INET)
+			df = ip_hdr(skb)->frag_off & htons(IP_DF);
 	} else {
 		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
 		if (mtu < 68) {
@@ -304,13 +303,14 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		}
 		maybe_update_pmtu(skb_af, skb, mtu);
 		/* MTU check allowed? */
-		df = sysctl_pmtu_disc(ipvs) ? iph->frag_off & htons(IP_DF) : 0;
+		if (skb_af == AF_INET && sysctl_pmtu_disc(ipvs))
+			df = ip_hdr(skb)->frag_off & htons(IP_DF);
 	}
 
 	/* MTU checking */
 	if (unlikely(df && skb->len > mtu && !skb_is_gso(skb))) {
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-		IP_VS_DBG(1, "frag needed for %pI4\n", &iph->saddr);
+		IP_VS_DBG(1, "frag needed for %pI4\n", &ip_hdr(skb)->saddr);
 		goto err_put;
 	}
 
-- 
1.8.1

