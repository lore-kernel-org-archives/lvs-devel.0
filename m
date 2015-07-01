From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ipvs: orphan_skb in tunnel transmit case
Date: Wed, 1 Jul 2015 13:50:22 -0700
Message-ID: <1435783822-2258560-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=+sjC6LfnR97dPTGEwwI1ZM029Iuj0fk2XkqBeacHo18=;
 b=lIvMS1SSh+0mxb5CdR3EseVl8pDg7QUszHwW1KI2FLpgSQDq+9fyK/Zic4Ww0LqeOCxE
 8BV+JJCMPhTiUkyyu2ZY/r2bsZQFUXDNY4KVwPTjaB9hDtzIkRvK4y/O72jJ3r7QK1EG
 4z1txgazmB8cVg1WeeucEh7vOq2AGz+7rP0= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

It's possible that the sk came from early_demux.  This will blow up every
time in the TCP_TIME_WAIT case in ip_local_out.  No similar crashes exist
for masquerade or gateway because they do not use ip_local_out{,6}.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index bf66a86..1db0ca7 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -521,6 +521,13 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 	if (unlikely(cp->flags & IP_VS_CONN_F_NFCT))
 		ret = ip_vs_confirm_conntrack(skb);
 	if (ret == NF_ACCEPT) {
+		/* In this case, skb is associated with an old, receiving
+		 * socket, which may be in TIME-WAIT and invalid for the
+		 * forward path, so we orphan it.
+		 */
+		if (skb->dev)
+			skb_orphan(skb);
+
 		nf_reset(skb);
 		skb_forward_csum(skb);
 	}
-- 
Alex Gartrell <agartrell@fb.com>

