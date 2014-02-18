From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Tue, 18 Feb 2014 14:54:41 +0100
Message-ID: <20140218135439.GB20771@telegraafnet.nl>
References: <20140217153206.GC18029@telegraafnet.nl>
 <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GID0FwUMdk1T2AWN"
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140218133725.GA20771@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org


--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 18, 2014 at 02:37:25PM +0100, Art -kwaak- van Breemen wrote:
> With attached patch (agains 3.13.3, but probably generic to >= 3.10) I get this:

should have been diff -up, instead of diff.

A cleanup of the icmpv6 handling for natted lvs services resulted
in the icmp packet being corrupted.
The ipv6_find_hdr seems to want to have -1 as a target for outer
level headers instead of a target >=0. The result is that packet
mangling was writing to the wrong offset, corrupting the packet,
and so disabling path-mtu-discovery.
- add extra debugging only output
- change target to -1

Signed-off-by: Ard van Breemen <ard@telegraafnet.nl>

--GID0FwUMdk1T2AWN
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="lvs-icmp-bug.patch"

--- l-3.13.3/net/netfilter/ipvs/ip_vs_core.c.org	2014-01-22 14:46:53.222738221 +0100
+++ l-3.13.3/net/netfilter/ipvs/ip_vs_core.c	2014-02-18 14:17:56.516319899 +0100
@@ -735,7 +735,9 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
 	struct ipv6hdr *ciph;
 	unsigned short fragoffs;
 
-	ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL);
+	EnterFunction(10);
+	protocol=ipv6_find_hdr(skb, &icmp_offset, -1, &fragoffs, NULL);
+	IP_VS_DBG(15,"icmp_offset=%d,protocol=%d\n",icmp_offset,protocol);
 	icmph = (struct icmp6hdr *)(skb_network_header(skb) + icmp_offset);
 	offs = icmp_offset + sizeof(struct icmp6hdr);
 	ciph = (struct ipv6hdr *)(skb_network_header(skb) + offs);
@@ -780,6 +782,7 @@ void ip_vs_nat_icmp_v6(struct sk_buff *s
 		IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
 			      (void *)ciph - (void *)iph,
 			      "Forwarding altered incoming ICMPv6");
+	LeaveFunction(10);
 }
 #endif
 

--GID0FwUMdk1T2AWN--
