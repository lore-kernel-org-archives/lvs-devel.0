From: junwei.zhang@6wind.com
Subject: [PATCH v2 net-next 2/2] netns: exclude ipvs from struct net when IPVS disabled
Date: Wed, 26 Jun 2013 16:40:06 +0800
Message-ID: <1372236006-16683-2-git-send-email-junwei.zhang@6wind.com>
References: <20130624.002401.1459814761780281188.davem@davemloft.net>
 <1372236006-16683-1-git-send-email-junwei.zhang@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1372236006-16683-1-git-send-email-junwei.zhang@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, nicolas.dichtel@6wind.com, JunweiZhang <junwei.zhang@6wind.com>

From: JunweiZhang <junwei.zhang@6wind.com>

no real problem is fixed, just save a few bytes in
net_namespace structure.

Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Reviewed-by: Julian Anastasov <ja@ssi.bg>

---
v2: rebase on net-next
 include/net/net_namespace.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 495bc57..84e37b1 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -115,7 +115,9 @@ struct net {
 #ifdef CONFIG_XFRM
 	struct netns_xfrm	xfrm;
 #endif
+#if IS_ENABLED(CONFIG_IP_VS)
 	struct netns_ipvs	*ipvs;
+#endif
 	struct sock		*diag_nlsk;
 	atomic_t		rt_genid;
 	atomic_t		fnhe_genid;
-- 
1.8.1.2
