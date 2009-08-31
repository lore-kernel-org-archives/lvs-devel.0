From: Simon Horman <horms@verge.net.au>
Subject: [patch, v2] IPVS: Add handling of incoming ICMPV6 messages
Date: Mon, 31 Aug 2009 17:59:06 +1000
Message-ID: <20090831075904.GA3430@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Julius Volz <julius.volz@gmail.com>, Rob Gallagher <robert.gallagher@heanet.ie>

From: Julius Volz <julius.volz@gmail.com>

IPVS: Add handling of incoming ICMPV6 messages

Add handling of incoming ICMPv6 messages.
This follows the handling of IPv4 ICMP messages.

Amongst ther things this problem allows IPVS to behave sensibly
when an ICMPV6_PKT_TOOBIG message is received:

    This message is received when a realserver sends a packet >PMTU to the
    client. The hop on this path with insufficient MTU will generate an
    ICMPv6 Packet Too Big message back to the VIP. The LVS server receives
    this message, but the call to the function handling this has been
    missing. Thus, IPVS fails to forward the message to the real server,
    which then does not adjust the path MTU. This patch adds the missing
    call to ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.

    Thanks to Rob Gallagher from HEAnet for reporting this issue and for
    testing this patch in production (with direct routing mode).

[horms@verge.net.au: tweaked changelog]
Signed-off-by: Julius Volz <julius.volz@gmail.com>
Tested-by: Rob Gallagher <robert.gallagher@heanet.ie>
Signed-off-by: Simon Horman <horms@verge.net.au>

---
 net/netfilter/ipvs/ip_vs_core.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

Changelog
---------

* Fri, 24 Jul 2009 12:47:16 +1000
  Initial post to netdev

* Mon, 31 Aug 2009 17:53:40 +1000
  Tweaked commit message as per feedback

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 8dddb17..5750800 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1274,13 +1274,24 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 		return NF_ACCEPT;
 	}
 
-	if (unlikely(iph.protocol == IPPROTO_ICMP)) {
-		int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
+			int related, verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
 
-		if (related)
-			return verdict;
-		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
-	}
+			if (related)
+				return verdict;
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
+	} else
+#endif
+		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
+			int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
+
+			if (related)
+				return verdict;
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
 
 	/* Protocol supported? */
 	pp = ip_vs_proto_get(iph.protocol);
--
To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
