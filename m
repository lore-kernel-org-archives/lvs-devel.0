From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH V3 0/8] ipvs: IPv6 fragment handling for IPVS
Date: Tue, 25 Sep 2012 23:48:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209252319260.1770@ja.ssi.bg>
References: <20120911123531.4305.40304.stgit@dragon>  <alpine.LFD.2.00.1209130143410.1653@ja.ssi.bg> <1348578674.2689.15.camel@localhost>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348578674.2689.15.camel@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Tue, 25 Sep 2012, Jesper Dangaard Brouer wrote:

> > 	Some comments:
> > 
> > - About patch 4: ip_vs_icmp_xmit_v6 already calls skb_make_writable
> > before ip_vs_nat_icmp_v6, that is why we provide 'offset'.
> 
> I see, that call path is correct, BUT I was talking about another call
> path of ip_vs_nat_icmp_v6(), via handle_response_icmp() (which also
> calls skb_make_writable).  That call path is triggered, if the
> real-server, have shutdown its service and send back an ICMPv6 packet.

	Yes, currently, both ip_vs_nat_icmp_v6 callers use
skb_make_writable before calling it.

> Hmm, testing it again, I cannot trigger this issue.  Perhaps I was
> confusing my self and were using my test script that added IPv6 exthdrs
> to the packet.  Adding print statements to the code, also show the
> correct offset now.
> I'm dropping this patch-4, and I'll adjust/fix patch-5 ("ipvs: fix
> faulty IPv6 extension header handling in IPVS") accordingly.  And I'll
> double check patch-5, that exthdr have been accounted for (in the offset
> used by skb_make_writable() before calling ip_vs_nat_icmp_v6()).

	Yes, patch-4 is not needed.

> > - May be we can provide the offset of ICMPv6 header
> > from ip_vs_in_icmp_v6 to ip_vs_icmp_xmit_v6 as additional
> > argument (icmp_offset) and then to ip_vs_nat_icmp_v6. By this
> > way we can avoid the two ipv6_find_hdr calls if we also provide
> > the iph argument from ip_vs_icmp_xmit_v6 to ip_vs_nat_icmp_v6,
> > its ->len points to the ports. ip_vs_in_icmp_v6 provides
> > also protocol in this ciph, so may be we have everything.
> 
> Is this comment for the API patch-7 ("ipvs: API change to avoid rescan
> of IPv6 exthdr") ?

	No, this comment is for patch-5 where 2 ipv6_find_hdr
calls are added to ip_vs_nat_icmp_v6. But we can change it
later in followup patch as an optimization.

> The API patch is going to save 19 calls to ipv6_find_hdr ().
> 
> 
> > - in ip_vs_in_icmp_v6 there must be 'offs_ciph = ciph.len;'
> > just before this line:
> > 
> > if (IPPROTO_TCP == ciph.protocol || IPPROTO_UDP == ciph.protocol ||
> > 
> 
> It would be a lot easier for me, if you commented directly on the
> patches.

	Sorry, this is for patch-5, its purpose is for
skb_make_writable in ip_vs_icmp_xmit_v6, not for debug.

> I can see that 'offs_ciph = ciph.len;' is set earlier in this patch, but
> that value is primarily used by IP_VS_DBG_PKT.  And offs_ciph, needs to
> be updated, again, with the value of ciph.len after the call to
> ipv6_find_hdr().  So, yes you are right ;-)
> 
> I'll rename offs_ciph to "writable" to emphasize what we are using this
> value for.

	Good idea, this is its purpose.

> > 	The idea is that we linearize for writing the inner
> > IP header and optionally the 2 ports. That is why old
> > logic was 'offset += 2 * sizeof(__u16);'
> 
> The port logic was kept.  But I'll make it more clear whats happening,
> and keep the "+=" coding style.

	Yes, it was in this way at 2 places before your changes,
one in handle_response_icmp and another in ip_vs_in_icmp_v6.

> > - initially, ip_vs_fill_iph_skb fills iphdr->flags from
> > current fragment, later ip_vs_out_icmp_v6 uses the same
> > ipvsh when calling ipv6_find_hdr. Should we initialize
> > ipvsh->flags to 0 before calling ipv6_find_hdr because
> > it is I/O argument?

	For the record, this is patch-7

> As we don't use the flag, after this point, we can just give
> ipv6_find_hdr() a NULL value instead.

	Agreed, NULL for flags looks fine.

> But I must give you, that it's a little confusing the way we reuse the
> ipvsh variable (in ip_vs_out_icmp_v6()).  Think, this needs to be
> rewritten to use a separate variable, like in ip_vs_in_icmp_v6().

	The initialization is risky but saves stack. So,
it is up to you to decide whether we need local ipvsh_stack
var as before patch-7.

Regards

--
Julian Anastasov <ja@ssi.bg>
