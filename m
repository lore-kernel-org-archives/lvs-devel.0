Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821614;
	b=1129wkc8Qlt5L6vdtuaLKZfgusp7R91hsUsQUtynE/TBUulWDjGxOcQ8tyVffm16ntOC
	 f4btaoSApYYAzjT3RjewZGVuDtPHRspvB7G0X8IX26kKuy62PAnI0iKNgGcIXS2QpcaBl
	 50tAb0ocr/Pg34Uj4FOjGefJld1qZlOTT8v8H28JIZYzYlIooKHj/8U0z1AL+XU8t3g2o
	 rx70djLqGsJQpBv0qyi7ltgJ8hSYXkYG4x11u+gHGQs2TnCNy1RcgDYRK1JHctSYqaUHR
	 oeS8N3gNm0LSVc5T030xAlt58LPegITzDZFKSVowkdjbVggepLa6hNxcqZzBYfPUu6g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821614;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=T9zmPINoXhTtPoNWi8WXSCFP2UdwDfmdo8eVYok8V3w=;
	b=CqF6e5N7D6O/NigagwxNIVxh0Ifkgxph+bwmEB3YenyhXMfE39HWWuEgkHKKx8b/yK8V
	 KuJANEI+1JmlK38eYNRZjMFsrA6YyUe5/T6NjRPMVZVHgYrlRbNBD7Jutc0XeuOGQQ3ei
	 79j4u901gHYgDRsNLqUzkx6yPvSOjDiGP1BptSPCyvO2ncPwVF/0DQ5SAhVXbJRvt6vVa
	 i5M1hTUIluqYK/2TrqjIp2zKwIZiCco5n0Rms8OvrS1AqaGntlzSZ5yOrDlS5f8vE4Fk6
	 4jjk2bPHQqQGPto7tvIwb1twi68V0jqheLEOVZ4vkz9im1Xl8It1JrkarPe0W9kflQw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Op5Yty+e;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9D40608C9A1;
	Wed,  4 Nov 2026 19:46:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D9D40608C9A1
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Op5Yty+e
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 27FFE213F4;
	Wed, 04 Nov 2026 21:46:51 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=T9zmPINoXhTtPoNWi8WXSCFP2UdwDfmdo8eVYok8V3w=; b=Op5Yty+ergpt
	eF7P1scnzmeSjKbwPhgmkShYXZp4VzK+dD34yVs8921Tac/Ss3xlrFL3RmmsoYjy
	MckGq1ZNAGoQthbrQDx/oh/P5+xxWMek5VC142REzsbkPGmotUpBDuizRolaHH/u
	9eWSp9izt1acLt0sonW7cNX/bkCPvnfO5SYmIdySIgbFO3o/ABffVd4usCoBhn+T
	+Wr43zL9rr6Cc1LSRiVgCywvv/58kg+t4XulaFkXnh3Bp4fIjH9+btIDWdy8ns3j
	VckrO+oWSxV4PlHRTIvIdokiI9xl0GvTuVQbuP6zI5mj0WrpQDY9CtDYMzjiRzpn
	e+RFvQ6Xt9OJ92aMVjluLM8l3YZEYK1jSlt0YtFkvv9nTZ/zcSRFQlYms81//KNB
	G/n4gKaZiUffNVTid9m5AusXYz44tB9F2n2JRVZCEmrN8JgyVlS9+kxfSJXHvNRF
	YWnDwW5zlrbFBbeTQ5BMdizsByn6DVmBDuUWsscD1q+JlIa7O6kxLSYZhzemY3Hr
	v0HtJqTysuYEc8kOdQ2mc3UWnd+tfvgiCDftlQ3g4tOZAb8sC+de1XaC7d5RcsCT
	d2IWUU+pOo0miBSSharwLw82QrXH8/VD60FS8c2NH7142EYIjmyAMJaK97d0uVMa
	jzccWEuxLk5v76dUyyhC0mjhRRdGPEc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 04 Nov 2026 21:46:51 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id DA91661CDA;
	Wed,  4 Nov 2026 21:46:49 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A4JkkEO143152;
	Wed, 4 Nov 2026 21:46:48 +0200
Date: Wed, 4 Nov 2026 21:46:46 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Axel Mierczuk <axel.mierczuk@1password.com>
Subject: Re: [PATCH nf] ipvs: do not create conns from packets with port 0
In-Reply-To: <20261003095001.20587-1-ja@ssi.bg>
Message-ID: <95b23fea-9e6c-158d-c989-6f5674e343ee@ssi.bg>
References: <20261003095001.20587-1-ja@ssi.bg>
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

On Sat, 3 Oct 2026, Julian Anastasov wrote:

> We should disallow normal connections with cport 0 to be
> created from packets by the scheduler (from clients) or
> by ip_vs_new_conn_out (from real servers) because later
> such traffic can not hit the connection due to the
> NO_CPORT requirement. As result, it can lead to duplicate
> connection for every packet. Do the same for vport 0.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Will send new version that drops the packets with port 0, 
otherwise the connections can succeed with the local server.

pw-bot: changes-requested

> ---
>  net/netfilter/ipvs/ip_vs_core.c       | 3 ++-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 5 +++++
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  | 5 +++++
>  net/netfilter/ipvs/ip_vs_proto_udp.c  | 4 ++++
>  4 files changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 397d5392ebed..8cdcab7d6edf 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1306,6 +1306,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
>   *    In fwmark-VS actual vaddr and vport are unknown to IPVS
>   * 2) Real Server and Virtual Service were NOT configured without port:
>   *    This is to allow match of different VS to the same RS ip-addr
> + * 3) Client port is not 0
>   */
>  struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
>  				      struct ip_vs_dest *dest,
> @@ -1329,7 +1330,7 @@ struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
>  	/* check pre-requisites are satisfied */
>  	if (svc->fwmark)
>  		return NULL;
> -	if (!vport || !dport)
> +	if (!vport || !dport || !cport)
>  		return NULL;
>  
>  	/* for persistent service first create connection template */
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index fb8af6b15a39..83d1443ebe01 100644
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
> @@ -47,6 +48,10 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  		return 0;
>  	}
>  
> +	/* Do not create connection for port 0, skip the packet */
> +	if (!ports[0] || !ports[1])
> +		return 1;
> +
>  	if (likely(!ip_vs_iph_inverse(iph)))
>  		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
>  					 &iph->daddr, ports[1]);
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index fec0e8b47b71..2e55b62445c6 100644
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
> @@ -62,6 +63,10 @@ tcp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  		return 0;
>  	}
>  
> +	/* Do not create connection for port 0, skip the packet */
> +	if (!ports[0] || !ports[1])
> +		return 1;
> +
>  	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
>  
>  	if (likely(!ip_vs_iph_inverse(iph)))
> diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
> index f32785682402..92c0b76c1a02 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_udp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
> @@ -52,6 +52,10 @@ udp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
>  		return 0;
>  	}
>  
> +	/* Do not create connection for port 0, skip the packet */
> +	if (!ports[0] || !ports[1])
> +		return 1;
> +
>  	if (likely(!ip_vs_iph_inverse(iph)))
>  		svc = ip_vs_service_find(ipvs, af, skb->mark, iph->protocol,
>  					 &iph->daddr, ports[1]);
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

