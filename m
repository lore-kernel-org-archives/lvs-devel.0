From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 68/84] ipvs: Pass ipvs into __ip_vs_get_out_rt
Date: Sun, 20 Sep 2015 01:23:24 -0500
Message-ID: <1442730220-32458-68-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index ec10ebf246fd..5cfd914d9a39 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -257,11 +257,12 @@ static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
 
 /* Get route to destination or remote server */
 static int
-__ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
+		   struct ip_vs_dest *dest,
 		   __be32 daddr, int rt_mode, __be32 *ret_saddr,
 		   struct ip_vs_iphdr *ipvsh)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct net *net = ipvs->net;
 	struct ip_vs_dest_dst *dest_dst;
 	struct rtable *rt;			/* Route to the other host */
 	int mtu;
@@ -630,7 +631,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt(cp->af, skb, NULL, iph->daddr,
+	if (__ip_vs_get_out_rt(cp->ipvs, cp->af, skb, NULL, iph->daddr,
 			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
 		goto tx_error;
 
@@ -709,7 +710,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	was_input = rt_is_input_route(skb_rtable(skb));
-	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_RDR, NULL, ipvsh);
@@ -988,7 +989,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
@@ -1169,7 +1170,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_KNOWN_NH, NULL, ipvsh);
@@ -1277,7 +1278,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
+	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
 				   NULL, iph);
 	if (local < 0)
 		goto tx_error;
-- 
2.2.1
