From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 22:44:02 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402192236060.1889@ja.home.ssi.bg>
References: <20140217153206.GC18029@telegraafnet.nl> <20140217161601.GD18029@telegraafnet.nl> <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg> <20140218100533.GE18029@telegraafnet.nl> <20140218133725.GA20771@telegraafnet.nl> <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg> <20140219102751.GD20771@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140219102751.GD20771@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Cc: lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>


	Hello,

On Wed, 19 Feb 2014, Art -kwaak- van Breemen wrote:

> I could not clearly see what really generatd the "invalid header"
> error message in the log.

	You mean "IPv6 header not found" ?
I guess it happens for the second
protocol = ipv6_find_hdr(skb, &offs, -1, &fragoffs, NULL);
when icmp_offset was 0. Message is from ipv6_find_hdr.

Regards

--
Julian Anastasov <ja@ssi.bg>
