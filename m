Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E2DC3FC5BD;
	Tue, 29 Sep 2026 15:57:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790697429; cv=none; b=i4JHAZHvvrIXQaj8tJE+bVHemPTi6m5XhaKJX2YH6A1r50R/bywMV3zsGrpLz2Pse0+BatEFRMc45OV400lFLlcjRbUgsCyAmBgsRzy0w7LYz+rESFzHaxvpNE7q5UptZNoNVa1sukYMuKj74VjzBSmh6wMXt7jXUEwYiS3A9XU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790697429; c=relaxed/simple;
	bh=7B+e+FnWsLazYxgye1h8ctzNv7cGHGkL1+hMlPHRpi0=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=KgJkxOhCJ2RxsPf+mRCdnF76KUIn2OF6EOTFMZ3yzDi4yuXdq+Xr9gZgLk0iaspafkGjS/zzBMRN3JshNNkZ5Z6CPfkmpsGuERCJBZP8Gfq2LYf7iXGpGFO7t2S76cnyRjf1uXBCY+fxzQlGU+ixOgjRgkGpYmdLwj0xralUqx4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mj+aOLt1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mj+aOLt1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 480C91F000FF;
	Tue, 29 Sep 2026 15:57:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790697428;
	bh=XtllMK+kIdfSUvzILF4t2kInHLK8Sf/p2SukZ5kL3zc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=mj+aOLt1/2XjGU4uwtkRq4sfu47NnpribrPB/4DxTpdmpotNZnvYumMjtmU+5LCXp
	 3nigsOhHANW4HFZ8GKuLfMEo2JFh5QKiCNAW9x1xJwt49g6DD0It/L/F+oPCUNVTV7
	 xlG9Q+8tao1VWv1hF76glK7kfSOb3bKzm+TTfYpyhqvrxrbLAK46oqWqhmgp9C54Kj
	 5n5ffvzk90M8DWCCRJY70LiMkz/AA1BgKKpod+ZO8zq8p64YDxx1LVaOVKSSxjQqvk
	 vbtaU3F3fFAp9kQAzWfj3gMMKh9dMIPGgNAcK+zgS6aZ/4aDsesVdhfJOLckQgcUu2
	 OY6NACRjrOjtg==
Subject:
 Re: [PATCH nf 1/2] ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
From: netdev-bot+sashiko@kernel.org
To: axel.mierczuk@1password.com
Cc: ja@ssi.bg, horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, dsahern@kernel.org, idosch@nvidia.com, edumazet@google.com,
 netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
 coreteam@netfilter.org, netdev@vger.kernel.org, w@1wt.eu,
 keith.hoodlet@1password.com, kuba@kernel.org
Date: Tue, 29 Sep 2026 15:57:06 +0000
Message-ID: <179069742680.434549.10138453724847288168@kernel.org>
In-Reply-To: <20260925141155.17603-2-axel.mierczuk@1password.com>
References: <20260925141155.17603-2-axel.mierczuk@1password.com>
X-sashiko-severity: Low
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found more severe
issue(s) in other patches of this series. This mail is only an FYI, in case
you want to address the nit picks below when you respin.

Low priority / nit picks for your consideration:

- [Low] Three problems with the comment and commit message; the code
  change itself is correct.

--

ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6

When ipv6_find_hdr() stops at a non-first fragment and leaves len equal
to off, this patch adds sizeof(struct ipv6hdr) to ciph.len in both
ip_vs_out_icmp_v6() and ip_vs_in_icmp_v6(). With that, the
skb_ensure_writable() calls in the ICMPv6 NAT paths cover the embedded
addresses that ip_vs_nat_icmp_v6() rewrites.

> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index fd503f0efb578..cfd193196a5bc 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1206,6 +1206,13 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
>  				     true, &ciph))
>  		return NF_ACCEPT; /* The packet looks wrong, ignore */
>  
> +	/* ipv6_find_hdr() does not include the embedded header for
> +	 * non-first fragments, add it so that ESP can pass and the
> +	 * NAT writable checks cover the rewritten addresses
> +	 */

[Severity: Low]
The code change looks correct. Is the "so that ESP can pass" part of
this comment accurate, though?

I couldn't find anything that blocks an embedded IPv6 ESP fragment based
on ciph.len:

  - Neither ip_vs_out_icmp_v6() nor ip_vs_in_icmp_v6() compares ciph.len
    with ciph.off.
  - The only such check is the "ciph->len - ciph->off" ihl check, and it
    exists only on the IPv4 path.
  - The ESP lookup reads only the addresses:

net/netfilter/ipvs/ip_vs_proto_ah_esp.c:ah_esp_conn_fill_param_proto() {
	if (likely(!ip_vs_iph_inverse(iph)))
		ip_vs_conn_fill_param(ipvs, af, IPPROTO_UDP,
				      &iph->saddr, htons(PORT_ISAKMP),
				      &iph->daddr, htons(PORT_ISAKMP), p);
	...
}

So non-first ESP fragments already reached connection lookup and NAT
before this patch. That is how the out-of-bounds write happened.

The new value seems to be used only as ctoff in handle_response_icmp()
and as wlen in ip_vs_icmp_xmit_v6():

net/netfilter/ipvs/ip_vs_xmit.c:ip_vs_icmp_xmit_v6() {
	...
	wlen = ciph->len;
	...
}

Would the comment be clearer if it said that len must cover the embedded
IPv6 header that ip_vs_nat_icmp_v6() rewrites? The same comment appears
again in ip_vs_in_icmp_v6().

The commit message also says:

    This fix does not depend on patch 2.

Once this is applied, "patch 2" has no meaning in the git history. Could
the message name the companion commit instead: "ipv6: update *offset for
non-first fragments in ipv6_find_hdr()"?

That companion commit makes ipv6_find_hdr() set
*offset = start + sizeof(struct frag_hdr) on the non-first-fragment
early return. After it lands, can ciph.len == ciph.off still be true in
either function?

If not, the new branch can never be reached in mainline. The comment's
premise, "ipv6_find_hdr() does not include the embedded header for
non-first fragments", would then be false. Should the comment say it
applies only to kernels where ipv6_find_hdr() leaves *offset unchanged?

> +	if (ciph.len == ciph.off)
> +		ciph.len += sizeof(struct ipv6hdr);
> +
>  	pp = ip_vs_proto_get(ciph.protocol);
>  	if (!pp)
>  		return NF_ACCEPT;

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141155.17603-1-axel.mierczuk%401password.com
