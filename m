From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: fix the IPVS_CMD_ATTR_MAX definition
Date: Wed, 28 Aug 2013 19:31:22 +0300
Message-ID: <1377707482-4420-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

It was wrong (bigger) but problem is harmless.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/uapi/linux/ip_vs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 2945822..fbcffe8 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -334,7 +334,7 @@ enum {
 	__IPVS_CMD_ATTR_MAX,
 };
 
-#define IPVS_CMD_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)
+#define IPVS_CMD_ATTR_MAX (__IPVS_CMD_ATTR_MAX - 1)
 
 /*
  * Attributes used to describe a service
-- 
1.7.3.4

