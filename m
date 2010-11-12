From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 8/9] IPVS: Break ports[2] into src_port and dst_port
Date: Fri, 12 Nov 2010 08:35:00 +0100
Message-ID: <1289547301-28015-8-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

Avoid sending invalid pointer due to skb_linearize() call.
This patch prepares for next patch where skb_linearize is a part.

In ip_vs_sched_persist() params the ports ptr will be replaced by
src and dst port.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_core.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e2bb3cd..9acdd79 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -200,7 +200,7 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 static struct ip_vs_conn *
 ip_vs_sched_persist(struct ip_vs_service *svc,
 		    struct sk_buff *skb,
-		    __be16 ports[2])
+		    __be16 src_port, __be16 dst_port)
 {
 	struct ip_vs_conn *cp = NULL;
 	struct ip_vs_iphdr iph;
@@ -224,8 +224,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 
 	IP_VS_DBG_BUF(6, "p-schedule: src %s:%u dest %s:%u "
 		      "mnet %s\n",
-		      IP_VS_DBG_ADDR(svc->af, &iph.saddr), ntohs(ports[0]),
-		      IP_VS_DBG_ADDR(svc->af, &iph.daddr), ntohs(ports[1]),
+		      IP_VS_DBG_ADDR(svc->af, &iph.saddr), ntohs(src_port),
+		      IP_VS_DBG_ADDR(svc->af, &iph.daddr), ntohs(dst_port),
 		      IP_VS_DBG_ADDR(svc->af, &snet));
 
 	/*
@@ -247,14 +247,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
 		__be16 vport = 0;
 
-		if (ports[1] == svc->port) {
+		if (dst_port == svc->port) {
 			/* non-FTP template:
 			 * <protocol, caddr, 0, vaddr, vport, daddr, dport>
 			 * FTP template:
 			 * <protocol, caddr, 0, vaddr, 0, daddr, 0>
 			 */
 			if (svc->port != FTPPORT)
-				vport = ports[1];
+				vport = dst_port;
 		} else {
 			/* Note: persistent fwmark-based services and
 			 * persistent port zero service are handled here.
@@ -285,7 +285,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 			return NULL;
 		}
 
-		if (ports[1] == svc->port && svc->port != FTPPORT)
+		if (dst_port == svc->port && svc->port != FTPPORT)
 			dport = dest->port;
 
 		/* Create a template
@@ -306,7 +306,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		kfree(param.pe_data);
 	}
 
-	dport = ports[1];
+	dport = dst_port;
 	if (dport == svc->port && dest->port)
 		dport = dest->port;
 
@@ -317,8 +317,9 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	/*
 	 *    Create a new connection according to the template
 	 */
-	ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr, ports[0],
-			      &iph.daddr, ports[1], &param);
+	ip_vs_conn_fill_param(svc->af, iph.protocol, &iph.saddr, src_port,
+			      &iph.daddr, dst_port, &param);
+
 	cp = ip_vs_conn_new(&param, &dest->addr, dport, flags, dest, skb->mark);
 	if (cp == NULL) {
 		ip_vs_conn_put(ct);
@@ -388,7 +389,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 */
 	if (svc->flags & IP_VS_SVC_F_PERSISTENT) {
 		*ignored = 0;
-		return ip_vs_sched_persist(svc, skb, pptr);
+		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1]);
 	}
 
 	/*
-- 
1.7.2.3

