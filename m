From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH V3 0/8] ipvs: IPv6 fragment handling for IPVS
Date: Thu, 13 Sep 2012 01:57:27 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209130143410.1653@ja.ssi.bg>
References: <20120911123531.4305.40304.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120911123531.4305.40304.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Tue, 11 Sep 2012, Jesper Dangaard Brouer wrote:

> The following patchset implement IPv6 fragment handling for IPVS.
> 
> This work is based upon patches from Hans Schillstrom.  I have taken
> over the patchset, in close agreement with Hans, because he don't have
> (gotten allocated) time to complete his work.
> 
> I have cleaned up the patchset significantly, and split the patchset
> up into eight patches.
> 
> The first 4 patches, are ready to be merged
> 
>  Patch01: Trivial changes, use compressed IPv6 address in output
>  Patch02: IPv6 extend ICMPv6 handling for future types
>  Patch03: Use config macro IS_ENABLED()
>  Patch04: Fix bug in IPVS IPv6 NAT mangling of ports inside ICMPv6 packets
> 
> The next 4 patches, I consider V3 of the patches I have submitted
> earlier, where I have incorporated all of Julian's feedback.  I have
> also tried to make the patches easier to review, by reorganizing the
> changes, to be more strictly split (exthdr vs. fragment handling).
> 
> I have also removed the API changes, and moved those to patch07.  This
> is done, (1) to make it easier to review the patches, and (2) to allow
> easier integration of Patricks idea and my RFC patch of caching exthdr
> info in skb->cb[].  Thus, we can get these patches applied (and later
> go back and apply the caching scheme easier).
> 
>  Patch05: Fix faulty IPv6 extension header handling in IPVS
>  Patch06: Complete IPv6 fragment handling for IPVS
>  Patch07: IPVS API change to avoid rescan of IPv6 exthdr
>  Patch08: IPVS SIP fragment handling
> 
> The SIP frag handling have been split into its own patch, as I have
> not been able to test this part my self.
> 
> This patchset is based upon:
>   Pablo's nf-next tree:  git://1984.lsi.us.es/nf-next
>   On top of commit 0edd94887d19ad73539477395c17ea0d6898947a
> 
> ---
> 
> Jesper Dangaard Brouer (8):
>       ipvs: SIP fragment handling
>       ipvs: API change to avoid rescan of IPv6 exthdr
>       ipvs: Complete IPv6 fragment handling for IPVS
>       ipvs: Fix faulty IPv6 extension header handling in IPVS
>       ipvs: Fix bug in IPv6 NAT mangling of ports inside ICMPv6 packets
>       ipvs: Use config macro IS_ENABLED()
>       ipvs: IPv6 extend ICMPv6 handling for future types
>       ipvs: Trivial changes, use compressed IPv6 address in output

	Some comments:

- About patch 4: ip_vs_icmp_xmit_v6 already calls skb_make_writable
before ip_vs_nat_icmp_v6, that is why we provide 'offset'.

- May be we can provide the offset of ICMPv6 header
from ip_vs_in_icmp_v6 to ip_vs_icmp_xmit_v6 as additional
argument (icmp_offset) and then to ip_vs_nat_icmp_v6. By this
way we can avoid the two ipv6_find_hdr calls if we also provide
the iph argument from ip_vs_icmp_xmit_v6 to ip_vs_nat_icmp_v6,
its ->len points to the ports. ip_vs_in_icmp_v6 provides
also protocol in this ciph, so may be we have everything.

- in ip_vs_in_icmp_v6 there must be 'offs_ciph = ciph.len;'
just before this line:

if (IPPROTO_TCP == ciph.protocol || IPPROTO_UDP == ciph.protocol ||

	The idea is that we linearize for writing the inner
IP header and optionally the 2 ports. That is why old
logic was 'offset += 2 * sizeof(__u16);'

- initially, ip_vs_fill_iph_skb fills iphdr->flags from
current fragment, later ip_vs_out_icmp_v6 uses the same
ipvsh when calling ipv6_find_hdr. Should we initialize
ipvsh->flags to 0 before calling ipv6_find_hdr because
it is I/O argument?

- in patch 5: in ip_vs_nat_icmp_v6 skb_make_writable can
move data to other addresses on linearization. Any pointers
like 'ciph' should be recalculated based on offsets. But
it does not matter because we should not call skb_make_writable
here.

	I also see that we should not send ICMP
errors (FRAG NEEDED/TOO BIG) in response to large
ICMP error packets but it is not related to your changes,
it needs separate change to all transmitters.

Regards

--
Julian Anastasov <ja@ssi.bg>
