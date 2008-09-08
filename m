From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Restrict connection table size via Kconfig
Date: Mon, 8 Sep 2008 13:38:11 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0809081332270.18192@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

Instead of checking the value in include/net/ip_vs.h, we can just
restrict the range in our Kconfig file. This will prevent values outside
of the range early.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 include/net/ip_vs.h   |   10 +---------
 net/ipv4/ipvs/Kconfig |    3 ++-
 2 files changed, 3 insertions(+), 10 deletions(-)

Don't know if we really should remove the check in ip_vs.h, but to some 
part we should trust our own code.

Based on lvs-next.

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 1b13cef..38f4f69 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -621,16 +621,8 @@ extern void ip_vs_init_hash_table(struct list_head *table, int rows);
 #ifndef CONFIG_IP_VS_TAB_BITS
 #define CONFIG_IP_VS_TAB_BITS   12
 #endif
-/* make sure that IP_VS_CONN_TAB_BITS is located in [8, 20] */
-#if CONFIG_IP_VS_TAB_BITS < 8
-#define IP_VS_CONN_TAB_BITS	8
-#endif
-#if CONFIG_IP_VS_TAB_BITS > 20
-#define IP_VS_CONN_TAB_BITS	20
-#endif
-#if 8 <= CONFIG_IP_VS_TAB_BITS && CONFIG_IP_VS_TAB_BITS <= 20
+
 #define IP_VS_CONN_TAB_BITS	CONFIG_IP_VS_TAB_BITS
-#endif
 #define IP_VS_CONN_TAB_SIZE     (1 << IP_VS_CONN_TAB_BITS)
 #define IP_VS_CONN_TAB_MASK     (IP_VS_CONN_TAB_SIZE - 1)
 
diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
index 794cecb..de6004d 100644
--- a/net/ipv4/ipvs/Kconfig
+++ b/net/ipv4/ipvs/Kconfig
@@ -41,7 +41,8 @@ config	IP_VS_DEBUG
 
 config	IP_VS_TAB_BITS
 	int "IPVS connection table size (the Nth power of 2)"
-	default "12" 
+	range 8 20
+	default 12
 	---help---
 	  The IPVS connection hash table uses the chaining scheme to handle
 	  hash collisions. Using a big IPVS connection hash table will greatly
