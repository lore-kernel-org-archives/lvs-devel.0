From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 05/15] ipvs: rename functions related to dst_cache reset
Date: Thu, 28 Mar 2013 14:39:34 +0900
Message-ID: <1364449184-26672-6-git-send-email-horms@verge.net.au>
References: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Move and give better names to two functions:

- ip_vs_dst_reset to __ip_vs_dst_cache_reset
- __ip_vs_dev_reset to ip_vs_forget_dev

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    1 -
 net/netfilter/ipvs/ip_vs_ctl.c  |   34 ++++++++++++++++++++++------------
 net/netfilter/ipvs/ip_vs_xmit.c |   14 --------------
 3 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9af673c..8e33c5d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1415,7 +1415,6 @@ extern int ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 extern int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 			   struct ip_vs_protocol *pp, int offset,
 			   unsigned int hooknum, struct ip_vs_iphdr *iph);
-extern void ip_vs_dst_reset(struct ip_vs_dest *dest);
 
 #ifdef CONFIG_IP_VS_IPV6
 extern int ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2af8074..ba099c8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -641,6 +641,17 @@ struct ip_vs_dest *ip_vs_find_dest(struct net  *net, int af,
 	return dest;
 }
 
+/* Release dst_cache for dest in user context */
+static void __ip_vs_dst_cache_reset(struct ip_vs_dest *dest)
+{
+	struct dst_entry *old_dst;
+
+	old_dst = dest->dst_cache;
+	dest->dst_cache = NULL;
+	dst_release(old_dst);
+	dest->dst_saddr.ip = 0;
+}
+
 /*
  *  Lookup dest by {svc,addr,port} in the destination trash.
  *  The destination trash is used to hold the destinations that are removed
@@ -690,7 +701,7 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
 				      ntohs(dest->port));
 			list_del(&dest->n_list);
-			ip_vs_dst_reset(dest);
+			__ip_vs_dst_cache_reset(dest);
 			__ip_vs_unbind_svc(dest);
 			free_percpu(dest->stats.cpustats);
 			kfree(dest);
@@ -717,7 +728,7 @@ static void ip_vs_trash_cleanup(struct net *net)
 
 	list_for_each_entry_safe(dest, nxt, &ipvs->dest_trash, n_list) {
 		list_del(&dest->n_list);
-		ip_vs_dst_reset(dest);
+		__ip_vs_dst_cache_reset(dest);
 		__ip_vs_unbind_svc(dest);
 		free_percpu(dest->stats.cpustats);
 		kfree(dest);
@@ -811,7 +822,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	dest->l_threshold = udest->l_threshold;
 
 	spin_lock_bh(&dest->dst_lock);
-	ip_vs_dst_reset(dest);
+	__ip_vs_dst_cache_reset(dest);
 	spin_unlock_bh(&dest->dst_lock);
 
 	if (add)
@@ -1037,7 +1048,7 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 			      dest->vfwmark,
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port));
-		ip_vs_dst_reset(dest);
+		__ip_vs_dst_cache_reset(dest);
 		/* simply decrease svc->refcnt here, let the caller check
 		   and release the service if nobody refers to it.
 		   Only user context can release destination and service,
@@ -1496,11 +1507,10 @@ void ip_vs_service_net_cleanup(struct net *net)
 	mutex_unlock(&__ip_vs_mutex);
 	LeaveFunction(2);
 }
-/*
- * Release dst hold by dst_cache
- */
+
+/* Put all references for device (dst_cache) */
 static inline void
-__ip_vs_dev_reset(struct ip_vs_dest *dest, struct net_device *dev)
+ip_vs_forget_dev(struct ip_vs_dest *dest, struct net_device *dev)
 {
 	spin_lock_bh(&dest->dst_lock);
 	if (dest->dst_cache && dest->dst_cache->dev == dev) {
@@ -1509,7 +1519,7 @@ __ip_vs_dev_reset(struct ip_vs_dest *dest, struct net_device *dev)
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
-		ip_vs_dst_reset(dest);
+		__ip_vs_dst_cache_reset(dest);
 	}
 	spin_unlock_bh(&dest->dst_lock);
 
@@ -1537,7 +1547,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 			if (net_eq(svc->net, net)) {
 				list_for_each_entry(dest, &svc->destinations,
 						    n_list) {
-					__ip_vs_dev_reset(dest, dev);
+					ip_vs_forget_dev(dest, dev);
 				}
 			}
 		}
@@ -1546,7 +1556,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 			if (net_eq(svc->net, net)) {
 				list_for_each_entry(dest, &svc->destinations,
 						    n_list) {
-					__ip_vs_dev_reset(dest, dev);
+					ip_vs_forget_dev(dest, dev);
 				}
 			}
 
@@ -1554,7 +1564,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
 	}
 
 	list_for_each_entry(dest, &ipvs->dest_trash, n_list) {
-		__ip_vs_dev_reset(dest, dev);
+		ip_vs_forget_dev(dest, dev);
 	}
 	mutex_unlock(&__ip_vs_mutex);
 	LeaveFunction(2);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 7cd7c61..6448a2e 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -362,20 +362,6 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 #endif
 
 
-/*
- *	Release dest->dst_cache before a dest is removed
- */
-void
-ip_vs_dst_reset(struct ip_vs_dest *dest)
-{
-	struct dst_entry *old_dst;
-
-	old_dst = dest->dst_cache;
-	dest->dst_cache = NULL;
-	dst_release(old_dst);
-	dest->dst_saddr.ip = 0;
-}
-
 /* return NF_ACCEPT to allow forwarding or other NF_xxx on error */
 static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 					    struct ip_vs_conn *cp)
-- 
1.7.10.4

