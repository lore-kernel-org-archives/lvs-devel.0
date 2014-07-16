From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack
Date: Wed, 16 Jul 2014 09:56:08 +0900
Message-ID: <1405472168-25192-2-git-send-email-horms@verge.net.au>
References: <1405472168-25192-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1405472168-25192-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

commit 8f4e0a18682d91 ("IPVS netns exit causes crash in conntrack")
added second ip_vs_conn_drop_conntrack call instead of just adding
the needed check. As result, the first call still can cause
crash on netns exit. Remove it.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a8eb0a8..610e19c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -797,7 +797,6 @@ static void ip_vs_conn_expire(unsigned long data)
 			ip_vs_control_del(cp);
 
 		if (cp->flags & IP_VS_CONN_F_NFCT) {
-			ip_vs_conn_drop_conntrack(cp);
 			/* Do not access conntracks during subsys cleanup
 			 * because nf_conntrack_find_get can not be used after
 			 * conntrack cleanup for the net.
-- 
2.0.0
