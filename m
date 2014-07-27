From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC] GSO: Questions for IPVS and GSO for IPv6
Date: Sun, 27 Jul 2014 10:21:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407270957400.2036@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, kernel-team <Kernel-team@fb.com>


	Hello,

	IPVS (IP Virtual Server) has a sending mode to
encapsulate IPv6 packet in a new IPv6 header (like ip6ip6 tunnel).
As IPVS is lacking skb->encapsulation support we are trying to
call iptunnel_handle_offloads() with some SKB_GSO_ value,
SKB_GSO_SIT looking the only available option.

	IPVS works by catching packets at LOCAL_IN (GRO
is possible) and injecting them via ip_local_out() and
ip6_local_out() after adding new IPIP or IPV6 header.
Draft patch is appended for comments.

	We have the following questions:

- Is it correct to provide SKB_GSO_SIT to iptunnel_handle_offloads()
for the case when we add IPPROTO_IPV6 header, I see
(SKB_GSO_SIT|SKB_GSO_IPIP) check in ipv6_gso_segment() that
may need to account network headers. Or we have to add
SKB_GSO_IPV6 with same value like SKB_GSO_SIT, in case the
SIT name looks confusing for ip6ip6 mode and to register
it in inet6_offloads?

	Questions not related to IPVS:

- I guess ipv6_gro_receive() does not support GRO for
IPPROTO_IPV6 in IPPROTO_IPV6 because IPPROTO_IPV6 is not
registered in inet6_offloads list?

- is it correct ip6_tnl_xmit2() to use
skb->transport_header = skb->network_header before calling
skb_reset_inner_headers() ? skb->inner_transport_header will
get wrong value? I guess this is bad for HW csum offload?

Thanks!

[PATCH net] ipvs: properly declare tunnel encapsulation

The tunneling method should properly use tunnel encapsulation.
Fixes problem with CHECKSUM_PARTIAL packets when TCP/UDP csum
offload is supported.

Thanks to Alex Gartrell for reporting the problem, providing
solution and for all suggestions.

Reported-by: Alex Gartrell <agartrell@fb.com>
TODO: waiting for final ack from Alex before adding Signed-off-by line
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 73ba1cc..8c1172c 100644
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
@@ -862,14 +863,19 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
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
+	skb_clear_hash(skb);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -900,7 +906,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	return NF_STOLEN;
 
   tx_error:
-	kfree_skb(skb);
+	if (!IS_ERR(skb))
+		kfree_skb(skb);
 	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -953,6 +960,10 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ipv6_hdr(skb);
 	}
 
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
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
1.9.0

