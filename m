From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Fri, 21 Feb 2014 00:17:49 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402202350280.2732@ja.home.ssi.bg>
References: <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg> <20140218100533.GE18029@telegraafnet.nl> <20140218133725.GA20771@telegraafnet.nl> <20140218135439.GB20771@telegraafnet.nl> <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
 <20140219102751.GD20771@telegraafnet.nl> <1392825857.5821.422.camel@hawk.mlab.se> <alpine.LFD.2.11.1402192254040.1889@ja.home.ssi.bg> <1392847723.5821.474.camel@hawk.mlab.se> <20140220131044.GP20771@telegraafnet.nl> <20140220185619.GA4048@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140220185619.GA4048@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Cc: Hans Schillstrom <hans@schillstrom.com>, Ansis Atteka <aatteka@nicira.com>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>


	Hello,

On Thu, 20 Feb 2014, Art -kwaak- van Breemen wrote:

> I ack the working of that change for my specific case: passing
> pmtud's correctly:
> Feb 20 18:58:59 c43236 kernel: [  721.473388] IPVS: Enter: ip_vs_icmp_xmit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1186
> Feb 20 18:58:59 c43236 kernel: [  721.473389] IPVS: Enter: ip_vs_nat_icmp_v6, net/netfilter/ipvs/ip_vs_core.c line 738
> Feb 20 18:58:59 c43236 kernel: [  721.473390] IPVS: icmp_offset=40,protocol=58
> Feb 20 18:58:59 c43236 kernel: [  721.473391] IPVS: ip_vs_nat_icmp_v6() changed port 80 to 80
> Feb 20 18:58:59 c43236 kernel: [  721.473393] IPVS: Leave: ip_vs_nat_icmp_v6, net/netfilter/ipvs/ip_vs_core.c line 786
> Feb 20 18:58:59 c43236 kernel: [  721.473396] IPVS: Leave: ip_vs_icmp_xmit_v6, net/netfilter/ipvs/ip_vs_xmit.c line 1263
> 
> and:
> 18:58:59.067282 00:23:24:26:b4:5c > 00:23:24:26:b4:34, ethertype IPv6 (0x86dd), length 1294: 2001:7b8:2ff:6f::1 > 2a02:310:0:1013::1003: ICMP6, packet too big, mtu 1472, length 1240
> 
> So the "|| found" sounds sane.

	Thanks for the confirmation. Then may be Hans
can post a fix for this problem after checking the callers
of ipv6_find_hdr.

> But now I'm going to be an ass by saying that maybe both patches must be
> applied because we only get into ip_vs_nat_icmp_v6 by ip_vs_fill_iph_skb in
> include/net/ip_vs.h, which determines the protocol and the start of the
> protocol header by using -1 as target in ipv6_find_hdr.
> Actually, before we reach that nat function we have traversed several constructs of:
> protocol,offset = ipv6_find_hdr (target = -1 )
> if ( protocol != IPPROTO_ICMPV6)
>   bail out (return NF_ACCEPT actually) .

	Yes, it is not expected, the protocol was
already validated. May be we will save some cycles
without such check...

> (and maybe use offset)
> 
> So I think it's clearer for the total code if we follow the exact same construct:
> find a protocol, bail out if protocol wrong.
> It should never happen at that point, but there are more things that never
> should happen :-).
> 
> Anyway: whatever you guys decide, I owe you all beer. I think we are one of the
> few companies that assume a working pmtud for ipv6. Most of the top companies
> just use an mtu of 1280 because the "hardware" loadbalancer cannot handle it
> (yet) or just want to prevent the hassle. Thanks!
> 
> Regards,
> 
> Ard van Breemen

Regards

--
Julian Anastasov <ja@ssi.bg>
