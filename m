From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Fri, 21 Feb 2014 11:34:42 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402211055530.1708@ja.home.ssi.bg>
References: <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>  <20140218100533.GE18029@telegraafnet.nl>  <20140218133725.GA20771@telegraafnet.nl>  <20140218135439.GB20771@telegraafnet.nl>  <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg> 
 <20140219102751.GD20771@telegraafnet.nl>  <1392825857.5821.422.camel@hawk.mlab.se>  <alpine.LFD.2.11.1402192254040.1889@ja.home.ssi.bg>  <1392847723.5821.474.camel@hawk.mlab.se>  <20140220131044.GP20771@telegraafnet.nl>  <20140220185619.GA4048@telegraafnet.nl>
  <alpine.LFD.2.11.1402202350280.2732@ja.home.ssi.bg> <1392961601.5821.499.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1392961601.5821.499.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Art -kwaak- van Breemen <ard@telegraafnet.nl>, Ansis Atteka <aatteka@nicira.com>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Patrick McHardy <kaber@trash.net>


	Hello,

On Fri, 21 Feb 2014, Hans Schillstrom wrote:

> We will save some cycles here, very few actually..
> I'm not sure about the mobility header if it can break this.
> Have not read the RFC :-)
> 
> The -1 is OK for me right now

	I don't see any difference what we use here because
we used -1 in ip_vs_fill_iph_skb. If not validated once, with
-1 we can get a NEXTHDR_NONE result when ipv6_find_hdr
returns without error.

	I see that IPVS is hooked before ip6_input_finish()
where all protocol headers without INET6_PROTO_FINAL bit
are pulled from the head.

	I guess such headers are pulled one by one and
at a final step after multiple ip6_input calls IPVS can
see the protocols it supports.

	So, IPVS catches known protocols if they are
first. IMHO, we can continue to use IPPROTO_ICMPV6
because ipv6_find_hdr always stops at the first final
header.

Regards

--
Julian Anastasov <ja@ssi.bg>
