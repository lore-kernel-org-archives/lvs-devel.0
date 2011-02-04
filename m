From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 02/14] IPVS: Add sysctl_snat_reroute()
Date: Fri,  4 Feb 2011 18:46:10 +0900
Message-ID: <1296812782-14953-3-git-send-email-horms@verge.net.au>
References: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1296812782-14953-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_snat_reroute in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index c4c8199..3abc009 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -599,6 +599,20 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 	return NF_DROP;
 }
 
+#ifdef CONFIG_SYSCTL
+
+static int sysctl_snat_reroute(struct sk_buff *skb)
+{
+	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	return ipvs->sysctl_snat_reroute;
+}
+
+#else
+
+static int sysctl_snat_reroute(struct sk_buff *skb) { return 0; }
+
+#endif
+
 __sum16 ip_vs_checksum_complete(struct sk_buff *skb, int offset)
 {
 	return csum_fold(skb_checksum(skb, offset, skb->len - offset, 0));
@@ -633,15 +647,13 @@ static inline int ip_vs_gather_frags_v6(struct sk_buff *skb, u_int32_t user)
 
 static int ip_vs_route_me_harder(int af, struct sk_buff *skb)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
