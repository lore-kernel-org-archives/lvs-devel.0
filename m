From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 14/20] IPVS: Conditinally use sysctl_lblc{r}_expiration
Date: Mon, 14 Mar 2011 12:45:40 +0900
Message-ID: <1300074346-13799-15-git-send-email-horms@verge.net.au>
References: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_lblc{r}_expiration in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblc.c  |   16 +++++++++++++---
 net/netfilter/ipvs/ip_vs_lblcr.c |   21 +++++++++++++++------
 2 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 6bf7a80..51a27f5 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -63,6 +63,8 @@
 #define CHECK_EXPIRE_INTERVAL   (60*HZ)
 #define ENTRY_TIMEOUT           (6*60*HZ)
 
+#define DEFAULT_EXPIRATION	(24*60*60*HZ)
+
 /*
  *    It is for full expiration check.
  *    When there is no partial expiration check (garbage collection)
@@ -238,6 +240,15 @@ static void ip_vs_lblc_flush(struct ip_vs_lblc_table *tbl)
 	}
 }
 
+static int sysctl_lblc_expiration(struct ip_vs_service *svc)
+{
+#ifdef CONFIG_SYSCTL
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	return ipvs->sysctl_lblc_expiration;
+#else
+	return DEFAULT_EXPIRATION;
+#endif
+}
 
 static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 {
@@ -245,7 +256,6 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 	struct ip_vs_lblc_entry *en, *nxt;
 	unsigned long now = jiffies;
 	int i, j;
-	struct netns_ipvs *ipvs = net_ipvs(svc->net);
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
@@ -254,7 +264,7 @@ static inline void ip_vs_lblc_full_check(struct ip_vs_service *svc)
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
 			if (time_before(now,
 					en->lastuse +
-					ipvs->sysctl_lblc_expiration))
+					sysctl_lblc_expiration(svc)))
 				continue;
 
 			ip_vs_lblc_free(en);
@@ -550,7 +560,7 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 			return -ENOMEM;
 	} else
 		ipvs->lblc_ctl_table = vs_vars_table;
-	ipvs->sysctl_lblc_expiration = 24*60*60*HZ;
+	ipvs->sysctl_lblc_expiration = DEFAULT_EXPIRATION;
 	ipvs->lblc_ctl_table[0].data = &ipvs->sysctl_lblc_expiration;
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 0063176..7fb9190 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -63,6 +63,8 @@
 #define CHECK_EXPIRE_INTERVAL   (60*HZ)
 #define ENTRY_TIMEOUT           (6*60*HZ)
 
+#define DEFAULT_EXPIRATION	(24*60*60*HZ)
+
 /*
  *    It is for full expiration check.
  *    When there is no partial expiration check (garbage collection)
@@ -410,6 +412,15 @@ static void ip_vs_lblcr_flush(struct ip_vs_lblcr_table *tbl)
 	}
 }
 
+static int sysctl_lblcr_expiration(struct ip_vs_service *svc)
+{
+#ifdef CONFIG_SYSCTL
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
+	return ipvs->sysctl_lblcr_expiration;
+#else
+	return DEFAULT_EXPIRATION;
+#endif
+}
 
 static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 {
@@ -417,15 +428,14 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 	unsigned long now = jiffies;
 	int i, j;
 	struct ip_vs_lblcr_entry *en, *nxt;
-	struct netns_ipvs *ipvs = net_ipvs(svc->net);
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
 
 		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
-			if (time_after(en->lastuse
-					+ ipvs->sysctl_lblcr_expiration, now))
+			if (time_after(en->lastuse +
+				       sysctl_lblcr_expiration(svc), now))
 				continue;
 
 			ip_vs_lblcr_free(en);
@@ -650,7 +660,6 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	read_lock(&svc->sched_lock);
 	en = ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
 	if (en) {
-		struct netns_ipvs *ipvs = net_ipvs(svc->net);
 		/* We only hold a read lock, but this is atomic */
 		en->lastuse = jiffies;
 
@@ -662,7 +671,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 		/* More than one destination + enough time passed by, cleanup */
 		if (atomic_read(&en->set.size) > 1 &&
 				time_after(jiffies, en->set.lastmod +
-				ipvs->sysctl_lblcr_expiration)) {
+				sysctl_lblcr_expiration(svc))) {
 			struct ip_vs_dest *m;
 
 			write_lock(&en->set.lock);
@@ -746,7 +755,7 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 			return -ENOMEM;
 	} else
 		ipvs->lblcr_ctl_table = vs_vars_table;
-	ipvs->sysctl_lblcr_expiration = 24*60*60*HZ;
+	ipvs->sysctl_lblcr_expiration = DEFAULT_EXPIRATION;
 	ipvs->lblcr_ctl_table[0].data = &ipvs->sysctl_lblcr_expiration;
 
 #ifdef CONFIG_SYSCTL
-- 
1.7.2.3

