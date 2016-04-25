From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/9] rtnl: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:14 +0200
Message-ID: <1461572722-6029-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org, pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, johannes@sipsolutions.net, linux-wireless@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 36 ++++++++++++++++++------------------
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ba69d4447249..5fdd3a42e377 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -666,6 +666,7 @@ enum {
 	IFLA_VF_STATS_TX_BYTES,
 	IFLA_VF_STATS_BROADCAST,
 	IFLA_VF_STATS_MULTICAST,
+	IFLA_VF_STATS_PAD,
 	__IFLA_VF_STATS_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5ec059d52823..9efc1f34ef3b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -825,17 +825,17 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			 nla_total_size(sizeof(struct ifla_vf_link_state)) +
 			 nla_total_size(sizeof(struct ifla_vf_rss_query_en)) +
 			 /* IFLA_VF_STATS_RX_PACKETS */
-			 nla_total_size(sizeof(__u64)) +
+			 nla_total_size_64bit(sizeof(__u64)) +
 			 /* IFLA_VF_STATS_TX_PACKETS */
-			 nla_total_size(sizeof(__u64)) +
+			 nla_total_size_64bit(sizeof(__u64)) +
 			 /* IFLA_VF_STATS_RX_BYTES */
-			 nla_total_size(sizeof(__u64)) +
+			 nla_total_size_64bit(sizeof(__u64)) +
 			 /* IFLA_VF_STATS_TX_BYTES */
-			 nla_total_size(sizeof(__u64)) +
+			 nla_total_size_64bit(sizeof(__u64)) +
 			 /* IFLA_VF_STATS_BROADCAST */
-			 nla_total_size(sizeof(__u64)) +
+			 nla_total_size_64bit(sizeof(__u64)) +
 			 /* IFLA_VF_STATS_MULTICAST */
-			 nla_total_size(sizeof(__u64)) +
+			 nla_total_size_64bit(sizeof(__u64)) +
 			 nla_total_size(sizeof(struct ifla_vf_trust)));
 		return size;
 	} else
@@ -1153,18 +1153,18 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 		nla_nest_cancel(skb, vfinfo);
 		return -EMSGSIZE;
 	}
-	if (nla_put_u64(skb, IFLA_VF_STATS_RX_PACKETS,
-			vf_stats.rx_packets) ||
-	    nla_put_u64(skb, IFLA_VF_STATS_TX_PACKETS,
-			vf_stats.tx_packets) ||
-	    nla_put_u64(skb, IFLA_VF_STATS_RX_BYTES,
-			vf_stats.rx_bytes) ||
-	    nla_put_u64(skb, IFLA_VF_STATS_TX_BYTES,
-			vf_stats.tx_bytes) ||
-	    nla_put_u64(skb, IFLA_VF_STATS_BROADCAST,
-			vf_stats.broadcast) ||
-	    nla_put_u64(skb, IFLA_VF_STATS_MULTICAST,
-			vf_stats.multicast))
+	if (nla_put_u64_64bit(skb, IFLA_VF_STATS_RX_PACKETS,
+			      vf_stats.rx_packets, IFLA_VF_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, IFLA_VF_STATS_TX_PACKETS,
+			      vf_stats.tx_packets, IFLA_VF_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, IFLA_VF_STATS_RX_BYTES,
+			      vf_stats.rx_bytes, IFLA_VF_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, IFLA_VF_STATS_TX_BYTES,
+			      vf_stats.tx_bytes, IFLA_VF_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, IFLA_VF_STATS_BROADCAST,
+			      vf_stats.broadcast, IFLA_VF_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, IFLA_VF_STATS_MULTICAST,
+			      vf_stats.multicast, IFLA_VF_STATS_PAD))
 		return -EMSGSIZE;
 	nla_nest_end(skb, vfstats);
 	nla_nest_end(skb, vf);
-- 
2.8.1

