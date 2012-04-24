From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v4 1/8] ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
Date: Tue, 24 Apr 2012 23:46:35 +0300
Message-ID: <1335300402-8076-2-git-send-email-ja@ssi.bg>
References: <1335300402-8076-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335300402-8076-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	As IP_VS_CONN_F_NOOUTPUT is derived from the
forwarding method we should get it from conn_flags just
like we do it for IP_VS_CONN_F_FWD_MASK bits when binding
to real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 4a09b78..f562e63 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -567,7 +567,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
 			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
 		/* connections inherit forwarding method from dest */
-		cp->flags &= ~IP_VS_CONN_F_FWD_MASK;
+		cp->flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
 	}
 	cp->flags |= conn_flags;
 	cp->dest = dest;
-- 
1.7.3.4

