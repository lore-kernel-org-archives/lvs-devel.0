From: "Ryan O'Hara" <rohara@redhat.com>
Subject: [PATCH v2] ipvsadm: Fix svc->pe_name conditional
Date: Mon, 19 Aug 2013 09:56:28 -0500
Message-ID: <1376924188-14556-1-git-send-email-rohara@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Ryan O'Hara <rohara@redhat.com>

The pe_name in ipvs_service_t is an array, so comparing it NULL has no
effect. Check first byte of pe_name.

Signed-off-by: Ryan O'Hara <rohara@redhat.com>
---
 libipvs/libipvs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 2b066d2..89f26b9 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -45,7 +45,7 @@ static int family, try_nl = 1;
 	{ errno = EAFNOSUPPORT; return ret; }			\
 	s->__addr_v4 = s->addr.ip;				\
 
-#define CHECK_PE(s, ret) if (s->pe_name)			\
+#define CHECK_PE(s, ret) if (s->pe_name[0])			\
 	{ errno = EAFNOSUPPORT; return ret; }
 
 #define CHECK_COMPAT_DEST(s, ret) CHECK_IPV4(s, ret)
@@ -234,7 +234,7 @@ static int ipvs_nl_fill_service_attr(struct nl_msg *msg, ipvs_service_t *svc)
 	}
 
 	NLA_PUT_STRING(msg, IPVS_SVC_ATTR_SCHED_NAME, svc->sched_name);
-	if (svc->pe_name)
+	if (svc->pe_name[0])
 		NLA_PUT_STRING(msg, IPVS_SVC_ATTR_PE_NAME, svc->pe_name);
 	NLA_PUT(msg, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags);
 	NLA_PUT_U32(msg, IPVS_SVC_ATTR_TIMEOUT, svc->timeout);
-- 
1.8.1.4

