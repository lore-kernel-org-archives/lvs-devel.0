From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 05/18] ipvs: Supply skb_af to out_rt* functions
Date: Thu, 14 Aug 2014 20:23:28 -0700
Message-ID: <1408073021-24007-6-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=tZO7e79lPcswDKkhc9BTSeAgYFsuuX32yBvWwefBqOY=;
 b=ADbgucRc6GZ0f1v3oRfqRXE3uLKTy4ynhWYELD6FU5mhEym9F7Nl7kWskqyEyaC4k9uf
 ZZvUCKc5tquBit+X/SPKbgfd9JHpOBZ+Z77m6KKGvXDNNjLGwKlm0HxWX7Ox4kKO6A/h
 M9XmpsMp3r16SN80scg+JptEhAOwwGcdQ78= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

The out_rt functions inspect the skb's to ensure that we aren't breaking
any rules by crossing local/external boundaries.  Right now, they assume
that the address family of the skb packets is the same as they are, but
that assumption will no longer be true.

This patch introduces an additional parameter to the out route functions so
that we can make more intelligent decisions based upon the actual skb
address family later.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 56896a4..94c7466 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -159,7 +159,7 @@ retry:
 
 /* Get route to destination or remote server */
 static int
-__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		   __be32 daddr, int rt_mode, __be32 *ret_saddr)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
@@ -339,7 +339,7 @@ out_err:
  * Get route to destination or remote server
  */
 static int
-__ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
+__ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 		      struct in6_addr *daddr, struct in6_addr *ret_saddr,
 		      struct ip_vs_iphdr *ipvsh, int do_xfrm, int rt_mode)
 {
@@ -556,8 +556,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt(skb, NULL, iph->daddr, IP_VS_RT_MODE_NON_LOCAL,
-			       NULL) < 0)
+	if (__ip_vs_get_out_rt(cp->af, skb, NULL, iph->daddr,
+			       IP_VS_RT_MODE_NON_LOCAL, NULL) < 0)
 		goto tx_error;
 
 	ip_send_check(iph);
@@ -586,7 +586,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	if (__ip_vs_get_out_rt_v6(skb, NULL, &ipvsh->daddr.in6, NULL,
+	if (__ip_vs_get_out_rt_v6(cp->af, skb, NULL, &ipvsh->daddr.in6, NULL,
 				  ipvsh, 0, IP_VS_RT_MODE_NON_LOCAL) < 0)
 		goto tx_error;
 
@@ -633,7 +633,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	was_input = rt_is_input_route(skb_rtable(skb));
-	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_RDR, NULL);
@@ -721,8 +721,8 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-				      ipvsh, 0,
+	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
 				      IP_VS_RT_MODE_RDR);
@@ -829,7 +829,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_CONNECT |
@@ -928,7 +928,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6,
+	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
 				      &saddr, ipvsh, 1,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL |
@@ -1021,7 +1021,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip,
+	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip,
 				   IP_VS_RT_MODE_LOCAL |
 				   IP_VS_RT_MODE_NON_LOCAL |
 				   IP_VS_RT_MODE_KNOWN_NH, NULL);
@@ -1060,8 +1060,8 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	EnterFunction(10);
 
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-				      ipvsh, 0,
+	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
 				      IP_VS_RT_MODE_NON_LOCAL);
 	if (local < 0)
@@ -1128,7 +1128,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt(skb, cp->dest, cp->daddr.ip, rt_mode, NULL);
+	local = __ip_vs_get_out_rt(cp->af, skb, cp->dest, cp->daddr.ip, rt_mode,
+				   NULL);
 	if (local < 0)
 		goto tx_error;
 	rt = skb_rtable(skb);
@@ -1219,8 +1220,8 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  IP_VS_RT_MODE_LOCAL | IP_VS_RT_MODE_NON_LOCAL |
 		  IP_VS_RT_MODE_RDR : IP_VS_RT_MODE_NON_LOCAL;
 	rcu_read_lock();
-	local = __ip_vs_get_out_rt_v6(skb, cp->dest, &cp->daddr.in6, NULL,
-				      ipvsh, 0, rt_mode);
+	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
+				      NULL, ipvsh, 0, rt_mode);
 	if (local < 0)
 		goto tx_error;
 	rt = (struct rt6_info *) skb_dst(skb);
-- 
1.8.1

