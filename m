From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 10/18] ipvs: address family of LBLC entry depends on svc family
Date: Thu, 14 Aug 2014 20:23:33 -0700
Message-ID: <1408073021-24007-11-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=28jNh8uC4B7E4EKsprdrvANZp6kXrXFQyKiSj21TYYg=;
 b=CHEXUv5c5/sPMvLvp6rx4QjF7J6vS+uXB131cCZduB1Fpoo5iJs33ZosV6xOjyaZPKcL
 LuaBUlTjK1A4/69BPIv3ISHZg5Syv92BNaiDFGK+syxExkyrlGPZa8Z+St6E0DW1HZav
 pQaytBa34Rn//gXMLUFz26w0GJR6sYQlewY= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

From: Julian Anastasov <ja@ssi.bg>

The LBLC entries should use svc->af, not dest->af.
Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_lblc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 547ff33..127f140 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -199,11 +199,11 @@ ip_vs_lblc_get(int af, struct ip_vs_lblc_table *tbl,
  */
 static inline struct ip_vs_lblc_entry *
 ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
-	       struct ip_vs_dest *dest)
+	       u16 af, struct ip_vs_dest *dest)
 {
 	struct ip_vs_lblc_entry *en;
 
-	en = ip_vs_lblc_get(dest->af, tbl, daddr);
+	en = ip_vs_lblc_get(af, tbl, daddr);
 	if (en) {
 		if (en->dest == dest)
 			return en;
@@ -213,8 +213,8 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
 	if (!en)
 		return NULL;
 
-	en->af = dest->af;
-	ip_vs_addr_copy(dest->af, &en->addr, daddr);
+	en->af = af;
+	ip_vs_addr_copy(af, &en->addr, daddr);
 	en->lastuse = jiffies;
 
 	ip_vs_dest_hold(dest);
@@ -521,13 +521,13 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	spin_lock_bh(&svc->sched_lock);
 	if (!tbl->dead)
-		ip_vs_lblc_new(tbl, &iph->daddr, dest);
+		ip_vs_lblc_new(tbl, &iph->daddr, svc->af, dest);
 	spin_unlock_bh(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLC: destination IP address %s --> server %s:%d\n",
 		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
-		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
 }
-- 
1.8.1

