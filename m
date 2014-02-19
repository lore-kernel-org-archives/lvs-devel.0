From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 19:02:32 +0100
Message-ID: <20140219180232.GK20771@telegraafnet.nl>
References: <20140217153206.GC18029@telegraafnet.nl>
 <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
 <20140219102751.GD20771@telegraafnet.nl>
 <1392825857.5821.422.camel@hawk.mlab.se>
 <20140219175335.GJ20771@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140219175335.GJ20771@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Ansis Atteka <aatteka@nicira.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

Hi,

On Wed, Feb 19, 2014 at 06:53:35PM +0100, Art -kwaak- van Breemen wrote:
> I think -1 is still the right target, as we already know it's
> about ICMP.
> Still the question remains is why do we get an ENOENT when
> looking for NEXTHDR_ICMP ?
Found it:

if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE)
So, it keeps traversing until no more ext headers are found (i.e.
the protocol header), or no headers at all.
Then it tests if you wanted that last header (<0 -> ok leave).

So target may only be an ext_hdr, or -1.

Regards,
Ard van Breemen
