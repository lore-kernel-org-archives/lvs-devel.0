Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8CD63E121A;
	Fri, 18 Sep 2026 04:23:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789705413; cv=none; b=AgIWMNS4z2eevvOoukPUXmJkoCceurWLMxuj9I7uHPtfcQbHBxl31EUvkXV/h4A8q4gwQW8fsOQ1sKjn8d8Chr363XuFSUn4wTtGKvfyugntsngNwyViFRWKxcZrvk4LnEsSGD3YS12WpHPLaNrnMyewdLueu5dKvbXXbODwwS8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789705413; c=relaxed/simple;
	bh=aSxHls9MVS/3a8uUTqPvhM097o5vx3URirRZ1iXqrKw=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=sRoyDLJi+N5qdlYtJ61y/16d2OsB5b2E/Ltz2nkyjC2gcCCvvHV3ImgauBVANPmEcrIbgQfRSU89LA6b+cyWIdopsu/MUkomWgFpER8a7FhWcX9UBuWWNX4mtCUGO3x4sAJxnCe9gu9b+TKyEQm8fQ4UD6zOzbVoWdfi0Nu2TPk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=SsTNIrNi; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="SsTNIrNi"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2484C2140B;
	Fri, 18 Sep 2026 07:23:23 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=qedc1u0QUZrEMWhoVHMW+yLn35P+IkxFSgJe8J1aXsI=; b=SsTNIrNiTLYZ
	TMird5LCIsdZDEoEAJV/Cyr8RZ3zmINADe3oS8MzCRm9tsWDLc4MTIN7PAdLFHNV
	Ok5O/J0/JDwTdTjHhSszGSouB9+RTS2CQNieJuUNPvJVomqxoWa6qEak7Tt3RFgd
	xQpJ+Uzhii7Yf+r/qMgTruoq9m0PHwSUT+lXUsIvJJ5pMEO+1DbM9MGae5NGeNqv
	IYpTKlhWAo3hVV5CH2K3wAhXHN0GrhB0Twf8tUY3TB+Fv5VKLO0fOny3LkbR73mg
	Z5YBdEl7E0T54P8XXnyo8cQ6OGu4kJRcKSF3/zBIpFam2+Hq3Auf//rKmsinBosa
	An7pPiCJaQfzNlUaEScQmEfN334VsFPo+tex3POKFCs31AoS/p2MXgIAQVt66uf6
	+2LUQhizD8Ixrq9etSJq74wq5F0Qhthf5tOSxpXX8E2K8j5JBjWSEyNW3K+rfX8b
	8QcZEOtWZ4aahaeBE5Sb0VVv2cwN+LuJkl5qJEfQo1KAQqLFFqJzUMPPEvvfH7h3
	82sV+LvrT5POSJWnOGhAlfrqw79yM4DsyvISvji2vkCEIFs0T0rndYKK8YMn5+Eb
	Sx++/JqGoOJhOf8z5E/E4t4CLWoDoQpPlRNwAciLY3r9v1CC/2IbhbO5qnipa1Ah
	P1pH4Fv6+c8iJRH8J1xxuYC1LqvGyBU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 18 Sep 2026 07:23:22 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id CB65F60F27;
	Fri, 18 Sep 2026 07:23:24 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68I4NJRb010045;
	Fri, 18 Sep 2026 07:23:22 +0300
Date: Fri, 18 Sep 2026 07:23:19 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: filter some flags received in the backup
 server
In-Reply-To: <20260911183429.71212-1-ja@ssi.bg>
Message-ID: <d4fa398d-f238-68f7-7c66-79a6e2918ed7@ssi.bg>
References: <20260911183429.71212-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 11 Sep 2026, Julian Anastasov wrote:

> While the IPVS SYNC protocol is not secure by design
> we can still protect the backup server from messages that
> can wreak havoc.
> 
> This commit addresses problems from received connection flags
> or their combinations. We now drop messages as follows:
> 
> 1. the NO_CPORT+TEMPLATE combination allows lookups for normal
> connections to hit template which can break in many ways
> 
> 2. ONE_PACKET: it is not sent by master, so we do not
> expect it in backup. Before now it was ignored by
> IP_VS_CONN_F_BACKUP_MASK for protocol v1 while protocol
> v0 created connections that are not hashed and dropped
> immediately. Better to apply the IP_VS_CONN_F_BACKUP_MASK
> also to the flags from v0 messages for consistency with v1.
> 
> Fixes: 87375ab47cd0 ("[IPVS]: ip_vs_ftp breaks connections using persistence")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Ignore this, will send v2 with better commit
message.

pw-bot: changes-requested

> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 33 ++++++++++++++++++++++++++++++---
>  1 file changed, 30 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index dfa8487ec0c2..1a30817fbbaf 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -954,6 +954,21 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
>  	ip_vs_conn_put(cp);
>  }
>  
> +/* Check for incompatible flags */
> +static bool ip_vs_sync_validate_flags(u32 flags)
> +{
> +	/* We do not expect NO_CPORT, especially to allow lookups
> +	 * to hit templates
> +	 */
> +	if (flags & IP_VS_CONN_F_NO_CPORT) {
> +		if (flags & IP_VS_CONN_F_TEMPLATE)
> +			return false;
> +	}
> +	if (flags & IP_VS_CONN_F_ONE_PACKET)
> +		return false;
> +	return true;
> +}
> +
>  /*
>   *  Process received multicast message for Version 0
>   */
> @@ -977,8 +992,7 @@ static void ip_vs_process_message_v0(struct netns_ipvs *ipvs, const char *buffer
>  			return;
>  		}
>  		s = (struct ip_vs_sync_conn_v0 *) p;
> -		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
> -		flags &= ~IP_VS_CONN_F_HASHED;
> +		flags = ntohs(s->flags);
>  		if (flags & IP_VS_CONN_F_SEQ_MASK) {
>  			opt = (struct ip_vs_sync_conn_options *)&s[1];
>  			p += FULL_CONN_SIZE;
> @@ -991,6 +1005,13 @@ static void ip_vs_process_message_v0(struct netns_ipvs *ipvs, const char *buffer
>  			p += SIMPLE_CONN_SIZE;
>  		}
>  
> +		if (!ip_vs_sync_validate_flags(flags)) {
> +			IP_VS_DBG(2, "BACKUP v0, Invalid flags 0x%X\n", flags);
> +			continue;
> +		}
> +		flags &= IP_VS_CONN_F_BACKUP_MASK;
> +		flags |= IP_VS_CONN_F_SYNC;
> +
>  		state = ntohs(s->state);
>  		if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
>  			pp = ip_vs_proto_get(s->protocol);
> @@ -1146,7 +1167,13 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
>  	}
>  
>  	/* Get flags and Mask off unsupported */
> -	flags  = ntohl(s->v4.flags) & IP_VS_CONN_F_BACKUP_MASK;
> +	flags = ntohl(s->v4.flags);
> +	if (!ip_vs_sync_validate_flags(flags)) {
> +		IP_VS_DBG(3, "BACKUP, Invalid flags 0x%X\n", flags);
> +		retc = 25;
> +		goto out;
> +	}
> +	flags &= IP_VS_CONN_F_BACKUP_MASK;
>  	flags |= IP_VS_CONN_F_SYNC;
>  	state = ntohs(s->v4.state);
>  
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

