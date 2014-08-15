From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 01/18] ipvs: Pass destination address family to ip_vs_trash_get_dest
Date: Thu, 14 Aug 2014 20:23:24 -0700
Message-ID: <1408073021-24007-2-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=UPJ+6ZqFCBZ06s4wRIMqXAVqM4hjFqp6uldluSu9Cb4=;
 b=mqtmiJyc09gTNPVx50NpbBdWJ2H96HJXDNOmEbbCUxp1sqQJPRTk2cQlip4YJ+9EAOyC
 nam/UWjSU/Pvut9W/wuso/P3r1TUxdeabjiJAdtkWMaUbyymus9XsnPepw30VJmxgTkB
 D0MzxN8MJUpgBGpHQY2gmn7C0FPG3SBaIWo= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Part of a series of diffs to tease out destination family from virtual
family.  This diff just adds a parameter to ip_vs_trash_get and then uses
it for comparison rather than svc->af.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index eec8dee..01c813e 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -657,8 +657,8 @@ static void __ip_vs_dst_cache_reset(struct ip_vs_dest *dest)
  *  scheduling.
  */
 static struct ip_vs_dest *
-ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
-		     __be16 dport)
+ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
+		     const union nf_inet_addr *daddr, __be16 dport)
 {
 	struct ip_vs_dest *dest;
 	struct netns_ipvs *ipvs = net_ipvs(svc->net);
@@ -671,11 +671,11 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 		IP_VS_DBG_BUF(3, "Destination %u/%s:%u still in trash, "
 			      "dest->refcnt=%d\n",
 			      dest->vfwmark,
-			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
-		if (dest->af == svc->af &&
-		    ip_vs_addr_equal(svc->af, &dest->addr, daddr) &&
+		if (dest->af == dest_af &&
+		    ip_vs_addr_equal(dest_af, &dest->addr, daddr) &&
 		    dest->port == dport &&
 		    dest->vfwmark == svc->fwmark &&
 		    dest->protocol == svc->protocol &&
@@ -950,7 +950,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 	 * Check if the dest already exists in the trash and
 	 * is from the same service
 	 */
-	dest = ip_vs_trash_get_dest(svc, &daddr, dport);
+	dest = ip_vs_trash_get_dest(svc, udest->af, &daddr, dport);
 
 	if (dest != NULL) {
 		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
-- 
1.8.1

