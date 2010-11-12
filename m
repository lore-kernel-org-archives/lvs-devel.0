From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 6/9] IPVS: Remove useless { } block from ip_vs_process_message()
Date: Fri, 12 Nov 2010 08:34:58 +0100
Message-ID: <1289547301-28015-6-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Simon Horman <horms@verge.net.au>

Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |   24 +++++++++++-------------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 4b0ed40..f21506c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -511,20 +511,18 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 			}
 		}
 
-		{
-			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
-					      (union nf_inet_addr *)&s->caddr,
-					      s->cport,
-					      (union nf_inet_addr *)&s->vaddr,
-					      s->vport, &param)) {
-				pr_err("ip_vs_conn_fill_param_sync failed");
-				return;
-			}
-			if (!(flags & IP_VS_CONN_F_TEMPLATE))
-				cp = ip_vs_conn_in_get(&param);
-			else
-				cp = ip_vs_ct_in_get(&param);
+		if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
+					       (union nf_inet_addr *)&s->caddr,
+					       s->cport,
+					       (union nf_inet_addr *)&s->vaddr,
+					       s->vport, &param)) {
+			pr_err("ip_vs_conn_fill_param_sync failed");
+			return;
 		}
+		if (!(flags & IP_VS_CONN_F_TEMPLATE))
+			cp = ip_vs_conn_in_get(&param);
+		else
+			cp = ip_vs_ct_in_get(&param);
 		if (!cp) {
 			/*
 			 * Find the appropriate destination for the connection.
-- 
1.7.2.3

