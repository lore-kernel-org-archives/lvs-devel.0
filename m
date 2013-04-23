From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 4/9] ipvs: fix sparse warnings in lblc and lblcr
Date: Tue, 23 Apr 2013 12:03:55 +0900
Message-ID: <1366686240-23493-5-git-send-email-horms@verge.net.au>
References: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

kbuild test robot reports for sparse warnings in
commits c2a4ffb70eef39 ("ipvs: convert lblc scheduler to rcu")
and c5549571f975ab ("ipvs: convert lblcr scheduler to rcu").

Fix it by removing extra __rcu annotation.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblc.c  | 2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index b2cc252..5ea26bd 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -104,7 +104,7 @@ struct ip_vs_lblc_entry {
  */
 struct ip_vs_lblc_table {
 	struct rcu_head		rcu_head;
-	struct hlist_head __rcu bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
+	struct hlist_head	bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
 	struct timer_list       periodic_timer; /* collect stale entries */
 	atomic_t                entries;        /* number of entries */
 	int                     max_size;       /* maximum size of entries */
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index feb9656..50123c2 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -284,7 +284,7 @@ struct ip_vs_lblcr_entry {
  */
 struct ip_vs_lblcr_table {
 	struct rcu_head		rcu_head;
-	struct hlist_head __rcu bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
+	struct hlist_head	bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
 	atomic_t                entries;        /* number of entries */
 	int                     max_size;       /* maximum size of entries */
 	struct timer_list       periodic_timer; /* collect stale entries */
-- 
1.8.2.1

