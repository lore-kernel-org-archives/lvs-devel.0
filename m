From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Thu, 20 Feb 2014 09:40:09 +0100
Message-ID: <20140220084009.GM20771@telegraafnet.nl>
References: <20140217153206.GC18029@telegraafnet.nl>
 <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
 <20140219102751.GD20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402192236060.1889@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1402192236060.1889@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, aatteka@nicira.com, kaber@trash.net, hans@schillstrom.com

Hi,

On Wed, Feb 19, 2014 at 10:44:02PM +0200, Julian Anastasov wrote:
> On Wed, 19 Feb 2014, Art -kwaak- van Breemen wrote:
> 
> > I could not clearly see what really generatd the "invalid header"
> > error message in the log.
> 
> 	You mean "IPv6 header not found" ?
> I guess it happens for the second
> protocol = ipv6_find_hdr(skb, &offs, -1, &fragoffs, NULL);
> when icmp_offset was 0. Message is from ipv6_find_hdr.

Yes :-). I figured that after I added debugging to pinpoint it
;-).

I always saw that message in the log but I thought that's some
new warning about other devices bugs.
The message as it is right now, states something is wrong, and
please go find out yourself :-).
It would be handy if it could be either quiet "Yes, I know it can
fail but it's usually right", or stack trace it once every...
The use of ipv6_find_hdr is not that widespread yet. And in the
current case the IPPROTO_ICMPV6 is the only test in the kernel
that searches for a non ext hdr.
To be clear: if I look at my 1200+ client wireless network the
ipv6 takes up 30% of the traffic. That means ipv6 gets more and
more important (== more code) and a clear understanding of
ipv6_find_hdr is important.

Thanks for all the work guys!

Regards,

Ard van Breemen
