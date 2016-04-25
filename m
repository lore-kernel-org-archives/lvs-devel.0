From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 8/9] netfilter/ipvs: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:21 +0200
Message-ID: <1461572722-6029-9-git-send-email-nicolas.dichtel@6wind.com>
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
 include/uapi/linux/ip_vs.h     |  1 +
 net/netfilter/ipvs/ip_vs_ctl.c | 36 ++++++++++++++++++++++++------------
 2 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 391395c06c7e..22d69894bc92 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -435,6 +435,7 @@ enum {
 	IPVS_STATS_ATTR_OUTPPS,		/* current out packet rate */
 	IPVS_STATS_ATTR_INBPS,		/* current in byte rate */
 	IPVS_STATS_ATTR_OUTBPS,		/* current out byte rate */
+	IPVS_STATS_ATTR_PAD,
 	__IPVS_STATS_ATTR_MAX,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 404b2a4f4b5b..f35ebc02fa5c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2875,8 +2875,10 @@ static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
 	if (nla_put_u32(skb, IPVS_STATS_ATTR_CONNS, (u32)kstats->conns) ||
 	    nla_put_u32(skb, IPVS_STATS_ATTR_INPKTS, (u32)kstats->inpkts) ||
 	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTPKTS, (u32)kstats->outpkts) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_INBYTES, kstats->inbytes) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTBYTES, kstats->outbytes) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_INBYTES, kstats->inbytes,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_OUTBYTES, kstats->outbytes,
+			      IPVS_STATS_ATTR_PAD) ||
 	    nla_put_u32(skb, IPVS_STATS_ATTR_CPS, (u32)kstats->cps) ||
 	    nla_put_u32(skb, IPVS_STATS_ATTR_INPPS, (u32)kstats->inpps) ||
 	    nla_put_u32(skb, IPVS_STATS_ATTR_OUTPPS, (u32)kstats->outpps) ||
@@ -2900,16 +2902,26 @@ static int ip_vs_genl_fill_stats64(struct sk_buff *skb, int container_type,
 	if (!nl_stats)
 		return -EMSGSIZE;
 
-	if (nla_put_u64(skb, IPVS_STATS_ATTR_CONNS, kstats->conns) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_INPKTS, kstats->inpkts) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTPKTS, kstats->outpkts) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_INBYTES, kstats->inbytes) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTBYTES, kstats->outbytes) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_CPS, kstats->cps) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_INPPS, kstats->inpps) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTPPS, kstats->outpps) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_INBPS, kstats->inbps) ||
-	    nla_put_u64(skb, IPVS_STATS_ATTR_OUTBPS, kstats->outbps))
+	if (nla_put_u64_64bit(skb, IPVS_STATS_ATTR_CONNS, kstats->conns,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_INPKTS, kstats->inpkts,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_OUTPKTS, kstats->outpkts,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_INBYTES, kstats->inbytes,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_OUTBYTES, kstats->outbytes,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_CPS, kstats->cps,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_INPPS, kstats->inpps,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_OUTPPS, kstats->outpps,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_INBPS, kstats->inbps,
+			      IPVS_STATS_ATTR_PAD) ||
+	    nla_put_u64_64bit(skb, IPVS_STATS_ATTR_OUTBPS, kstats->outbps,
+			      IPVS_STATS_ATTR_PAD))
 		goto nla_put_failure;
 	nla_nest_end(skb, nl_stats);
 
-- 
2.8.1

