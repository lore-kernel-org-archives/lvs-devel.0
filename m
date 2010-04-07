From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPVS: replace sprintf to snprintf to avoid stack buffer
 overflow
Date: Wed, 07 Apr 2010 18:09:54 +0200
Message-ID: <4BBCAE52.9080501@trash.net>
References: <20100406025020.GA2741@localhost.localdomain> <20100406032248.GF30359@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070109050004060302030809"
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100406032248.GF30359@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Cc: wzt.wzt@gmail.com, linux-kernel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

This is a multi-part message in MIME format.
--------------070109050004060302030809
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Simon Horman wrote:
> On Tue, Apr 06, 2010 at 10:50:20AM +0800, wzt.wzt@gmail.com wrote:
>> IPVS not check the length of pp->name, use sprintf will cause stack buffer overflow.
>> struct ip_vs_protocol{} declare name as char *, if register a protocol as:
>> struct ip_vs_protocol ip_vs_test = {
>>         .name =			"aaaaaaaa....128...aaa",
>> 	.debug_packet =         ip_vs_tcpudp_debug_packet,
>> };
>>
>> when called ip_vs_tcpudp_debug_packet(), sprintf(buf, "%s TRUNCATED", pp->name); 
>> will cause stack buffer overflow.
>>
>> Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>
> 
> I think that the simple answer is, don't do that.

Indeed.

> But your patch seems entirely reasonable to me.
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Patrick, please consider merging this.

I think this fix is a bit silly, we can simply print the name in
the pr_debug() statement and avoid both the potential overflow
and truncation.

How does this look?

--------------070109050004060302030809
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 0e58455..27add97 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -166,26 +166,24 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		sprintf(buf, "TRUNCATED");
 	else if (ih->frag_off & htons(IP_OFFSET))
-		sprintf(buf, "%s %pI4->%pI4 frag",
-			pp->name, &ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI4->%pI4 frag", &ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr
 ;
 		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED %pI4->%pI4",
-				pp->name, &ih->saddr, &ih->daddr);
+			sprintf(buf, "TRUNCATED %pI4->%pI4",
+				&ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s %pI4:%u->%pI4:%u",
-				pp->name,
+			sprintf(buf, "%pI4:%u->%pI4:%u",
 				&ih->saddr, ntohs(pptr[0]),
 				&ih->daddr, ntohs(pptr[1]));
 	}
 
-	pr_debug("%s: %s\n", msg, buf);
+	pr_debug("%s: %s %s\n", msg, pp->name, buf);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -200,26 +198,24 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		sprintf(buf, "TRUNCATED");
 	else if (ih->nexthdr == IPPROTO_FRAGMENT)
-		sprintf(buf, "%s %pI6->%pI6 frag",
-			pp->name, &ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI6->%pI6 frag",	&ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr;
 
 		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED %pI6->%pI6",
-				pp->name, &ih->saddr, &ih->daddr);
+			sprintf(buf, "TRUNCATED %pI6->%pI6",
+				&ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s %pI6:%u->%pI6:%u",
-				pp->name,
+			sprintf(buf, "%pI6:%u->%pI6:%u",
 				&ih->saddr, ntohs(pptr[0]),
 				&ih->daddr, ntohs(pptr[1]));
 	}
 
-	pr_debug("%s: %s\n", msg, buf);
+	pr_debug("%s: %s %s\n", msg, pp->name, buf);
 }
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index c30b43c..1892dfc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -136,12 +136,11 @@ ah_esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		sprintf(buf, "TRUNCATED");
 	else
-		sprintf(buf, "%s %pI4->%pI4",
-			pp->name, &ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI4->%pI4", &ih->saddr, &ih->daddr);
 
-	pr_debug("%s: %s\n", msg, buf);
+	pr_debug("%s: %s %s\n", msg, pp->name, buf);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -154,12 +153,11 @@ ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		sprintf(buf, "TRUNCATED");
 	else
-		sprintf(buf, "%s %pI6->%pI6",
-			pp->name, &ih->saddr, &ih->daddr);
+		sprintf(buf, "%pI6->%pI6", &ih->saddr, &ih->daddr);
 
-	pr_debug("%s: %s\n", msg, buf);
+	pr_debug("%s: %s %s\n", msg, pp->name, buf);
 }
 #endif
 

--------------070109050004060302030809--
