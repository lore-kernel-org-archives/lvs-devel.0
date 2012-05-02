From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 08/18] ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
Date: Wed,  2 May 2012 15:22:32 +0900
Message-ID: <1335939762-1912-9-git-send-email-horms@verge.net.au>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	As IP_VS_CONN_F_NOOUTPUT is derived from the
forwarding method we should get it from conn_flags just
like we do it for IP_VS_CONN_F_FWD_MASK bits when binding
to real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
1.7.10
