From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvsadm: init svc in ipvs_get_service
Date: Sat, 24 Aug 2013 13:40:53 +0300
Message-ID: <1377340853-2391-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

ipvs_get_service() needs to init the allocated svc
for the non-netlink case due to the used CHECK_COMPAT_SVC
macro that includes pe_name[0] check in CHECK_PE. Use
calloc to avoid reading random data.

For the netlink case use malloc as before.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 libipvs/libipvs.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 04473fb..d2fec49 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -930,22 +930,18 @@ ipvs_get_service(__u32 fwmark, __u16 af, __u16 protocol, union nf_inet_addr addr
 	ipvs_service_entry_t *svc;
 	socklen_t len;
 
-	len = sizeof(*svc);
-	if (!(svc = malloc(len)))
-		return NULL;
-
 	ipvs_func = ipvs_get_service;
 
-	svc->fwmark = fwmark;
-	svc->af = af;
-	svc->protocol = protocol;
-	svc->addr = addr;
-	svc->port = port;
 #ifdef LIBIPVS_USE_NL
 	if (try_nl) {
 		struct ip_vs_get_services *get;
 		struct nl_msg *msg;
 		ipvs_service_t tsvc;
+
+		svc = malloc(sizeof(*svc));
+		if (!svc)
+			return NULL;
+
 		tsvc.fwmark = fwmark;
 		tsvc.af = af;
 		tsvc.protocol= protocol;
@@ -978,6 +974,17 @@ ipvs_get_service_err2:
 	}
 #endif
 
+	len = sizeof(*svc);
+	svc = calloc(1, len);
+	if (!svc)
+		return NULL;
+
+	svc->fwmark = fwmark;
+	svc->af = af;
+	svc->protocol = protocol;
+	svc->addr = addr;
+	svc->port = port;
+
 	CHECK_COMPAT_SVC(svc, NULL);
 	if (getsockopt(sockfd, IPPROTO_IP, IP_VS_SO_GET_SERVICE,
 		       (char *)svc, &len)) {
-- 
1.7.3.4

