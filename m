From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: Regression in pmtud lvs-nat with ipv6 since at least 3.10
Date: Tue, 18 Feb 2014 14:37:26 +0100
Message-ID: <20140218133725.GA20771@telegraafnet.nl>
References: <20140217153206.GC18029@telegraafnet.nl>
 <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140218100533.GE18029@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Julian,
> On Mon, Feb 17, 2014 at 11:34:43PM +0200, Julian Anastasov wrote:
> > 	May be ipv6_find_hdr() can not be called with
> > exact protocol number, the offset is not updated,
> > it remains 0 and -ENOENT is returned. As result,
> > icmp_offset is not changed to 40.
> 
> I was thinking along that line too, since sizeof(struct icmp6hdr)
> would exactly skip that part, hence pointing ciph at the
> second half of the first ip address.

I've made a test setup.
With attached patch (agains 3.13.3, but probably generic to >= 3.10) I get this:

Feb 18 14:24:41 c43236 kernel: [ 7103.570868] IPVS: Enter: ip_vs_out, net/netfilter/ipvs/ip_vs_core.c line 1119
Feb 18 14:24:41 c43236 kernel: [ 7103.570872] IPVS: Outgoing ICMPv6 (2,0) 2001:7b8:2ff:6f::1->2a02:310:0:1013::1005
Feb 18 14:24:41 c43236 kernel: [ 7103.570875] IPVS: lookup/out TCP [2001:7b8:32d:0:1864:b6ff:febf:3636]:38259->[2a02:310:0:1013::1005]:80 not hit
Feb 18 14:24:41 c43236 kernel: [ 7103.570877] IPVS: Incoming ICMPv6 (2,0) 2001:7b8:2ff:6f::1->2a02:310:0:1013::1005
Feb 18 14:24:41 c43236 kernel: [ 7103.570881] IPVS: lookup/in TCP [2001:7b8:32d:0:1864:b6ff:febf:3636]:38259->[2a02:310:0:1013::1005]:80 hit
Feb 18 14:24:41 c43236 kernel: [ 7103.570883] IPVS: Enter: ip_vs_icmp_xmit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1186
Feb 18 14:24:41 c43236 kernel: [ 7103.570887] IPVS: Enter: ip_vs_nat_icmp_v6, net/netfilter/ipvs/ip_vs_core.c line 738
Feb 18 14:24:41 c43236 kernel: [ 7103.570888] IPVS: icmp_offset=40,protocol=58
Feb 18 14:24:41 c43236 kernel: [ 7103.570889] IPVS: ip_vs_nat_icmp_v6() changed port 80 to 80
Feb 18 14:24:41 c43236 kernel: [ 7103.570891] IPVS: Leave: ip_vs_nat_icmp_v6, net/netfilter/ipvs/ip_vs_core.c line 785
Feb 18 14:24:41 c43236 kernel: [ 7103.570896] IPVS: Leave: ip_vs_icmp_xmit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1263

With a former version when the -1 was still IPPROTO_ICMPV6, it was:
Feb 18 13:31:30 c43236 kernel: [ 3912.655400] IPVS: Enter: ip_vs_out, net/netfilter/ipvs/ip_vs_core.c line 1119
Feb 18 13:31:30 c43236 kernel: [ 3912.655404] IPVS: Outgoing ICMPv6 (2,0) 2001:7b8:2ff:6f::1->2a02:310:0:1013::1005
Feb 18 13:31:30 c43236 kernel: [ 3912.655407] IPVS: lookup/out TCP [2001:7b8:32d:0:1864:b6ff:febf:3636]:38198->[2a02:310:0:1013::1005]:80 not hit
Feb 18 13:31:30 c43236 kernel: [ 3912.655408] IPVS: Incoming ICMPv6 (2,0) 2001:7b8:2ff:6f::1->2a02:310:0:1013::1005
Feb 18 13:31:30 c43236 kernel: [ 3912.655412] IPVS: lookup/in TCP [2001:7b8:32d:0:1864:b6ff:febf:3636]:38198->[2a02:310:0:1013::1005]:80 hit
Feb 18 13:31:30 c43236 kernel: [ 3912.655413] IPVS: Enter: ip_vs_icmp_xmit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1186
Feb 18 13:31:30 c43236 kernel: [ 3912.655417] IPVS: Enter: ip_vs_nat_icmp_v6, net/netfilter/ipvs/ip_vs_core.c line 738
Feb 18 13:31:30 c43236 kernel: [ 3912.655418] IPVS: icmp_offset=0
Feb 18 13:31:30 c43236 kernel: [ 3912.655419] IPv6 header not found
Feb 18 13:31:30 c43236 kernel: [ 3912.655422] IPVS: Leave: ip_vs_nat_icmp_v6, net/netfilter/ipvs/ip_vs_core.c line 785
Feb 18 13:31:30 c43236 kernel: [ 3912.655426] IPVS: Leave: ip_vs_icmp_xmit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1263
Feb 18 13:31:30 c43236 kernel: [ 3912.655430] IPVS: Enter: ip_vs_out, net/netfilter/ipvs/ip_vs_core.c line 1119

So the icmp_offset was indeed 0, which made the second find-hdr fail.

When reading net/ipv6/exthdrs_core.c it seems to me that outer protocols should
not be used. We already know it is procol 58 though :-).

I've added the Enterfunction debugs because of the:
"IPv6 header not found" . It actually means that something is probably wrong
with the code. Fixing the icmp_offset removed the error message, but it might
be a nice pointer when the icmp message itself is crippled.

Regards,
Ard van Breemen

--xHFwDpU9dbj6ez1V
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="lvs-icmp-bug.patch"

--- l-3.13.3/net/netfilter/ipvs/ip_vs_core.c.org	2014-01-22 14:46:53.222738221 +0100
+++ l-3.13.3/net/netfilter/ipvs/ip_vs_core.c	2014-02-18 14:17:56.516319899 +0100
@@ -735,7 +735,9 @@
 	struct ipv6hdr *ciph;
 	unsigned short fragoffs;
 
-	ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL);
+	EnterFunction(10);
+	protocol=ipv6_find_hdr(skb, &icmp_offset, -1, &fragoffs, NULL);
+	IP_VS_DBG(15,"icmp_offset=%d,protocol=%d\n",icmp_offset,protocol);
 	icmph = (struct icmp6hdr *)(skb_network_header(skb) + icmp_offset);
 	offs = icmp_offset + sizeof(struct icmp6hdr);
 	ciph = (struct ipv6hdr *)(skb_network_header(skb) + offs);
@@ -780,6 +782,7 @@
 		IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
 			      (void *)ciph - (void *)iph,
 			      "Forwarding altered incoming ICMPv6");
+	LeaveFunction(10);
 }
 #endif
 

--xHFwDpU9dbj6ez1V--
