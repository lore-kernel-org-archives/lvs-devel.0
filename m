Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794464990;
	b=VfaTbeUKkolhDG8rKIoZ9WTXADNVYzELVnPXUoz3ZA209cAlmYHGwEzdjB8v9WHuhX62
	 YDo3ERE3j7jGmq8e2xsHv89iqGE7oorDoN3RzG7nCNJBDTIJrbFt00A4h8OP1BQfRWPMU
	 uxrry0kpWTDxRSoNfCc7QmuzPtTeH9eUCHSKt7xwdZ+C4Q80nGsRTrJOHg3A9uunix1Bs
	 6Jfab4UvwZxB/JiUOZwgUuzHO1xDLkNJEUbPAp+Blxl9aIrSwRXfEM4ILDKk9uSPgZOY+
	 nRgv8GJ5xtRqnjqS04Q7srOO6zsiPB9o2IqCN3ThGjWVvU21PTlD4UJBY6+q3GXHjZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794464990;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=8qZZQEkUIFj2Xhzq+RsWdX9rHuudFHEuh0AfEJPY9HA=;
	b=ppfNPok1LnYd1bYc/VR+K7oJ2MAQqfJBLQDENb5PljfET2fXHlED0ClS43GRQ6JoZliu
	 D8A1pdY8Qy+2SG1Nef6vrvym3LuhgfHs54pkDSmY5tnoGPlJ5RhSb0Sn9IRw0itoUoE50
	 0x5YpvmX8abKT5demmVo99KOjSYBh2kKqkEbWf/d9qWHDcE4OXbjQ7+qOEA67tYMNsSKP
	 fb7yYlL4Jn6FTFXjZAePdM8Fos5fs6kS9QwwMcbOekrhtnO5NZXuMzR9Q7OCXQRGl9m1f
	 Ud93oGo4GndAwyi6idyiKwW6jEWxgcSk0O6aKtwCQMhWWCBUyTTQfZwRQPUWMROQcsg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=wlIdZP6z;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D7E7606A31C;
	Thu, 12 Nov 2026 06:29:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1D7E7606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=wlIdZP6z
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0DC5822390;
	Thu, 12 Nov 2026 08:29:46 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=8qZZQEkUIFj2Xhzq+RsWdX9rHuudFHEuh0AfEJPY9HA=; b=wlIdZP6zXUVc
	k5TeJ60Rup7ks8qeWnxWDXMwBC/nCxhy/Gjv9AGvYkDc9kRopHDJrGiLNrpehDM6
	fcxuLx9pXy7VwB+VWYXRbkauvRN0kGcuseMiw34rXAjg+38jAWrWFpK3HVDuf1nd
	wP1YHCFZ4ML+S1JleW5PY5QD+MPfYWNxvVFHB1t5KR6bhcUDtKxM/1AQLO3Gwc22
	r6Hcm8rmtORZAvzUUwX5a0WKd7GbVca4433qwMxz3aO9cDKjUBRmkSLQIS9c3lKD
	pljpRSfJPrv8M+9cdvu+jQGYqpDhF75vIJBXcTAhtTj39eVlkpIpm1iFJwXYTYeC
	L4K+xgtj0Fd4DC1RWlr3TkAAayRWKrNvY0WNmR5WHj55YWbdWODscL0s2M0hl0Uj
	f1ewQryZ5typmhaW6Ao4XYgN3VILYKbktpGqmnZVc89yKw+UhL0/tdfzbu8Ofbg8
	a92Mwx1PNgPRhUmgPe0ycA9NWoZIHZcgHbdJNQaG57ewwcFlKx6Sp2SS3zI0oarp
	tfTKV2oYMYB7jOOTZsw62GbWO0oARkve0a+6AlDOE/i2aY7X8iIdjTKf8uInKWXT
	kfPvcROx2QcclrzvsBzIIwWBgHRgqXQ+vG+IDivOiGKr6ytHYKD3q5S6RGuJfPsS
	e9kxwfJHdISi61AnpkgyVrQ9U5lT8Fc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 12 Nov 2026 08:29:45 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9819060B9F;
	Thu, 12 Nov 2026 08:29:45 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AC6TgmZ015260;
	Thu, 12 Nov 2026 08:29:44 +0200
Date: Thu, 12 Nov 2026 08:29:42 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v3] ipvs: do not create conns from packets with port
 0
In-Reply-To: <20261105231534.5542-1-ja@ssi.bg>
Message-ID: <3fd9a77f-9b9c-0b1f-86ea-de50a91c18ce@ssi.bg>
References: <20261105231534.5542-1-ja@ssi.bg>
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

On Fri, 6 Nov 2026, Julian Anastasov wrote:

> We should disallow normal connections with cport 0 to be
> created from packets by the scheduler (from clients) or
> by ip_vs_new_conn_out (from real servers) because later
> such traffic can not hit the connection due to the
> NO_CPORT requirement. As result, it can lead to duplicate
> connection for every packet. Do the same for vport 0.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Link: https://sashiko.dev/#/patchset/20261104201530.147292-1-ja%40ssi.bg
> Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261103140308.591690-3-pablo%40netfilter.org
> Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	As v1 is already applied I will send a followup patch,
so this v3 should be dropped.

pw-bot: changes-requested

> ---
>  Changes in v3:
>  * Check the ports and drop port 0 only for traffic handled by IPVS
> 
>  Changes in v2:
>  * Drop the packets with port 0 instead of passing them to the local
>    server
> 
>  net/netfilter/ipvs/ip_vs_core.c       | 3 ++-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 7 +++++++
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  | 7 +++++++
>  net/netfilter/ipvs/ip_vs_proto_udp.c  | 6 ++++++
>  4 files changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index fd503f0efb57..0ed5f6c95ad8 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1305,6 +1305,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
>   *    In fwmark-VS actual vaddr and vport are unknown to IPVS
>   * 2) Real Server and Virtual Service were NOT configured without port:
>   *    This is to allow match of different VS to the same RS ip-addr
> + * 3) Client port is not 0
>   */
>  struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
>  				      struct ip_vs_dest *dest,
> @@ -1328,7 +1329,7 @@ struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
>  	/* check pre-requisites are satisfied */
>  	if (svc->fwmark)
>  		return NULL;
> -	if (!vport || !dport)
> +	if (!vport || !dport || !cport)
>  		return NULL;
>  
>  	/* for persistent service first create connection template */
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index fb8af6b15a39..cb34bcceb4f6 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -30,6 +30,7 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  			sch = skb_header_pointer(skb, iph->len + sizeof(_sctph),
>  						 sizeof(_schunkh), &_schunkh);
>  			if (sch) {
> +				/* Accept packet without scheduling? */
>  				if (sch->type == SCTP_CID_ABORT ||
>  				    !(sysctl_sloppy_sctp(ipvs) ||
>  				      sch->type == SCTP_CID_INIT))
> @@ -56,6 +57,12 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  	if (svc) {
>  		int ignored;
>  
> +		/* Do not create connection for port 0 */
> +		if (!ports[0] || !ports[1]) {
> +			*verdict = NF_DROP;
> +			return 0;
> +		}
> +
>  		if (ip_vs_todrop(ipvs)) {
>  			/*
>  			 * It seems that we are very loaded.
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index fec0e8b47b71..25d4576d0e12 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -48,6 +48,7 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  	if (likely(!ip_vs_iph_icmp(iph))) {
>  		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
>  		if (th) {
> +			/* Accept packet without scheduling? */
>  			if (th->rst || !(sysctl_sloppy_tcp(ipvs) || th->syn))
>  				return 1;
>  			ports = &th->source;
> @@ -74,6 +75,12 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  	if (svc) {
>  		int ignored;
>  
> +		/* Do not create connection for port 0 */
> +		if (!ports[0] || !ports[1]) {
> +			*verdict = NF_DROP;
> +			return 0;
> +		}
> +
>  		if (ip_vs_todrop(ipvs)) {
>  			/*
>  			 * It seems that we are very loaded.
> diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
> index f32785682402..ab3ab9524168 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_udp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
> @@ -62,6 +62,12 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  	if (svc) {
>  		int ignored;
>  
> +		/* Do not create connection for port 0 */
> +		if (!ports[0] || !ports[1]) {
> +			*verdict = NF_DROP;
> +			return 0;
> +		}
> +
>  		if (ip_vs_todrop(ipvs)) {
>  			/*
>  			 * It seems that we are very loaded.
> -- 
> 2.56.0

Regards

--
Julian Anastasov <ja@ssi.bg>

