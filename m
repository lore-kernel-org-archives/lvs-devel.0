From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 21/24] IPVS: Minimise ip_vs_leave when CONFIG_SYSCTL is undefined
Date: Tue, 15 Mar 2011 14:27:29 +0900
Message-ID: <1300166852-725-22-git-send-email-horms@verge.net.au>
References: <1300166852-725-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1300166852-725-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

Much of ip_vs_leave() is unnecessary if CONFIG_SYSCTL is undefined.

I tried an approach of breaking the now #ifdef'ed portions out
into a separate function. However this appeared to grow the
compiled code on x86_64 by about 200 bytes in the case where
CONFIG_SYSCTL is defined. So I have gone with the simpler though
less elegant #ifdef'ed solution for now.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d418bc6..07accf6 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -499,11 +499,13 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		struct ip_vs_proto_data *pd)
 {
-	struct net *net;
-	struct netns_ipvs *ipvs;
 	__be16 _ports[2], *pptr;
 	struct ip_vs_iphdr iph;
+#ifdef CONFIG_SYSCTL
+	struct net *net;
+	struct netns_ipvs *ipvs;
 	int unicast;
+#endif
 
 	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
 
@@ -512,6 +514,8 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_service_put(svc);
 		return NF_DROP;
 	}
+
+#ifdef CONFIG_SYSCTL
 	net = skb_net(skb);
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -563,6 +567,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ip_vs_conn_put(cp);
 		return ret;
 	}
+#endif
 
 	/*
 	 * When the virtual ftp service is presented, packets destined
-- 
1.7.2.3

