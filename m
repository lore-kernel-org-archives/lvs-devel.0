Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793854777;
	b=LBUcgj2X/kxzrHHg5q7FgYK8hnJuXX0PKZIi7PsWE1i+JjJ3cMYVdvMKo6cgQgoW8Do7
	 kw9gGNVygRog+UzVvaPWgtYZq7aeTaJWuapaSsFLcAeSrm3J3bPDRV5qCqmlUa04y5ZiE
	 nr0O1S7jIGHxOseDKZw6qgiV5OVeJJ9XWLyVo+CA/AWrCSQlLOr7/mHuHh9FFCiPSeyna
	 TVRiOWkEmijw4hWRajUHxV/LNewdZj2NO6VMnVOf6fTEILj+EZA7RKyx0qVzTggEaIPNr
	 PDlblq7ViGtPGyiCF3juP83uxeHL098X07bpXxs4bzyNppn17wDZcYpJxs2+RurGBhg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793854777;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=sRVhAEacJUXzOD7Z9t9X7l05UEG0bagzaqInGlzUg/E=;
	b=PTvzfMZcTbuT+Pq7sn1n0xfvtK2uwq0/BNaw2JryZu9V16wE1wjJdFVQeEAWe1YOPb8Q
	 BJeWKGQyMBkT5tHsmt4lKIU2SMYjq+YNX9mycqRU1rKIinbP4+KOPIGVPov6nKg08imxo
	 l/VotrxtXxsq9vffZu6ymZzxmplW8cb8LOLMe0/ERyBAWfug3ff0+IwmPtdueBMO7EV1X
	 E5oln6ZsxYXP/rzEKnmC2zPSKX7VVGyQ4q1ZCNSllvuRpaKxoK3ro3mgDvDptBup8EQsR
	 VPRBsF/fiu7ziObJ8DGthqPDfRlO7/MPrsvm0GwfND8V0+iV1cRZTvqFsJ9jBmUPk2g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=vT2TwnZX;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 054B4606A31B;
	Thu,  5 Nov 2026 04:59:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 054B4606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=vT2TwnZX
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E877A21DB9;
	Thu, 05 Nov 2026 06:59:31 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=sRVhAEacJUXzOD7Z9t9X7l05UEG0bagzaqInGlzUg/E=; b=vT2TwnZXEndm
	kcFdbC0mXc2Je/e1MuyrSbc06OLP//PwAeurZmlJ/UMvNlBjJAT9vcxW0QMo4ObV
	dgeOmnFZBDWFYyPb8KC6VtxWA3I635JYwgJLssm2m+eIMCsD66BIrM2aEp8VbdG1
	LD4yraIOWq8g32sB8f1DiNYpZDn0JaU2ROUZx9ikFQhXSTDidx3LJ5ffewvUT4Xh
	YVONWAqNwIg2JVbexY8Wc7uKtN7GEDc+mULulHkGoXshmo8weyNhL2/EftTo/f/J
	dOKoRVOt3tvoyalyta9BgLiEttZYPm+Zt1cyt3VEQ6QVRm+LlZo2gMg/vCVnH18J
	zbgM3sndAHRLLdmYhIiaqEj3xw8LuoFcSWDKlCAwQCrqf+G98WgjyrHH0yYTzBKh
	vxbiPvrh0WlWXiSDdkqZzgtixoWBjRIH1QdmaXpEH5Nb7zIdyilJBdSu7yHdiJTZ
	TgrCI8ZnSmr+4kHItc0cvmVK+p9UPVHIzCOV1PLnxwq8cXJVkvqosPSTiPCNsw14
	fD7dC4TLH+Qs7nAfvtljVgVKDjHfYsPGpXi2sHlTaqftP30WwiaMfHnoOYP1Hlmu
	AHt2LRgs6RVfB14chyr8ORQdmZdYHJYjYfEF5PURLRq6Ptb92zmlUDM63LROAOG9
	dM8rEmXyi+nSEcT0mjSQ7EGq1nuT0No=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 05 Nov 2026 06:59:31 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7F36961C68;
	Thu,  5 Nov 2026 06:59:31 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A54xTS2007322;
	Thu, 5 Nov 2026 06:59:29 +0200
Date: Thu, 5 Nov 2026 06:59:29 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v2] ipvs: do not create conns from packets with port
 0
In-Reply-To: <20261104201530.147292-1-ja@ssi.bg>
Message-ID: <5e3fc9f1-1786-bfb3-4da6-d313ba9f6125@ssi.bg>
References: <20261104201530.147292-1-ja@ssi.bg>
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

On Wed, 4 Nov 2026, Julian Anastasov wrote:

> We should disallow normal connections with cport 0 to be
> created from packets by the scheduler (from clients) or
> by ip_vs_new_conn_out (from real servers) because later
> such traffic can not hit the connection due to the
> NO_CPORT requirement. As result, it can lead to duplicate
> connection for every packet. Do the same for vport 0.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261103140308.591690-3-pablo%40netfilter.org
> Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  Changes in v2:
>  * Drop the packets with port 0 instead of passing them to the local
>    server

	It was ok to ignore packets before service lookup but
if we are dropping them it should be only for IPVS traffic,
i.e. after service lookup. Dropping this v2 and preparing v3.

https://sashiko.dev/#/patchset/20261104201530.147292-1-ja%40ssi.bg

pw-bot: changes-requested

>  net/netfilter/ipvs/ip_vs_core.c       | 3 ++-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 4 +++-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  | 4 +++-
>  net/netfilter/ipvs/ip_vs_proto_udp.c  | 3 ++-
>  4 files changed, 10 insertions(+), 4 deletions(-)
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
> index fb8af6b15a39..31431094073d 100644
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
> @@ -42,7 +43,8 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  			skb, iph->len, sizeof(_ports), &_ports);
>  	}
>  
> -	if (!ports) {
> +	/* Do not create connection for port 0 */
> +	if (!ports || !ports[0] || !ports[1]) {
>  		*verdict = NF_DROP;
>  		return 0;
>  	}
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index fec0e8b47b71..6f1cc9165e0c 100644
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
> @@ -57,7 +58,8 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  			skb, iph->len, sizeof(_ports), &_ports);
>  	}
>  
> -	if (!ports) {
> +	/* Do not create connection for port 0 */
> +	if (!ports || !ports[0] || !ports[1]) {
>  		*verdict = NF_DROP;
>  		return 0;
>  	}
> diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
> index f32785682402..0e7b4427d258 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_udp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
> @@ -47,7 +47,8 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  			skb, iph->len, sizeof(_ports), &_ports);
>  	}
>  
> -	if (!ports) {
> +	/* Do not create connection for port 0 */
> +	if (!ports || !ports[0] || !ports[1]) {
>  		*verdict = NF_DROP;
>  		return 0;
>  	}
> -- 
> 2.56.0

Regards

--
Julian Anastasov <ja@ssi.bg>

