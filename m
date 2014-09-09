From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 11/20] ipvs: address family of LBLCR entry depends on svc family
Date: Tue, 9 Sep 2014 16:40:30 -0700
Message-ID: <1410306039-2977-12-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=cVwzNXPUoE6XSoWspsTR6Yny/jFTR52bR0W03Fv6rR0=;
 b=AM5iqDHJA9KaeFIdjpZQeD45LIkXOjmmvJmeQ9MkLfi3Cq6E/TpXXD8cpd8xngfVijZa
 /TILvbAi6Z107zeNXFtP0jeuQxuxFFmB9psvfRCU6bNmWaWy4X+TO8rlhbhAVRo6AqXs
 J0pkw+3yQrDjxF36DafrlxsehCDP2CIasI0= 
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, Alex Gartrell <agartrell@fb.com>

From: Julian Anastasov <ja@ssi.bg>

The LBLCR entries should use svc->af, not dest->af.
Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_lblcr.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 3f21a2f..2229d2d 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -362,18 +362,18 @@ ip_vs_lblcr_get(int af, struct ip_vs_lblcr_table *tbl,
  */
 static inline struct ip_vs_lblcr_entry *
 ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
-		struct ip_vs_dest *dest)
+		u16 af, struct ip_vs_dest *dest)
 {
 	struct ip_vs_lblcr_entry *en;
 
-	en = ip_vs_lblcr_get(dest->af, tbl, daddr);
+	en = ip_vs_lblcr_get(af, tbl, daddr);
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
 		if (!en)
 			return NULL;
 
-		en->af = dest->af;
-		ip_vs_addr_copy(dest->af, &en->addr, daddr);
+		en->af = af;
+		ip_vs_addr_copy(af, &en->addr, daddr);
 		en->lastuse = jiffies;
 
 		/* initialize its dest set */
@@ -706,13 +706,13 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	spin_lock_bh(&svc->sched_lock);
 	if (!tbl->dead)
-		ip_vs_lblcr_new(tbl, &iph->daddr, dest);
+		ip_vs_lblcr_new(tbl, &iph->daddr, svc->af, dest);
 	spin_unlock_bh(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
 		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
-		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
 }
-- 
1.8.1
