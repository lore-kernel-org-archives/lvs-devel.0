From: "Ryan O'Hara" <rohara@redhat.com>
Subject: [PATCH] libipvs: Initialize ipvs_service_t variable
Date: Fri, 17 Jan 2014 11:53:46 -0600
Message-ID: <1389981226-6668-1-git-send-email-rohara@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Ryan O'Hara <rohara@redhat.com>

The ipvs_get_service function declares an ipvs_service_t type variable
and initializes some of the values, but should really start by
initializing the entire structure.

Signed-off-by: Ryan O'Hara <rohara@redhat.com>
---
 libipvs/libipvs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index d2fec49..8baafed 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -942,6 +942,7 @@ ipvs_get_service(__u32 fwmark, __u16 af, __u16 protocol, union nf_inet_addr addr
 		if (!svc)
 			return NULL;
 
+		memset(&tsvc, 0, sizeof(tsvc));
 		tsvc.fwmark = fwmark;
 		tsvc.af = af;
 		tsvc.protocol= protocol;
-- 
1.8.1.4

