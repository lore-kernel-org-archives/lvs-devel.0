Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E5522E040D;
	Sun,  5 Jul 2026 17:35:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783272940; cv=none; b=Qm2B/nEmYpyD5Dk1q09Et03dXMP+9TQ8hEfHBPa7m/r41n8Jblb0ka+dNfl4eF8BcDDCyE2rNfApHS+N+GqelwVyFGjjgHfMSnHYqiRAsPy26tV04pnR2YNlSJIReegd4hZAHZDv+ti7KvzwwNtnRTn0yveXiAP1OKASdI+cjc8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783272940; c=relaxed/simple;
	bh=WyGwWJN+OH50Z91REEm9w4KWOCCGAKHjGjZe1XG/yl4=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=DVRCy+NTbI2kN3qk+gnIpuSshDe5GbkxSMk1ie6MG9E+otfnURlGbToS7dxEwcUIKRvzMonTjrd4wJ154aoG25oZfY4XZ5OwVnKo41LlwvfOTiy/5asN8RE+1/6FqzB+LrgpmwdqplP1Hzn85IDDZpZVhfIlats3xe4bqVI/MME=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=0tafbLot; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="0tafbLot"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A2804210B7;
	Sun, 05 Jul 2026 20:35:24 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=QRg4sK/4xZE7XJSekjtTVWzTFsM2DwDYito+csqtwXQ=; b=0tafbLotiqDD
	n8fK+HYmIT4/IwKXwBrWJmgBN8v5rmyyganWzc26KxxwaE1PGkwDH1eW2vKkjHzj
	SJ7l75me59d7kPSimYdamWkJCfjwDkhzkLyWT0FaAzh2bgO4v0dgEq2g5FzKW6EX
	MFIu5ZBGgJMnup2bRvYg4nK7vg1u1BGbZ+zDc9XzT06cRM5Zzk3c0SgpYUKYuG8r
	omxL1mDFM3L9vKLVnpP+NnDXYiGxM3QPpQnqx/1+ycGhCunD3K1oYyOLjlk9DmTY
	gJrmvlxPsUWVxPGRdLqwyB24Lw3R3K/aJ29mt8pZJ4MGYNf7jSEn/IfrRK+RZ+aT
	VOt+1NCGKzAomZrgWGM4heeTr92KyjNear1HEC9uR5iEdlSMTMcYtqVDxMskwY/f
	KYyCcpa+3OIjLCYMdGd0eOinGhnjqRZGCp9FE6tR5sSrZqjYAXjRkfZT4i9ReMj/
	rARJFQYkL8vhAJgYhhcmbc8K8zpcbGtIlL/Kq7FAcrl5iBcl+6T5tKKnX9MYIF0b
	34XJH1JyXbLEqLimbmMr8uxM98Wt6mTPC6qCZfuHyL1+i5k7tpXe4xJa3RuIHIZ9
	qMcPTJv9Mg8ZShcCydAZlN/ekW+5aZwsNyg3t4juZBzt0jlez7sY3qAnuEhT0BZp
	mDNvctKjPsT2bj3x1WE6i1al5pS2A2k=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 05 Jul 2026 20:35:24 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7E18960546;
	Sun,  5 Jul 2026 20:35:20 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 665HZ06j033003;
	Sun, 5 Jul 2026 20:35:02 +0300
Date: Sun, 5 Jul 2026 20:35:00 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org,
        Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
        Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
        Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>,
        stable@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: skip IPv6 extension headers in SCTP state
 lookup
In-Reply-To: <20260705123040.35755-1-zhaoyz24@mails.tsinghua.edu.cn>
Message-ID: <92783c87-7e6a-e90a-b2fc-e5d1332139e0@ssi.bg>
References: <20260705123040.35755-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sun, 5 Jul 2026, Yizhou Zhao wrote:

> set_sctp_state() reads the SCTP chunk header again in order to drive the
> IPVS SCTP state table.  For IPv6 it computes the offset with
> sizeof(struct ipv6hdr), while the surrounding IPVS code uses iph->len from
> ip_vs_fill_iph_skb(), where ipv6_find_hdr() has already skipped extension
> headers and found the real transport header.
> 
> This makes the state machine read from the wrong offset for IPv6 SCTP
> packets that carry extension headers.  For example, an INIT packet with an
> 8-byte destination options header can be scheduled correctly by
> sctp_conn_schedule(), but set_sctp_state() reads the first byte of the SCTP
> verification tag as a DATA chunk type.  The connection then moves from NONE
> to ESTABLISHED instead of INIT1, gets the longer established timeout, and
> updates the active/inactive destination counters incorrectly.  This happens
> even though the SCTP handshake has not completed.
> 
> Use ip_vs_fill_iph_skb() in set_sctp_state() and base the chunk-header
> offset on iph.len, matching sctp_conn_schedule() and the SCTP NAT handlers.
> For IPv4 and IPv6 packets without extension headers this preserves the
> existing offset.
> 
> Fixes: 2906f66a5682 ("ipvs: SCTP Trasport Loadbalancing Support")
> Cc: stable@vger.kernel.org
> Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
> Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
> Reported-by: Ao Wang <wangao@seu.edu.cn>
> Reported-by: Xuewei Feng <fengxw06@126.com>
> Reported-by: Qi Li <qli01@tsinghua.edu.cn>
> Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
> Assisted-by: Claude-Code:GLM-5.2
> Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
> ---
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 63c78a1f3918..6e0fc23be305 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -375,17 +375,15 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>  		int direction, const struct sk_buff *skb)
>  {
>  	struct sctp_chunkhdr _sctpch, *sch;
>  	unsigned char chunk_type;
> +	struct ip_vs_iphdr iph;
>  	int event, next_state;
> -	int ihl, cofs;
> +	int cofs;
>  
> -#ifdef CONFIG_IP_VS_IPV6
> -	ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
> -#else
> -	ihl = ip_hdrlen(skb);
> -#endif
> +	if (!ip_vs_fill_iph_skb(cp->af, skb, false, &iph))
> +		return;

	May be it is better starting from ip_vs_set_state()
to provide new arg 'int iph_len/offset' (set to iph.len), down to
state_transition(), sctp_state_transition() and set_sctp_state().
Same for all protos. It should cost less stack and ipv6_find_hdr()
calls and what matters most, correct iph context in case we
have IP+ICMP+TCP (with just two ports or even with TCP flags)
and are scheduling ICMP, i.e. not IP+TCP as usually.

	But what I see is that ip_vs_in_icmp*() are missing
the ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd) call just
after ip_vs_in_stats() and before ip_vs_icmp_xmit() where
we should provide ciph.len. That is why we don't reach the
set_tcp_state() calls to set correct cp->state and timeout
when scheduling related ICMP. So, this should be fixed too.

> -	cofs = ihl + sizeof(struct sctphdr);
> +	cofs = iph.len + sizeof(struct sctphdr);
>  	sch = skb_header_pointer(skb, cofs, sizeof(_sctpch), &_sctpch);
>  	if (sch == NULL)
>  		return;
> -- 
> 2.47.3

Regards

--
Julian Anastasov <ja@ssi.bg>

