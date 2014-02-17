From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Regression in pmtud lvs-nat with ipv6 since at least 3.10
Date: Mon, 17 Feb 2014 23:34:43 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
References: <20140217153206.GC18029@telegraafnet.nl> <20140217161601.GD18029@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140217161601.GD18029@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 17 Feb 2014, Art -kwaak- van Breemen wrote:

> Hi,
> 
> On Mon, Feb 17, 2014 at 04:32:06PM +0100, Art -kwaak- van Breemen wrote:
> > A wrong dump (any since 3.10.27):
> > 14:32:11.822345 IP6 2001:7b8:2ff:6f:2a02:310:0:2950 > ::80:104:0:0:80:104: ICMP6, packet too big, mtu 1472, length 1240
> >         0x0000:  6000 aa5f 04d8 3a3c 2001 07b8 02ff 006f  `.._..:<.......o
> >         0x0010:  2a02 0310 0000 2950 0000 0000 0080 0104  *.....)P........
> >         0x0020:  0000 0000 0080 0104 0200 0617 0000 05c0  ................
> >         0x0030:  6000 0000 05a8 063b 2a02 0310 0000 0100  `......;*.......
> >         0x0040:  0200 f8ff fe80 0004 2001 07b8 032d 0000  .............-..
> >         0x0050:  YYYY YYYY YYYY YYYY 0050 c723 7e6a 835c  .d....66.P.#~j.\
> >         0x0060:  ca00 19c5 8010 0078 f3b6 0000 0101 080a  .......x........
> >         0x0070:  c8df df1e 0945 23c2 4854 5450 2f31 2e31  .....E#.HTTP/1.1
> > <snip>
> > 
> > What we can clearly see in the wrong picture is this:
> > source higher 64 bits is correct (my home gw address)
> > source lower 64 bits is the higher 64 bits of the destination machine.
> > destination higher 64 bits is the lower 64 bits of the destination machine
> > destination lower 64 bits is the lower 64 bits of the destination machine.
> > That last part in question is this on the loadbalancer:
> > TCP  [2a02:310:0:100:200:f8ff:fe80:4]:http wrr
> >   -> [2a02:310:0:2950::80:104]:http Masq    4      0          0         
> >   -> [2a02:310:0:2950::80:204]:http Masq    4      0          0         
> > 
> > The addresses within the icmp6 packet itself are also not translated.
> What I think happened is that the ipv6 headers themselves are
> correctly handled, but that the ipv6 address in the icmp part is
> written to the wrong place.
> (See: net/netfilter/ipvs/ip_vs_core.c: ip_vs_nat_icmp_v6() )
> 
> So what happens is this:
> ip6:source address is written,
> icmp6:destination address is written
> ip6:destination address is rewritten to correct destination machine
> icmp6:source address is actually written to the ip6 source
> address+8 bytes, overwriting the last 64 bits of ip6:saddr and
> the first 64 bits of ip6:daddr...
> 
> I think there might be an of by  wrong structsize problem here.

	Can you try to change the IPPROTO_ICMPV6 argument
of ipv6_find_hdr with -1, eg:

from:

ipv6_find_hdr(skb, &icmp_offset, IPPROTO_ICMPV6, &fragoffs, NULL);

to:

ipv6_find_hdr(skb, &icmp_offset, -1, &fragoffs, NULL);

	May be ipv6_find_hdr() can not be called with
exact protocol number, the offset is not updated,
it remains 0 and -ENOENT is returned. As result,
icmp_offset is not changed to 40.

Regards

--
Julian Anastasov <ja@ssi.bg>
