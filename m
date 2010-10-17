From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 08/12] ipvs: move ip_route_me_harder for ICMP
Date: Sun, 17 Oct 2010 16:35:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171632300.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Currently, ip_route_me_harder after ip_vs_out_icmp
is called even if packet is not related to IPVS connection.
Move it into handle_response_icmp. Also, force rerouting
if sending to local client because IPv4 stack uses addresses
from the route.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 17:18:47.290355715 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-10-16 17:51:57.252355662 +0300
@@ -702,6 +702,17 @@ static int handle_response_icmp(int af,
  #endif
  		ip_vs_nat_icmp(skb, pp, cp, 1);

+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (sysctl_ip_vs_snat_reroute && ip6_route_me_harder(skb) != 0)
+			goto out;
+	} else
+#endif
+		if ((sysctl_ip_vs_snat_reroute ||
+		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
+		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
+			goto out;
+
  	/* do the statistics and put it back */
  	ip_vs_out_stats(cp, skb);

@@ -940,16 +951,16 @@ handle_response(int af, struct sk_buff *
  	 * if it came from this machine itself.  So re-compute
  	 * the routing information.
  	 */
-	if (sysctl_ip_vs_snat_reroute) {
  #ifdef CONFIG_IP_VS_IPV6
-		if (af == AF_INET6) {
-			if (ip6_route_me_harder(skb) != 0)
-				goto drop;
-		} else
+	if (af == AF_INET6) {
+		if (sysctl_ip_vs_snat_reroute && ip6_route_me_harder(skb) != 0)
+			goto drop;
+	} else
  #endif
-			if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
-				goto drop;
-	}
+		if ((sysctl_ip_vs_snat_reroute ||
+		     skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
+		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
+			goto drop;

  	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");

@@ -1001,13 +1012,8 @@ ip_vs_out(unsigned int hooknum, struct s
  			int verdict = ip_vs_out_icmp_v6(skb, &related,
  							hooknum);

-			if (related) {
-				if (sysctl_ip_vs_snat_reroute &&
-					NF_ACCEPT == verdict &&
-					ip6_route_me_harder(skb))
-					verdict = NF_DROP;
+			if (related)
  				return verdict;
-			}
  			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
  		}
  	} else
@@ -1016,13 +1022,8 @@ ip_vs_out(unsigned int hooknum, struct s
  			int related;
  			int verdict = ip_vs_out_icmp(skb, &related, hooknum);

-			if (related) {
-				if (sysctl_ip_vs_snat_reroute &&
-					NF_ACCEPT == verdict &&
-					ip_route_me_harder(skb, RTN_LOCAL))
-					verdict = NF_DROP;
+			if (related)
  				return verdict;
-			}
  			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
  		}

