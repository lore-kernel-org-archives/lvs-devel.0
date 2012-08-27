From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 1/2] ipvs: IPv6 MTU checking cleanup and bugfix
Date: Mon, 27 Aug 2012 16:40:54 +0200
Message-ID: <20120827144040.5754.64302.stgit@dragon>
References: <20120827144024.5754.23872.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120827144024.5754.23872.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

Cleaning up the IPv6 MTU checking in the IPVS xmit code, by using
a common helper function __mtu_check_toobig_v6().  The MTU check
for tunnel mode is special, and does not use this helper.

Notice, this also fixes a bug, as the the MTU check in ip_vs_dr_xmit_v6()
were missing a check for skb_is_gso().

This e.g. caused issues for KVM IPVS setups, where different
Segmentation Offloading techniques are utilized, between guests,
via the virtio driver.  This resulted in very bad performance,
due to the ICMPv6 "too big" messages didn't affect the sender.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/netfilter/ipvs/ip_vs_xmit.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 543a554..e56f0df 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -85,6 +85,15 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
 	return dst;
 }
 
+static inline bool
+__mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
+{
+	if (skb->len > mtu && !skb_is_gso(skb)) {
+		return true; /* Packet size violate MTU size */
+	}
+	return false;
+}
+
 /* Get route to daddr, update *saddr, optionally bind route to saddr */
 static struct rtable *do_output_route4(struct net *net, __be32 daddr,
 				       u32 rtos, int rt_mode, __be32 *saddr)
@@ -491,7 +500,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu && !skb_is_gso(skb)) {
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -712,7 +721,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu && !skb_is_gso(skb)) {
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -946,6 +955,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb_dst(skb))
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
+	/* MTU checking: Special for tunnel mode */
 	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
 	    !skb_is_gso(skb)) {
 		if (!skb->dev) {
@@ -1113,7 +1123,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -1349,7 +1359,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu && !skb_is_gso(skb)) {
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 

