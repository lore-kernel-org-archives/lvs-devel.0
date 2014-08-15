From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 17/18] ipvs: use correct address family in SH logs
Date: Thu, 14 Aug 2014 20:23:40 -0700
Message-ID: <1408073021-24007-18-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=mS9+bcZ+6nx86e0p1cS8kIIhA8kNCSEcFBSuxkoeqcw=;
 b=LbVpxHMmTAJtIs4MIM2oRpdeb4c1n1AuoGcUmNmKmtbRPPXMIB2fHDWPGYVbMxeFkqQD
 SveHQGUADox4P01aF+eoG1lWF46Y8yVdGL1qQ+cUqC27YrOjVsBtksLfzq14zd7vQCdI
 Gj4db+D1gWKVFAeZJyL57bH5iSX9XglG9cg= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

From: Julian Anastasov <ja@ssi.bg>

Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_sh.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index cc65b2f..98a1343 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -138,7 +138,7 @@ ip_vs_sh_get_fallback(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
 		return dest;
 
 	IP_VS_DBG_BUF(6, "SH: selected unavailable server %s:%d, reselecting",
-		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port));
 
 	/* if the original dest is unavailable, loop around the table
 	 * starting from ihash to find a new dest
@@ -153,7 +153,7 @@ ip_vs_sh_get_fallback(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
 			return dest;
 		IP_VS_DBG_BUF(6, "SH: selected unavailable "
 			      "server %s:%d (offset %d), reselecting",
-			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port), roffset);
 	}
 
@@ -192,7 +192,7 @@ ip_vs_sh_reassign(struct ip_vs_sh_state *s, struct ip_vs_service *svc)
 			RCU_INIT_POINTER(b->dest, dest);
 
 			IP_VS_DBG_BUF(6, "assigned i: %d dest: %s weight: %d\n",
-				      i, IP_VS_DBG_ADDR(svc->af, &dest->addr),
+				      i, IP_VS_DBG_ADDR(dest->af, &dest->addr),
 				      atomic_read(&dest->weight));
 
 			/* Don't move to next dest until filling weight */
@@ -342,7 +342,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	IP_VS_DBG_BUF(6, "SH: source IP address %s --> server %s:%d\n",
 		      IP_VS_DBG_ADDR(svc->af, &iph->saddr),
-		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 		      ntohs(dest->port));
 
 	return dest;
-- 
1.8.1

