From: baloo@gandi.net
Subject: [PATCH] libipvs: discrepancy with libnl genlmsg_put
Date: Wed, 27 Sep 2017 15:31:05 +0000
Message-ID: <20170927153105.7222-1-baloo@gandi.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Arthur Gautier <baloo@gandi.net>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Jesper Dangaard Brouer <brouer@redhat.com>

From: Arthur Gautier <baloo@gandi.net>

There is a mixup between NL_AUTO_PORT and NL_AUTO_PID. The
first should be used with genlmsg_put while the second with
nlmsg_put.

This is not a problem, because both NL_AUTO_PORT and NL_AUTO_PID
have the same value, but still a discrepancy with libnl documentation.

see documentation of genlmsg_put here:
  http://www.infradead.org/~tgr/libnl/doc/api/group__genl.html#ga9a86a71bbba6961d41b8a75f62f9e946

Cc: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Arthur Gautier <baloo@gandi.net>
---
 libipvs/libipvs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index d271c48e36faa..a8432431fbbf6 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -63,7 +63,7 @@ struct nl_msg *ipvs_nl_message(int cmd, int flags)
 	if (!msg)
 		return NULL;
 
-	genlmsg_put(msg, NL_AUTO_PID, NL_AUTO_SEQ, family, 0, flags,
+	genlmsg_put(msg, NL_AUTO_PORT, NL_AUTO_SEQ, family, 0, flags,
 		    cmd, IPVS_GENL_VERSION);
 
 	return msg;
-- 
2.14.1

