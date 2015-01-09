From: Hibari Michiro <hibari.michiro@lab.ntt.co.jp>
Subject: [PATCH] ipvsadm: Enable to work display host name of IPv6
Date: Fri, 09 Jan 2015 17:41:29 +0900
Message-ID: <54AF9439.8040409@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: hibari.michiro@lab.ntt.co.jp

So far ipvsadm can not display host name of IPv6.
This patch add process in the case of IPv6 for
addr_to_host function.

Signed-off-by: Michiro Hibari <hibari.michiro@lab.ntt.co.jp>
---
 ipvsadm.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 72ddc8a..162d4a2 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1770,8 +1770,14 @@ static char * addr_to_host(int af, const void *addr)
 {
 	struct hostent *host;
-	if ((host = gethostbyaddr((char *) addr,
-				  sizeof(struct in_addr), af)) != NULL)
+	if (af == AF_INET)
+		host = gethostbyaddr((char *) addr,
+				     sizeof(struct in_addr), af);
+	else
+		host = gethostbyaddr((char *) addr,
+				     sizeof(struct in6_addr), af);
+
+	if (host != NULL)
 		return (char *) host->h_name;
 	else
 		return (char *) NULL;
-- 
1.8.3.1

-- 
Michiro Hibari <hibari.michiro@lab.ntt.co.jp>




