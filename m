From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ipvs: use true and false for boolean values
Date: Mon, 5 Mar 2018 15:35:57 -0600
Message-ID: <20180305213557.GA12365@embeddedor.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, "Gustavo A. R. Silva" <garsilva@embeddedor.com>

Assign true or false to boolean variables instead of an integer value.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/netfilter/ipvs/ip_vs_lblc.c  | 4 ++--
 net/netfilter/ipvs/ip_vs_lblcr.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 6a340c9..942e835 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -238,7 +238,7 @@ static void ip_vs_lblc_flush(struct ip_vs_service *svc)
 	int i;
 
 	spin_lock_bh(&svc->sched_lock);
-	tbl->dead = 1;
+	tbl->dead = true;
 	for (i = 0; i < IP_VS_LBLC_TAB_SIZE; i++) {
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
 			ip_vs_lblc_del(en);
@@ -369,7 +369,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
 	tbl->max_size = IP_VS_LBLC_TAB_SIZE*16;
 	tbl->rover = 0;
 	tbl->counter = 1;
-	tbl->dead = 0;
+	tbl->dead = false;
 	tbl->svc = svc;
 
 	/*
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 0627881..a5acab2 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -404,7 +404,7 @@ static void ip_vs_lblcr_flush(struct ip_vs_service *svc)
 	struct hlist_node *next;
 
 	spin_lock_bh(&svc->sched_lock);
-	tbl->dead = 1;
+	tbl->dead = true;
 	for (i = 0; i < IP_VS_LBLCR_TAB_SIZE; i++) {
 		hlist_for_each_entry_safe(en, next, &tbl->bucket[i], list) {
 			ip_vs_lblcr_free(en);
@@ -532,7 +532,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
 	tbl->max_size = IP_VS_LBLCR_TAB_SIZE*16;
 	tbl->rover = 0;
 	tbl->counter = 1;
-	tbl->dead = 0;
+	tbl->dead = false;
 	tbl->svc = svc;
 
 	/*
-- 
2.7.4

