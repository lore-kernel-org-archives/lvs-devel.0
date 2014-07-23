From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs] ipvs: invoke skb_checksum_help prior to encapsulation in tunnel xmit
Date: Wed, 23 Jul 2014 12:16:27 -0700
Message-ID: <1406142987-30436-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=Fel/D8Jfdqs4Ef69iZoJESVP+/yYhSnUkid5VWgB2tY=;
 b=GL+syQhyl5lBA7zibcOISH1hyQRJ6i/2rGxl0+TgX9QweupKQwfnVVE0uF2fZY/2ul6r
 icH5V18LIWj5SH+dkl5UYuEN0/dP4SGsnzhn/gko6sZPV9j60el+hjeV9MOEWHSvraXs
 +onBjlUKtVnrZ1TCo18vk+lXFyUCdQ3k2qk= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

If we don't do this and we have hardware checksumming enabled, we'll simply
never actually checksum NF_INET_LOCAL_OUT tcp packets.  This is due to the
fact that the partially checksummed packet is plucked on it's way out of
the system and thrown through the ipvs machinery.  While the expectation
was that the NIC would be able to checksum the packet as it was, once we
place the packet into an ipip packet, the NIC can no longer fulfill that
expectation.  Thus, we send out random garbage, which is dropped by the
real server.

skb_checksum_help does the right things insofar as checking to see if the
checksum is only partial and then completing the checksum if it is, so we
can blindly call it on every packet and let it figure things out.

There's no reason to keep ip_send check either.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6f70bdd..9c68089 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -862,10 +862,12 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ip_hdr(skb);
 	}
 
-	skb->transport_header = skb->network_header;
+	/* We are about to encapsulate the ip header, which breaks hardware
+	 * checksum offload.  Let's call skb_checksum_help to finish up any
+	 * partial checksums */
+	skb_checksum_help(skb);
 
-	/* fix old IP header checksum */
-	ip_send_check(old_iph);
+	skb->transport_header = skb->network_header;
 
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
@@ -953,6 +955,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ipv6_hdr(skb);
 	}
 
+	/* We are about to encapsulate the ip header, which breaks hardware
+	 * checksum offload.  Let's call skb_checksum_help to finish up any
+	 * partial checksums */
+	skb_checksum_help(skb);
+
 	skb->transport_header = skb->network_header;
 
 	skb_push(skb, sizeof(struct ipv6hdr));
-- 
1.8.1

