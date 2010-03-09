From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/netfilter/ipvs/ip_vs_ftp.c: Remove use of NIPQUAD
Date: Mon, 08 Mar 2010 16:31:39 -0800
Message-ID: <1268094699.1617.5.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, lvs-devel <lvs-devel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

NIPQUAD has very few uses left.

Remove this use and make the code have the identical form of the only
other use of "%u,%u,%u,%u,%u,%u" in net/ipv4/netfilter/nf_nat_ftp.c

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/ipvs/ip_vs_ftp.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c
b/net/netfilter/ipvs/ip_vs_ftp.c
index 73f38ea..9f63283 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -208,8 +208,14 @@ static int ip_vs_ftp_out(struct ip_vs_app *app,
struct ip_vs_conn *cp,
 		 */
 		from.ip = n_cp->vaddr.ip;
 		port = n_cp->vport;
-		sprintf(buf, "%u,%u,%u,%u,%u,%u", NIPQUAD(from.ip),
-			(ntohs(port)>>8)&255, ntohs(port)&255);
+		snprintf(buf, sizeof(buf), "%u,%u,%u,%u,%u,%u",
+			 ((unsigned char *)&from.ip)[0],
+			 ((unsigned char *)&from.ip)[1],
+			 ((unsigned char *)&from.ip)[2],
+			 ((unsigned char *)&from.ip)[3],
+			 ntohs(port) >> 8,
+			 ntohs(port) & 0xFF);
+
 		buf_len = strlen(buf);
 
 		/*


