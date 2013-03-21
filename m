From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net-next 03/15] ipvs: prefer NETDEV_DOWN event to free cached dsts
Date: Thu, 21 Mar 2013 11:58:00 +0200
Message-ID: <1363859892-9058-4-git-send-email-ja@ssi.bg>
References: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	The real server becomes unreachable on down event,
no need to wait device unregistration. Should help in
releasing dsts early before dst->dev is replaced with lo.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 9e2d1cc..1648454 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1512,10 +1512,8 @@ __ip_vs_dev_reset(struct ip_vs_dest *dest, struct net_device *dev)
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
@@ -1527,7 +1525,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	struct ip_vs_dest *dest;
 	unsigned int idx;
 
-	if (event != NETDEV_UNREGISTER || !ipvs)
+	if (event != NETDEV_DOWN || !ipvs)
 		return NOTIFY_DONE;
 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
 	EnterFunction(2);
-- 
1.7.3.4

