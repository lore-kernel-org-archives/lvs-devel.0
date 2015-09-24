From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 14/84] ipvs: Pass ipvs not net to ip_vs_find_dest
Date: Thu, 24 Sep 2015 09:51:59 +0900
Message-ID: <1443055989-1306-15-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 4 ++--
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b93ee28fb011..b54a19eaa630 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1423,7 +1423,7 @@ void ip_vs_unregister_nl_ioctl(void);
 int ip_vs_control_init(void);
 void ip_vs_control_cleanup(void);
 struct ip_vs_dest *
-ip_vs_find_dest(struct net *net, int svc_af, int dest_af,
+ip_vs_find_dest(struct netns_ipvs *ipvs, int svc_af, int dest_af,
 		const union nf_inet_addr *daddr, __be16 dport,
 		const union nf_inet_addr *vaddr, __be16 vport,
 		__u16 protocol, __u32 fwmark, __u32 flags);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 3e277093ec45..ce788f8781f4 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -638,7 +638,7 @@ void ip_vs_try_bind_dest(struct ip_vs_conn *cp)
 	 * so we can make the assumption that the svc_af is the same as the
 	 * dest_af
 	 */
-	dest = ip_vs_find_dest(cp->ipvs->net, cp->af, cp->af, &cp->daddr,
+	dest = ip_vs_find_dest(cp->ipvs, cp->af, cp->af, &cp->daddr,
 			       cp->dport, &cp->vaddr, cp->vport,
 			       cp->protocol, cp->fwmark, cp->flags);
 	if (dest) {
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 8f914b67b41a..24dceaccb0a1 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -599,7 +599,7 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, int dest_af,
  * on the backup.
  * Called under RCU lock, no refcnt is returned.
  */
-struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int svc_af, int dest_af,
+struct ip_vs_dest *ip_vs_find_dest(struct netns_ipvs *ipvs, int svc_af, int dest_af,
 				   const union nf_inet_addr *daddr,
 				   __be16 dport,
 				   const union nf_inet_addr *vaddr,
@@ -610,7 +610,7 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int svc_af, int dest_af,
 	struct ip_vs_service *svc;
 	__be16 port = dport;
 
-	svc = ip_vs_service_find(net_ipvs(net), svc_af, fwmark, protocol, vaddr, vport);
+	svc = ip_vs_service_find(ipvs, svc_af, fwmark, protocol, vaddr, vport);
 	if (!svc)
 		return NULL;
 	if (fwmark && (flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ)
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f8bc2027a6c4..9a49c3899f2e 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -904,7 +904,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		 * with synchronization, so we can make the assumption that
 		 * the svc_af is the same as the dest_af
 		 */
-		dest = ip_vs_find_dest(net, type, type, daddr, dport,
+		dest = ip_vs_find_dest(ipvs, type, type, daddr, dport,
 				       param->vaddr, param->vport, protocol,
 				       fwmark, flags);
 
-- 
2.1.4

