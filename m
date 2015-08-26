From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v4 11/14] ipvs: ensure that ICMP cannot be sent in reply to ICMP
Date: Wed, 26 Aug 2015 09:40:38 -0700
Message-ID: <1440607241-355987-11-git-send-email-agartrell@fb.com>
References: <1440607241-355987-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=CUTg9L75TMr9ivzKtKlyO3vt5LcI9+xsthUX8Vwa/Kc=;
 b=g6bk0xPIKyN4lxSL3B/hFEKQZsfxjLxcCCHNcKta7WpAOslPgefNwq6px/q9KPIho1m1
 nBVaRZ8NeL0/BTW07IRnP5IULiWXtps/e0pQigZXrs0BTIkyfhyCyG9L0xX/koEBbhQh
 k7qI4hpGKJ/nvgS7y9zdvE2V5XAxoWhS5oc= 
In-Reply-To: <1440607241-355987-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Check the header for icmp before sending a PACKET_TOO_BIG

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index af5e9d3..c5be055 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -224,7 +224,7 @@ static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
 			if (!skb->dev)
 				skb->dev = net->loopback_dev;
 			/* only send ICMP too big on first fragment */
-			if (!ipvsh->fragoffs)
+			if (!ipvsh->fragoffs && !ip_vs_iph_icmp(ipvsh))
 				icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			IP_VS_DBG(1, "frag needed for %pI6c\n",
 				  &ipv6_hdr(skb)->saddr);
@@ -242,7 +242,8 @@ static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
 			return true;
 
 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
-			     skb->len > mtu && !skb_is_gso(skb))) {
+			     skb->len > mtu && !skb_is_gso(skb) &&
+			     !ip_vs_iph_icmp(ipvsh))) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
 			IP_VS_DBG(1, "frag needed for %pI4\n",
-- 
Alex Gartrell <agartrell@fb.com>

