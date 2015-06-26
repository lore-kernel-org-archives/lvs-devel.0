From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ipvs: fix ipv6 route unreach panic
Date: Fri, 26 Jun 2015 03:18:45 -0700
Message-ID: <1435313925-107850-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=HqJREUgNrk+dnqBO+QNPp6t1u1dKtrZs7qKTbdjkBGw=;
 b=OY7spOmWZ96h76BTeOnNDwpAia3Y3Y83fQfddrZE9hTTXk2+yxDAdpkZQiAk5K6jET39
 euAz5lebqHdkmHgMviOSkmeyNCcb2+4qF+X5LBMDw9p9W88RRPG1S7Dt/0WFJZgdDoID
 iRCDGv3+SU5WS4h/o3MBFrH/ncmy9KTA6tQ= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Previously there was a trivial panic

unshare -n /bin/bash <<EOF
ip addr add dev lo face::1/128
ipvsadm -A -t [face::1]:15213
ipvsadm -a -t [face::1]:15213 -r b00c::1
echo boom | nc face::1 15213
EOF

This patch allows us to replicate the net logic above and simply capture
the skb_dst(skb)->dev and use that for the purpose of the invocation.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index bf66a86..b99d806 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -505,6 +505,13 @@ err_put:
 	return -1;
 
 err_unreach:
+	/* The ip6_link_failure function requires the dev field to be set
+	 * in order to get the net (further for the sake of fwmark
+	 * reflection).
+	 */
+	if (!skb->dev)
+		skb->dev = skb_dst(skb)->dev;
+
 	dst_link_failure(skb);
 	return -1;
 }
-- 
Alex Gartrell <agartrell@fb.com>

