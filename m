From: wzt.wzt@gmail.com
Subject: [PATCH] IPVS: replace sprintf to snprintf to avoid stack buffer overflow
Date: Tue, 6 Apr 2010 10:50:20 +0800
Message-ID: <20100406025020.GA2741@localhost.localdomain>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:mime-version:content-type:content-disposition:user-agent;
        bh=6gNHwzG/6GvUkat9Isd3cm17suRrzN/TlfRMstO/Cm0=;
        b=iGlraj/J7zrXcRtfKp2V17OUhxDXSdcRBHElbNr/qO11sA87v6TOvJvqjnRLBU4ME7
         fdaNm1Lk61PI28pvaUd584EWZx7JBWR/xqXSqflXtGKT2++VZ/ZXoF1Z3M2f7AO58OxI
         2JtAKlyzNb1TZ4Oebs6s1WDfy4PMnKTcfxnaE=
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: wensong@linux-vs.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

IPVS not check the length of pp->name, use sprintf will cause stack buffer overflow.
struct ip_vs_protocol{} declare name as char *, if register a protocol as:
struct ip_vs_protocol ip_vs_test = {
        .name =			"aaaaaaaa....128...aaa",
	.debug_packet =         ip_vs_tcpudp_debug_packet,
};

when called ip_vs_tcpudp_debug_packet(), sprintf(buf, "%s TRUNCATED", pp->name); 
will cause stack buffer overflow.

Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

---
 net/netfilter/ipvs/ip_vs_proto.c        |   16 ++++++++--------
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    8 ++++----
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 0e58455..8143318 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -166,9 +166,9 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		snprintf(buf, sizeof(buf), "%s TRUNCATED", pp->name);
 	else if (ih->frag_off & htons(IP_OFFSET))
-		sprintf(buf, "%s %pI4->%pI4 frag",
+		snprintf(buf, sizeof(buf), "%s %pI4->%pI4 frag",
 			pp->name, &ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr
@@ -176,10 +176,10 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED %pI4->%pI4",
+			snprintf(buf, sizeof(buf), "%s TRUNCATED %pI4->%pI4",
 				pp->name, &ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s %pI4:%u->%pI4:%u",
+			snprintf(buf, sizeof(buf), "%s %pI4:%u->%pI4:%u",
 				pp->name,
 				&ih->saddr, ntohs(pptr[0]),
 				&ih->daddr, ntohs(pptr[1]));
@@ -200,9 +200,9 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		snprintf(buf, sizeof(buf), "%s TRUNCATED", pp->name);
 	else if (ih->nexthdr == IPPROTO_FRAGMENT)
-		sprintf(buf, "%s %pI6->%pI6 frag",
+		snprintf(buf, sizeof(buf), "%s %pI6->%pI6 frag",
 			pp->name, &ih->saddr, &ih->daddr);
 	else {
 		__be16 _ports[2], *pptr;
@@ -210,10 +210,10 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 		pptr = skb_header_pointer(skb, offset + sizeof(struct ipv6hdr),
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
-			sprintf(buf, "%s TRUNCATED %pI6->%pI6",
+			snprintf(buf, sizeof(buf), "%s TRUNCATED %pI6->%pI6",
 				pp->name, &ih->saddr, &ih->daddr);
 		else
-			sprintf(buf, "%s %pI6:%u->%pI6:%u",
+			snprintf(buf, sizeof(buf), "%s %pI6:%u->%pI6:%u",
 				pp->name,
 				&ih->saddr, ntohs(pptr[0]),
 				&ih->daddr, ntohs(pptr[1]));
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index c30b43c..ce795ab 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -136,9 +136,9 @@ ah_esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		snprintf(buf, sizeof(buf), "%s TRUNCATED", pp->name);
 	else
-		sprintf(buf, "%s %pI4->%pI4",
+		snprintf(buf, sizeof(buf), "%s %pI4->%pI4",
 			pp->name, &ih->saddr, &ih->daddr);
 
 	pr_debug("%s: %s\n", msg, buf);
@@ -154,9 +154,9 @@ ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
-		sprintf(buf, "%s TRUNCATED", pp->name);
+		snprintf(buf, sizeof(buf), "%s TRUNCATED", pp->name);
 	else
-		sprintf(buf, "%s %pI6->%pI6",
+		snprintf(buf, sizeof(buf), "%s %pI6->%pI6",
 			pp->name, &ih->saddr, &ih->daddr);
 
 	pr_debug("%s: %s\n", msg, buf);
-- 
1.6.5.3

