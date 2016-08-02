From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1116/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:54 +0800
Message-ID: <20160802121754.24527-1-baolex.ni@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, chuansheng.liu@intel.com, baolex.ni@intel.com, aryabinin@virtuozzo.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 096a451..6a88389 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -50,7 +50,7 @@
  * Connection hash size. Default is what was selected at compile time.
 */
 static int ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
-module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, 0444);
+module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(conn_tab_bits, "Set connections' hash size");
 
 /* size and mask values */
-- 
2.9.2

