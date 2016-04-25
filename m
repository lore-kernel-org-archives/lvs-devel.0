From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 7/9] ieee802154: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:20 +0200
Message-ID: <1461572722-6029-8-git-send-email-nicolas.dichtel@6wind.com>
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
 include/linux/nl802154.h  |  2 ++
 net/ieee802154/nl-mac.c   | 17 +++++++++++------
 net/ieee802154/nl802154.c |  3 ++-
 3 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 167342c2ce6b..0f6f6607f592 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -92,6 +92,8 @@ enum {
 	IEEE802154_ATTR_LLSEC_DEV_OVERRIDE,
 	IEEE802154_ATTR_LLSEC_DEV_KEY_MODE,
 
+	IEEE802154_ATTR_PAD,
+
 	__IEEE802154_ATTR_MAX,
 };
 
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index 3503c38954f9..d3cbb3258718 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -34,9 +34,11 @@
 
 #include "ieee802154.h"
 
-static int nla_put_hwaddr(struct sk_buff *msg, int type, __le64 hwaddr)
+static int nla_put_hwaddr(struct sk_buff *msg, int type, __le64 hwaddr,
+			  int padattr)
 {
-	return nla_put_u64(msg, type, swab64((__force u64)hwaddr));
+	return nla_put_u64_64bit(msg, type, swab64((__force u64)hwaddr),
+				 padattr);
 }
 
 static __le64 nla_get_hwaddr(const struct nlattr *nla)
@@ -623,7 +625,8 @@ ieee802154_llsec_fill_key_id(struct sk_buff *msg,
 
 		if (desc->device_addr.mode == IEEE802154_ADDR_LONG &&
 		    nla_put_hwaddr(msg, IEEE802154_ATTR_HW_ADDR,
-				   desc->device_addr.extended_addr))
+				   desc->device_addr.extended_addr,
+				   IEEE802154_ATTR_PAD))
 			return -EMSGSIZE;
 	}
 
@@ -638,7 +641,7 @@ ieee802154_llsec_fill_key_id(struct sk_buff *msg,
 
 	if (desc->mode == IEEE802154_SCF_KEY_HW_INDEX &&
 	    nla_put_hwaddr(msg, IEEE802154_ATTR_LLSEC_KEY_SOURCE_EXTENDED,
-			   desc->extended_source))
+			   desc->extended_source, IEEE802154_ATTR_PAD))
 		return -EMSGSIZE;
 
 	return 0;
@@ -1063,7 +1066,8 @@ ieee802154_nl_fill_dev(struct sk_buff *msg, u32 portid, u32 seq,
 	    nla_put_shortaddr(msg, IEEE802154_ATTR_PAN_ID, desc->pan_id) ||
 	    nla_put_shortaddr(msg, IEEE802154_ATTR_SHORT_ADDR,
 			      desc->short_addr) ||
-	    nla_put_hwaddr(msg, IEEE802154_ATTR_HW_ADDR, desc->hwaddr) ||
+	    nla_put_hwaddr(msg, IEEE802154_ATTR_HW_ADDR, desc->hwaddr,
+			   IEEE802154_ATTR_PAD) ||
 	    nla_put_u32(msg, IEEE802154_ATTR_LLSEC_FRAME_COUNTER,
 			desc->frame_counter) ||
 	    nla_put_u8(msg, IEEE802154_ATTR_LLSEC_DEV_OVERRIDE,
@@ -1167,7 +1171,8 @@ ieee802154_nl_fill_devkey(struct sk_buff *msg, u32 portid, u32 seq,
 
 	if (nla_put_string(msg, IEEE802154_ATTR_DEV_NAME, dev->name) ||
 	    nla_put_u32(msg, IEEE802154_ATTR_DEV_INDEX, dev->ifindex) ||
-	    nla_put_hwaddr(msg, IEEE802154_ATTR_HW_ADDR, devaddr) ||
+	    nla_put_hwaddr(msg, IEEE802154_ATTR_HW_ADDR, devaddr,
+			   IEEE802154_ATTR_PAD) ||
 	    nla_put_u32(msg, IEEE802154_ATTR_LLSEC_FRAME_COUNTER,
 			devkey->frame_counter) ||
 	    ieee802154_llsec_fill_key_id(msg, &devkey->key_id))
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index 614072064d03..8035c93dd527 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -813,7 +813,8 @@ nl802154_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 
 	if (nla_put_u32(msg, NL802154_ATTR_WPAN_PHY, rdev->wpan_phy_idx) ||
 	    nla_put_u32(msg, NL802154_ATTR_IFTYPE, wpan_dev->iftype) ||
-	    nla_put_u64(msg, NL802154_ATTR_WPAN_DEV, wpan_dev_id(wpan_dev)) ||
+	    nla_put_u64_64bit(msg, NL802154_ATTR_WPAN_DEV,
+			      wpan_dev_id(wpan_dev), NL802154_ATTR_PAD) ||
 	    nla_put_u32(msg, NL802154_ATTR_GENERATION,
 			rdev->devlist_generation ^
 			(cfg802154_rdev_list_generation << 2)))
-- 
2.8.1

