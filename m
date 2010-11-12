From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 4/9] IPVS: Only match pe_data created by the same pe
Date: Fri, 12 Nov 2010 08:34:56 +0100
Message-ID: <1289547301-28015-4-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Simon Horman <horms@verge.net.au>

Only match persistence engine data if it was
created by the same persistence engine.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 1d5cead..079cc53 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -354,7 +354,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (p->pe_data && p->pe->ct_match) {
-			if (p->pe->ct_match(p, cp))
+			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
 				goto out;
 			continue;
 		}
-- 
1.7.2.3

