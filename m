From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix ipv6 icmp forwarding in natted services
Date: Tue, 18 Feb 2014 23:02:13 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1402182225560.2011@ja.home.ssi.bg>
References: <20140217153206.GC18029@telegraafnet.nl> <20140217161601.GD18029@telegraafnet.nl> <alpine.LFD.2.11.1402172321200.2420@ja.home.ssi.bg> <20140218100533.GE18029@telegraafnet.nl> <20140218133725.GA20771@telegraafnet.nl>
 <20140218135439.GB20771@telegraafnet.nl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140218135439.GB20771@telegraafnet.nl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 18 Feb 2014, Art -kwaak- van Breemen wrote:

> On Tue, Feb 18, 2014 at 02:37:25PM +0100, Art -kwaak- van Breemen wrote:
> > With attached patch (agains 3.13.3, but probably generic to >= 3.10) I get this:
> 
> should have been diff -up, instead of diff.
> 
> A cleanup of the icmpv6 handling for natted lvs services resulted
> in the icmp packet being corrupted.
> The ipv6_find_hdr seems to want to have -1 as a target for outer
> level headers instead of a target >=0. The result is that packet
> mangling was writing to the wrong offset, corrupting the packet,
> and so disabling path-mtu-discovery.
> - add extra debugging only output
> - change target to -1
> 
> Signed-off-by: Ard van Breemen <ard@telegraafnet.nl>

	Thanks for testing! This patch needs some tuning,
refer to Documentation/CodingStyle for the rules.
checkpatch.pl reports for the problems:

====
# scripts/checkpatch.pl /tmp/lvs-icmp-bug.patch 
ERROR: spaces required around that '=' (ctx:VxV)
#9: FILE: net/netfilter/ipvs/ip_vs_core.c:739:
+       protocol=ipv6_find_hdr(skb, &icmp_offset, -1, &fragoffs, NULL);
                ^

ERROR: space required after that ',' (ctx:VxV)
#10: FILE: net/netfilter/ipvs/ip_vs_core.c:740:
+       IP_VS_DBG(15,"icmp_offset=%d,protocol=%d\n",icmp_offset,protocol);
                    ^

ERROR: space required after that ',' (ctx:VxV)
#10: FILE: net/netfilter/ipvs/ip_vs_core.c:740:
+       IP_VS_DBG(15,"icmp_offset=%d,protocol=%d\n",icmp_offset,protocol);
                                                   ^

ERROR: space required after that ',' (ctx:VxV)
#10: FILE: net/netfilter/ipvs/ip_vs_core.c:740:
+       IP_VS_DBG(15,"icmp_offset=%d,protocol=%d\n",icmp_offset,protocol);
                                                               ^

ERROR: Missing Signed-off-by: line(s)

total: 5 errors, 0 warnings, 17 lines checked

/tmp/lvs-icmp-bug.patch has style problems, please review.
====

	I agree for the comment but not sure if it is
appropriate for bugfixes that go to stable kernels.
Also, the format should be icmp_offset=%u, not %d.

	Also, we should mention the problematic commit
and to CC the authors. You can tune/borrow from the
following example:

====
[PATCH] ipvs: fix wrong icmp_offset in ip_vs_nat_icmp_v6

Fix regression introduced in 3.8 with commit 63dca2c0b0e7a9
("ipvs: Fix faulty IPv6 extension header handling in IPVS").
Calling ipv6_find_hdr with protocol (IPPROTO_ICMPV6) is not
supported, use -1 instead. Solves problem of damaged IPv6
headers in NAT-ed ICMP packets.

Signed-off-by: Ard van Breemen <ard@telegraafnet.nl>
CC: Jesper Dangaard Brouer <brouer@redhat.com>
CC: Hans Schillstrom <hans.schillstrom@ericsson.com>
====

Regards

--
Julian Anastasov <ja@ssi.bg>
