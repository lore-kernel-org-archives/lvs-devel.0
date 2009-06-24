From: Julius Volz <julius.volz@gmail.com>
Subject: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG messages
Date: Wed, 24 Jun 2009 15:22:32 +0200
Message-ID: <20090624132232.GA9633@egardia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:mime-version:content-type:content-disposition:user-agent;
        bh=Mc6oaprkQb4u2nVh4/GxCtUMDDhgpGqZj1WpGm+Fors=;
        b=fMOZddJJhvK64M4WY7wE8E8hh4p1du8IfhirGbRn4DoGagYTOnmZkIC3fP/kNLYh41
         /zMRiZlug/si4KQ8xhgaRHECM9lnyQXz8I77AWYqMjD609nJFv22YnvB/hMdJITk702L
         YT20+81x0yN3JjFBHZ0I9gO9PZvnlMA6FaoQc=
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: robert.gallagher@heanet.ie, horms@verge.net.au

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
---
 net/netfilter/ipvs/ip_vs_core.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

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
1.6.0.4

