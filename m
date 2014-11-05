From: Calvin Owens <calvinowens@fb.com>
Subject: [PATCH] ipvs: Keep skb->sk when allocating headroom on tunnel xmit
Date: Tue, 4 Nov 2014 16:37:40 -0800
Message-ID: <1415147860-11389-1-git-send-email-calvinowens@fb.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=rRkr7nQDah1XqWQkbOHdDw5voPCHuhX/HXfXQLdZzxA=;
 b=Egw1HWQlueDhJkJvzrtU/xX97yykq2d8tpYkUHaROF1FST3GKVUvE4TaFU0vXam1qqT9
 8cO11S72T1acg9FrfC1jubQgxJmRRhEuFx3UxlrtBCiu5K1Qs93KDvFX/4bXs1pm8y10
 4S46APBgdlREYiIdxDYRmcEPWsNj49oRPGU= 
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com, Calvin Owens <calvinowens@fb.com>

ip_vs_prepare_tunneled_skb() ignores ->sk when allocating a new
skb, either unconditionally setting ->sk to NULL or allowing
the uninitialized ->sk from a newly allocated skb to leak through
to the caller.

This patch properly copies ->sk and increments its reference count.

Signed-off-by: Calvin Owens <calvinowens@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 437a366..bd90bf8 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -846,6 +846,8 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
 		new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb)
 			goto error;
+		if (skb->sk)
+			skb_set_owner_w(new_skb, skb->sk);
 		consume_skb(skb);
 		skb = new_skb;
 	}
-- 
2.1.1
