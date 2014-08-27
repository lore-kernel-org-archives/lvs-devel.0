From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf] ipvs: properly declare tunnel encapsulation
Date: Wed, 27 Aug 2014 15:15:15 +0900
Message-ID: <1409120115-32053-2-git-send-email-horms@verge.net.au>
References: <1409120115-32053-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1409120115-32053-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

The tunneling method should properly use tunnel encapsulation.
Fixes problem with CHECKSUM_PARTIAL packets when TCP/UDP csum
offload is supported.

Thanks to Alex Gartrell for reporting the problem, providing
solution and for all suggestions.

Reported-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6f70bdd..56896a4 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -38,6 +38,7 @@
 #include <net/route.h>                  /* for ip_route_output */
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/ip_tunnels.h>
 #include <net/addrconf.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
@@ -862,11 +863,15 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ip_hdr(skb);
 	}
 
-	skb->transport_header = skb->network_header;
-
 	/* fix old IP header checksum */
 	ip_send_check(old_iph);
 
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	if (IS_ERR(skb))
+		goto tx_error;
+
+	skb->transport_header = skb->network_header;
+
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
@@ -900,7 +905,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	return NF_STOLEN;
 
   tx_error:
-	kfree_skb(skb);
+	if (!IS_ERR(skb))
+		kfree_skb(skb);
 	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -953,6 +959,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ipv6_hdr(skb);
 	}
 
+	/* GSO: we need to provide proper SKB_GSO_ value for IPv6 */
+	skb = iptunnel_handle_offloads(skb, false, 0); /* SKB_GSO_SIT/IPV6 */
+	if (IS_ERR(skb))
+		goto tx_error;
+
 	skb->transport_header = skb->network_header;
 
 	skb_push(skb, sizeof(struct ipv6hdr));
@@ -988,7 +999,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	return NF_STOLEN;
 
 tx_error:
-	kfree_skb(skb);
+	if (!IS_ERR(skb))
+		kfree_skb(skb);
 	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
-- 
2.0.1
