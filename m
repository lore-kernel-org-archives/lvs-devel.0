From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 18:53:36 +0100
Message-ID: <20140219175335.GJ20771@telegraafnet.nl>
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

On Wed, Feb 19, 2014 at 05:04:17PM +0100, Hans Schillstrom wrote:
> The problem is if icmp6 is not the first header it will not work...
> i.e. it can be other headers before icmp and if you have -1 you will not
> always get the icmp header.

If I look at the ipv6_find_hdr code, it will actually loop until
all headers have been visited, because no header will equal -1.

Eventually it will stop because there are no next headers
anymore. So -1 will point at the last header before the payload.

I think -1 is still the right target, as we already know it's
about ICMP.
Still the question remains is why do we get an ENOENT when
looking for NEXTHDR_ICMP ?

Regards,
Ard
