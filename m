From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS: use ipv6_addr_copy()
Date: Sat, 6 Sep 2008 14:27:29 +1000
Message-ID: <20080906042727.GE21521@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julius Volz <juliusv@google.com>, Brian Haley <brian.haley@hp.com>

It is standard to use ipv6_addr_copy() to fill in
the in6 element of a union nf_inet_addr snet.

Thanks to Julius Volz for pointing this out.

Cc: Julius Volz <juliusv@google.com>
Cc: Brian Haley <brian.haley@hp.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 05797a5..f07953a 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -847,7 +847,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
 	if (!cp)
 		return NF_ACCEPT;
 
-	snet.in6 = iph->saddr;
+	ipv6_addr_copy(&snet.in6, &iph->saddr);
 	return handle_response_icmp(AF_INET6, skb, &snet, cih->nexthdr, cp,
 				    pp, offset, sizeof(struct ipv6hdr));
 }
@@ -1227,7 +1227,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 		/* The packet could also belong to a local client */
 		cp = pp->conn_out_get(AF_INET6, skb, pp, &ciph, offset, 1);
 		if (cp) {
-			snet.in6 = iph->saddr;
+			ipv6_addr_copy(&snet.in6, &iph->saddr);
 			return handle_response_icmp(AF_INET6, skb, &snet,
 						    cih->nexthdr,
 						    cp, pp, offset,
