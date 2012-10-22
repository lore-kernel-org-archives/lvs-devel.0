From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [nf-next PATCH] ipvs: fix build error when CONFIG_IP_VS_IPV6 is
	disabled
Date: Mon, 22 Oct 2012 14:17:11 +0200
Message-ID: <20121022121711.31397.6231.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, fengguang.wu@intel.com, yuanhan.liu@linux.intel.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

From: Yuanhan Liu <yuanhan.liu@linux.intel.com>

Fix build error introduced by commit 63dca2c0:
 "ipvs: Fix faulty IPv6 extension header handling in IPVS"

The build error only occur, when CONFIG_IP_VS_IPV6 is disabled.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/ip_vs.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a681ad6..d930749 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
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

