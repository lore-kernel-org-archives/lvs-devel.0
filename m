Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7FA67313295;
	Wed, 10 Sep 2025 09:39:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757497167; cv=none; b=mtNlRzt5WTOuSUu+fZp+IJfE9yKd4uDe05gI0M7+sdbVbAFDa6syBOCJYUK1g6lhxthHSGZo34TAPBRm4PoGX8rmKl+O2PyMXn0aNwOpmL17zc8Q9mLIu5cCXajBa18CqJZ0lNLIKjU771FxpgkR6qMvc3OnBrCLg67P5kaSOCk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757497167; c=relaxed/simple;
	bh=zTFxX1dpzU75gVQTHXC020MPra4QqYog6g5AI98AKe4=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=mn7Zlc87vIrQPfkuUPyjRUb2yK3Su4gKvGME3oMKQDCpXbGXVqz0+nDvOwCiYbeDRC6etRl+tRa7339bZV1T7TtW5+aiO0ErnE1z7aRxuFxn8Ky3zpdlS7Vvq0ZqQIAhZu37o//7/4vzWO5StmerVnkxrOz8MnViquzEEAbV/y8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=u3CoKjJJ; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="u3CoKjJJ"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id BEAEE2054A;
	Wed, 10 Sep 2025 12:39:21 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=7V7Dfe/CZwaAIY8UKFxBZElMW1h1SHQgs67YmIaOWW4=; b=u3CoKjJJ0snP
	Zu1+opb9aOixXBRd93/J9Ko6EYp8VC9cn203lpmjETMERu+x4VUawr5Hw2WV4sqn
	QkCOddugVRn4bj1ioUTCpJjO4yeY4z+DUGQLSTXfeF3G13QV9+7fV7LX3nnyDMdX
	7OMh2k+LMX1Y+NZ4A4RK1e15PYKbt9aSkqdWcsHkJ1kByTzKvo3/c90dNwT7TdJA
	SfaqOBcLxASdnvA8Plx5+HlIso2veIEskRTg6NVrV3SAXat+Laeqdb1n2Yu0VkOV
	LsRexVhRkOR0Xe5NZyqsj6bYDbWXW/jnK+dcnMH/1A6Ugf5sKPJoOgaakOBe1NI9
	aPouQ9ec5uh2YZWwArbMrPaeOTRV599GoZXC0Ot345EN43am3U2gjL+feGXB7e18
	bCvIURBcG8WlQXK8s4ENY3E9QlQTdEp0epe3yEe8ogpikClGZ/tVPqTg3ANRriOU
	UvGCvz/4AepWKQQrBhs5fenZIiFMQVRKSmZrR2Hta6wB+pKIrinEXC9agP2jse8v
	xdhc8RJ+6XuKTH1xc2+c4S2/tnj7yZ+y2C+KaciJNqlCWfOXLqW6MMUBpt3+3PT6
	iIPA9dAuUu39qiCNdWwc68PK8VV0DFxY+Rk7Lv+3LcpzVSFx2+fVY3BOCqMOAgcx
	a8jyUBLMMdK+DKa72Kuq59uW3f48h9Q=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 10 Sep 2025 12:39:21 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B513C60F04;
	Wed, 10 Sep 2025 12:39:18 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 58A9d7dP015831;
	Wed, 10 Sep 2025 12:39:07 +0300
Date: Wed, 10 Sep 2025 12:39:07 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Slavin Liu <slavin452@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] ipvs: Check ipvs->enable before unregistration in
 __ip_vs_ftp_exit()
In-Reply-To: <20250909212113.481-1-slavin452@gmail.com>
Message-ID: <5d3aae32-1c81-05fb-f210-29ec864c4f6d@ssi.bg>
References: <20250909212113.481-1-slavin452@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 10 Sep 2025, Slavin Liu wrote:

> On netns cleanup path, before unregistration in __ip_vs_ftp_exit(),
> there could still be existing conns with valid cp->app.
> 
> Suggested by Julian, this patch fixes this issue by checking ipvs->enable 
> to ensure the right order of cleanup:
> 1. Set ipvs->enable to 0 in ipvs_core_dev_ops->exit_batch()
> 2. Skip app unregistration in ip_vs_ftp_ops->exit() by 
> 	checking ipvs->enable
> 3. Flush all conns in ipvs_core_ops->exit_batch()
> 4. Unregister all apps in ipvs_core_ops->exit_batch()
> 
> Access ipvs->enable by READ_ONCE to avoid concurrency issue.
> 
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Slavin Liu <slavin452@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_ftp.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index d8a284999544..d3e2f7798bf3 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -605,7 +605,7 @@ static void __ip_vs_ftp_exit(struct net *net)
>  {
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> -	if (!ipvs)
> +	if (!ipvs || !READ_ONCE(ipvs->enable))

	Ops, I forgot that ipvs->enable is set later when
service is added. May be we have to add some new global flag
for this in ip_vs_ftp.c:

static bool removing;

	We will set it in ip_vs_ftp_exit() before calling
unregister_pernet_subsys() and the above check will become:

	if (!ipvs || !removing)

	Also, we have to add Fixes tag, this looks the
one that starts to remove apps from netns exit handler:

Fixes: 61b1ab4583e2 ("IPVS: netns, add basic init per netns.")

Regards

--
Julian Anastasov <ja@ssi.bg>

