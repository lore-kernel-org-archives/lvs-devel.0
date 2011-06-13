From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/3] ipvs: support more FTP PASV responses
Date: Mon, 13 Jun 2011 17:26:07 +0900
Message-ID: <1307953569-15429-2-git-send-email-horms@verge.net.au>
References: <1307953569-15429-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1307953569-15429-1-git-send-email-horms@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Change the parsing of FTP commands and responses to
support skip character. It allows to detect variations in
the 227 PASV response.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ftp.c |   52 +++++++++++++++++++++++++++++----------
 1 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index af63553..4490a32 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -44,8 +44,8 @@
 #include <net/ip_vs.h>
 
 
-#define SERVER_STRING "227 Entering Passive Mode ("
-#define CLIENT_STRING "PORT "
+#define SERVER_STRING "227 "
+#define CLIENT_STRING "PORT"
 
 
 /*
@@ -79,14 +79,17 @@ ip_vs_ftp_done_conn(struct ip_vs_app *app, struct ip_vs_conn *cp)
 
 /*
  * Get <addr,port> from the string "xxx.xxx.xxx.xxx,ppp,ppp", started
- * with the "pattern" and terminated with the "term" character.
+ * with the "pattern", ignoring before "skip" and terminated with
+ * the "term" character.
  * <addr,port> is in network order.
  */
 static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
-				  const char *pattern, size_t plen, char term,
+				  const char *pattern, size_t plen,
+				  char skip, char term,
 				  __be32 *addr, __be16 *port,
 				  char **start, char **end)
 {
+	char *s, c;
 	unsigned char p[6];
 	int i = 0;
 
@@ -101,19 +104,38 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
 	if (strnicmp(data, pattern, plen) != 0) {
 		return 0;
 	}
-	*start = data + plen;
+	s = data + plen;
+	if (skip) {
+		int found = 0;
+
+		for (;; s++) {
+			if (s == data_limit)
+				return -1;
+			if (!found) {
+				if (*s == skip)
+					found = 1;
+			} else if (*s != skip) {
+				break;
+			}
+		}
+	}
 
-	for (data = *start; *data != term; data++) {
+	for (data = s; ; data++) {
 		if (data == data_limit)
 			return -1;
+		if (*data == term)
+			break;
 	}
 	*end = data;
 
 	memset(p, 0, sizeof(p));
-	for (data = *start; data != *end; data++) {
-		if (*data >= '0' && *data <= '9') {
-			p[i] = p[i]*10 + *data - '0';
-		} else if (*data == ',' && i < 5) {
+	for (data = s; ; data++) {
+		c = *data;
+		if (c == term)
+			break;
+		if (c >= '0' && c <= '9') {
+			p[i] = p[i]*10 + c - '0';
+		} else if (c == ',' && i < 5) {
 			i++;
 		} else {
 			/* unexpected character */
@@ -124,8 +146,9 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
 	if (i != 5)
 		return -1;
 
-	*addr = get_unaligned((__be32 *)p);
-	*port = get_unaligned((__be16 *)(p + 4));
+	*start = s;
+	*addr = get_unaligned((__be32 *) p);
+	*port = get_unaligned((__be16 *) (p + 4));
 	return 1;
 }
 
@@ -185,7 +208,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 
 		if (ip_vs_ftp_get_addrport(data, data_limit,
 					   SERVER_STRING,
-					   sizeof(SERVER_STRING)-1, ')',
+					   sizeof(SERVER_STRING)-1,
+					   '(', ')',
 					   &from.ip, &port,
 					   &start, &end) != 1)
 			return 1;
@@ -345,7 +369,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	 */
 	if (ip_vs_ftp_get_addrport(data_start, data_limit,
 				   CLIENT_STRING, sizeof(CLIENT_STRING)-1,
-				   '\r', &to.ip, &port,
+				   ' ', '\r', &to.ip, &port,
 				   &start, &end) != 1)
 		return 1;
 
-- 
1.7.4.4

