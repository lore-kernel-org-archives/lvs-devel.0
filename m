Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793807570;
	b=AJamp5ACHIZkS5sX8kkz3IWp7aWWtiOuXTjuHt/ha192uKldLOV1mnLqvFFFpT9k/QMM
	 uxQrp8mcxJGw/KR2MiiUIoikF4oWs47Nm0OLuKss2UXJy/BARDb2kLrTeODLSocnMAATB
	 WRUhLqwIXUmnIoPVQynfo0A1ae3rMChf/AwzTiIUyH/ZGzrJ8JrQmrFW8cJ65X7FvXgIq
	 E3bWj9sJWDq2t8wytBtXOMN2Q2rIe7wkgh/H5yZPi9iXc6eEFbIV1OYzSWFEzmFbKQCyl
	 KGWnOrKiR9nY6/Npk2AkhD6wdnDkEAlfF3HVzh3nGN1xE1koYFrp5xOvDuHw52HQKUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793807570;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=Sy8oZDmX7TMbajG9GG2uc2ElEeej6I0jsG5wGiysAXA=;
	b=lXGSQWgWgkYjYvEOfavTPsKtewDQ8QqMA/E9Kzu2BAgoLyAlRyC/r5PuiRSUkjdGc2uL
	 4MYcJFyb1PX+JO+M3yZjo0w5+cJ22NvUfGSQlYYCXeYM8zAc0M4dD/1od9GHlAOkpltHX
	 yA9JsOQ6zJh27vKUCxIfjiiWj/FnUcai1bMI5w1xFr8VULikXoM+5SfOiaMj/C0wI13Sh
	 5jfvZvLVpI9O16pqerM/UCUcVNvjleZ63LdBctz4wIjNGT/QJ95HOqcd48AAAPE/LmtlB
	 Gz3PGKVmSMpUSeOPZEw+1QJR76DZCHlizjdzCvop10rKCrhE84S9FhQIwJ5Wcn+BuHw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=u9UYhEi3;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FC60606A31B;
	Wed,  4 Nov 2026 15:52:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2FC60606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=u9UYhEi3
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 37CCD213F4;
	Wed, 04 Nov 2026 17:52:46 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Sy8oZDmX7TMbajG9GG2uc2ElEeej6I0jsG5wGiysAXA=; b=u9UYhEi33Ofm
	4dp4iI9sGxeSr+1B8DBcT3q8Si81+IPEVSgIq9jo/nAB0n2k/kVC5xFDujL9x26t
	Vy0G0GVRBBqjzMVkLbbzrZxd5BqIuzz4cydfhX29RU27tiKicYrPOL4j5gGk1XbA
	NVvtY3914QI+oVntbP+KHSDfXt1V0IROGE0P8dKYWf3OM+BU9O1lAd5OZ4Ddgg7f
	fOyle5ZN7bDOH11JzmTvmzKF+Gra3NUh9PDcaOdBHntvFlJ+814E7k+0QQBHxqs8
	1MOzv/jk4vvWfHLbeOuSXLsWXPatxWajjsB6NJstf4EOboCqWgD30AB9Z+ZnVxL6
	CEH27TugeWQnMtgG+/e99BxZ9k1WEaeCSV/6HtBA7gI7Ys7QtJItGaVZhgkRx2q7
	pJHGXBqnujNuWBtqN17s/N2mlr3SZwS0IDRBI2U+dR4I4gV0ikStf1T/UybuNQ6S
	F5Xh4dQONmdjoaKCkL80yj9hiR0/PXwWO3OXcG4zBc2W8AhH6uKHGGAsi79nf6CA
	ZApGz7QtdmxyLhCOplP/aFB41xqawuHyYcL3FKTMa2y3/jEwDi5k9iSdiDz/FVrA
	zR4j8qcdmo0bWPJKblzpI4EeJw9GN8H0DMRjV9gL5LKIrXZF4BppNnm51c38wa3L
	IrVTCCqM1c2dJskNFOboGNxIb/fVRk0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 04 Nov 2026 17:52:46 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8718E60A1B;
	Wed,  4 Nov 2026 17:52:45 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A4Fqfn6111012;
	Wed, 4 Nov 2026 17:52:41 +0200
Date: Wed, 4 Nov 2026 17:52:41 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: netdev-bot+sashiko@kernel.org
cc: axel.mierczuk@1password.com, horms@verge.net.au, pablo@netfilter.org,
        fw@strlen.de, phil@nwl.cc, dsahern@kernel.org, idosch@nvidia.com,
        edumazet@google.com, netfilter-devel@vger.kernel.org,
        lvs-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, w@1wt.eu, keith.hoodlet@1password.com,
        kuba@kernel.org
Subject: Re: [PATCH nf 2/2] ipv6: update *offset for non-first fragments in
 ipv6_find_hdr()
In-Reply-To: <179069742830.434549.18028711366472001762@kernel.org>
Message-ID: <db60879b-b876-5ae5-2025-3c423dd9654e@ssi.bg>
References: <20260925141155.17603-3-axel.mierczuk@1password.com> <179069742830.434549.18028711366472001762@kernel.org>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-418008661-1793807563=:94418"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-418008661-1793807563=:94418
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hi Axel,

On Tue, 29 Sep 2026, netdev-bot+sashiko@kernel.org wrote:

> Thank you for your contribution! Sashiko AI review found 4 potential
> issue(s) to consider.
> 
> Critical: 1 · High: 0 · Medium: 0 · Low: 3
> 
> If you believe none of the issues are legitimate, please reply to each
> issue of Medium severity or higher and explain why the AI is wrong.
> If any of them are legitimate and you plan to respin, please let patchwork
> know by including "pw-bot: cr" as a separate line at the end of your reply
> (one such reply per series is enough).
> 
> - [Critical] The new early-return assignment `*offset = start +
>   sizeof(struct frag_hdr)` in ipv6_find_hdr()…
> - [Low] This patch leaves dead code and stale comments in IPVS.
> - [Low] The commit message says "Other target < 0 callers check the
>   returned fragment offset or ignore *offset here." That is not accurate…
> - [Low] The commit message justifies the change only with "IPVS used the
>   initial offset as if it had been updated".
> 
> --
> 
> ipv6: update *offset for non-first fragments in ipv6_find_hdr()
> 
> This commit makes ipv6_find_hdr() set *offset to the byte after the
> Fragment header when it returns early for a non-first fragment with
> target < 0. The kernel-doc is updated to match. The motivation given is
> that IPVS used the initial offset as if it had been updated.
> 
> > The non-first fragment early return is the only successful exit of
> > ipv6_find_hdr() that leaves *offset untouched. IPVS used the initial
> > offset as if it had been updated.
> 
> [Severity: Low]
> What user-visible problem does this fix? The message doesn't name one, and
> there is no Fixes: tag. So it is hard to tell whether this is meant for
> net/stable or is a semantics cleanup of an exported helper with many
> in-tree callers.

	The user-visible problem is that we want ipv6_find_hdr to
advance the *offset at least with the embedded IP header while at the 
same time for ipv6_find_hdr it is more correct to point to the protocol
header or payload not depending on the fragoff field.

> The IPVS ICMPv6 paths already work around the old behaviour (previous patch
> in the series). The offset still seems to matter elsewhere, though.
> ip_vs_fill_iph_skb_off() does:
> 
>     iphdr->len       = offset;
> 
> Take an untracked non-first ESP fragment matched through
> ah_esp_conn_out_get(). Before this patch iph->len stayed at 0 for it, and
> handle_response() then does:
> 
>     if (skb_ensure_writable(skb, iph->len))
>         goto drop;
>     ...
>     ipv6_hdr(skb)->saddr = cp->vaddr.in6;
> 
> This patch changes the writable length used there.
> 
> If this is a fix, could the commit message describe this effect and add a
> Fixes: tag?

	We need a Fixes tag too, may be:

Fixes: b777e0ce7437 ("[NETFILTER]: make ipv6_find_hdr() find transport protocol header")

> > For non-first fragments with target < 0, set *offset immediately
> > after the Fragment header, at the start of the fragment payload.
> > Callers must still account for the nonzero fragment offset. A
> > NEXTHDR_FRAGMENT search continues to return the Fragment header's
> > offset. Other target < 0 callers check the returned fragment offset
> > or ignore *offset here.
> 
> [Severity: Low]
> Is the last sentence accurate for nf_tables? nft_set_pktinfo_ipv6(),
> __nft_set_pktinfo_ipv6_validate() and nft_set_pktinfo_ipv6_ingress() in
> include/net/netfilter/nf_tables_ipv6.h store thoff whatever frag_off is:
> 
>     protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, &flags);
>     ...
>     pkt->thoff = thoff;
>     pkt->fragoff = frag_off;
> 
> nf_trace_fill_pkt_info() in net/netfilter/nf_tables_trace.c then splits
> the NFTA_TRACE_NETWORK_HEADER and NFTA_TRACE_TRANSPORT_HEADER dumps at
> nft_thoff(pkt). It never checks pkt->fragoff:
> 
>     nh_end = pkt->flags & NFT_PKTINFO_L4PROTO ? nft_thoff(pkt) : skb->len;
>     ...
>     len = min_t(unsigned int, skb->len - nft_thoff(pkt), NFT_TRACETYPE_TRANSPORT_HSIZE);
> 
> Before this patch, a non-first fragment had thoff = 0. The network header
> dump was empty and the transport dump held the IPv6 header.
> 
> After it, the network dump covers the IPv6, extension and Fragment
> headers, and the transport dump holds fragment payload. So nft monitor
> trace output changes for non-first IPv6 fragments.
> 
> Could the commit message mention this change?
> 
> The SYNPROXY callers also use this offset without checking the fragment
> offset. That case is covered in the comment on the code below.
> 
> > diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
> > index 4a9748338cf40..e27f5b8cc1542 100644
> > --- a/net/ipv6/exthdrs_core.c
> > +++ b/net/ipv6/exthdrs_core.c
> 
> [ ... ]
> 
> > @@ -261,6 +264,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
> >  				     hp->nexthdr == NEXTHDR_NONE)) {
> >  					if (fragoff)
> >  						*fragoff = _frag_off;

	if (skb->len - start < sizeof(struct frag_hdr))
		return -EBADMSG;

> > +					*offset = start + sizeof(struct frag_hdr);
> 
> [Severity: Critical]
> Can this offset end up past skb->len? In the NEXTHDR_FRAGMENT branch,
> skb_header_pointer() has only read hp (2 bytes at start) and frag_off
> (2 bytes at start + 2). All that is known is skb->len >= start + 4.

	We need the above check.

> 
> This early return also skips the check that guards every other successful
> exit:
> 
>     if (!found) {
>         if (skb->len - start < hdrlen)
>             return -EBADMSG;
> 
> Before this patch, every successful return left *offset <= skb->len. Now
> it can be as large as skb->len + 4.
> 
> Here is an example. A 44-byte IPv6 packet has payload_len = 4 and
> nexthdr = 44. Its 4 bytes of Fragment header carry nexthdr = TCP and a
> nonzero fragment offset. ip6_rcv_core() trims the skb to 44 bytes, and
> ipv6_find_hdr() returns IPPROTO_TCP with *offset = 48.
> 
> nft_set_pktinfo_ipv6() only checks thoff > U16_MAX, so pkt->thoff = 48.
> nft_synproxy_do_eval() checks pkt->tprot but not pkt->fragoff:
> 
>     if (pkt->tprot != IPPROTO_TCP) {
>         ...
>     }
> 
>     if (nf_checksum(skb, nft_hook(pkt), thoff, IPPROTO_TCP,
>                     nft_pf(pkt))) {
> 
> That leads to:
> 
> nft_synproxy_do_eval()
>   nf_checksum()
>     nf_ip6_checksum()
>       skb_checksum(skb, 0, dataoff, 0)
>         BUG_ON(len)
> 
> nf_ip6_checksum() also computes skb->len - dataoff, which underflows.
> 
> synproxy_tg6() in ip6t_SYNPROXY is exposed the same way. It passes
> par->thoff to nf_ip6_checksum() without checking par->fragoff, and
> ip6_packet_match() sets par->thoff from ipv6_find_hdr().
> 
> nf_ct_frag6_gather() would drop such a packet. Untracked packets skip it,
> though, because ipv6_defrag() returns NF_ACCEPT for IP_CT_UNTRACKED.
> Examples are notrack in an nft chain with priority below -400, ip6table_raw
> with raw_before_defrag, and a "ct state untracked synproxy" rule. An
> unprivileged user can also set this up inside a user and network
> namespace.
> 
> Other callers see an out-of-range offset too:
> 
>   - In nf_trace_fill_pkt_info(), skb->len - nft_thoff(pkt) wraps and the
>     trace event is lost.
>   - In IPVS, a ciph.len beyond skb->len makes skb_ensure_writable() fail.
>     ICMPv6 errors that used to be NATed are then dropped.
> 
> The updated kernel-doc says *offset points at the start of the fragment
> payload. That isn't guaranteed when the Fragment header is truncated.
> 
> Should this return -EBADMSG when skb->len - start is less than
> sizeof(struct frag_hdr)? Another option is to read the full struct
> frag_hdr with skb_header_pointer() before setting the offset.
> 
> [Severity: Low]
> Does this assignment make the workaround from the previous patch in the
> series ("ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6") dead code?
> ip_vs_out_icmp_v6() and ip_vs_in_icmp_v6() in
> net/netfilter/ipvs/ip_vs_core.c both contain:
> 
>     /* ipv6_find_hdr() does not include the embedded header for
>      * non-first fragments, add it so that ESP can pass and the
>      * NAT writable checks cover the rewritten addresses
>      */
>     if (ciph.len == ciph.off)
>         ciph.len += sizeof(struct ipv6hdr);
> 
> Both call ip_vs_fill_iph_skb_icmp() with a nonzero offset. So
> ipv6_find_hdr() starts at *offset + sizeof(struct ipv6hdr).
> 
> Every successful return now writes *offset, either start or
> start + sizeof(struct frag_hdr). So ciph.len can no longer equal
> ciph.off. The comment at both sites now also contradicts the helper's
> documented behaviour.
> 
> The previous patch needs to stand alone for stable. Could this patch, or a
> follow-up, drop the check and update those comments?
> 
> >  					return hp->nexthdr;
> >  				}
> >  				if (!found)
> 
> -- 
> Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141155.17603-1-axel.mierczuk%401password.com

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-418008661-1793807563=:94418--

