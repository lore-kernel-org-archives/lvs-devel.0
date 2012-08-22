From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH] ipvs: Fix GSO support for IPVS DR IPv6 mode
Date: Wed, 22 Aug 2012 13:11:18 +0200
Message-ID: <20120822111040.29174.4871.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

The MTU check in ip_vs_dr_xmit_v6() were missing a
check for skb_is_gso().

This e.g. caused issues for KVM IPVS setups, where different
Segmentation Offloading techniques are utilized, between guests,
via the virtio driver.  This resulted in very bad performance,
due to the ICMPv6 "too big" messages didn't affect the sender.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
To Simon,
This should perhaps go to stable?
The patch is based on ipvs-next, but will apply on ipvs with an offset.
Jesper

 net/netfilter/ipvs/ip_vs_xmit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 543a554..80c3006 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1113,7 +1113,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb))) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 

