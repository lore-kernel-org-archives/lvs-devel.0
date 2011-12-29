From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: try also real server with port 0 in backup server
Date: Thu, 29 Dec 2011 22:46:42 +0200
Message-ID: <1325191602-1772-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	We should not forget to try for real server with port 0
in the backup server when processing the sync message. We should
do it in all cases because the backup server can use different
forwarding method.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  |   10 ++++++++--
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 4 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 48fd12e..ebe517f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1207,7 +1207,7 @@ extern void ip_vs_control_cleanup(void);
 extern struct ip_vs_dest *
 ip_vs_find_dest(struct net *net, int af, const union nf_inet_addr *daddr,
 		__be16 dport, const union nf_inet_addr *vaddr, __be16 vport,
-		__u16 protocol, __u32 fwmark);
+		__u16 protocol, __u32 fwmark, __u32 flags);
 extern struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 12571fb..29fa5ba 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -616,7 +616,7 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	if ((cp) && (!cp->dest)) {
 		dest = ip_vs_find_dest(ip_vs_conn_net(cp), cp->af, &cp->daddr,
 				       cp->dport, &cp->vaddr, cp->vport,
-				       cp->protocol, cp->fwmark);
+				       cp->protocol, cp->fwmark, cp->flags);
 		ip_vs_bind_dest(cp, dest);
 		return dest;
 	} else
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 008bf97..e1a66cf 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -619,15 +619,21 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 				   const union nf_inet_addr *daddr,
 				   __be16 dport,
 				   const union nf_inet_addr *vaddr,
-				   __be16 vport, __u16 protocol, __u32 fwmark)
+				   __be16 vport, __u16 protocol, __u32 fwmark,
+				   __u32 flags)
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_service *svc;
+	__be16 port = dport;
 
 	svc = ip_vs_service_get(net, af, fwmark, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
-	dest = ip_vs_lookup_dest(svc, daddr, dport);
+	if (fwmark && (flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ)
+		port = 0;
+	dest = ip_vs_lookup_dest(svc, daddr, port);
+	if (!dest)
+		dest = ip_vs_lookup_dest(svc, daddr, port ^ dport);
 	if (dest)
 		atomic_inc(&dest->refcnt);
 	ip_vs_service_put(svc);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index bcf5563..8a0d6d6 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -740,7 +740,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		 * but still handled.
 		 */
 		dest = ip_vs_find_dest(net, type, daddr, dport, param->vaddr,
-				       param->vport, protocol, fwmark);
+				       param->vport, protocol, fwmark, flags);
 
 		/*  Set the approprite ativity flag */
 		if (protocol == IPPROTO_TCP) {
-- 
1.7.3.4

