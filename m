Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24E103F4DE9;
	Tue, 29 Sep 2026 15:57:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790697431; cv=none; b=WSK5L57GSkBWUmXRXRUFfgwyxa3tzqmqb7H2mUkPaoIO5RCY2UMTs7piUdbIhS1Vi05aRQE29UX164lOm3U+URLZZ1mwI4gtMxwVQWQzR5qT9utaEedNN7Q/TKtBQdbM6jWFm3ju4TwB+R/fAua/1dCMbAuP4IpDt6ECtmPv+Tc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790697431; c=relaxed/simple;
	bh=wKSezAIzzdZTvHkKw/xVf/zlAkGtS6i2FdCXa6kjPCo=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=jDl5u5I3Rp9w36ZJB7HpMKQL2JuP7ZZw/9UnAM0wV/5FwJFAtaosu6cVAR0hF8p0Sc6n5rjvJFmBOjS/70HOzKoOVSy1x6OeVROjkyQwXiSYB7dhi6mrhfZs8Izxx5J0Erw36MGRYp/fwnOMGmKHKr5oGfB4bSTLrKd4bbGj7VQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A7hXz3Iw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A7hXz3Iw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C1EEB1F00893;
	Tue, 29 Sep 2026 15:57:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790697429;
	bh=fc8ig+KNLWkhooZSOGE/YBEt0jucYgHx7aDgKxTBVNo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=A7hXz3IwRHJwrfgG9UEg5V9OZE/6dcqT7k/aCgOdeha8XOCZnKhsXcdnhStIxgtxt
	 3dtZsx8L0OvtYSSKvRTr6qQZ3k5EF9+RJZvX8bG+LBfIgPncZLobz0WqQJhfywOppp
	 jUYjahMhoqAtsKAMrXPIScAyHi+ClFlJ6/Y3/AOxBjKaUsuZoIZXObV+pBOi5IRhxZ
	 jnZVN1RQD4nSP2LpbZ1hP7Z0YBbUvEvrVTLYK5fOV10jWJtjBYgfLpqxKq5714oNdN
	 vn8wdn+IOFT/2iEGVZl6CthgFjfPuLpxANiD4shQSsSdT8TOmvoRqtL55DR0dV/SKB
	 ANQV4NI3WueJA==
Subject: Re: [PATCH nf 2/2] ipv6: update *offset for non-first fragments in
 ipv6_find_hdr()
From: netdev-bot+sashiko@kernel.org
To: axel.mierczuk@1password.com
Cc: ja@ssi.bg, horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, dsahern@kernel.org, idosch@nvidia.com, edumazet@google.com,
 netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
 coreteam@netfilter.org, netdev@vger.kernel.org, w@1wt.eu,
 keith.hoodlet@1password.com, kuba@kernel.org
Date: Tue, 29 Sep 2026 15:57:08 +0000
Message-ID: <179069742830.434549.18028711366472001762@kernel.org>
In-Reply-To: <20260925141155.17603-3-axel.mierczuk@1password.com>
References: <20260925141155.17603-3-axel.mierczuk@1password.com>
X-sashiko-severity: Critical
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 4 potential
issue(s) to consider.

Critical: 1 · High: 0 · Medium: 0 · Low: 3

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [Critical] The new early-return assignment `*offset = start +
  sizeof(struct frag_hdr)` in ipv6_find_hdr()…
- [Low] This patch leaves dead code and stale comments in IPVS.
- [Low] The commit message says "Other target < 0 callers check the
  returned fragment offset or ignore *offset here." That is not accurate…
- [Low] The commit message justifies the change only with "IPVS used the
  initial offset as if it had been updated".

--

ipv6: update *offset for non-first fragments in ipv6_find_hdr()

This commit makes ipv6_find_hdr() set *offset to the byte after the
Fragment header when it returns early for a non-first fragment with
target < 0. The kernel-doc is updated to match. The motivation given is
that IPVS used the initial offset as if it had been updated.

> The non-first fragment early return is the only successful exit of
> ipv6_find_hdr() that leaves *offset untouched. IPVS used the initial
> offset as if it had been updated.

[Severity: Low]
What user-visible problem does this fix? The message doesn't name one, and
there is no Fixes: tag. So it is hard to tell whether this is meant for
net/stable or is a semantics cleanup of an exported helper with many
in-tree callers.

The IPVS ICMPv6 paths already work around the old behaviour (previous patch
in the series). The offset still seems to matter elsewhere, though.
ip_vs_fill_iph_skb_off() does:

    iphdr->len       = offset;

Take an untracked non-first ESP fragment matched through
ah_esp_conn_out_get(). Before this patch iph->len stayed at 0 for it, and
handle_response() then does:

    if (skb_ensure_writable(skb, iph->len))
        goto drop;
    ...
    ipv6_hdr(skb)->saddr = cp->vaddr.in6;

This patch changes the writable length used there.

If this is a fix, could the commit message describe this effect and add a
Fixes: tag?

> For non-first fragments with target < 0, set *offset immediately
> after the Fragment header, at the start of the fragment payload.
> Callers must still account for the nonzero fragment offset. A
> NEXTHDR_FRAGMENT search continues to return the Fragment header's
> offset. Other target < 0 callers check the returned fragment offset
> or ignore *offset here.

[Severity: Low]
Is the last sentence accurate for nf_tables? nft_set_pktinfo_ipv6(),
__nft_set_pktinfo_ipv6_validate() and nft_set_pktinfo_ipv6_ingress() in
include/net/netfilter/nf_tables_ipv6.h store thoff whatever frag_off is:

    protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, &flags);
    ...
    pkt->thoff = thoff;
    pkt->fragoff = frag_off;

nf_trace_fill_pkt_info() in net/netfilter/nf_tables_trace.c then splits
the NFTA_TRACE_NETWORK_HEADER and NFTA_TRACE_TRANSPORT_HEADER dumps at
nft_thoff(pkt). It never checks pkt->fragoff:

    nh_end = pkt->flags & NFT_PKTINFO_L4PROTO ? nft_thoff(pkt) : skb->len;
    ...
    len = min_t(unsigned int, skb->len - nft_thoff(pkt), NFT_TRACETYPE_TRANSPORT_HSIZE);

Before this patch, a non-first fragment had thoff = 0. The network header
dump was empty and the transport dump held the IPv6 header.

After it, the network dump covers the IPv6, extension and Fragment
headers, and the transport dump holds fragment payload. So nft monitor
trace output changes for non-first IPv6 fragments.

Could the commit message mention this change?

The SYNPROXY callers also use this offset without checking the fragment
offset. That case is covered in the comment on the code below.

> diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
> index 4a9748338cf40..e27f5b8cc1542 100644
> --- a/net/ipv6/exthdrs_core.c
> +++ b/net/ipv6/exthdrs_core.c

[ ... ]

> @@ -261,6 +264,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>  				     hp->nexthdr == NEXTHDR_NONE)) {
>  					if (fragoff)
>  						*fragoff = _frag_off;
> +					*offset = start + sizeof(struct frag_hdr);

[Severity: Critical]
Can this offset end up past skb->len? In the NEXTHDR_FRAGMENT branch,
skb_header_pointer() has only read hp (2 bytes at start) and frag_off
(2 bytes at start + 2). All that is known is skb->len >= start + 4.

This early return also skips the check that guards every other successful
exit:

    if (!found) {
        if (skb->len - start < hdrlen)
            return -EBADMSG;

Before this patch, every successful return left *offset <= skb->len. Now
it can be as large as skb->len + 4.

Here is an example. A 44-byte IPv6 packet has payload_len = 4 and
nexthdr = 44. Its 4 bytes of Fragment header carry nexthdr = TCP and a
nonzero fragment offset. ip6_rcv_core() trims the skb to 44 bytes, and
ipv6_find_hdr() returns IPPROTO_TCP with *offset = 48.

nft_set_pktinfo_ipv6() only checks thoff > U16_MAX, so pkt->thoff = 48.
nft_synproxy_do_eval() checks pkt->tprot but not pkt->fragoff:

    if (pkt->tprot != IPPROTO_TCP) {
        ...
    }

    if (nf_checksum(skb, nft_hook(pkt), thoff, IPPROTO_TCP,
                    nft_pf(pkt))) {

That leads to:

nft_synproxy_do_eval()
  nf_checksum()
    nf_ip6_checksum()
      skb_checksum(skb, 0, dataoff, 0)
        BUG_ON(len)

nf_ip6_checksum() also computes skb->len - dataoff, which underflows.

synproxy_tg6() in ip6t_SYNPROXY is exposed the same way. It passes
par->thoff to nf_ip6_checksum() without checking par->fragoff, and
ip6_packet_match() sets par->thoff from ipv6_find_hdr().

nf_ct_frag6_gather() would drop such a packet. Untracked packets skip it,
though, because ipv6_defrag() returns NF_ACCEPT for IP_CT_UNTRACKED.
Examples are notrack in an nft chain with priority below -400, ip6table_raw
with raw_before_defrag, and a "ct state untracked synproxy" rule. An
unprivileged user can also set this up inside a user and network
namespace.

Other callers see an out-of-range offset too:

  - In nf_trace_fill_pkt_info(), skb->len - nft_thoff(pkt) wraps and the
    trace event is lost.
  - In IPVS, a ciph.len beyond skb->len makes skb_ensure_writable() fail.
    ICMPv6 errors that used to be NATed are then dropped.

The updated kernel-doc says *offset points at the start of the fragment
payload. That isn't guaranteed when the Fragment header is truncated.

Should this return -EBADMSG when skb->len - start is less than
sizeof(struct frag_hdr)? Another option is to read the full struct
frag_hdr with skb_header_pointer() before setting the offset.

[Severity: Low]
Does this assignment make the workaround from the previous patch in the
series ("ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6") dead code?
ip_vs_out_icmp_v6() and ip_vs_in_icmp_v6() in
net/netfilter/ipvs/ip_vs_core.c both contain:

    /* ipv6_find_hdr() does not include the embedded header for
     * non-first fragments, add it so that ESP can pass and the
     * NAT writable checks cover the rewritten addresses
     */
    if (ciph.len == ciph.off)
        ciph.len += sizeof(struct ipv6hdr);

Both call ip_vs_fill_iph_skb_icmp() with a nonzero offset. So
ipv6_find_hdr() starts at *offset + sizeof(struct ipv6hdr).

Every successful return now writes *offset, either start or
start + sizeof(struct frag_hdr). So ciph.len can no longer equal
ciph.off. The comment at both sites now also contradicts the helper's
documented behaviour.

The previous patch needs to stand alone for stable. Could this patch, or a
follow-up, drop the check and update those comments?

>  					return hp->nexthdr;
>  				}
>  				if (!found)

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141155.17603-1-axel.mierczuk%401password.com
