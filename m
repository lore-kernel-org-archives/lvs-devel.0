Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794946805;
	b=fFDlWaQHUl6/y0i+lh+SjiOPECbjQPgXXL6JJVro5CsWPQzx+aD8kpYyq8buTcUgjASS
	 3wkxAp2Y2Idxz1jwVBE4nrrm/2MQ6AzixphcRq2SEsylOJR4VYFNeQ1rLusGaeJjoVJxp
	 wQCVghk1omq9fHNBNIA/f/UGkfi29MDADpjRRQzPxVY1izxNgg3NsbD36f9wFkWdjjkHW
	 EE2UQLV5x/p5rsuN1Ol/g3VSlqdca7ARbtMym+yP4Hgsc3CUmFDvs/Kug67s0wROfD+sa
	 WvtPgG/mPTheEPHgFfSMscKt8YRmdF9Sb85erPJR+0jar6VohkorqPhwwXO96MQ48mg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794946805;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=2Yth5nPHUGbJx18vRlBtBWemzjlOS16UhKx0Z9GyHbk=;
	b=NrHmBRcIURgWKJbJghW4ITf+s52UudniO6JZVnL5mjd4hdOY498E6t0GoViWnl6aWR8u
	 nho6wMJXSMZM91sDBfecIEq9HRiEPSk8rWQGMekGr9xf2ykS6aPUMkUblcFQV6wACbcVF
	 gdUO/wt7rbC417n27aNCCulWfx2aNW7uGMXzI9Nbzr1XZlQCKCxUAidTz5PiLuhgPhnAq
	 Ogl9Rq2fDr2MwqJaW/TxIMoc4b7FfDNwk7QSblnNWBqLIiPS+hUfmWxX7xAUx8c3/3R2m
	 hkaqpRzsbPBIU4u1qKh04lKo77JbUNPxFzGfUfjcVF52QzrSVeVGNXE69IDUTQ77REQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=qwHDIuNG;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F86B606A31C;
	Tue, 17 Nov 2026 20:20:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0F86B606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=qwHDIuNG
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9115521FD2;
	Tue, 17 Nov 2026 22:19:54 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2Yth5nPHUGbJx18vRlBtBWemzjlOS16UhKx0Z9GyHbk=; b=qwHDIuNGaklG
	GqrIYu5RtpspwbXefEwaUfDpr20Fr2MeB8Nf4+A9c4y8CMfEnzif9/ip0g3zVX7G
	rvSL0aAo7EbrPN/jQ0PtSTM8/LQ+YZ29ThN7+7VG4NoOU+3uGgzPtzHb9FDXnR3M
	9sO+AMPGshUAhiyXe0Y2P+2cTB2iy2vE1ZIpC8xBF7WX/qliDXBmpzjMnCTyQaVd
	RTuHTyC99nlhLBwDeLJ9r+O3QsekU6as8k8OjzNXjZukdDPTHaJa093PcXsiOUi7
	R/jhmdfTnGXe3JYJd3OXmLS9+KIkjTXVX50bqYs94vFx4z/4+AwvL/aF3um/rW0r
	hehF7zvJFhwNKrfu2Is3B2gR5SQSNeiparag8r++Hvli1EFgKZC93A+7/eVThjQy
	4WOYZ70+iVwsc87riBBU55CurJ7yJ8VYgdJoWiRkonvp5fI1QkG4F+zES97i62qS
	6l4qNW3z6yw0cFg189F+X/PMbj5HHaW5NWnpHKVAcTOsoVTiekWchK+DcE2r4P4+
	HdUI3rERqbwmz7yxWthikarxlleMfdeY2mP9d6kR5wfWpIXmdaWeF0fAMnhF4rQ2
	OueVyXsCZOVR5vwV4sx2PNJLwWl8B1vBB0SgTTNOvzTACSdwwDeMNpDB8sVesZFB
	7xe8+x3nWoAaELiEYQ6Xdejpp0StHkU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 17 Nov 2026 22:19:54 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 18261603F2;
	Tue, 17 Nov 2026 22:19:54 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AHKJind097451;
	Tue, 17 Nov 2026 22:19:45 +0200
Date: Tue, 17 Nov 2026 22:19:44 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Axel Mierczuk <axel.mierczuk@1password.com>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        dsahern@kernel.org, kuba@kernel.org, edumazet@kernel.org,
        pabeni@redhat.com, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org, w@1wt.eu
Subject: Re: [PATCH nf v2 0/2] ipvs: fix OOB write when NATing ICMPv6 errors
 quoting non-first fragments
In-Reply-To: <20261117134049.52386-1-axel.mierczuk@1password.com>
Message-ID: <a41ef905-ffa8-14e0-ba12-672d69de41df@ssi.bg>
References: <20261117134049.52386-1-axel.mierczuk@1password.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 17 Nov 2026, Axel Mierczuk wrote:

> This series fixes a 16-byte OOB write past the verified skb area,
> reachable through ICMPv6 errors that quote non-first fragments.
> Following Julian's suggestion, it preserves ESP ICMPv6 handling.
> 
> Patch 1 includes the embedded IP header in ciph.len at both ICMPv6
> call sites when parsing stops at a non-first fragment. It stands on
> its own for stable.
> 
> Patch 2 makes ipv6_find_hdr() set *offset to the fragment payload
> for non-first fragments when target < 0, rejecting a truncated
> Fragment header, so every successful return updates *offset. It
> drops the workaround from patch 1, which becomes dead code.
> 
> Changes since v1:
> - Patch 1: rewrote the comment and commit message. Nothing blocks an
>   embedded ESP fragment on ciph.len; it continues because of
>   pp->dont_defrag and its lookup reads only the addresses. Name the
>   skb_ensure_writable() callers, handle_response_icmp() and
>   ip_vs_icmp_xmit_v6(), that size the writable area from ciph.len.
>   Code unchanged.
> - Patch 2: return -EBADMSG when the Fragment header is truncated, so
>   *offset never exceeds skb->len (Sashiko, Julian). Add Fixes tag
>   (Julian). Drop the ciph.len workaround from patch 1 now that every
>   successful return writes *offset (Sashiko). Describe the
>   handle_response() effect, the nf_tables trace output change and the
>   SYNPROXY callers in the commit message.
> 
> v1: https://lore.kernel.org/netfilter-devel/20260925141155.17603-1-axel.mierczuk@1password.com/
> 
> Axel Mierczuk (2):
>   ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
>   ipv6: update *offset for non-first fragments in ipv6_find_hdr()

	Both patches look good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> 
>  net/ipv6/exthdrs_core.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> 
> base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b
> -- 
> 2.50.1 (Apple Git-155)

Regards

--
Julian Anastasov <ja@ssi.bg>

