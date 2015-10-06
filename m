From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 02/15] xfrm: Only compute net once in xfrm_policy_queue_process
Date: Tue,  6 Oct 2015 13:53:02 -0500
Message-ID: <1444157595-28816-2-git-send-email-ebiederm@xmission.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/xfrm/xfrm_policy.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 418daa038edf..be1776bc5673 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1887,6 +1887,7 @@ static void xfrm_policy_queue_process(unsigned long arg)
 	struct sock *sk;
 	struct dst_entry *dst;
 	struct xfrm_policy *pol = (struct xfrm_policy *)arg;
+	struct net *net = xp_net(pol);
 	struct xfrm_policy_queue *pq = &pol->polq;
 	struct flowi fl;
 	struct sk_buff_head list;
@@ -1903,8 +1904,7 @@ static void xfrm_policy_queue_process(unsigned long arg)
 	spin_unlock(&pq->hold_queue.lock);
 
 	dst_hold(dst->path);
-	dst = xfrm_lookup(xp_net(pol), dst->path, &fl,
-			  sk, 0);
+	dst = xfrm_lookup(net, dst->path, &fl, sk, 0);
 	if (IS_ERR(dst))
 		goto purge_queue;
 
@@ -1934,8 +1934,7 @@ static void xfrm_policy_queue_process(unsigned long arg)
 
 		xfrm_decode_session(skb, &fl, skb_dst(skb)->ops->family);
 		dst_hold(skb_dst(skb)->path);
-		dst = xfrm_lookup(xp_net(pol), skb_dst(skb)->path,
-				  &fl, skb->sk, 0);
+		dst = xfrm_lookup(net, skb_dst(skb)->path, &fl, skb->sk, 0);
 		if (IS_ERR(dst)) {
 			kfree_skb(skb);
 			continue;
-- 
2.2.1
