From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 18:05:05 +0100
Message-ID: <20140219170505.GI20771@telegraafnet.nl>
References: <20140217153206.GC18029@telegraafnet.nl>
 <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
 <20140219102751.GD20771@telegraafnet.nl>
 <1392825857.5821.422.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392825857.5821.422.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Ansis Atteka <aatteka@nicira.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>

Hi Hans,

On Wed, Feb 19, 2014 at 05:04:17PM +0100, Hans Schillstrom wrote:
> The problem is if icmp6 is not the first header it will not work...
> i.e. it can be other headers before icmp and if you have -1 you will not
> always get the icmp header.

Ah bah, I thought they move every extra header after the payload.

> The patch that broke it was:
> commit 9195bb8e381d81d5a315f911904cdf0cfcc919b8
> Author: Ansis Atteka <aatteka@nicira.com>

I will take a hard look into that one :-).

> --- a/net/ipv6/exthdrs_core.c     2014-02-19 16:36:22.031686037 +0100
> +++ b/net/ipv6/exthdrs_core.c     2014-02-19 16:37:28.838082168 +0100

If I patch my kernel:
ard@freeze8dev:/mnt/source/kernels/build-hp-ws/l-3.13.3$ diff -u net/netfilter/ipvs/ip_vs_core.c{.org,} ;diff -u net/ipv6/exthdrs_core.c{.org,}
--- net/netfilter/ipvs/ip_vs_core.c.org 2014-01-22 14:46:53.222738221 +0100
+++ net/netfilter/ipvs/ip_vs_core.c     2014-02-19 17:48:09.306379357 +0100
@@ -735,7 +735,10 @@
        struct ipv6hdr *ciph;
        unsigned short fragoffs;
 
-       ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL);
+       EnterFunction(10);
+       protocol=ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL);
+       //ipv6_find_hdr(skb, &icmp_offset, -1, &fragoffs, NULL);
+       IP_VS_DBG(15,"icmp_offset=%d,protocol=%d\n",icmp_offset,protocol);
        icmph = (struct icmp6hdr *)(skb_network_header(skb) + icmp_offset);
        offs = icmp_offset + sizeof(struct icmp6hdr);
        ciph = (struct ipv6hdr *)(skb_network_header(skb) + offs);
@@ -780,6 +783,7 @@
                IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
                              (void *)ciph - (void *)iph,
                              "Forwarding altered incoming ICMPv6");
+       LeaveFunction(10);
 }
 #endif
 
--- net/ipv6/exthdrs_core.c.org 2013-11-06 13:32:34.653688901 +0100
+++ net/ipv6/exthdrs_core.c     2014-02-19 17:49:38.771351902 +0100
@@ -211,6 +211,8 @@
                unsigned int hdrlen;
                found = (nexthdr == target);
 
+               if (found && (target > 0))
+                       break;
                if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE) {
                        if (target < 0)
                                break;

I get this again:
Feb 19 18:02:36 c43236 kernel: [106578.432947] IPVS: Enter: ip_vs_out, net/netfilter/ipvs/ip_vs_core.c line 1120
Feb 19 18:02:36 c43236 kernel: [106578.432950] IPVS: Outgoing ICMPv6 (2,0) 2001:7b8:2ff:6f::1->2a02:310:0:1013::1005
Feb 19 18:02:36 c43236 kernel: [106578.432954] IPVS: lookup/out TCP [2001:7b8:32d:0:1864:b6ff:febf:3636]:39993->[2a02:310:0:1013::1005]:80 not hit
Feb 19 18:02:36 c43236 kernel: [106578.432956] IPVS: Incoming ICMPv6 (2,0) 2001:7b8:2ff:6f::1->2a02:310:0:1013::1005
Feb 19 18:02:36 c43236 kernel: [106578.432960] IPVS: lookup/in TCP [2001:7b8:32d:0:1864:b6ff:febf:3636]:39993->[2a02:310:0:1013::1005]:80 hit
Feb 19 18:02:36 c43236 kernel: [106578.432962] IPVS: Enter: ip_vs_icmp_xmit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1186
Feb 19 18:02:36 c43236 kernel: [106578.432964] IPVS: Enter: ip_vs_nat_icmp_v6, net/netfilter/ipvs/ip_vs_core.c line 738
Feb 19 18:02:36 c43236 kernel: [106578.432965] IPVS: icmp_offset=0,protocol=-2
Feb 19 18:02:36 c43236 kernel: [106578.432966] IPv6 header not found
Feb 19 18:02:36 c43236 kernel: [106578.432969] IPVS: Leave: ip_vs_nat_icmp_v6, net/netfilter/ipvs/ip_vs_core.c line 786
Feb 19 18:02:36 c43236 kernel: [106578.432974] IPVS: Leave: ip_vs_icmp_xmit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1263

I will take a closer look...

Regards,
Ard



