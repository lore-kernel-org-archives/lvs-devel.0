Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A3E5308F03;
	Sat, 26 Sep 2026 19:48:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790452143; cv=none; b=U3wVcbpKe4yCwCgN+d3RV1ck8MfDlwihufvOaw24E5EMVit8VHn2UmVnCrAseV0TFlSD1FUFImy9mL9C7L5rqr1EAaye1piyan5Vk6/x6zoAD4c06NXFRpmVG3wJpWOBy00bC+GUTLGBtV/vxlWmJjEoXGVP3eLgSy3O3Y1OAyk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790452143; c=relaxed/simple;
	bh=Ibb/6XXCwXQp4NCYZvletoa717y4olArOp/reI1OTVc=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=HQ3S0ATMRT7FlXyqpoq1VwCbv8dcyQyj1K0BlFFyvsNCwtza7WEfkKK8Qfpig2Ez4w+ibzK5XaA5yqIcWDMMevMbCm1Z2l8wGGuTxSNXxNkUGNtBTjE1dMcAmt8HxMYs9aTAPRJpY6G/jH7ugSq1HCuwSSIWwhGHPjxmw3rnawM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=jJQ12Axa; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="jJQ12Axa"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 315D9213BC;
	Sat, 26 Sep 2026 22:48:46 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=r65cERo9nN3Di2tCK7Ta1e4t4LWAALdjLsCb4qNUXHk=; b=jJQ12Axa2HCs
	kfHXTLDavQxDxR/qvSBGW91RBDI0r2HBTMUiucDSuR1oXZzAiZTPZYrxaYISQ2lK
	pdEWjpXx8afq8wDxHOYo33WpD8gbbrxNs+pk4Us6pQe8bkgcKhzJzsFMRTXs7sdz
	rI4OwpOXzQOQWpPUn2o8JENhtBMVoULXeUhezYhuLuU1xj1h6b+nS0mO0mY7mdAW
	XpOw9qAlflM3aGthodAb/uH4zpKo0DQxURziSqkDUgRyWNbNx6W3F+IPThQg8qU3
	eZhFeAT0BdaZYPTDTx1KmwSqbSOARglq6E6tOF3aaFq0FATH6bJEs4ZiESr6DXsJ
	nSQ0xTSr9c0e+89gdBA8yILMUCRN4IWF2ilKrB1S/IYk6TDln1zvOO9aZEl+J0S3
	mbvgJcKWlVNy4dp47BA/WrEjzYsddagvKihTQWzSrfUpQ435bWtswdd2Dm3zD/DQ
	FBl92HJcq9hWwN+Q4zgEJBCSj61RepqvUepMzZeKgHdioAJ6ogiQJnAgptq+GwqU
	gbu+GuvW8TKz2jY54cIOTwTYgpi70VWjKTWNJrtmK3cwwWK6ATCQkapHjj2kE/Hv
	ofJ86DKV2Uid/1A85+NWOqOplBMfJ+9JszdNlFgkeL1ukhPj7uUYxkz6Z24kyQW3
	JS9A3hZLh1i7kOgvFfdSmyPy3qM+jVE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 26 Sep 2026 22:48:46 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4DCD4608A1;
	Sat, 26 Sep 2026 22:48:48 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68QJmeRi056579;
	Sat, 26 Sep 2026 22:48:40 +0300
Date: Sat, 26 Sep 2026 22:48:40 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Chengfeng Ye <nicoyip.dev@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org
Subject: Re: [PATCH net] ipvs: Defer application parent freeing until after
 RCU readers
In-Reply-To: <20260926175129.2612644-1-nicoyip.dev@gmail.com>
Message-ID: <7ee83494-378a-ea25-6f31-e3164d533594@ssi.bg>
References: <20260926175129.2612644-1-nicoyip.dev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sun, 27 Sep 2026, Chengfeng Ye wrote:

> unregister_ip_vs_app() removes each incarnation from its protocol list and
> uses call_rcu() to defer freeing it, but frees the parent application
> immediately. An RCU reader that already found an incarnation can still
> access the parent through inc->app in ip_vs_app_inc_get().
> 
> During FTP helper module unload, the following interleaving is possible:
> 
>   CPU 0 (RCU reader)                 CPU 1 (module unload)
>   tcp_app_conn_bind()
>     find inc in protocol list
>                                      unregister_ip_vs_app()
>                                        ip_vs_app_inc_release(inc)
>                                          list_del_rcu(&inc->p_list)
>                                          call_rcu(&inc->rcu_head, ...)
>                                        kfree(a)
>     ip_vs_app_inc_get(inc)
>       try_module_get(inc->app->module)
> 
> The helper module is already going away, so try_module_get() would fail,
> but evaluating its argument first reads the freed parent. The subsequent
> rcu_barrier() in pernet unregistration cannot protect this earlier free.
> KASAN reported:
> 
>   BUG: KASAN: slab-use-after-free in ip_vs_app_inc_get+0x7c/0x90
>   Call Trace:
>    ip_vs_app_inc_get+0x7c/0x90
>    tcp_app_conn_bind+0x1bc/0x290
>    ip_vs_conn_new+0x1915/0x20d0
>    ip_vs_schedule+0x697/0xea0
>    tcp_conn_schedule+0x489/0x820
>    ip_vs_in_hook+0x7bf/0x1f40
>   Allocated by task 88:
>    kmemdup_noprof+0x20/0x50
>    register_ip_vs_app+0x12d/0x2c0
>    __ip_vs_ftp_init+0x56/0x160 [ip_vs_ftp]
>   Freed by task 104:
>    kfree+0x131/0x3c0
>    unregister_ip_vs_app+0x2f4/0x5b0
>    unregister_pernet_operations+0x232/0x490
>    unregister_pernet_subsys+0x1c/0x30
>    __do_sys_delete_module+0x346/0x510
> 
> Use kfree_rcu() with the existing rcu_head to keep the parent alive until
> these readers finish. Successful helper references already prevent normal
> module unload, and incarnation RCU callbacks do not access the parent.
> 
> Fixes: 363c97d7435e ("ipvs: convert app locks")
> Cc: stable@vger.kernel.org
> Signed-off-by: Chengfeng Ye <nicoyip.dev@gmail.com>

	Looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_app.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
> index 11cbdbaf561d..2c1b47702da2 100644
> --- a/net/netfilter/ipvs/ip_vs_app.c
> +++ b/net/netfilter/ipvs/ip_vs_app.c
> @@ -242,7 +242,7 @@ void unregister_ip_vs_app(struct netns_ipvs *ipvs, struct ip_vs_app *app)
>  		}
>  
>  		list_del(&a->a_list);
> -		kfree(a);
> +		kfree_rcu(a, rcu_head);
>  
>  		/* decrease the module use count */
>  		ip_vs_use_count_dec();
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

