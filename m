From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/9] ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
Date: Wed, 21 Mar 2012 17:56:16 +0900
Message-ID: <1332320185-27157-2-git-send-email-horms@verge.net.au>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	As IP_VS_CONN_F_NOOUTPUT is derived from the
forwarding method we should get it from conn_flags just
like we do it for IP_VS_CONN_F_FWD_MASK bits when binding
to real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 29fa5ba..6413d58 100644
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
1.7.6.3

