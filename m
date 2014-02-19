From: Ansis Atteka <aatteka@nicira.com>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 12:32:07 -0800
Message-ID: <CAA=3Oq=gG9rbDcidNzwrKj=E=kGa1Fr16YwypDkj-+Spr2P8UQ@mail.gmail.com>
References: <20140217161601.GD18029@telegraafnet.nl>
	<alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
	<20140218100533.GE18029@telegraafnet.nl>
	<20140218133725.GA20771@telegraafnet.nl>
	<20140218135439.GB20771@telegraafnet.nl>
	<alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
	<20140219102751.GD20771@telegraafnet.nl>
	<1392825857.5821.422.camel@hawk.mlab.se>
	<20140219175335.GJ20771@telegraafnet.nl>
	<20140219180232.GK20771@telegraafnet.nl>
	<20140219182103.GL20771@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140219182103.GL20771@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Cc: Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Feb 19, 2014 at 10:21 AM, Art -kwaak- van Breemen
<ard@telegraafnet.nl> wrote:
>
> Hans,
> I want to keep the patch as is, but change the description:
>
> ====
> [PATCH] ipvs: fix wrong icmp_offset in ip_vs_nat_icmp_v6
> From: Ard van Breemen <ard@telegraafnet.nl>
>
>
> Fix regression introduced in 3.8 with commit 9195bb8e381d81
> ("ipv6: improve ipv6_find_hdr() to skip empty routing headers")
> which broke commit 63dca2c0b0e7a9
> ("ipvs: Fix faulty IPv6 extension header handling in IPVS").
> by a small change in ipv6_find_hdr: finding specific protocols is not
> supported anymore, use -1 instead. Solves (pmtud) problems caused by
> damaged IPv6 headers in NAT-ed ICMP packets.
>
> Signed-off-by: Ard van Breemen <ard@telegraafnet.nl>
> CC: Jesper Dangaard Brouer <brouer@redhat.com>
> CC: Hans Schillstrom <hans@schillstrom.com>
>
> ---
>
> Do you and Ansis agree with me?
My changes to this function were necessary for the Open vSwitch
set_ipv6() action implementation so that checksums would be correctly
recalculated.

I introduced IP6_FH_F_SKIP_RH flag that skips all Routing Headers,
where segments_left==0. This flag allows Open vSwitch kernel module to
figure out whether it needs to recalculate checksum after changing
destination IP address in IPv6 header. In ipv6 the checkum is
calculated over final destination IP address that could also be in
Routing Header intead of ipv6 header (see rfc2460 section 8.1 for more
details).

I believe your patch would break meaning of IP6_FH_F_SKIP_RH flag,
because it would exit early when it saw Routing Header where segments
left == 0.
