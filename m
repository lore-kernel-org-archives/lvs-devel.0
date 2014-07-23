From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs 1/2] ipvs: Do tcp/udp checksumming prior to tunnel xmit
Date: Tue, 22 Jul 2014 23:37:44 -0700
Message-ID: <1406097465-8180-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=cxClRtCypiig/1vdmC9U8WnbnkiPsQe8uVyX18eBdsc=;
 b=QCMXQC80cVcLJhlABsFcC/MjviMcwBGhnkVewTnfa9gjjrnKYPMsDXREVVhKtEV50eao
 PhfFSPjpOMDxOcmCX7nxfIGBXoCOxFm4ftcCzHzLDCHiBZUIvID5rZ0kj2ojUlFRbBSL
 9vtHeLt4pbjmYRQgn5tKEu6uFSSSyguRx1k= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

The combination of NF_INET_LOCAL_OUT and hardware checksum offload results
in picking the packet out of the send path before it gets proper checksums.
Our NICs (most NICs?) cannot do the checksumming in ipip packets, so these
faulty tcp/udp headers arrive at their destination and are discarded.

Instead, checksum the tcp/udp packets in the tunnel transmit path.  Right
now we do this for all packets, but a subsequent patch will limit this to
the NF_INET_LOCAL_OUT hook.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 49 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6f70bdd..e9b5e6e 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -37,6 +37,7 @@
 #include <net/icmp.h>                   /* for icmp_send */
 #include <net/route.h>                  /* for ip_route_output */
 #include <net/ipv6.h>
+#include <net/ip6_checksum.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
 #include <linux/icmpv6.h>
@@ -824,6 +825,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	int ret, local;
+	unsigned int l4_len = 0;
 
 	EnterFunction(10);
 
@@ -862,6 +864,29 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ip_hdr(skb);
 	}
 
+	{
+		/* ipip breaks layer 4 checksumming on many (all?) NICs, so
+		 * we must do it ourselves instead of relying upon checksum
+		 * offload */
+		l4_len = ntohs(old_iph->tot_len) - (old_iph->ihl * 4);
+		switch (old_iph->protocol) {
+		case IPPROTO_TCP:
+			tcp_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = tcp_v4_check(
+				l4_len, old_iph->saddr, old_iph->daddr,
+				csum_partial(tcp_hdr(skb), l4_len, 0));
+			break;
+		case IPPROTO_UDP:
+			udp_hdr(skb)->check = 0;
+			udp_hdr(skb)->check = udp_v4_check(
+				l4_len, old_iph->saddr, old_iph->daddr,
+				csum_partial(udp_hdr(skb), l4_len, 0));
+			break;
+		default:
+			break;
+		}
+	}
+
 	skb->transport_header = skb->network_header;
 
 	/* fix old IP header checksum */
@@ -918,6 +943,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	struct ipv6hdr  *iph;		/* Our new IP header */
 	unsigned int max_headroom;	/* The extra header space needed */
 	int ret, local;
+	unsigned int l4_len = 0;
 
 	EnterFunction(10);
 
@@ -953,6 +979,29 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ipv6_hdr(skb);
 	}
 
+	{
+		/* ipip breaks layer 4 checksumming on many (all?) NICs, so
+		 * we must do it ourselves instead of relying upon checksum
+		 * offload */
+		l4_len = ntohs(old_iph->payload_len);
+		switch (old_iph->nexthdr) {
+		case IPPROTO_TCP:
+			tcp_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = tcp_v6_check(
+				l4_len, &old_iph->saddr, &old_iph->daddr,
+				csum_partial(tcp_hdr(skb), l4_len, 0));
+			break;
+		case IPPROTO_UDP:
+			udp_hdr(skb)->check = 0;
+			udp_hdr(skb)->check = udp_v6_check(
+				l4_len, &old_iph->saddr, &old_iph->daddr,
+				csum_partial(udp_hdr(skb), l4_len, 0));
+			break;
+		default:
+			break;
+		}
+	}
+
 	skb->transport_header = skb->network_header;
 
 	skb_push(skb, sizeof(struct ipv6hdr));
-- 
1.8.1

