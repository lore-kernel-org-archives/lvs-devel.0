From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: fix build errors related to config option combinations
Date: Tue, 23 Oct 2012 09:50:51 +0900
Message-ID: <1350953451-19441-2-git-send-email-horms@verge.net.au>
References: <1350953451-19441-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1350953451-19441-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Simon Horman <horms@verge.net.au>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Fix two build error introduced by commit 63dca2c0:
 "ipvs: Fix faulty IPv6 extension header handling in IPVS"

First build error was fairly trivial and can occur, when
CONFIG_IP_VS_IPV6 is disabled.

The second build error was tricky, and can occur when deselecting
both all Netfilter and IPVS, but selecting CONFIG_IPV6.  This is
caused by "kernel/sysctl_binary.c" including "net/ip_vs.h", which
includes "linux/netfilter_ipv6/ip6_tables.h" causing include
of "include/linux/netfilter/x_tables.h" which then cannot find
the typedef nf_hookfn.

Fix this by only including "linux/netfilter_ipv6/ip6_tables.h" in
case of CONFIG_IP_VS_IPV6 as its already used to guard the usage
of ipv6_find_hdr().

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Reported-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a681ad6..68c69d5 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -22,7 +22,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>
-#if IS_ENABLED(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_IP_VS_IPV6)
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #endif
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
@@ -212,8 +212,9 @@ ip_vs_fill_iph_addr_only(int af, const struct sk_buff *skb,
 			(struct ipv6hdr *)skb_network_header(skb);
 		iphdr->saddr.in6 = iph->saddr;
 		iphdr->daddr.in6 = iph->daddr;
-	} else {
+	} else
 #endif
+	{
 		const struct iphdr *iph =
 			(struct iphdr *)skb_network_header(skb);
 		iphdr->saddr.ip = iph->saddr;
-- 
1.7.10.4

