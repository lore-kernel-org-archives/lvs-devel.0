From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 2/2] ipvsadm: allow different address family in connection listing
Date: Sat, 30 Aug 2014 14:35:49 +0300
Message-ID: <1409398549-5386-3-git-send-email-ja@ssi.bg>
References: <1409398549-5386-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1409398549-5386-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Alex Gartrell <agartrell@fb.com>, kernel-team@fb.com

Real server can have different address family, fix it
for connection listing.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 ipvsadm.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 3000117..7263d03 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1296,6 +1296,7 @@ static void print_conn(char *buf, unsigned int format)
 	char            state[16];
 	unsigned int    expires;
 	unsigned short  af = AF_INET;
+	unsigned short  daf = AF_INET;
 	char		pe_name[IP_VS_PENAME_MAXLEN];
 	char		pe_data[IP_VS_PEDATA_MAXLEN];
 
@@ -1320,22 +1321,24 @@ static void print_conn(char *buf, unsigned int format)
 
 	if (inet_pton(AF_INET6, temp1, &caddr.in6) > 0) {
 		inet_pton(AF_INET6, temp2, &vaddr.in6);
-		inet_pton(AF_INET6, temp3, &daddr.in6);
 		af = AF_INET6;
 	} else if (inet_pton(AF_INET, temp1, &caddr.ip) > 0) {
 		inet_pton(AF_INET, temp2, &vaddr.ip);
-		inet_pton(AF_INET, temp3, &daddr.ip);
 	} else {
 		caddr.ip = (__u32) htonl(strtoul(temp1, NULL, 16));
 		vaddr.ip = (__u32) htonl(strtoul(temp2, NULL, 16));
-		daddr.ip = (__u32) htonl(strtoul(temp3, NULL, 16));
 	}
 
+	if (inet_pton(AF_INET6, temp3, &daddr.in6) > 0)
+		daf = AF_INET6;
+	else if (inet_pton(AF_INET, temp3, &daddr.ip) <= 0)
+		daddr.ip = (__u32) htonl(strtoul(temp3, NULL, 16));
+
 	if (!(cname = addrport_to_anyname(af, &caddr, cport, proto, format)))
 		exit(1);
 	if (!(vname = addrport_to_anyname(af, &vaddr, vport, proto, format)))
 		exit(1);
-	if (!(dname = addrport_to_anyname(af, &daddr, dport, proto, format)))
+	if (!(dname = addrport_to_anyname(daf, &daddr, dport, proto, format)))
 		exit(1);
 
 	seconds = expires % 60;
-- 
1.9.0

