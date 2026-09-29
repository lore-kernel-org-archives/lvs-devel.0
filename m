Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3ECC3D3481;
	Tue, 29 Sep 2026 04:24:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790655856; cv=none; b=Q2iA2nsFPfrjH2jQ5izOCBQkgiFJUX7qnqMsdv8jmv++MfJKWOZaurk9SeqfosTxqRijhMZf7Sp+U2jB2pvGJDuqzABihoFfwjWQG2p54nMjsxEKYIYhUlUINLXkY8KPLr78J1wJHNQqXLmwsQHOzLCOfEdfSBjwDcpZtE+GTKc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790655856; c=relaxed/simple;
	bh=RtoJOfpOaYtHKo31eOIIdw1tUTEjlYEDi65y3iE6eXw=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=vFKSxzXCDjFhCkLOE84dcoyN2y9SJe2auoVmyk1DHJ47kwOOrRJkyamaa9RYsIupPgH3KEPWfhDppID7UkEydvGk9WwGAI6hEgrgM/rVwCnJS8S5hqSM0xild0u4Aqhq8NoKHwcCvxZiQECgaIQrwIGKHjxbBahNEt7vrNRg6mM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=oiU7QkyK; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="oiU7QkyK"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A6BC820F96;
	Tue, 29 Sep 2026 07:24:08 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=v56CWubdgShrVU549Ej75pIwZsfaH71H43StsPqFeVY=; b=oiU7QkyK4PBW
	0/+4Znss+o2PfSn927QzYnwJI6Hq7M2DhJUDtL1+6VPyPz95VbJ9PrdoyfwWu3zi
	621CDJfHnwLwEYqDps6yhpzfJf2ZJ5B7Y22wj2oQBFvBY9lbD+//+ySIowl3H4AF
	zc9nZTZHvM75mHY0Jq8F+X3dFd1+Q90Vwk/+a7XhXocMAYCiBMmNwMFI0gf9Tl5U
	qWCH62MgNPx3HxVTJT5Unz0GcL2GhV8H/6gfiAccD0nOLN20ln/DlDSR3QonfgaX
	DMwFF+dkDz3ybgLaXA4C0NPt2cgPvL8NrLW7eijXnxtTBSPRfx5zBVbk581xiIAh
	g5oT542emVlW3zppc9pFdFa+gbDCoVJzRrV2mY4HRBOcraAvbUdWOEdVJ7PtEfcL
	U5hUXkZrwu4TYo9KLmbjoMptFQvhrzC7OGOM7oLManiWtZG6fvtjkx/6M4tDkVuZ
	J62SmiMEpHn9ktGQqPKcNGX1/W4QBb/MW0rvDhMaiZj9XJsFmVWJY8CDFo59TRfS
	Cp8qsMStXTb8feFWo7TSwdyF8TrU7CeSLdKuMkPOnc0iisqZ3NFV+9Rr5QYG08wt
	bTT+OVzscxd//1xdDhP+FAqpWRPzdhWK9UU+wP9ZP/J/HHxAjUgpSb8C3PPJKTYc
	AA7CnvxVj4mtiUMl8NK9zzhz0UptVaE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 29 Sep 2026 07:24:08 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id DBB8660A64;
	Tue, 29 Sep 2026 07:24:10 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68T4O6RJ009220;
	Tue, 29 Sep 2026 07:24:09 +0300
Date: Tue, 29 Sep 2026 07:24:06 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: fix buffer overflow when sending sync
 messages
In-Reply-To: <20260909155500.68273-1-ja@ssi.bg>
Message-ID: <01ad6f8a-b4e9-fbc9-c1b5-fe471e74681f@ssi.bg>
References: <20260909155500.68273-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 9 Sep 2026, Julian Anastasov wrote:

> Sashiko reports for possible heap buffer overflow when
> generating sync message for the v0 and v1 message formats.
> We should read the cp->flags only once because another
> CPU can concurrently set the SEQ_MASK between the two
> reads.
> 
> Note that IPVS does not set the SEQ_MASK anymore for the
> ip_vs_ftp.c helper starting from commit 7f1c40757951
> ("IPVS: make FTP work with full NAT support") (2.6.36+),
> so the problem should not be reproducible.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Link: https://sashiko.dev/#/patchset/20260903004149.1037028-1-pablo%40netfilter.org
> Link: https://sashiko.dev/#/patchset/20260909111338.44357-1-ja%40ssi.bg
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	If not late, this version can be dropped, I'll
post new version that reads flags and seqs together under
lock before sending it, as per the Sashiko review:

https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260927220816.268206-1-pablo%40netfilter.org

	In any case, this is a low priority fix.

pw-bot: changes-requested

> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 23 ++++++++++++++---------
>  1 file changed, 14 insertions(+), 9 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 5383aeafb0ae..dfa8487ec0c2 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -543,13 +543,15 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
>  	struct ip_vs_sync_conn_v0 *s;
>  	struct ip_vs_sync_buff *buff;
>  	struct ipvs_master_sync_state *ms;
> -	int id;
> +	u32 flags, seq_mask;
>  	unsigned int len;
> +	int id;
>  
>  	if (unlikely(cp->af != AF_INET))
>  		return;
> +	flags = READ_ONCE(cp->flags);
>  	/* Do not sync ONE PACKET */
> -	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
> +	if (flags & IP_VS_CONN_F_ONE_PACKET)
>  		return;
>  
>  	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
> @@ -564,8 +566,8 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
>  	id = select_master_thread_id(ipvs, cp);
>  	ms = &ipvs->ms[id];
>  	buff = ms->sync_buff;
> -	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
> -		SIMPLE_CONN_SIZE;
> +	seq_mask = flags & IP_VS_CONN_F_SEQ_MASK;
> +	len = seq_mask ? FULL_CONN_SIZE : SIMPLE_CONN_SIZE;
>  	if (buff) {
>  		m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
>  		/* Send buffer if it is for v1 */
> @@ -597,9 +599,9 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
>  	s->caddr = cp->caddr.ip;
>  	s->vaddr = cp->vaddr.ip;
>  	s->daddr = cp->daddr.ip;
> -	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
> +	s->flags = htons(flags & ~IP_VS_CONN_F_HASHED);
>  	s->state = htons(cp->state);
> -	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
> +	if (seq_mask) {
>  		struct ip_vs_sync_conn_options *opt =
>  			(struct ip_vs_sync_conn_options *)&s[1];
>  		memcpy(opt, &cp->sync_conn_opt, sizeof(*opt));
> @@ -635,6 +637,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  	int id;
>  	__u8 *p;
>  	unsigned int len, pe_name_len, pad;
> +	u32 flags, seq_mask;
>  
>  	/* Handle old version of the protocol */
>  	if (sysctl_sync_ver(ipvs) == 0) {
> @@ -647,6 +650,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  sloop:
>  	if (!ip_vs_sync_conn_needed(ipvs, cp, pkts))
>  		goto control;
> +	flags = READ_ONCE(cp->flags);
>  
>  	/* Sanity checks */
>  	pe_name_len = 0;
> @@ -674,7 +678,8 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  #endif
>  		len = sizeof(struct ip_vs_sync_v4);
>  
> -	if (cp->flags & IP_VS_CONN_F_SEQ_MASK)
> +	seq_mask = flags & IP_VS_CONN_F_SEQ_MASK;
> +	if (seq_mask)
>  		len += sizeof(struct ip_vs_sync_conn_options) + 2;
>  
>  	if (cp->pe_data_len)
> @@ -720,7 +725,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  	/* Set message type  & copy members */
>  	s->v4.type = (cp->af == AF_INET6 ? STYPE_F_INET6 : 0);
>  	s->v4.ver_size = htons(len & SVER_MASK);	/* Version 0 */
> -	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);
> +	s->v4.flags = htonl(flags & ~IP_VS_CONN_F_HASHED);
>  	s->v4.state = htons(cp->state);
>  	s->v4.protocol = cp->protocol;
>  	s->v4.cport = cp->cport;
> @@ -744,7 +749,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  		s->v4.vaddr = cp->vaddr.ip;
>  		s->v4.daddr = cp->daddr.ip;
>  	}
> -	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
> +	if (seq_mask) {
>  		*(p++) = IPVS_OPT_SEQ_DATA;
>  		*(p++) = sizeof(struct ip_vs_sync_conn_options);
>  		hton_seq(&cp->in_seq, (struct ip_vs_seq *)p);
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

