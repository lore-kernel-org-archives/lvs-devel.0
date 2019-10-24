From: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH trivial] net: Fix various misspellings of "connect"
Date: Thu, 24 Oct 2019 17:23:23 +0200
Message-ID: <20191024152323.29987-1-geert+renesas@glider.be>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Ping-Ke Shih <pkshih-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, Wensong Zhang <wensong-ud5FBsm0p/xg9hUCZPvPmw@public.gmane.org>, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>, Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>, Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Jozsef Kadlecsik <kadlec-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>

Fix misspellings of "disconnect", "disconnecting", "connections", and
"disconnected".

Signed-off-by: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
---
 drivers/net/wimax/i2400m/usb.c                      | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c | 4 ++--
 include/net/cfg80211.h                              | 2 +-
 net/netfilter/ipvs/ip_vs_ovf.c                      | 2 +-
 net/wireless/reg.h                                  | 2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 6953f904232f8d9b..9659f9e1aaa64c8a 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -511,7 +511,7 @@ int i2400mu_probe(struct usb_interface *iface,
 
 
 /*
- * Disconect a i2400m from the system.
+ * Disconnect a i2400m from the system.
  *
  * i2400m_stop() has been called before, so al the rx and tx contexts
  * have been taken down already. Make sure the queue is stopped,
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
index 6d6e8994460d90ba..81313e0ca83411f7 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c
@@ -1352,9 +1352,9 @@ static void _rtl92s_phy_set_rfhalt(struct ieee80211_hw *hw)
 	/* SW/HW radio off or halt adapter!! For example S3/S4 */
 	} else {
 		/* LED function disable. Power range is about 8mA now. */
-		/* if write 0xF1 disconnet_pci power
+		/* if write 0xF1 disconnect_pci power
 		 *	 ifconfig wlan0 down power are both high 35:70 */
-		/* if write oxF9 disconnet_pci power
+		/* if write oxF9 disconnect_pci power
 		 * ifconfig wlan0 down power are both low  12:45*/
 		rtl_write_byte(rtlpriv, 0x03, 0xF9);
 	}
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 4ab2c49423dcba4b..ab6850bbba995e15 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -6593,7 +6593,7 @@ struct cfg80211_roam_info {
  * time it is accessed in __cfg80211_roamed() due to delay in scheduling
  * rdev->event_work. In case of any failures, the reference is released
  * either in cfg80211_roamed() or in __cfg80211_romed(), Otherwise, it will be
- * released while diconneting from the current bss.
+ * released while disconnecting from the current bss.
  */
 void cfg80211_roamed(struct net_device *dev, struct cfg80211_roam_info *info,
 		     gfp_t gfp);
diff --git a/net/netfilter/ipvs/ip_vs_ovf.c b/net/netfilter/ipvs/ip_vs_ovf.c
index 78b074cd54646923..c03066fdd5ca69a3 100644
--- a/net/netfilter/ipvs/ip_vs_ovf.c
+++ b/net/netfilter/ipvs/ip_vs_ovf.c
@@ -5,7 +5,7 @@
  * Authors:     Raducu Deaconu <rhadoo_io-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
  *
  * Scheduler implements "overflow" loadbalancing according to number of active
- * connections , will keep all conections to the node with the highest weight
+ * connections , will keep all connections to the node with the highest weight
  * and overflow to the next node if the number of connections exceeds the node's
  * weight.
  * Note that this scheduler might not be suitable for UDP because it only uses
diff --git a/net/wireless/reg.h b/net/wireless/reg.h
index dc8f689bd46902af..f9e83031a40a5eb3 100644
--- a/net/wireless/reg.h
+++ b/net/wireless/reg.h
@@ -114,7 +114,7 @@ void regulatory_hint_country_ie(struct wiphy *wiphy,
 			 u8 country_ie_len);
 
 /**
- * regulatory_hint_disconnect - informs all devices have been disconneted
+ * regulatory_hint_disconnect - informs all devices have been disconnected
  *
  * Regulotory rules can be enhanced further upon scanning and upon
  * connection to an AP. These rules become stale if we disconnect
-- 
2.17.1

