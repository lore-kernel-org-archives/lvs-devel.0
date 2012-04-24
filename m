From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v4 3/8] ipvs: fix ip_vs_try_bind_dest to rebind app and transmitter
Date: Tue, 24 Apr 2012 23:46:37 +0300
Message-ID: <1335300402-8076-4-git-send-email-ja@ssi.bg>
References: <1335300402-8076-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335300402-8076-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	Initially, when the synced connection is created we
use the forwarding method provided by master but once we
bind to destination it can be changed. As result, we must
update the application and the transmitter.

	As ip_vs_try_bind_dest is called always for connections
that require dest binding, there is no need to validate the
cp and dest pointers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |   33 ++++++++++++++++++++++++++-------
 1 files changed, 26 insertions(+), 7 deletions(-)

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
1.7.3.4

