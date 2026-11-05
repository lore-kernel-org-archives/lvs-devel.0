Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=217.70.190.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793883049;
	b=xOW7QNfSXNDncZBRhkTCTjsriZxj5j/a/nzvgoUfoWyQnfGaesDByja8tb9hx1IB42Vo
	 Ir9D4Efkkq4mH2ZyzTbnaRMz6bVTPh6oN+Fotjv619hddlHe0ogAFm9VTivQmSUzvHx6P
	 SWu11jmD+KYNsqAZnO/yQDzxaKczJgbBEeM2VU6/qwDrNAqeJG9zwX/SbXWhjsn432c78
	 4phmWGDDfOfhORGib8DUglJRvyV5jhqoJKweB3udyUTjne5/NahwYXTPy0fg+i8IzFvdu
	 vUDqkRYTczwInKGMP3vVsZCbWFbiC00OGxsqRyInC2JPWd4b1lDCKR7Gkg6sDcsfnTA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793883049;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Status:X-Spam-Checker-Version;
	bh=v0EKemWaVul/SJRIFOgKfeiqTYp2UXkQr3SJZOcMb7c=;
	b=iXWU8KYVIvmZUoQmWJbTYXB+4s1HowsiB4ODX/6srW5LhYqLGzTe6RyZeS9mBMknB5l6
	 BN9SvqscZfXCkOEsyNRWGWDvG2Md1JXJ54ixTKDId//LxZfAb83Ja8H0mtRr8bHvoeuCO
	 Sx5XJv78GPXq8JbW2W2ijNVYo6LC12OXCyQGy5bXSPD+KtWsZH1eT2fAXJULUWUFoC6QL
	 dniU6HGeC1R+MOM84xVrQB2ly1fpy5g90mU4f11Y/0OhEIbwPOUVuDDM0eiQK/7J2tBeN
	 Wf7XqGkX0J4yimQO/J7Ayk4U1ztjsVVV8aUxSd1Zh1JfwGslUWup+wQjKvwficTtyXg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=netfilter.org;
	spf=pass smtp.mailfrom=netfilter.org;
	dkim=pass header.d=netfilter.org header.i=@netfilter.org header.a=rsa-sha256 header.s=2025 header.b="g8/YAWDY";
	arc=none smtp.remote-ip=217.70.190.124
Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 3A455606D818;
	Thu,  5 Nov 2026 12:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3A455606D818
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=netfilter.org header.i=@netfilter.org header.a=rsa-sha256 header.s=2025 header.b=g8/YAWDY
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1793883046;
	bh=v0EKemWaVul/SJRIFOgKfeiqTYp2UXkQr3SJZOcMb7c=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=g8/YAWDY+Mwci/BUsDnUqYvyk0NGOqTcA6I6DqHT0K2Z0Z/EgPx4YBjpWup0dhQCJ
	 vQCG1LpKx7dwnxipjjZ39E3GDRigfK+gz32MR1jJzrAUTQqaXotCufEP+5eJo3obJt
	 yD/MDjqgdYJg8uZbeSEbezWHu+FlK1UrQ/Kwx1Ta6oLfcOGZ7Qhu+de4esCXZw95lR
	 s2yF99K0PCQ20J0S4olWRQF7HO6zgb0hMO0cqI6le6ptnl/KiXp9hfG1lDJNJN+wRu
	 7NlJKcpdan4e1HVw0soNAxIUgPVwhCZv4KB2RTiOUorWlESqebzL9HkMVpxeXKn2Kg
	 EsDXOS7SprsWg==
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id BFBAD60457;
	Thu,  5 Nov 2026 13:50:46 +0100 (CET)
Date: Thu, 5 Nov 2026 13:50:44 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Florian Westphal <fw@strlen.de>,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v2] ipvs: do not create conns from packets with port 0
Message-ID: <aux7pEgj-lz9eq4c@chamomile>
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
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261104201530.147292-1-ja@ssi.bg>

On Wed, Nov 04, 2026 at 10:15:30PM +0200, Julian Anastasov wrote:
> We should disallow normal connections with cport 0 to be
> created from packets by the scheduler (from clients) or
> by ip_vs_new_conn_out (from real servers) because later
> such traffic can not hit the connection due to the
> NO_CPORT requirement. As result, it can lead to duplicate
> connection for every packet. Do the same for vport 0.

I think a follow up is a better option for patches that are not
clearly wrong, because I prefer to drop patches that need more work,
otherwise we risk entering a loop of N iterations in a PR.

I think safest approach is to drop anything that is controversial.

Just for the next time, if it helps, if patch is good but not perfect
(as it seems to be to me in this case), a follow up is better IMO.

So let's find a slot for this patch in the next PR chance, I think it
is better to skip this new v2 at this stage.

Apologies and thanks.

> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261103140308.591690-3-pablo%40netfilter.org
> Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  Changes in v2:
>  * Drop the packets with port 0 instead of passing them to the local
>    server
> 
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
> 
> 
> 
