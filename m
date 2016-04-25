From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 6/9] l2tp: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:19 +0200
Message-ID: <1461572722-6029-7-git-send-email-nicolas.dichtel@6wind.com>
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
 include/uapi/linux/l2tp.h |  1 +
 net/l2tp/l2tp_netlink.c   | 80 ++++++++++++++++++++++++++++-------------------
 2 files changed, 49 insertions(+), 32 deletions(-)

diff --git a/include/uapi/linux/l2tp.h b/include/uapi/linux/l2tp.h
index 3386a99e0397..4bd27d0270a2 100644
--- a/include/uapi/linux/l2tp.h
+++ b/include/uapi/linux/l2tp.h
@@ -143,6 +143,7 @@ enum {
 	L2TP_ATTR_RX_SEQ_DISCARDS,	/* u64 */
 	L2TP_ATTR_RX_OOS_PACKETS,	/* u64 */
 	L2TP_ATTR_RX_ERRORS,		/* u64 */
+	L2TP_ATTR_STATS_PAD,
 	__L2TP_ATTR_STATS_MAX,
 };
 
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 24ed2e875c45..1d02e8d20e56 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -346,22 +346,30 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS,
-		    atomic_long_read(&tunnel->stats.tx_packets)) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES,
-		    atomic_long_read(&tunnel->stats.tx_bytes)) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS,
-		    atomic_long_read(&tunnel->stats.tx_errors)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS,
-		    atomic_long_read(&tunnel->stats.rx_packets)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES,
-		    atomic_long_read(&tunnel->stats.rx_bytes)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
-		    atomic_long_read(&tunnel->stats.rx_seq_discards)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
-		    atomic_long_read(&tunnel->stats.rx_oos_packets)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS,
-		    atomic_long_read(&tunnel->stats.rx_errors)))
+	if (nla_put_u64_64bit(skb, L2TP_ATTR_TX_PACKETS,
+			      atomic_long_read(&tunnel->stats.tx_packets),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_TX_BYTES,
+			      atomic_long_read(&tunnel->stats.tx_bytes),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_TX_ERRORS,
+			      atomic_long_read(&tunnel->stats.tx_errors),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_PACKETS,
+			      atomic_long_read(&tunnel->stats.rx_packets),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_BYTES,
+			      atomic_long_read(&tunnel->stats.rx_bytes),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
+			      atomic_long_read(&tunnel->stats.rx_seq_discards),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_OOS_PACKETS,
+			      atomic_long_read(&tunnel->stats.rx_oos_packets),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_ERRORS,
+			      atomic_long_read(&tunnel->stats.rx_errors),
+			      L2TP_ATTR_STATS_PAD))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
@@ -754,22 +762,30 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq, int fl
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS,
-		atomic_long_read(&session->stats.tx_packets)) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES,
-		atomic_long_read(&session->stats.tx_bytes)) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS,
-		atomic_long_read(&session->stats.tx_errors)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS,
-		atomic_long_read(&session->stats.rx_packets)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES,
-		atomic_long_read(&session->stats.rx_bytes)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
-		atomic_long_read(&session->stats.rx_seq_discards)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
-		atomic_long_read(&session->stats.rx_oos_packets)) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS,
-		atomic_long_read(&session->stats.rx_errors)))
+	if (nla_put_u64_64bit(skb, L2TP_ATTR_TX_PACKETS,
+			      atomic_long_read(&session->stats.tx_packets),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_TX_BYTES,
+			      atomic_long_read(&session->stats.tx_bytes),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_TX_ERRORS,
+			      atomic_long_read(&session->stats.tx_errors),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_PACKETS,
+			      atomic_long_read(&session->stats.rx_packets),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_BYTES,
+			      atomic_long_read(&session->stats.rx_bytes),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
+			      atomic_long_read(&session->stats.rx_seq_discards),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_OOS_PACKETS,
+			      atomic_long_read(&session->stats.rx_oos_packets),
+			      L2TP_ATTR_STATS_PAD) ||
+	    nla_put_u64_64bit(skb, L2TP_ATTR_RX_ERRORS,
+			      atomic_long_read(&session->stats.rx_errors),
+			      L2TP_ATTR_STATS_PAD))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
-- 
2.8.1

