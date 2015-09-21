From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 69/84] ipvs: Pass ipvs into __ip_vs_get_out_rt_v6
Date: Mon, 21 Sep 2015 13:02:46 -0500
Message-ID: <1442858581-15869-69-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 5cfd914d9a39..13a678a63ed5 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -404,11 +404,12 @@ out_err:
  * Get route to destination or remote server
  */
 static int
-__ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
+		      struct ip_vs_dest *dest,
 		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
 		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct net *net = ipvs->net;
 	struct ip_vs_dest_dst *dest_dst;
 	struct rt6_info *rt;			/* Route to the other host */
 	struct dst_entry *dst;
@@ -663,7 +664,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt_v6(cp->af, skb, NULL, &iph->daddr, NULL,
+	if (__ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, NULL,
+				  &iph->daddr, NULL,
 				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
 		goto tx_error;
 
@@ -799,7 +801,8 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
+				      &cp->daddr.in6,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
@@ -1083,7 +1086,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
+				      &cp->daddr.in6,
 				      &saddr, ipvsh, 1,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
@@ -1209,7 +1213,8 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
+				      &cp->daddr.in6,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
@@ -1370,8 +1375,8 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
-				      NULL, ipvsh, 0, rt_mode);
+	local = __ip_vs_get_out_rt_v6(cp->ipvs, cp->af, skb, cp->dest,
+				      &cp->daddr.in6, NULL, ipvsh, 0, rt_mode);
 	if (local < 0)
 		goto tx_error;
 	rt = (struct rt6_info *) skb_dst(skb);
-- 
2.2.1
