Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9C3B403150;
	Tue, 11 Aug 2026 17:10:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786468228; cv=none; b=dblzjTowNPmXzB8ANPZY1DQWvEX4uwzGmtwxpsYa3MSCCjX8bpgRiokiGOCUi2OPhCS7oHQIKBzJt1GDr0ThNKtGK224Sv0oLeQQCHJkdM48T7iIiTe7yAQYClbbQGCR9chjRSq9M55ZVfvmu8PJYaQWT2UQYE/jYLrNYAvNboc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786468228; c=relaxed/simple;
	bh=7+BOQrzfppgtrUlN0Rvl2PPzBO7F4k1K07Abi/KlxpA=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=lJACcJ+GUU8zWTv6gY33L+QuKj6rkIwYPmpWl3RHWK7qrS4FZ07o8k9S5mvcIozoKCdQn8YBiN9oRTPNr2GOGRuztT8y5yHS3nMoxZTTHG9puZ/xgS93tyEWyQHp0j4ejQoIoSHfY3nX2vr47vcC6cKWnnla7RNx9Wv6HDaswaw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=BANyS2XD; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="BANyS2XD"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A6E3C21CE3;
	Tue, 11 Aug 2026 20:10:12 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=l6OM/BOENyTOdiotG01fICGLAfmhUn24KFY+eHqixnY=; b=BANyS2XD+sq6
	x3rIOeBb4Jple8v7ia2JFuf9cXrwPUUW0vNPNlnYX9IiB+2LBfwWWMWhIesl+5TR
	Y7zrxQEXdLKpjaOzHYT8myBT5IDYEjzYCX7gPu3E6kJo+14FrWtx+PgZIRX1looX
	t9RNsugPH8FMDeGV+2vQ+ftXgzwu8vXdA3vqEbfSOUaixGAOaffWk5MGSMhLeQM4
	fK3LP2FRXm7CE9Ib15F+6FvMCdxlsVOn3guuvW3ftPLlo0BFfGlavqJD6UyfexIF
	ICUJ0yxHO0wjHmO24+/90m2QcmkbTi8NjeEoF46cnAJnrTFUYOkUtrXvgTQs4a7b
	boqk2pk4cHPf4L/fxMVE5PX9zZ7lRDTGCPiGQG5vmLCEukdCe6cUHES8KYTZduBe
	/32iBLEpJVpwh53iLWDb3ditGNBjR8lU63idr9N2bLno51APfg1DuRm+AHBkxqAT
	aREpcq9tr79LBXeD1CTNVb0vNQs1s7/rXYkFoqwHP0q0pJADjSq22P/BnKB6pglh
	3BWmtV5S47reBdgli7u1C/EfyHf5hwgvGViPJEhpW6klDm2UJ/6KqtIiwdhRVxR9
	1aGtNpynmVloFsvsRQyYoaV30aORmf3yYjLv2hXSQbIM5VR/8F8OAc07jvG0FRGh
	55WB0rgt/vhD8VuMqjZMRkNUhUoz+zU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 11 Aug 2026 20:10:12 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 34B0E60510;
	Tue, 11 Aug 2026 20:10:14 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 67BHA8iS079781;
	Tue, 11 Aug 2026 20:10:08 +0300
Date: Tue, 11 Aug 2026 20:10:08 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Kyle Zeng <kylebot@openai.com>
cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH] ipvs: reject invalid states in connection template sync
 records
In-Reply-To: <20260810221034.33751-1-kylebot@openai.com>
Message-ID: <475e1a29-960d-2a50-7dfd-52d89c535ad7@ssi.bg>
References: <20260810221034.33751-1-kylebot@openai.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 10 Aug 2026, Kyle Zeng wrote:

> IPVS sync receivers validate protocol states before creating or updating a
> connection. For connection templates, however, they only log states outside
> the template state range and still store the value in the connection.
> 
> A template can be returned by ordinary connection lookup. TCP and SCTP then
> use the invalid state as an index into their transition tables.

	I guess, this is possible again due to sync. I'll
provide fix for this problem.

> 
> Reject invalid template states in both sync protocol versions before
> looking up or modifying a connection. The version 1 path handles both
> IPv4 and IPv6 records.
> 
> Fixes: 275411430f89 ("ipvs: add assured state for conn templates")
> Cc: stable@vger.kernel.org
> Assisted-by: Codex:gpt-5.6-sol
> Signed-off-by: Kyle Zeng <kylebot@openai.com>

	Looks good to me for the nf tree, thanks! Next time use
"nf" or "nf-next" tags for IPVS patches.

Acked-by: Julian Anastasov <ja@ssi.bg>

> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 93038ab..6f0c2a4 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1002,10 +1002,10 @@ static void ip_vs_process_message_v0(struct netns_ipvs *ipvs, const char *buffer
>  					pp->name, state);
>  				continue;
>  			}
> -		} else {
> -			if (state >= IP_VS_CTPL_S_LAST)
> -				IP_VS_DBG(7, "BACKUP v0, Invalid tpl state %u\n",
> -					  state);
> +		} else if (state >= IP_VS_CTPL_S_LAST) {
> +			IP_VS_DBG(7, "BACKUP v0, Invalid tpl state %u\n",
> +				  state);
> +			continue;
>  		}
>  
>  		ip_vs_conn_fill_param(ipvs, AF_INET, s->protocol,
> @@ -1162,10 +1162,10 @@ static inline int ip_vs_proc_sync_conn(struct netns_ipvs *ipvs, __u8 *p, __u8 *m
>  			retc = 40;
>  			goto out;
>  		}
> -	} else {
> -		if (state >= IP_VS_CTPL_S_LAST)
> -			IP_VS_DBG(7, "BACKUP, Invalid tpl state %u\n",
> -				  state);
> +	} else if (state >= IP_VS_CTPL_S_LAST) {
> +		IP_VS_DBG(7, "BACKUP, Invalid tpl state %u\n", state);
> +		retc = 40;
> +		goto out;
>  	}
>  	if (ip_vs_conn_fill_param_sync(ipvs, af, s, &param, pe_data,
>  				       pe_data_len, pe_name, pe_name_len)) {
> -- 
> 2.53.0

Regards

--
Julian Anastasov <ja@ssi.bg>

