From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Wed, 19 Feb 2014 11:27:52 +0100
Message-ID: <20140219102751.GD20771@telegraafnet.nl>
References: <20140217153206.GC18029@telegraafnet.nl>
 <20140217161601.GD18029@telegraafnet.nl>
 <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg>
 <20140218100533.GE18029@telegraafnet.nl>
 <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
 <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>

Hi Julian,
On Tue, Feb 18, 2014 at 11:02:13PM +0200, Julian Anastasov wrote:
> 	Thanks for testing! This patch needs some tuning,
> refer to Documentation/CodingStyle for the rules.
> checkpatch.pl reports for the problems:

Thanks. I was a reading it, but something with impatience and
lazy, and worst of all, I still don't know an easy way to blame
without cloning the repository :-(

<snipped proof of lazy incompetence>                                                                ^

> 	I agree for the comment but not sure if it is
> appropriate for bugfixes that go to stable kernels.
> Also, the format should be icmp_offset=%u, not %d.

Thanks for yet another oversight ;-). And it would definitely not
be needed here. I do wonder about the EnterFunction though.
I could not clearly see what really generatd the "invalid header"
error message in the log.

> 	Also, we should mention the problematic commit
> and to CC the authors. You can tune/borrow from the
> following example:

Thanks!

> ====
> [PATCH] ipvs: fix wrong icmp_offset in ip_vs_nat_icmp_v6
> 
> Fix regression introduced in 3.8 with commit 63dca2c0b0e7a9
> ("ipvs: Fix faulty IPv6 extension header handling in IPVS").
> Calling ipv6_find_hdr with protocol (IPPROTO_ICMPV6) is not
> supported, use -1 instead. Solves problem of damaged IPv6
> headers in NAT-ed ICMP packets.

Jesper and Hans, I think that ipv6_find_hdr should have a target
of -1 to find the protocol header, and any other next-header
target will be valid after that.

Anyway, I will read the committing patches again and reduce the
patch to just a change -1.

If I see any "invalid headers" again on the firewall, I will add
the debugging.

The current patch is live using 3.12.11
( http://www.speurders.nl/ and http://www.spitsnieuws.nl/ f.i. )

Regards,

Ard
