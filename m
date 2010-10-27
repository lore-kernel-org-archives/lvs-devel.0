From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH] IPVS: ip_vs_pe.c, use strncmp to be safe.
Date: Wed, 27 Oct 2010 17:05:00 +0200
Message-ID: <1288191900-24613-1-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

With pe data traveling between master and backup,
strcmp should not be used. 
How knows what size it will have in future.

To be safe use strncmp.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_pe.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
index 3414af7..baab44f 100644
--- a/net/netfilter/ipvs/ip_vs_pe.c
+++ b/net/netfilter/ipvs/ip_vs_pe.c
@@ -46,7 +46,7 @@ ip_vs_pe_getbyname(const char *pe_name)
 			/* This pe is just deleted */
 			continue;
 		}
-		if (strcmp(pe_name, pe->name)==0) {
+		if (strncmp(pe_name, pe->name, IP_VS_PENAME_MAXLEN )==0) {
 			/* HIT */
 			spin_unlock_bh(&ip_vs_pe_lock);
 			return pe;
@@ -104,7 +104,7 @@ int register_ip_vs_pe(struct ip_vs_pe *pe)
 	 * in the pe list.
 	 */
 	list_for_each_entry(tmp, &ip_vs_pe, n_list) {
-		if (strcmp(tmp->name, pe->name) == 0) {
+		if (strncmp(tmp->name, pe->name, IP_VS_PENAME_MAXLEN) == 0) {
 			spin_unlock_bh(&ip_vs_pe_lock);
 			ip_vs_use_count_dec();
 			pr_err("%s(): [%s] pe already existed "
-- 
1.6.0.2

