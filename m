From: sven.wegener@stealer.net
Subject: [PATCH 3/9] ipvs: Use ARRAY_SIZE()
Date: Sun, 10 Aug 2008 11:07:33 +0000
Message-ID: <1218366459-23971-4-git-send-email-sven.wegener@stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: Sven Wegener <sven.wegener@stealer.net>

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 include/net/ip_vs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index cbb59eb..e980416 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -440,7 +440,7 @@ struct ip_vs_app
  */
 extern const char *ip_vs_proto_name(unsigned proto);
 extern void ip_vs_init_hash_table(struct list_head *table, int rows);
-#define IP_VS_INIT_HASH_TABLE(t) ip_vs_init_hash_table(t, sizeof(t)/sizeof(t[0]))
+#define IP_VS_INIT_HASH_TABLE(t) ip_vs_init_hash_table((t), ARRAY_SIZE((t)))
 
 #define IP_VS_APP_TYPE_FTP	1
 
-- 
1.5.6.4

