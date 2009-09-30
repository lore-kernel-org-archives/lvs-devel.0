From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] net/netfilter/ipvs: Move #define KMSG_COMPONENT to Makefile
Date: Wed, 30 Sep 2009 15:37:16 -0700
Message-ID: <0026bcf5aad9ae5036e68fc2dcda9c778d30dc47.1254349375.git.joe@perches.com>
References: <cover.1254349374.git.joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <cover.1254349374.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

This centralizes the definition and removes the
replicated #defines from all files

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/ipvs/Makefile             |    3 +++
 net/netfilter/ipvs/ip_vs_app.c          |    3 ---
 net/netfilter/ipvs/ip_vs_conn.c         |    3 ---
 net/netfilter/ipvs/ip_vs_core.c         |    3 ---
 net/netfilter/ipvs/ip_vs_ctl.c          |    3 ---
 net/netfilter/ipvs/ip_vs_dh.c           |    3 ---
 net/netfilter/ipvs/ip_vs_est.c          |    3 ---
 net/netfilter/ipvs/ip_vs_ftp.c          |    3 ---
 net/netfilter/ipvs/ip_vs_lblc.c         |    3 ---
 net/netfilter/ipvs/ip_vs_lblcr.c        |    3 ---
 net/netfilter/ipvs/ip_vs_lc.c           |    3 ---
 net/netfilter/ipvs/ip_vs_nq.c           |    3 ---
 net/netfilter/ipvs/ip_vs_proto.c        |    3 ---
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    3 ---
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |    3 ---
 net/netfilter/ipvs/ip_vs_proto_udp.c    |    3 ---
 net/netfilter/ipvs/ip_vs_rr.c           |    3 ---
 net/netfilter/ipvs/ip_vs_sched.c        |    3 ---
 net/netfilter/ipvs/ip_vs_sed.c          |    3 ---
 net/netfilter/ipvs/ip_vs_sh.c           |    3 ---
 net/netfilter/ipvs/ip_vs_sync.c         |    3 ---
 net/netfilter/ipvs/ip_vs_wlc.c          |    3 ---
 net/netfilter/ipvs/ip_vs_wrr.c          |    3 ---
 net/netfilter/ipvs/ip_vs_xmit.c         |    3 ---
 24 files changed, 3 insertions(+), 69 deletions(-)

diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index 73a46fe..0d6f5f8 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -2,6 +2,9 @@
 # Makefile for the IPVS modules on top of IPv4.
 #
 
+ccflags-y += -D "KMSG_COMPONENT=\"IPVS\""
+ccflags-y += -D "pr_fmt(fmt)=KMSG_COMPONENT \": \" fmt"
+
 # IPVS transport protocol load balancing support
 ip_vs_proto-objs-y :=
 ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_TCP) += ip_vs_proto_tcp.o
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 3c7e427..a5283d8 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -18,9 +18,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 27c30cf..b62fdf6 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -22,9 +22,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/interrupt.h>
 #include <linux/in.h>
 #include <linux/net.h>
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b95699f..b3a103f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -24,9 +24,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/ip.h>
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 446e9bd..9c19485 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -18,9 +18,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/types.h>
diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index fe3e188..a91ce7b 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -35,9 +35,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 702b53c..1fa96bd 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -12,9 +12,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/slab.h>
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 33e2c79..e1c9c03 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -22,9 +22,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index c1757f3..8512305 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -39,9 +39,6 @@
  * me to write this module.
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 715b57f..4412b45 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -37,9 +37,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
index 4f69db1..e906763 100644
--- a/net/netfilter/ipvs/ip_vs_lc.c
+++ b/net/netfilter/ipvs/ip_vs_lc.c
@@ -14,9 +14,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index c413e18..4fbaf1d 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -31,9 +31,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 3e76716..b61e4b6 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -13,9 +13,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index c30b43c..b4249f2 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -10,9 +10,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/module.h>
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 91d28e0..3ca6278 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -13,9 +13,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/kernel.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>                  /* for tcphdr */
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index e7a6885..61aec0c 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -13,9 +13,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index e210f37..5857da9 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -19,9 +19,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
index bbc1ac7..cd9efc9 100644
--- a/net/netfilter/ipvs/ip_vs_sched.c
+++ b/net/netfilter/ipvs/ip_vs_sched.c
@@ -17,9 +17,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index 1ab75a9..2b9d2c0 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -35,9 +35,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 8e6cfd3..b5cabba 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -32,9 +32,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index e177f0d..6919cda 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -17,9 +17,6 @@
  *	Justin Ossevoort	:	Fix endian problem on sync message size.
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/inetdevice.h>
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index bbddfdb..8e94256 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -19,9 +19,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 6182e8e..ab97dc1 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -18,9 +18,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/net.h>
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 30b3189..c23c0a1 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -13,9 +13,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/kernel.h>
 #include <linux/tcp.h>                  /* for tcphdr */
 #include <net/ip.h>
-- 
1.6.3.1.10.g659a0.dirty

