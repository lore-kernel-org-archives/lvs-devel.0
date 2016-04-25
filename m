From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 9/9] wireless: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:22 +0200
Message-ID: <1461572722-6029-10-git-send-email-nicolas.dichtel@6wind.com>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org, pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, johannes@sipsolutions.net, linux-wireless@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/nl80211.h |  4 ++
 net/wireless/nl80211.c       | 91 ++++++++++++++++++++++++++------------------
 2 files changed, 59 insertions(+), 36 deletions(-)

diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index 1df655d8aa52..2c55dd1894c3 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -2197,6 +2197,8 @@ enum nl80211_attrs {
 
 	NL80211_ATTR_STA_SUPPORT_P2P_PS,
 
+	NL80211_ATTR_PAD,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
@@ -3023,6 +3025,7 @@ enum nl80211_survey_info {
 	NL80211_SURVEY_INFO_TIME_RX,
 	NL80211_SURVEY_INFO_TIME_TX,
 	NL80211_SURVEY_INFO_TIME_SCAN,
+	NL80211_SURVEY_INFO_PAD,
 
 	/* keep last */
 	__NL80211_SURVEY_INFO_AFTER_LAST,
@@ -3468,6 +3471,7 @@ enum nl80211_bss {
 	NL80211_BSS_BEACON_TSF,
 	NL80211_BSS_PRESP_DATA,
 	NL80211_BSS_LAST_SEEN_BOOTTIME,
+	NL80211_BSS_PAD,
 
 	/* keep last */
 	__NL80211_BSS_AFTER_LAST,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index fd7f34a2b10c..afeb1ef1b199 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2429,7 +2429,8 @@ static int nl80211_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flag
 
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    nla_put_u32(msg, NL80211_ATTR_IFTYPE, wdev->iftype) ||
-	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)) ||
+	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD) ||
 	    nla_put(msg, NL80211_ATTR_MAC, ETH_ALEN, wdev_address(wdev)) ||
 	    nla_put_u32(msg, NL80211_ATTR_GENERATION,
 			rdev->devlist_generation ^
@@ -6874,7 +6875,8 @@ static int nl80211_send_bss(struct sk_buff *msg, struct netlink_callback *cb,
 	if (wdev->netdev &&
 	    nla_put_u32(msg, NL80211_ATTR_IFINDEX, wdev->netdev->ifindex))
 		goto nla_put_failure;
-	if (nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)))
+	if (nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD))
 		goto nla_put_failure;
 
 	bss = nla_nest_start(msg, NL80211_ATTR_BSS);
@@ -6895,7 +6897,8 @@ static int nl80211_send_bss(struct sk_buff *msg, struct netlink_callback *cb,
 	 */
 	ies = rcu_dereference(res->ies);
 	if (ies) {
-		if (nla_put_u64(msg, NL80211_BSS_TSF, ies->tsf))
+		if (nla_put_u64_64bit(msg, NL80211_BSS_TSF, ies->tsf,
+				      NL80211_BSS_PAD))
 			goto fail_unlock_rcu;
 		if (ies->len && nla_put(msg, NL80211_BSS_INFORMATION_ELEMENTS,
 					ies->len, ies->data))
@@ -6905,7 +6908,8 @@ static int nl80211_send_bss(struct sk_buff *msg, struct netlink_callback *cb,
 	/* and this pointer is always (unless driver didn't know) beacon data */
 	ies = rcu_dereference(res->beacon_ies);
 	if (ies && ies->from_beacon) {
-		if (nla_put_u64(msg, NL80211_BSS_BEACON_TSF, ies->tsf))
+		if (nla_put_u64_64bit(msg, NL80211_BSS_BEACON_TSF, ies->tsf,
+				      NL80211_BSS_PAD))
 			goto fail_unlock_rcu;
 		if (ies->len && nla_put(msg, NL80211_BSS_BEACON_IES,
 					ies->len, ies->data))
@@ -6924,8 +6928,8 @@ static int nl80211_send_bss(struct sk_buff *msg, struct netlink_callback *cb,
 		goto nla_put_failure;
 
 	if (intbss->ts_boottime &&
-	    nla_put_u64(msg, NL80211_BSS_LAST_SEEN_BOOTTIME,
-			intbss->ts_boottime))
+	    nla_put_u64_64bit(msg, NL80211_BSS_LAST_SEEN_BOOTTIME,
+			      intbss->ts_boottime, NL80211_BSS_PAD))
 		goto nla_put_failure;
 
 	switch (rdev->wiphy.signal_type) {
@@ -7045,28 +7049,28 @@ static int nl80211_send_survey(struct sk_buff *msg, u32 portid, u32 seq,
 	    nla_put_flag(msg, NL80211_SURVEY_INFO_IN_USE))
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME) &&
-	    nla_put_u64(msg, NL80211_SURVEY_INFO_TIME,
-			survey->time))
+	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME,
+			survey->time, NL80211_SURVEY_INFO_PAD))
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME_BUSY) &&
-	    nla_put_u64(msg, NL80211_SURVEY_INFO_TIME_BUSY,
-			survey->time_busy))
+	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME_BUSY,
+			      survey->time_busy, NL80211_SURVEY_INFO_PAD))
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME_EXT_BUSY) &&
-	    nla_put_u64(msg, NL80211_SURVEY_INFO_TIME_EXT_BUSY,
-			survey->time_ext_busy))
+	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME_EXT_BUSY,
+			      survey->time_ext_busy, NL80211_SURVEY_INFO_PAD))
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME_RX) &&
-	    nla_put_u64(msg, NL80211_SURVEY_INFO_TIME_RX,
-			survey->time_rx))
+	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME_RX,
+			      survey->time_rx, NL80211_SURVEY_INFO_PAD))
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME_TX) &&
-	    nla_put_u64(msg, NL80211_SURVEY_INFO_TIME_TX,
-			survey->time_tx))
+	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME_TX,
+			      survey->time_tx, NL80211_SURVEY_INFO_PAD))
 		goto nla_put_failure;
 	if ((survey->filled & SURVEY_INFO_TIME_SCAN) &&
-	    nla_put_u64(msg, NL80211_SURVEY_INFO_TIME_SCAN,
-			survey->time_scan))
+	    nla_put_u64_64bit(msg, NL80211_SURVEY_INFO_TIME_SCAN,
+			      survey->time_scan, NL80211_SURVEY_INFO_PAD))
 		goto nla_put_failure;
 
 	nla_nest_end(msg, infoattr);
@@ -7786,8 +7790,8 @@ __cfg80211_alloc_vendor_skb(struct cfg80211_registered_device *rdev,
 	}
 
 	if (wdev) {
-		if (nla_put_u64(skb, NL80211_ATTR_WDEV,
-				wdev_id(wdev)))
+		if (nla_put_u64_64bit(skb, NL80211_ATTR_WDEV,
+				      wdev_id(wdev), NL80211_ATTR_PAD))
 			goto nla_put_failure;
 		if (wdev->netdev &&
 		    nla_put_u32(skb, NL80211_ATTR_IFINDEX,
@@ -8380,7 +8384,8 @@ static int nl80211_remain_on_channel(struct sk_buff *skb,
 	if (err)
 		goto free_msg;
 
-	if (nla_put_u64(msg, NL80211_ATTR_COOKIE, cookie))
+	if (nla_put_u64_64bit(msg, NL80211_ATTR_COOKIE, cookie,
+			      NL80211_ATTR_PAD))
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
@@ -8792,7 +8797,8 @@ static int nl80211_tx_mgmt(struct sk_buff *skb, struct genl_info *info)
 		goto free_msg;
 
 	if (msg) {
-		if (nla_put_u64(msg, NL80211_ATTR_COOKIE, cookie))
+		if (nla_put_u64_64bit(msg, NL80211_ATTR_COOKIE, cookie,
+				      NL80211_ATTR_PAD))
 			goto nla_put_failure;
 
 		genlmsg_end(msg, hdr);
@@ -10078,7 +10084,8 @@ static int nl80211_probe_client(struct sk_buff *skb,
 	if (err)
 		goto free_msg;
 
-	if (nla_put_u64(msg, NL80211_ATTR_COOKIE, cookie))
+	if (nla_put_u64_64bit(msg, NL80211_ATTR_COOKIE, cookie,
+			      NL80211_ATTR_PAD))
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
@@ -10503,8 +10510,9 @@ static int nl80211_vendor_cmd_dump(struct sk_buff *skb,
 			break;
 
 		if (nla_put_u32(skb, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
-		    (wdev && nla_put_u64(skb, NL80211_ATTR_WDEV,
-					 wdev_id(wdev)))) {
+		    (wdev && nla_put_u64_64bit(skb, NL80211_ATTR_WDEV,
+					       wdev_id(wdev),
+					       NL80211_ATTR_PAD))) {
 			genlmsg_cancel(skb, hdr);
 			break;
 		}
@@ -11711,7 +11719,8 @@ static int nl80211_send_scan_msg(struct sk_buff *msg,
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    (wdev->netdev && nla_put_u32(msg, NL80211_ATTR_IFINDEX,
 					 wdev->netdev->ifindex)) ||
-	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)))
+	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD))
 		goto nla_put_failure;
 
 	/* ignore errors and send incomplete event anyway */
@@ -12378,11 +12387,13 @@ static void nl80211_send_remain_on_chan_event(
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    (wdev->netdev && nla_put_u32(msg, NL80211_ATTR_IFINDEX,
 					 wdev->netdev->ifindex)) ||
-	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)) ||
+	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD) ||
 	    nla_put_u32(msg, NL80211_ATTR_WIPHY_FREQ, chan->center_freq) ||
 	    nla_put_u32(msg, NL80211_ATTR_WIPHY_CHANNEL_TYPE,
 			NL80211_CHAN_NO_HT) ||
-	    nla_put_u64(msg, NL80211_ATTR_COOKIE, cookie))
+	    nla_put_u64_64bit(msg, NL80211_ATTR_COOKIE, cookie,
+			      NL80211_ATTR_PAD))
 		goto nla_put_failure;
 
 	if (cmd == NL80211_CMD_REMAIN_ON_CHANNEL &&
@@ -12616,7 +12627,8 @@ int nl80211_send_mgmt(struct cfg80211_registered_device *rdev,
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    (netdev && nla_put_u32(msg, NL80211_ATTR_IFINDEX,
 					netdev->ifindex)) ||
-	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)) ||
+	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD) ||
 	    nla_put_u32(msg, NL80211_ATTR_WIPHY_FREQ, freq) ||
 	    (sig_dbm &&
 	     nla_put_u32(msg, NL80211_ATTR_RX_SIGNAL_DBM, sig_dbm)) ||
@@ -12659,9 +12671,11 @@ void cfg80211_mgmt_tx_status(struct wireless_dev *wdev, u64 cookie,
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    (netdev && nla_put_u32(msg, NL80211_ATTR_IFINDEX,
 				   netdev->ifindex)) ||
-	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)) ||
+	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD) ||
 	    nla_put(msg, NL80211_ATTR_FRAME, len, buf) ||
-	    nla_put_u64(msg, NL80211_ATTR_COOKIE, cookie) ||
+	    nla_put_u64_64bit(msg, NL80211_ATTR_COOKIE, cookie,
+			      NL80211_ATTR_PAD) ||
 	    (ack && nla_put_flag(msg, NL80211_ATTR_ACK)))
 		goto nla_put_failure;
 
@@ -13041,7 +13055,8 @@ nl80211_radar_notify(struct cfg80211_registered_device *rdev,
 		struct wireless_dev *wdev = netdev->ieee80211_ptr;
 
 		if (nla_put_u32(msg, NL80211_ATTR_IFINDEX, netdev->ifindex) ||
-		    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)))
+		    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+				      NL80211_ATTR_PAD))
 			goto nla_put_failure;
 	}
 
@@ -13086,7 +13101,8 @@ void cfg80211_probe_status(struct net_device *dev, const u8 *addr,
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    nla_put_u32(msg, NL80211_ATTR_IFINDEX, dev->ifindex) ||
 	    nla_put(msg, NL80211_ATTR_MAC, ETH_ALEN, addr) ||
-	    nla_put_u64(msg, NL80211_ATTR_COOKIE, cookie) ||
+	    nla_put_u64_64bit(msg, NL80211_ATTR_COOKIE, cookie,
+			      NL80211_ATTR_PAD) ||
 	    (acked && nla_put_flag(msg, NL80211_ATTR_ACK)))
 		goto nla_put_failure;
 
@@ -13231,7 +13247,8 @@ void cfg80211_report_wowlan_wakeup(struct wireless_dev *wdev,
 		goto free_msg;
 
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
-	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)))
+	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD))
 		goto free_msg;
 
 	if (wdev->netdev && nla_put_u32(msg, NL80211_ATTR_IFINDEX,
@@ -13506,7 +13523,8 @@ void cfg80211_crit_proto_stopped(struct wireless_dev *wdev, gfp_t gfp)
 		goto nla_put_failure;
 
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
-	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)))
+	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD))
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
@@ -13539,7 +13557,8 @@ void nl80211_send_ap_stopped(struct wireless_dev *wdev)
 
 	if (nla_put_u32(msg, NL80211_ATTR_WIPHY, rdev->wiphy_idx) ||
 	    nla_put_u32(msg, NL80211_ATTR_IFINDEX, wdev->netdev->ifindex) ||
-	    nla_put_u64(msg, NL80211_ATTR_WDEV, wdev_id(wdev)))
+	    nla_put_u64_64bit(msg, NL80211_ATTR_WDEV, wdev_id(wdev),
+			      NL80211_ATTR_PAD))
 		goto out;
 
 	genlmsg_end(msg, hdr);
-- 
2.8.1

