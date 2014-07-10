From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack
Date: Thu, 10 Jul 2014 09:24:01 +0300
Message-ID: <1404973441-8989-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>

commit 8f4e0a18682d91 ("IPVS netns exit causes crash in conntrack")
added second ip_vs_conn_drop_conntrack call instead of just adding
the needed check. As result, the first call still can cause
crash on netns exit. Remove it.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
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
1.9.0

