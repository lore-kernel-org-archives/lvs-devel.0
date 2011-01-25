From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] [patch v2] IPVS: Remove unused pr_fmt #define
Date: Tue, 25 Jan 2011 16:22:18 +1000
Message-ID: <1295936538-20575-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, Joe Perches <joe@perches.com>

Cc: Joe Perches <joe@perches.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

v2:
Also remove unused pr_fmt from other files in net/netfilter/ipvs/
Also remove KMSG_COMPONENT
---
 net/netfilter/ipvs/ip_vs_app.c          |    3 ---
 net/netfilter/ipvs/ip_vs_est.c          |    3 ---
 net/netfilter/ipvs/ip_vs_lc.c           |    3 ---
 net/netfilter/ipvs/ip_vs_nfct.c         |    3 ---
 net/netfilter/ipvs/ip_vs_nq.c           |    3 ---
 net/netfilter/ipvs/ip_vs_pe_sip.c       |    3 ---
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    3 ---
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |    3 ---
 net/netfilter/ipvs/ip_vs_rr.c           |    3 ---
 net/netfilter/ipvs/ip_vs_sed.c          |    3 ---
 net/netfilter/ipvs/ip_vs_wlc.c          |    3 ---
 net/netfilter/ipvs/ip_vs_xmit.c         |    3 ---
 12 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 5c48ffb..e216dda 100644
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
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index f560a05..10a100a 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -16,9 +16,6 @@
  *              get_stats()) do the per cpu summing.
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/types.h>
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
 
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index f454c80..05954db 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -47,9 +47,6 @@
  *
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/types.h>
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
 
diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 0d83bc0..2a3da04 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -1,6 +1,3 @@
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 5b8eb8b..0ae9710 100644
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
index c0cc341..791e558 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -17,9 +17,6 @@
  *              protocol ip_vs_proto_data and is handled by netns
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
-
 #include <linux/kernel.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>                  /* for tcphdr */
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
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 1f2a4e3..92734bb 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -23,9 +23,6 @@
  * - the only place where we can see skb->sk != NULL
  */
 
-#define KMSG_COMPONENT "IPVS"
-#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
