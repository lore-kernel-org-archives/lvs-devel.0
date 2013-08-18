From: "Ryan O'Hara" <rohara@redhat.com>
Subject: [PATCH] ipvsadm: Fix svc->pe_name conditional
Date: Sun, 18 Aug 2013 11:41:03 -0500
Message-ID: <1376844063-4298-1-git-send-email-rohara@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Ryan O'Hara <rohara@redhat.com>

The pe_name in ipvs_service_t is an array, so comparing it NULL has no
effect. Use strlen to see if pe_name is set.

Signed-off-by: Ryan O'Hara <rohara@redhat.com>
---
 libipvs/libipvs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index c3c3b0a..ebc46e9 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -229,7 +229,7 @@ static int ipvs_nl_fill_service_attr(struct nl_msg *msg, ipvs_service_t *svc)
 	}
 
 	NLA_PUT_STRING(msg, IPVS_SVC_ATTR_SCHED_NAME, svc->sched_name);
-	if (svc->pe_name)
+	if (strlen(svc->pe_name))
 		NLA_PUT_STRING(msg, IPVS_SVC_ATTR_PE_NAME, svc->pe_name);
 	NLA_PUT(msg, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
 	NLA_PUT_U32(msg, IPVS_SVC_ATTR_TIMEOUT, svc->timeout);
-- 
1.8.1.4

