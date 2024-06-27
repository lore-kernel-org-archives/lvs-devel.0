Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FEFF19A294;
	Thu, 27 Jun 2024 19:09:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719515368; cv=none; b=k7ZxPWBFTxn9nC3RlHjnPI7KnZe32YQApH3ZtfF0hU6w7THJ+02NawH9rj+0JTHifn83WRvWUR9aUck7ZlDi5tAbinauWIjbxxWqL2QIvLbBjG6N4LnT42r9ByDvF3z7RK9UDcqSZOFzGtk6onQXJusawqJh79zV3i1M51qxQME=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719515368; c=relaxed/simple;
	bh=xLMzz62KCg/+ORSjR85luR+L2JfDFo4OR3KMezt3O90=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=njbVnXBYx0ZGCLK00pADwYc/z5f3dVc2h3bLis8zMH/XL2qn47tmyGNF3qm5kt6Rqn35sdGQbV6t697TUKLumI5sNak1J8EPDRqo/s5CW+eA1T5aIgefgJyT2CxCvvrtxMj2BkBeqBvqdgcNNv7vUYTwyZycjLv2TuIb3URHSiw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=J7AUjKNe; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="J7AUjKNe"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id AA5DB1C0B9;
	Thu, 27 Jun 2024 22:09:16 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Thu, 27 Jun 2024 22:09:16 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id A34809004EF;
	Thu, 27 Jun 2024 22:09:11 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1719515353; bh=xLMzz62KCg/+ORSjR85luR+L2JfDFo4OR3KMezt3O90=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=J7AUjKNehXrt6e315joPRqDdeRCWw8kUtIQGoFaKCnlDCMPG053D6GXu5iPZdqA2Z
	 l7hA9IDzvlM1jEsc/5lK+bvuY7KcrtV8XAVepG9/aAFYe3lL+Xn4L1Uov0/Y7+jqHO
	 pgwz/9f9uhKvU7eKRfdwg9b9snVFlAF8T15PPNx4=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 45RJ92YK078348;
	Thu, 27 Jun 2024 22:09:03 +0300
Date: Thu, 27 Jun 2024 22:09:02 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Chen Hanxiao <chenhx.fnst@fujitsu.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH net-next v2] ipvs: properly dereference pe in
 ip_vs_add_service
In-Reply-To: <20240627061515.1477-1-chenhx.fnst@fujitsu.com>
Message-ID: <b6867456-a926-4d51-9000-fc7816788c17@ssi.bg>
References: <20240627061515.1477-1-chenhx.fnst@fujitsu.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 27 Jun 2024, Chen Hanxiao wrote:

> Use pe directly to resolve sparse warning:
> 
>   net/netfilter/ipvs/ip_vs_ctl.c:1471:27: warning: dereference of noderef expression
> 
> Fixes: 39b972231536 ("ipvs: handle connections started by real-servers")
> Signed-off-by: Chen Hanxiao <chenhx.fnst@fujitsu.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> v2:
> 	use pe directly.
> 
>  net/netfilter/ipvs/ip_vs_ctl.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index b6d0dcf3a5c3..f4384e147ee1 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1459,18 +1459,18 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  	if (ret < 0)
>  		goto out_err;
>  
> -	/* Bind the ct retriever */
> -	RCU_INIT_POINTER(svc->pe, pe);
> -	pe = NULL;
> -
>  	/* Update the virtual service counters */
>  	if (svc->port == FTPPORT)
>  		atomic_inc(&ipvs->ftpsvc_counter);
>  	else if (svc->port == 0)
>  		atomic_inc(&ipvs->nullsvc_counter);
> -	if (svc->pe && svc->pe->conn_out)
> +	if (pe && pe->conn_out)
>  		atomic_inc(&ipvs->conn_out_counter);
>  
> +	/* Bind the ct retriever */
> +	RCU_INIT_POINTER(svc->pe, pe);
> +	pe = NULL;
> +
>  	/* Count only IPv4 services for old get/setsockopt interface */
>  	if (svc->af == AF_INET)
>  		ipvs->num_services++;
> -- 
> 2.39.1

Regards

--
Julian Anastasov <ja@ssi.bg>

