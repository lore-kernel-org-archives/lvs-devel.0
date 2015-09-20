From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 82/84] ipvs: Remove skb_net
Date: Sun, 20 Sep 2015 01:23:38 -0500
Message-ID: <1442730220-32458-82-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

This hack has no more users so remove it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h | 31 -------------------------------
 1 file changed, 31 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 00318d63a565..d621330d423c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -38,37 +38,6 @@ static inline struct netns_ipvs *net_ipvs(struct net* net)
 	return net->ipvs;
 }
 
-/* Get net ptr from skb in traffic cases
- * use skb_sknet when call is from userland (ioctl or netlink)
- */
-static inline struct net *skb_net(const struct sk_buff *skb)
-{
-#ifdef CONFIG_NET_NS
-#ifdef CONFIG_IP_VS_DEBUG
-	/*
-	 * This is used for debug only.
-	 * Start with the most likely hit
-	 * End with BUG
-	 */
-	if (likely(skb->dev && dev_net(skb->dev)))
-		return dev_net(skb->dev);
-	if (skb_dst(skb) && skb_dst(skb)->dev)
-		return dev_net(skb_dst(skb)->dev);
-	WARN(skb->sk, "Maybe skb_sknet should be used in %s() at line:%d\n",
-		      __func__, __LINE__);
-	if (likely(skb->sk && sock_net(skb->sk)))
-		return sock_net(skb->sk);
-	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
-		__func__, __LINE__);
-	BUG();
-#else
-	return dev_net(skb->dev ? : skb_dst(skb)->dev);
-#endif
-#else
-	return &init_net;
-#endif
-}
-
 static inline struct net *skb_sknet(const struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_NS
-- 
2.2.1
