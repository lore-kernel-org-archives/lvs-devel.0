Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793608677;
	b=vAJv1T31DFgmpdr1rfGCKSL0yDOvA1GEVj79tL6LBe1N7zeTlMwEleizp2F7myrbHywB
	 6t+rGhFX499wM7WkUommAbYKgLw1cJP9VOF6PMJqdwvNwK+0v9zd4TL6/s5tmwoJ6XBDW
	 dnA/hehQvlVt2vNA81syqwGUygxWEIOIcOw2qFiCG2OozF+VJ4M8xCCugfgIp73yBfInW
	 Bc0B9FBNAYr80p7lFwrRo43O4rRpNYoHN3U2Ffl6tzXdg1ajGv+OWDNy3QjnP2au3X+un
	 4urvy6pUMMBLp1wWCVucZPhhgAdjW/QboTQNYaxpnWF9tpZuzX9eGssFlu2pkIPOT9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793608677;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=UNXfYq8Mz5SEsKnMwiVAwZg1lZOEWjxHj4W+Edy0uS0=;
	b=lr3CxOG0bOytI8ESTeNqv3fdlvTMRNemJqOW6+KCOg00BFVEzOTySZF6uf3l4NOGI1dw
	 XjpPKuFkhijhrmoSy4famtWIrw8qwcvi8bPNCavXZlgbpNksIKD1yu8qH4mfjpOjl+HSG
	 dcbOFkirmm4LxqH0ZZMEu/uQLKOFvBe+kgJ38og3ea+ThA5sazOpmpN634sipIbcEV7Wk
	 fVYN5eBaGUcJrqZOahu/R+0mkdWtyk4cx40d4HYLlaAliFlNPzT6Dpeo93rT+4n9kS02X
	 9mYbTiLYppXUfuaJO9N1obWnFGVmIqPcINB3pMdH27PKFnXWAOxot73Kb1imocE/2Fw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=d0I15Uhv;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC0E9606A327;
	Mon,  2 Nov 2026 08:37:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EC0E9606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=d0I15Uhv
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 6641C21F8B;
	Mon, 02 Nov 2026 10:37:54 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=UNXfYq8Mz5SEsKnMwiVAwZg1lZOEWjxHj4W+Edy0uS0=; b=d0I15UhvOZJb
	9hsrvZrLYVjQ3sg/0GiIjBT3sn4aHS5r+0J5HuiENPGQy1rjrOJKeFO3Vg/amhIX
	Wtq6vM3IZ+rk6wD/C7mwPsEeuxtGvDJp9gdxf7e4S2vNetpvua6e9ENKhtHaZ9qw
	DdJwzkvXPV66z2gCTSPJRRn0TEdtGivjgX42bi5pdLlWwdOp3X/aUAg4lj0tJrUD
	+fwWC/t0oiUDbMFGdaJnVfLeqEa6PoKs7Hx67KuHnpIxyGaNKHodGDnFI8CRUyjt
	gS3+x69SWa7Px3N0Syg88EqwybiTIkBMn459/2GyEm6Eztgh0e9X05CipkoloTB0
	oS/BZAHb+ihuyfAMGlxe+bT4e+yLna5QMP3SDIitzj21DH15u9EzZ3y0oYjFON42
	NWqS5+XuGQRZwrQEvUCEsZ+WbTtAzVjTDJ87aZWEpEwlCGyqv5hCPJm0lqcT3dRe
	jX2t5bSONkj/zvtUp2Xw4lypPGib/hboAvm2XymWlNWaZdkFvFtCKET0aEvxstLp
	H03xckd2qhZBpxtfVJoHmKzclLcdF3hiIkloAJgegFU6WLSplpnSIvLCEG5yx3rk
	dWm49r1knkPpIlTcy2xIHF0OI1roUOKHA7+Y8WKgnJCudaN7/44Wwin0DfWM/+h+
	b8W3esXMW6qbXMy2A476BJIuHAvKNg0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 02 Nov 2026 10:37:54 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C7774609A3;
	Mon,  2 Nov 2026 10:37:53 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A28bq33026165;
	Mon, 2 Nov 2026 10:37:52 +0200
Date: Mon, 2 Nov 2026 10:37:52 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: pass correct sk to update_pmtu and on
 tunneling
In-Reply-To: <20261102082101.23437-1-ja@ssi.bg>
Message-ID: <115ccf69-603f-91fe-6e9b-3dd6380e8089@ssi.bg>
References: <20261102082101.23437-1-ja@ssi.bg>
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

On Mon, 2 Nov 2026, Julian Anastasov wrote:

> This commit fixes two cases of providing sk on tunneling,
> one to the update_pmtu handler and the second case is to
> the ip_local_out() call.
> 
> For local clients, we can see at LOCAL_OUT a netfilter hook's
> state->sk that is different from the protocol's skb->sk. This
> can be the case for UDP_TUNNEL where different sk is provided to
> ip_local_out. If such packet is then forwarded via IPVS tunnel
> we may need to provide state->sk to the update_pmtu handler.
> 
> Fix that by passing the netfilter's hook state via the
> packet_xmit and conn_schedule handlers to call the update_pmtu
> handler with state->sk instead of skb->sk.
> 
> While here, change maybe_update_pmtu() to be family independent
> by using dst and do not request neigh confirm via the last
> update_pmtu arg because we do not generate the event based on
> remote signal.
> 
> The second problem is that on tunnel forwarding we call
> ip_local_out() with skb->sk. As we push our own outer IP header
> in ip_vs_tunnel_xmit*(), the right thing is to provide NULL
> instead.
> 
> For consistency, even if we do not walk the netfilter hooks and
> just pass the packet with NF_ACCEPT, provide ip_vs_null_xmit_v6
> handler to properly indicate that we are sending IPv6 packet.
> Before now we used ip_vs_null_xmit for both families.
> 
> Fixes: 79b16aadea32 ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb().")
> Fixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okfn().")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/net/ip_vs.h                     |  45 ++++++----
>  net/netfilter/ipvs/ip_vs_conn.c         |   2 +-
>  net/netfilter/ipvs/ip_vs_core.c         |  41 +++++----
>  net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   2 +-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c   |   5 +-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c    |   5 +-
>  net/netfilter/ipvs/ip_vs_proto_udp.c    |   5 +-
>  net/netfilter/ipvs/ip_vs_xmit.c         | 106 +++++++++++++++---------
>  8 files changed, 134 insertions(+), 77 deletions(-)
> 

> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index f5f72a2135e1..931ecd849fe5 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c

>  /*
>   *      Bypass transmitter
>   *      Let packets bypass the destination when the destination is not
> @@ -734,12 +753,14 @@ ip_vs_null_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>   */
>  int
>  ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
> -		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
> +		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh,
> +		  const struct nf_hook_state *state)
>  {
>  	struct iphdr  *iph = ip_hdr(skb);
>  
>  	if (__ip_vs_get_out_rt(cp->ipvs, cp->af, skb, NULL, iph->daddr,
> -			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh) < 0)
> +			       IP_VS_RT_MODE_NON_LOCAL, NULL, ipvsh,
> +			       state) < 0)
>  		goto tx_error;

	Oh well, this hunk does not apply to recent nf, will send v2.

pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

