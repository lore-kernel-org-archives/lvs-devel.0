From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 12/19] ipvs: convert wlc scheduler to rcu
Date: Fri, 22 Mar 2013 11:46:47 +0200
Message-ID: <1363945614-11752-13-git-send-email-ja@ssi.bg>
References: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	The schedule method now needs _rcu list-traversal
primitive for svc->destinations.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_wlc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index bc1bfc4..dafae88 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -51,7 +51,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	 * new connections.
 	 */
 
-	list_for_each_entry(dest, &svc->destinations, n_list) {
+	list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
 		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&dest->weight) > 0) {
 			least = dest;
@@ -66,7 +66,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	list_for_each_entry_continue(dest, &svc->destinations, n_list) {
+	list_for_each_entry_continue_rcu(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		doh = ip_vs_dest_conn_overhead(dest);
-- 
1.7.3.4
