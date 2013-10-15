From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/3] ipvs: improved SH fallback strategy
Date: Tue, 15 Oct 2013 11:01:47 +0900
Message-ID: <1381802507-7934-4-git-send-email-horms@verge.net.au>
References: <1381802507-7934-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1381802507-7934-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alexander Frolkin <avf@eldamar.org.uk>, Simon Horman <horms@verge.net.au>

From: Alexander Frolkin <avf@eldamar.org.uk>

Improve the SH fallback realserver selection strategy.

With sh and sh-fallback, if a realserver is down, this attempts to
distribute the traffic that would have gone to that server evenly
among the remaining servers.

Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sh.c | 39 +++++++++++++++++++++++++++++----------
 1 file changed, 29 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 3588fae..cc65b2f 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -115,27 +115,46 @@ ip_vs_sh_get(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
 }
 
 
-/* As ip_vs_sh_get, but with fallback if selected server is unavailable */
+/* As ip_vs_sh_get, but with fallback if selected server is unavailable
+ *
+ * The fallback strategy loops around the table starting from a "random"
+ * point (in fact, it is chosen to be the original hash value to make the
+ * algorithm deterministic) to find a new server.
+ */
 static inline struct ip_vs_dest *
 ip_vs_sh_get_fallback(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
 		      const union nf_inet_addr *addr, __be16 port)
 {
-	unsigned int offset;
-	unsigned int hash;
+	unsigned int offset, roffset;
+	unsigned int hash, ihash;
 	struct ip_vs_dest *dest;
 
+	/* first try the dest it's supposed to go to */
+	ihash = ip_vs_sh_hashkey(svc->af, addr, port, 0);
+	dest = rcu_dereference(s->buckets[ihash].dest);
+	if (!dest)
+		return NULL;
+	if (!is_unavailable(dest))
+		return dest;
+
+	IP_VS_DBG_BUF(6, "SH: selected unavailable server %s:%d, reselecting",
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
+
+	/* if the original dest is unavailable, loop around the table
+	 * starting from ihash to find a new dest
+	 */
 	for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
-		hash = ip_vs_sh_hashkey(svc->af, addr, port, offset);
+		roffset = (offset + ihash) % IP_VS_SH_TAB_SIZE;
+		hash = ip_vs_sh_hashkey(svc->af, addr, port, roffset);
 		dest = rcu_dereference(s->buckets[hash].dest);
 		if (!dest)
 			break;
-		if (is_unavailable(dest))
-			IP_VS_DBG_BUF(6, "SH: selected unavailable server "
-				      "%s:%d (offset %d)",
-				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
-				      ntohs(dest->port), offset);
-		else
+		if (!is_unavailable(dest))
 			return dest;
+		IP_VS_DBG_BUF(6, "SH: selected unavailable "
+			      "server %s:%d (offset %d), reselecting",
+			      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+			      ntohs(dest->port), roffset);
 	}
 
 	return NULL;
-- 
1.8.4
