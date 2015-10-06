From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 12/15] ipvlan: Cache net in ipvlan_process_v4_outbound and ipvlan_process_v6_outbound
Date: Tue,  6 Oct 2015 13:53:12 -0500
Message-ID: <1444157595-28816-12-git-send-email-ebiederm@xmission.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Compute net once in ipvlan_process_v4_outbound and ipvlan_process_v6_outbound
and store it in a variable so that net does not need to be recomputed next time
it is used.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 75dcf36c0366..976f30b291f6 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -344,6 +344,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 {
 	const struct iphdr *ip4h = ip_hdr(skb);
 	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
 	struct rtable *rt;
 	int err, ret = NET_XMIT_DROP;
 	struct flowi4 fl4 = {
@@ -354,7 +355,7 @@ static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 		.saddr = ip4h->saddr,
 	};
 
-	rt = ip_route_output_flow(dev_net(dev), &fl4, NULL);
+	rt = ip_route_output_flow(net, &fl4, NULL);
 	if (IS_ERR(rt))
 		goto err;
 
@@ -381,6 +382,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
 	struct dst_entry *dst;
 	int err, ret = NET_XMIT_DROP;
 	struct flowi6 fl6 = {
@@ -393,7 +395,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 		.flowi6_proto = ip6h->nexthdr,
 	};
 
-	dst = ip6_route_output(dev_net(dev), NULL, &fl6);
+	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst->error) {
 		ret = dst->error;
 		dst_release(dst);
-- 
2.2.1

