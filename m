From: Simon Horman <horms@verge.net.au>
Subject: [rfc] IPVS: Masq local real-servers
Date: Mon, 20 Sep 2010 18:09:14 +0900
Message-ID: <20100920090911.GA4646@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

IPVS has a special Local forwarding mechanism that is used if the
real-server is a local IP address. Like the Route and Tunnel forwarding
mechanism Local does not allow port mapping, and thus the port of the
real-server is always set to be the same as the virtual service.

The Masq forwarding mechanism does allow port mapping, and this causes some
confusion when the real-server happens to be local.

This patch addresses this confusion by not using the Local forwarding
mechanism if the masq forwarding mechanism is requested. That is, the masq
forwarding mechanism will be used, and the real-servers may have a
different port to the virtual service.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

I considered using Local for the case where the real-server and virtual
service ports are the same. However, this would require updating the
real-servers if the port of the virtual-service was changed, however
editing the forwarding mechanism of a real-server currently isn't
supported and the extra complexity for an unmeasured performance gain seems
to be at best left for another patch.

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_core.c	2010-09-19 20:51:30.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_core.c	2010-09-20 16:30:59.000000000 +0900
@@ -1496,6 +1496,22 @@ static struct nf_hook_ops ip_vs_ops[] __
 		.hooknum        = NF_INET_FORWARD,
 		.priority       = 100,
 	},
+	/* change source only for local VS/NAT */
+	{
+	       .hook           = ip_vs_out,
+	       .owner          = THIS_MODULE,
+	       .pf             = PF_INET,
+	       .hooknum        = NF_INET_LOCAL_OUT,
+	       .priority       = 100,
+	},
+	/* change source only for local VS/NAT */
+	{
+	       .hook           = ip_vs_out,
+	       .owner          = THIS_MODULE,
+	       .pf             = PF_INET,
+	       .hooknum        = NF_INET_LOCAL_OUT,
+	       .priority       = 100,
+	},
 	/* After packet filtering (but before ip_vs_out_icmp), catch icmp
 	 * destined for 0.0.0.0/0, which is for incoming IPVS connections */
 	{
Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-20 15:07:27.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2010-09-20 17:45:46.000000000 +0900
@@ -766,7 +766,7 @@ ip_vs_zero_stats(struct ip_vs_stats *sta
  *	Update a destination in the given service
  */
 static void
-__ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
+_ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 		    struct ip_vs_dest_user_kern *udest, int add)
 {
 	int conn_flags;
@@ -777,18 +777,22 @@ __ip_vs_update_dest(struct ip_vs_service
 	conn_flags |= IP_VS_CONN_F_INACTIVE;
 
 	/* check if local node and update the flags */
+	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ ||
+	    svc->fwmark) {
 #ifdef CONFIG_IP_VS_IPV6
-	if (svc->af == AF_INET6) {
-		if (__ip_vs_addr_is_local_v6(&udest->addr.in6)) {
-			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
-				| IP_VS_CONN_F_LOCALNODE;
-		}
-	} else
+		if (svc->af == AF_INET6) {
+			if (__ip_vs_addr_is_local_v6(&udest->addr.in6)) {
+				conn_flags = (conn_flags &
+					      ~IP_VS_CONN_F_FWD_MASK) |
+					IP_VS_CONN_F_LOCALNODE;
+			}
+		} else
 #endif
 		if (inet_addr_type(&init_net, udest->addr.ip) == RTN_LOCAL) {
 			conn_flags = (conn_flags & ~IP_VS_CONN_F_FWD_MASK)
 				| IP_VS_CONN_F_LOCALNODE;
 		}
+	}
 
 	/* set the IP_VS_CONN_F_NOOUTPUT flag if not masquerading/NAT */
 	if ((conn_flags & IP_VS_CONN_F_FWD_MASK) != IP_VS_CONN_F_MASQ) {
