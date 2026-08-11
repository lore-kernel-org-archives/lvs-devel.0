Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8D584562BF;
	Tue, 11 Aug 2026 17:12:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786468365; cv=none; b=BILW5EvzjgnuI1YRFbDHbDFm2Nhs1n6m4mheZGObrKlhUDxDCscUjv29GXmIqw5olgvxTdpC2/q3rvmriLdncLrHFTI0DjJ0e8Cla69PQ4/aImxAoqttaGLRZdS8t+nHdqp5/e1e2qI+LT5xwNU+/AyFL9tsqfxbkdfW9+uNSLA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786468365; c=relaxed/simple;
	bh=3lfeUjRIwa3v4b48TQUjBSSD26EMOuDtDyzo8ulsskg=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=DOEblRdQLwVQ23yBZLnkzVsw+SLon/XAqPf0fP9ZsA+NJSKPbnrWLxVGn4bY5h2c922BV68WV3C/h617jGKQCna5ibQxCYwmPxgGf+eoDNW7BRY5GvumamaW3xBYediZKrpJm2p9F7ETLXj6uffKZuiuigGOLRjAs9Kh/htq0+c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=DZmuMOn+; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="DZmuMOn+"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E1BC321CE3;
	Tue, 11 Aug 2026 20:12:37 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=X6No1x2Nfwn88vzzSEa0SzTiwOCd6VcaFMEUolYm+gs=; b=DZmuMOn+ctpf
	cSYsKrpn3XzYQIt6l2//HSFOl8KfIamTUalhSidZoQCTGG3kojR+ZyZYSvgX1xtb
	KO9xhhQXkFXXDbXICnpbitEQc55bULhLUB5Ofw+9is3oZfFB4Q9GtyNA1dZAz2iN
	OuLVyrNRY7rU2tik4hOBlKlinXEP/8IhrT/YWR2RTJihxxmVGbVGt27Kvc19TllN
	GXGoHtUnvzHHWSxMYqtkpNEOI4UgkX9xVkaQphR6lQHNX4E8sF62h2RVh/pdRwfG
	dXG9Og6I9ISkAABzVQCRqFEhWkiNiDIDjAtQbOgC2KsK5VSRGs0BIz+6xsmVd71X
	u2L73/EWBq63g/StdlQJIP9aSNuMWkxNqcG0KwSXT6n6l5s2LWn7Sog9JBDrPvxV
	7aqmwu8yETtgwu8YGWQ1REYRcUkP8lny7F2vIipYAM3NnYJMIWFERv/z/vRPR3s/
	5Zhhdqb6Q84cbgwEwpT7RAtxvaZ1gLpuZZO9jFz+zRDeeCByUrbsL0vdjL7G22g8
	afXAnlVlDytIpzli7Jv4Js47I7uK8RihiFERMqoKcbBpC5ze7AA38R5X/qWGDESd
	BRPFpqTvP52sf7XIWZ2vshq2trZCjUvWoSkh/XL4VFePLS0Hx1vsWA5WB463w6Az
	Dbsb79+c1DumuY6+g7p5ITD2Hz7AQ50=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 11 Aug 2026 20:12:37 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4382C60510;
	Tue, 11 Aug 2026 20:12:39 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 67BHCbYA080220;
	Tue, 11 Aug 2026 20:12:38 +0300
Date: Tue, 11 Aug 2026 20:12:37 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Kyle Zeng <kylebot@openai.com>
cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: Re: [PATCH] ipvs: fix reversed sequence option serialization
In-Reply-To: <20260810221347.34267-1-kylebot@openai.com>
Message-ID: <3fcb66ae-b20f-b97e-5f85-e91ab4a4792c@ssi.bg>
References: <20260810221347.34267-1-kylebot@openai.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 10 Aug 2026, Kyle Zeng wrote:

> hton_seq() expects the host-order source first and the unaligned
> network-order destination second. The version 1 sync sender passes these
> arguments in reverse for both sequence blocks. This leaves 24 bytes of the
> kmalloc-backed message unwritten. It may disclose stale heap data and
> replace the live connection sequence state with values read from the
> buffer.
> 
> Pass the connection sequence state as the source and the message payload as
> the destination for both blocks.
> 
> Fixes: 986a07579533 ("IPVS: Backup, Change sending to Version 1 format")
> Assisted-by: Codex:gpt-5.6-sol
> Signed-off-by: Kyle Zeng <kylebot@openai.com>

	Looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 93038abbf..f6ea6c953 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -747,9 +747,9 @@ sloop:
>  	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
>  		*(p++) = IPVS_OPT_SEQ_DATA;
>  		*(p++) = sizeof(struct ip_vs_sync_conn_options);
> -		hton_seq((struct ip_vs_seq *)p, &cp->in_seq);
> +		hton_seq(&cp->in_seq, (struct ip_vs_seq *)p);
>  		p += sizeof(struct ip_vs_seq);
> -		hton_seq((struct ip_vs_seq *)p, &cp->out_seq);
> +		hton_seq(&cp->out_seq, (struct ip_vs_seq *)p);
>  		p += sizeof(struct ip_vs_seq);
>  	}
>  	/* Handle pe data */
> -- 
> 2.53.0

Regards

--
Julian Anastasov <ja@ssi.bg>

