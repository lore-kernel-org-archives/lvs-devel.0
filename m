From: Simon Horman <horms@verge.net.au>
Subject: [patch] ipvs: zero usvc and udest
Date: Tue, 15 Dec 2009 09:39:03 +1100
Message-ID: <20091214223902.GA3784@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Deon van der Merwe <dvdm@truteq.co.za>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, David Miller <davem@davemloft.org>

Make sure that any otherwise uninitialised fields of usvc are zero.

This has been obvserved to cause a problem whereby the port of
fwmark services may end up as a non-zero value which causes
scheduling of a destination server to fail for persisitent services.

As observed by Deon van der Merwe <dvdm@truteq.co.za>.
This fix suggested by Julian Anastasov <ja@ssi.bg>.

For good measure also zero udest.

Cc: Deon van der Merwe <dvdm@truteq.co.za>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

This bug has been present since the netlink interface to IPVS was
introduced in 2.6.28. I think it is relevant for 2.6.33 as well
as -stable.

Index: linux-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- linux-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2009-12-11 14:22:23.000000000 +0900
+++ linux-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2009-12-14 11:05:50.000000000 +0900
@@ -2714,6 +2714,8 @@ static int ip_vs_genl_parse_service(stru
 	if (!(nla_af && (nla_fwmark || (nla_port && nla_protocol && nla_addr))))
 		return -EINVAL;
 
+	memset(usvc, 0, sizeof(*usvc));
+
 	usvc->af = nla_get_u16(nla_af);
 #ifdef CONFIG_IP_VS_IPV6
 	if (usvc->af != AF_INET && usvc->af != AF_INET6)
@@ -2901,6 +2903,8 @@ static int ip_vs_genl_parse_dest(struct 
 	if (!(nla_addr && nla_port))
 		return -EINVAL;
 
+	memset(udest, 0, sizeof(*udest));
+
 	nla_memcpy(&udest->addr, nla_addr, sizeof(udest->addr));
 	udest->port = nla_get_u16(nla_port);
 

