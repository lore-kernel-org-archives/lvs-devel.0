Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793778071;
	b=ve5rrDiY9iU6uaV6SDa1Rwg7t0xbtc4lvgw1Bl8VTmCmNblvb/mgvJOU6JJ/GgjEt4IL
	 96KkQ4PHVuXdr7VdyiBSc9FAkmFI7mr4FaUKhS4BXJdIasE9RZjFvdDHcgzNN7cRpygOl
	 tc9yI0eD5N4sWwxtjQX0yDK7EyuoSsJctrrQmnVfv+mlwfnYGX51k1vH0m4l4fN0YgkUr
	 240oOk2dc3sA+XL45EYiB+Tp0XUcQf243ssLAWfbZGRf7kTo8be9d3T0nQ6xZ0C9N8ovG
	 ghPEufgZ7mYwaEcOHMkFwaOof7bVdBJ9/IE4yS+7SV3OnmHkUf8xshWMtRL99e/tYBQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793778071;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=1P0UdRGesSvRcYWLOcSq2v6TwJ6oFJppYDalpqzJ4qI=;
	b=E2yWTTryfJKC9TzndKEhFHBRk8KBTv/+HkgpM5p+m0bouvWbUVOLAlC0GnjlD/bYnIB6
	 U7Y7R15v6oZv+hv9ZiCx7XYCwmXhVvcOhcQk65+WZwzbTjmltFaXtsnekzUrowiPELI9h
	 P8KACLeHk/k42KGBqcTkgpEPmL5cYVeCtJSm9v6ejp/86xAmA7hG2198uE5EcoE0BMyIG
	 B1CF47Pj2cMtGh9DzKa7XXi/qN32NnB9p0evOaK8AI/7gejZf62obJl7g8Ir8n+8bXzWd
	 rM6TnOCaQaMny5sxOj3AB9xMTJyqXNrdhRkeAqCOotRM7gDqpuXcltsrKxMHdiTtWYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b="U7Itfj/R";
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35251606A328;
	Wed,  4 Nov 2026 07:41:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 35251606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=U7Itfj/R
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id ED28021F8C;
	Wed, 04 Nov 2026 09:41:05 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=1P0UdRGesSvRcYWLOcSq2v6TwJ6oFJppYDalpqzJ4qI=; b=U7Itfj/RWc35
	3MpdDW+66Nf/QskNbtdt8egnB90PjT0ewOxcpgzWJrpb1nTT7KWzvO5bEAvzFlts
	YHRxeb/LHIZHALAVy8CifVF3JJpUY3Fkv7jSY1ME6fIFud35+mBk02fPxT3VU5Ug
	xC2NczTdiMBJ5gfXdkRMYfCkeQq0qXW5r44OJVQ3KXky0Y6DUOc7wBvxRCN7ccqe
	+dh5UXYaUj+NsmTKPOMNKE2XsJtWC0cQmYxtgO9/OdLQZPF/TOslSio4wO+m/RVu
	+6lTzP9KE1il2DDhUvc99Lnw72ABmpBdh0waRbvi3LLchmWtPJORTAT5XVU89oYd
	kjagN4VkZbR5Qm1wqyLL+pOZDa1eQIrmuE74kNiB2VKdKNQybm9/rxqCGP/p+r3D
	CRAXcPvtKxaGVZlhMTltxM62VD2NkesoKjoE2xzQ8jaT4LRkwWvEgGeW4JbkvB8h
	UZM4Gj7BdkdwwtqlyMhfRy4N068PvfeELMZaf82IUAhiPrSXCFBqnMs3jFRBHnYv
	+Bsz2GLIASfYxnsrrLts+zPtkM6TgU5/QOdQ2CyWXbswh3ZClW47U8jyGtJpS6uz
	8BkcepXJGvIOdmP7tef83Sh1kdo0eH9aurShHBJLU4Mwya2ZYkIWIS1HST1AJW6A
	8cVFdd3L168F3CsCfrjY9uEk+YSkCuE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 04 Nov 2026 09:41:05 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9032960881;
	Wed,  4 Nov 2026 09:41:05 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A47exSv020371;
	Wed, 4 Nov 2026 09:40:59 +0200
Date: Wed, 4 Nov 2026 09:40:59 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Yingjie Wang <1075151112@qq.com>
cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au,
        dsahern@kernel.org, idosch@nvidia.com, pablo@netfilter.org,
        fw@strlen.de, phil@nwl.cc, davem@davemloft.net, edumazet@kernel.org,
        kuba@kernel.org, pabeni@redhat.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH nf v2] ipvs: reject negative sync_refresh_period values
In-Reply-To: <tencent_9109FFF19F0341A556269E694408976E2708@qq.com>
Message-ID: <6cbe5281-99d0-bc08-6691-0a87f87442d3@ssi.bg>
References: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com> <tencent_9109FFF19F0341A556269E694408976E2708@qq.com>
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

On Wed, 4 Nov 2026, Yingjie Wang wrote:

> net.ipv4.vs.sync_refresh_period is documented as an unsigned number of
> seconds.  proc_dointvec_jiffies() accepts a signed integer and converts
> it to jiffies before storing it in an unsigned int field.  Consequently,
> writing -1 stores UINT_MAX - HZ + 1 jiffies and bypasses the finite
> bound applied to ordinary positive writes.
> 
> This changes the behavior of ip_vs_sync_conn_needed().  With
> sync_threshold="0 1" (threshold 0, period 1) and
> sync_refresh_period=-1, only the first of twelve packets requests a
> sync message; the zero-refresh control requests all twelve.
> 
> Store the value in seconds, as documented, and convert it at the single
> consumer.  Use proc_douintvec_minmax() to reject negative input.  Cap the
> value at INT_MAX / HZ to preserve the prior jiffies range and avoid
> overflow in secs_to_jiffies().
> 
> The issue was reproduced on an affected 7.0 distribution kernel in a
> temporary network namespace.  A patched target kernel was built with W=1
> and exercised in QEMU; -1 is now rejected with EINVAL, zero and positive
> values retain their behavior, and the HZ=1000 boundary accepts 2147483
> while rejecting 2147484.
> 
> Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
> Cc: stable@vger.kernel.org
> Signed-off-by: Yingjie Wang <1075151112@qq.com>

	Patch looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> 
> Notes:
>     Changes since v1:
>     - Drop the unnecessary <linux/jiffies.h> include.
>     - Rebase on current net/main and use the nf target tag.
>     
>     Link: https://lore.kernel.org/r/tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com/
> 
>  include/net/ip_vs.h            | 6 +++---
>  net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++++--
>  2 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9a83bff32569..b6834542489a 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1267,7 +1267,7 @@ struct netns_ipvs {
>  	int			sysctl_sloppy_sctp;
>  	int			sysctl_expire_quiescent_template;
>  	int			sysctl_sync_threshold[2];
> -	unsigned int		sysctl_sync_refresh_period;
> +	unsigned int		sysctl_sync_refresh_period; /* seconds */
>  	int			sysctl_sync_retries;
>  	int			sysctl_nat_icmp_send;
>  	int			sysctl_pmtu_disc;
> @@ -1335,7 +1335,7 @@ struct netns_ipvs {
>  #define DEFAULT_SYNC_VER	1
>  #define DEFAULT_SLOPPY_TCP	0
>  #define DEFAULT_SLOPPY_SCTP	0
> -#define DEFAULT_SYNC_REFRESH_PERIOD	(0U * HZ)
> +#define DEFAULT_SYNC_REFRESH_PERIOD	0U
>  #define DEFAULT_SYNC_RETRIES		0
>  #define IPVS_SYNC_WAKEUP_RATE	8
>  #define IPVS_SYNC_QLEN_MAX	(IPVS_SYNC_WAKEUP_RATE * 4)
> @@ -1363,7 +1363,7 @@ static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
>  
>  static inline unsigned int sysctl_sync_refresh_period(struct netns_ipvs *ipvs)
>  {
> -	return READ_ONCE(ipvs->sysctl_sync_refresh_period);
> +	return secs_to_jiffies(READ_ONCE(ipvs->sysctl_sync_refresh_period));
>  }
>  
>  static inline int sysctl_sync_retries(struct netns_ipvs *ipvs)
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index ce9fe20d6106..82726b6b5e3a 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2369,6 +2369,8 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
>  
>  #ifdef CONFIG_SYSCTL
>  
> +static unsigned int sync_refresh_period_max = INT_MAX / HZ;
> +
>  static int
>  proc_do_conn_max(const struct ctl_table *table, int write,
>  		 void *buffer, size_t *lenp, loff_t *ppos)
> @@ -2824,9 +2826,11 @@ static struct ctl_table vs_vars[] = {
>  	},
>  	{
>  		.procname	= "sync_refresh_period",
> -		.maxlen		= sizeof(int),
> +		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec_jiffies,
> +		.proc_handler	= proc_douintvec_minmax,
> +		.extra1		= SYSCTL_ZERO,
> +		.extra2		= &sync_refresh_period_max,
>  	},
>  	{
>  		.procname	= "sync_retries",
> 
> base-commit: 647b81ddefc6364290e67bf33c89d54971f8995e
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

