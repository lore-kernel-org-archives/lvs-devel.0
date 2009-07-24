From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG
	messages
Date: Fri, 24 Jul 2009 12:47:16 +1000
Message-ID: <20090724024711.GA13280@verge.net.au>
References: <20090624132232.GA9633@egardia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090624132232.GA9633@egardia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Julius Volz <julius.volz@gmail.com>, Rob Gallagher <robert.gallagher@heanet.ie>

From: Julius Volz <julius.volz@gmail.com>

IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG messages

Add handling of incoming ICMPv6 Packet Too Big messages. This message
is received when a realserver sends a packet >PMTU to the client. The
hop on this path with insufficient MTU will generate an ICMPv6 Packet
Too Big message back to the VIP. The LVS server receives this message,
but the call to the function handling this has been missing. Thus, IPVS
fails to forward the message to the real server, which then does not
adjust the path MTU. This patch adds the missing call to
ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.

Thanks to Rob Gallagher from HEAnet for reporting this issue and for
testing this patch in production (with direct routing mode).

Signed-off-by: Julius Volz <julius.volz@gmail.com>
Tested-by: Rob Gallagher <robert.gallagher@heanet.ie>
Signed-off-by: Simon Horman <horms@verge.net.au>

---
 net/netfilter/ipvs/ip_vs_core.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

Dave, please consider applying this change.

I'm ok with it not going into 2.6.31 as I don't think that
many people are affected by this problem.

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
