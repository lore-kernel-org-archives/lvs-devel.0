From: <agartrell@fb.com>
Subject: [PATCH ipvs-next] ipvs: Maintain all DSCP and ECN bits for ipv6 tun forwarding
Date: Wed, 16 Jul 2014 15:57:34 -0700
Message-ID: <1405551454-23327-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=8oNwcq38z+HKAzx8zuGZxFnZxUECury1z7XKO6TWEC8=;
 b=DkGwzGcooVpwsqErgFs7rfRJu/H1SS5J/OtMba4fcIt8SZFSxPRhZofRZqDNuaWzul7v
 O6rIRDPCA2CGuKpIACdtJbrtFqEfcDcJ2EuTjJG4+reI7SqFMfQ+Lz7kZg0v5ugfTPGB
 Sd6AWdfU1he/0uwSO3WxGkqJ7uSBNTCZlz0= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, Alex Gartrell <agartrell@fb.com>

From: Alex Gartrell <agartrell@fb.com>

Previously, only the four high bits of the tclass were maintained in the
ipv6 case.  This matches the behavior of ipv4, though whether or not we
should reflect ECN bits may be up for debate.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index c47444e..28ee592 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -967,8 +967,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->nexthdr		=	IPPROTO_IPV6;
 	iph->payload_len	=	old_iph->payload_len;
 	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
-	iph->priority		=	old_iph->priority;
 	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
+	ipv6_change_dsfield(iph, 0, ipv6_get_dsfield(old_iph));
 	iph->daddr = cp->daddr.in6;
 	iph->saddr = saddr;
 	iph->hop_limit		=	old_iph->hop_limit;
-- 
1.8.1

