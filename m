From: "Ryan O'Hara" <rohara@redhat.com>
Subject: [PATCH 2/2] libipvs: CHECK_IPV4 and CHECK_PE macros should not call return
Date: Tue, 20 Aug 2013 09:29:51 -0500
Message-ID: <1377008991-23950-1-git-send-email-rohara@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Ryan O'Hara <rohara@redhat.com>

The CHECK_IPV4 and CHECK_PE macros will call return if a conditional
is true. This is a problem for any caller that has allocated memory
and needs to do cleanup before returning. This patch replaces the
return in both macros with a goto statement. As a result, each caller
needs a out_err label.

Signed-off-by: Ryan O'Hara <rohara@redhat.com>
---
 libipvs/libipvs.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 309ccce..04473fb 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -42,11 +42,11 @@ static int family, try_nl = 1;
 #endif
 
 #define CHECK_IPV4(s, ret) if (s->af && s->af != AF_INET)	\
-	{ errno = EAFNOSUPPORT; return ret; }			\
+	{ errno = EAFNOSUPPORT; goto out_err; }			\
 	s->__addr_v4 = s->addr.ip;				\
 
 #define CHECK_PE(s, ret) if (s->pe_name[0])			\
-	{ errno = EAFNOSUPPORT; return ret; }
+	{ errno = EAFNOSUPPORT; goto out_err; }
 
 #define CHECK_COMPAT_DEST(s, ret) CHECK_IPV4(s, ret)
 
@@ -266,6 +266,8 @@ int ipvs_add_service(ipvs_service_t *svc)
 	CHECK_COMPAT_SVC(svc, -1);
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_ADD, (char *)svc,
 			  sizeof(struct ip_vs_service_kern));
+out_err:
+	return -1;
 }
 
 
@@ -286,6 +288,8 @@ int ipvs_update_service(ipvs_service_t *svc)
 	CHECK_COMPAT_SVC(svc, -1);
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_EDIT, (char *)svc,
 			  sizeof(struct ip_vs_service_kern));
+out_err:
+	return -1;
 }
 
 
@@ -306,6 +310,8 @@ int ipvs_del_service(ipvs_service_t *svc)
 	CHECK_COMPAT_SVC(svc, -1);
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_DEL, (char *)svc,
 			  sizeof(struct ip_vs_service_kern));
+out_err:
+	return -1;
 }
 
 
@@ -331,6 +337,8 @@ int ipvs_zero_service(ipvs_service_t *svc)
 	CHECK_COMPAT_SVC(svc, -1);
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_ZERO, (char *)svc,
 			  sizeof(struct ip_vs_service_kern));
+out_err:
+	return -1;
 }
 
 #ifdef LIBIPVS_USE_NL
@@ -384,6 +392,8 @@ nla_put_failure:
 	memcpy(&svcdest.dest, dest, sizeof(svcdest.dest));
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_ADDDEST,
 			  (char *)&svcdest, sizeof(svcdest));
+out_err:
+	return -1;
 }
 
 
@@ -413,6 +423,8 @@ nla_put_failure:
 	memcpy(&svcdest.dest, dest, sizeof(svcdest.dest));
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_EDITDEST,
 			  (char *)&svcdest, sizeof(svcdest));
+out_err:
+	return -1;
 }
 
 
@@ -443,6 +455,8 @@ nla_put_failure:
 	memcpy(&svcdest.dest, dest, sizeof(svcdest.dest));
 	return setsockopt(sockfd, IPPROTO_IP, IP_VS_SO_SET_DELDEST,
 			  (char *)&svcdest, sizeof(svcdest));
+out_err:
+	return -1;
 }
 
 
@@ -974,6 +988,9 @@ ipvs_get_service_err2:
 	svc->addr.ip = svc->__addr_v4;
 	svc->pe_name[0] = '\0';
 	return svc;
+out_err:
+	free(svc);
+	return NULL;
 }
 
 #ifdef LIBIPVS_USE_NL
-- 
1.8.1.4

