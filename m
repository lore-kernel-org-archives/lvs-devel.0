From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 01/12] ipvs: fix CHECKSUM_PARTIAL for TCP, UDP
Date: Sun, 17 Oct 2010 16:14:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171612240.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Fix CHECKSUM_PARTIAL handling. Tested for IPv4 TCP,
UDP not tested because it needs network card with HW CSUM support.
May be fixes problem where IPVS can not be used in virtual boxes.
Problem appears with DNAT to local address when the local stack
sends reply in CHECKSUM_PARTIAL mode.

 	Fix tcp_dnat_handler and udp_dnat_handler to provide
vaddr and daddr in right order (old and new IP) when calling
tcp_partial_csum_update/udp_partial_csum_update (CHECKSUM_PARTIAL).

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c linux/net/netfilter/ipvs/ip_vs_proto_tcp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_tcp.c	2010-10-16 12:40:42.565354671 +0300
@@ -101,15 +101,15 @@ tcp_partial_csum_update(int af, struct t
  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6)
  		tcph->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+			~csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
  					 ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(tcph->check))));
+						csum_unfold(tcph->check))));
  	else
  #endif
  	tcph->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+		~csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
  				ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(tcph->check))));
+						csum_unfold(tcph->check))));
  }


@@ -223,7 +223,7 @@ tcp_dnat_handler(struct sk_buff *skb,
  	 *	Adjust TCP checksums
  	 */
  	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
+		tcp_partial_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
  					htons(oldlen),
  					htons(skb->len - tcphoff));
  	} else if (!cp->app) {
diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_udp.c linux/net/netfilter/ipvs/ip_vs_proto_udp.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_proto_udp.c	2010-10-16 12:40:42.566354727 +0300
@@ -102,15 +102,15 @@ udp_partial_csum_update(int af, struct u
  #ifdef CONFIG_IP_VS_IPV6
  	if (af == AF_INET6)
  		uhdr->check =
-			csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
+			~csum_fold(ip_vs_check_diff16(oldip->ip6, newip->ip6,
  					 ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(uhdr->check))));
+						csum_unfold(uhdr->check))));
  	else
  #endif
  	uhdr->check =
-		csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
+		~csum_fold(ip_vs_check_diff4(oldip->ip, newip->ip,
  				ip_vs_check_diff2(oldlen, newlen,
-						~csum_unfold(uhdr->check))));
+						csum_unfold(uhdr->check))));
  }


@@ -229,7 +229,7 @@ udp_dnat_handler(struct sk_buff *skb,
  	 *	Adjust UDP checksums
  	 */
  	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
+		udp_partial_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
  					htons(oldlen),
  					htons(skb->len - udphoff));
  	} else if (!cp->app && (udph->check != 0)) {
