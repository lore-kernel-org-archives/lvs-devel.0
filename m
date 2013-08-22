From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvsadm: Fix wrong format of --pe option in FMT_RULE listing
Date: Thu, 22 Aug 2013 09:45:51 +0300
Message-ID: <1377153951-1975-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

'ipvsadm -S' listed the persistence engine option in wrong format
(' pe ...' instead of ' --pe ...') preventing any service with
PE from restoring using 'ipvsadm -R'.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 ipvsadm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 0197515..58f8241 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1485,7 +1485,7 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 				}
 		}
 		if (se->pe_name[0])
-			printf(" pe %s", se->pe_name);
+			printf(" --pe %s", se->pe_name);
 		if (se->flags & IP_VS_SVC_F_ONEPACKET)
 			printf(" -o");
 	} else if (format & FMT_STATS) {
-- 
1.7.3.4

