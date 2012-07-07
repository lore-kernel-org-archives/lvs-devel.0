From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipvs: fix oops in ip_vs_dst_event on rmmod
Date: Sat,  7 Jul 2012 20:30:11 +0300
Message-ID: <1341682211-4751-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	After commit 39f618b4fd95ae243d940ec64c961009c74e3333 (3.4)
"ipvs: reset ipvs pointer in netns" we can oops in
ip_vs_dst_event on rmmod ip_vs because ip_vs_control_cleanup
is called after the ipvs_core_ops subsys is unregistered and
net->ipvs is NULL. Fix it by exiting early from ip_vs_dst_event
if ipvs is NULL. It is safe because all services and dests
for the net are already freed.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index dd811b8..b4a21d9 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1521,11 +1521,12 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = ptr;
 	struct net *net = dev_net(dev);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_service *svc;
 	struct ip_vs_dest *dest;
 	unsigned int idx;
 
-	if (event != NETDEV_UNREGISTER)
+	if (event != NETDEV_UNREGISTER || !ipvs)
 		return NOTIFY_DONE;
 	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
 	EnterFunction(2);
@@ -1551,7 +1552,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 		}
 	}
 
-	list_for_each_entry(dest, &net_ipvs(net)->dest_trash, n_list) {
+	list_for_each_entry(dest, &ipvs->dest_trash, n_list) {
 		__ip_vs_dev_reset(dest, dev);
 	}
 	mutex_unlock(&__ip_vs_mutex);
-- 
1.7.3.4

