From: "Ryan O'Hara" <rohara@redhat.com>
Subject: [PATCH 1/2] libipvs: Remove redundant CHECK_PE
Date: Tue, 20 Aug 2013 09:29:43 -0500
Message-ID: <1377008983-23901-1-git-send-email-rohara@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Ryan O'Hara <rohara@redhat.com>

Since the CHECK_COMPAT_SVC macro calls CHECK_PE, remove the extra
CHECK_PE call from ipvs_get_service().

Signed-off-by: Ryan O'Hara <rohara@redhat.com>
---
 libipvs/libipvs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index ef242db..309ccce 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -965,7 +965,6 @@ ipvs_get_service_err2:
 #endif
 
 	CHECK_COMPAT_SVC(svc, NULL);
-	CHECK_PE(svc, NULL);
 	if (getsockopt(sockfd, IPPROTO_IP, IP_VS_SO_GET_SERVICE,
 		       (char *)svc, &len)) {
 		free(svc);
-- 
1.8.1.4

