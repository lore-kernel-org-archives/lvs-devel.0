From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 10/18] ipvs: fix ip_vs_try_bind_dest to rebind app and transmitter
Date: Wed,  2 May 2012 15:22:34 +0900
Message-ID: <1335939762-1912-11-git-send-email-horms@verge.net.au>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Initially, when the synced connection is created we
use the forwarding method provided by master but once we
bind to destination it can be changed. As result, we must
update the application and the transmitter.

	As ip_vs_try_bind_dest is called always for connections
that require dest binding, there is no need to validate the
cp and dest pointers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |   33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 7647f3b..9d237d7 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -612,14 +612,33 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 {
 	struct ip_vs_dest *dest;
 
-	if ((cp) && (!cp->dest)) {
-		dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, &cp->daddr,
-				       cp->dport, &cp->vaddr, cp->vport,
-				       cp->protocol, cp->fwmark, cp->flags);
+	dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, &cp->daddr,
+			       cp->dport, &cp->vaddr, cp->vport,
+			       cp->protocol, cp->fwmark, cp->flags);
+	if (dest) {
+		struct ip_vs_proto_data *pd;
+
+		/* Applications work depending on the forwarding method
+		 * but better to reassign them always when binding dest */
+		if (cp->app)
+			ip_vs_unbind_app(cp);
+
 		ip_vs_bind_dest(cp, dest);
-		return dest;
-	} else
-		return NULL;
+
+		/* Update its packet transmitter */
+		cp->packet_xmit = NULL;
+#ifdef CONFIG_IP_VS_IPV6
+		if (cp->af == AF_INET6)
+			ip_vs_bind_xmit_v6(cp);
+		else
+#endif
+			ip_vs_bind_xmit(cp);
+
+		pd = ip_vs_proto_data_get(ip_vs_conn_net(cp), cp->protocol);
+		if (pd && atomic_read(&pd->appcnt))
+			ip_vs_bind_app(cp, pd->pp);
+	}
+	return dest;
 }
 
 
-- 
1.7.10
