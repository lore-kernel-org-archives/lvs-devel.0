From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: [PATCH] ipvs: fix wrong icmp_offset in ip_vs_nat_icmp_v6
Date: Wed, 19 Feb 2014 13:31:50 +0100
Message-ID: <20140219123150.GF20771@telegraafnet.nl>
References: <20140217153206.GC18029@telegraafnet.nl>
 <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
 <20140219102751.GD20771@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140219102751.GD20771@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans@schillstrom.com>

Fix regression introduced in 3.8 with commit 63dca2c0b0e7a9
("ipvs: Fix faulty IPv6 extension header handling in IPVS").
Calling ipv6_find_hdr with protocol (IPPROTO_ICMPV6) is not
supported, use -1 instead. Solves (pmtud) problems caused by
damaged IPv6 headers in NAT-ed ICMP packets.

Signed-off-by: Ard van Breemen <ard@telegraafnet.nl>
CC: Jesper Dangaard Brouer <brouer@redhat.com>
CC: Hans Schillstrom <hans@schillstrom.com>

---

--- l-3.13.3/net/netfilter/ipvs/ip_vs_core.c.org	2014-01-22 14:46:53.222738221 +0100
+++ l-3.13.3/net/netfilter/ipvs/ip_vs_core.c	2014-02-19 12:22:25.641612230 +0100
@@ -735,7 +735,7 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
 	struct ipv6hdr *ciph;
 	unsigned short fragoffs;
 
-	ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL);
+	ipv6_find_hdr(skb, &icmp_offset, -1, &fragoffs, NULL);
 	icmph = (struct icmp6hdr *)(skb_network_header(skb) + icmp_offset);
 	offs = icmp_offset + sizeof(struct icmp6hdr);
 	ciph = (struct ipv6hdr *)(skb_network_header(skb) + offs);
