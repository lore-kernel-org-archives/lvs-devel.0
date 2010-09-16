From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 3/3] ipvs: make rerouting optional with snat_reroute
Date: Thu, 16 Sep 2010 23:49:52 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009162346520.6976@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Add new sysctl flag "snat_reroute". Recent kernels use
ip_route_me_harder() to route LVS-NAT responses properly by
VIP when there are multiple paths to client. But setups
that do not have alternative default routes can skip this
routing lookup by using snat_reroute=0.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp net-next-2.6-e548833-nfct/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- net-next-2.6-e548833-nfct/linux/include/net/ip_vs.h	2010-09-16 09:02:25.000000000 +0300
+++ linux/include/net/ip_vs.h	2010-09-16 09:03:48.000000000 +0300
@@ -801,6 +801,7 @@ extern int sysctl_ip_vs_expire_quiescent
 extern int sysctl_ip_vs_sync_threshold[2];
 extern int sysctl_ip_vs_nat_icmp_send;
 extern int sysctl_ip_vs_conntrack;
+extern int sysctl_ip_vs_snat_reroute;
 extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
 
diff -urp net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
--- net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-16 09:02:25.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-16 09:07:13.000000000 +0300
@@ -929,20 +929,31 @@ handle_response(int af, struct sk_buff *
 		ip_send_check(ip_hdr(skb));
 	}
 
+	/*
+	 * nf_iterate does not expect change in the skb->dst->dev.
+	 * It looks like it is not fatal to enable this code for hooks
+	 * where our handlers are at the end of the chain list and
+	 * when all next handlers use skb->dst->dev and not outdev.
+	 * It will definitely route properly the inout NAT traffic
+	 * when multiple paths are used.
+	 */
+
 	/* For policy routing, packets originating from this
 	 * machine itself may be routed differently to packets
 	 * passing through.  We want this packet to be routed as
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
+	if (sysctl_ip_vs_snat_reroute) {
 #ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6) {
-		if (ip6_route_me_harder(skb) != 0)
-			goto drop;
-	} else
+		if (af == AF_INET6) {
+			if (ip6_route_me_harder(skb) != 0)
+				goto drop;
+		} else
 #endif
-		if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
-			goto drop;
+			if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
+				goto drop;
+	}
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
 
@@ -991,8 +1002,13 @@ ip_vs_out(unsigned int hooknum, struct s
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
 
-			if (related)
+			if (related) {
+				if (sysctl_ip_vs_snat_reroute &&
+					NF_ACCEPT == verdict &&
+					ip6_route_me_harder(skb))
+					verdict = NF_DROP;
 				return verdict;
+			}
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 	} else
@@ -1000,8 +1016,13 @@ ip_vs_out(unsigned int hooknum, struct s
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related, verdict = ip_vs_out_icmp(skb, &related);
 
-			if (related)
+			if (related) {
+				if (sysctl_ip_vs_snat_reroute &&
+					NF_ACCEPT == verdict &&
+					ip_route_me_harder(skb, RTN_LOCAL))
+					verdict = NF_DROP;
 				return verdict;
+			}
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 
diff -urp net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_ctl.c linux/net/netfilter/ipvs/ip_vs_ctl.c
--- net-next-2.6-e548833-nfct/linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-16 09:02:25.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-16 09:08:47.000000000 +0300
@@ -91,6 +91,7 @@ int sysctl_ip_vs_nat_icmp_send = 0;
 #ifdef CONFIG_IP_VS_NFCT
 int sysctl_ip_vs_conntrack;
 #endif
+int sysctl_ip_vs_snat_reroute = 1;
 
 
 #ifdef CONFIG_IP_VS_DEBUG
@@ -1599,6 +1600,13 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
+	{
+		.procname	= "snat_reroute",
+		.data		= &sysctl_ip_vs_snat_reroute,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #if 0
 	{
 		.procname	= "timeout_established",
