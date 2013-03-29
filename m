From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 03/34] ipvs: prefer NETDEV_DOWN event to free cached dsts
Date: Fri, 29 Mar 2013 13:11:20 +0900
Message-ID: <1364530311-11512-4-git-send-email-horms@verge.net.au>
References: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

The real server becomes unreachable on down event,
no need to wait device unregistration. Should help in
releasing dsts early before dst->dev is replaced with lo.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 8104120..6b55ba6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1514,10 +1514,8 @@ __ip_vs_dev_reset(struct ip_vs_dest *dest, struct net_device *dev)
 	spin_unlock_bh(&dest->dst_lock);
 
 }
-/*
- * Netdev event receiver
- * Currently only NETDEV_UNREGISTER is handled, i.e. if we hold a reference to
- * a device that is "unregister" it must be released.
+/* Netdev event receiver
+ * Currently only NETDEV_DOWN is handled to release refs to cached dsts
  */
 static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
@@ -1529,7 +1527,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	struct ip_vs_dest *dest;
 	unsigned int idx;
 
-	if (event != NETDEV_UNREGISTER || !ipvs)
+	if (event != NETDEV_DOWN || !ipvs)
 		return NOTIFY_DONE;
 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
 	EnterFunction(2);
-- 
1.7.10.4

