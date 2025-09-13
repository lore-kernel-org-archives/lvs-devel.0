Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F1BF1E8333;
	Sat, 13 Sep 2025 17:23:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757784217; cv=none; b=kYkCHFGeOrUj2O6phL00AwZda7MxAlxQdf0VCPsQQLUUidgxE7BTZJfFJW9RRcZgDm3HkObIV3yZwiNeNKB7AfHPy3Rv3JZ4l7tZp2ettQnpFx9Rbv/zAY7XflfvUnNaGtPz7f9FsTGpwrWgUG9twMHs00a4d6AAPqp1zPSazmw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757784217; c=relaxed/simple;
	bh=hQrqb6mIdtNaw5IoEb/MqdcF49HaYq7QCH933ZOxA3Q=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=rnJCEgPIh9YOXveTxDunJEllkj170Vofa1TEc9zjcmO/L0Kt8b9U6GPHKCLj16fkTtTizj9xzpWhNCsymv+EV76h4mQ5fvd0LONh9+VkwsjbExqwV/gr6uPneyLtv2gEbvbqEI3SqTINZ1l3OsVaKWhLXD0zhCeKxdcuHB8aRTo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=sqn/FvhW; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="sqn/FvhW"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 261D52055B;
	Sat, 13 Sep 2025 20:23:24 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=U/LMK9fOxEJZWLbS+ivg/XnNJz/FLhKUxGb+S6dYdE4=; b=sqn/FvhWwnIK
	Pq1Enswo9aHUqGsRmwF/E+CzNALMVkLsr9c0wugg35TMBgTBwz9yIiPhHsIJmFgP
	1YlA5MZfR8mlb+A1lMCW3QtXRRoAO+89I98ozwHnRbnykfs1R4gi4ma7Yl3OAlIF
	1tY78io3VqNKwj+0IJG83IjNqic2geer3E2w2i/k2/BHQIhIPbgna93mAdIOdbCf
	HKLDp1saMzYTTag7aTLsGK0GTafeSb0tGuEHlovynLK1xyOxzyQyhFS3IzgujnKW
	Ppxsj/0FVe2+97nrauNPq/orFEX5v/ChcCN5Bdgo6rxO1KgttSLcNNdz7MZ2srAY
	eZ/a3X20t15W2KVbCucQmXH73YHQBXE3soR229FJT4gbrpn3FAnzmAr0t3TVvJup
	+u+w2wYTJNkLl/XZV9YZtKUAHQ8gQ/gljMRujtVjtEht0a1D8dOa8ALaNS7C8Ceh
	TOdiWaJ24mYw8EF/hvUCbv6F77lfRoSmnhfwcidv/F+fmObCRzcyep0/v6K+zuVf
	aLSI/SMawYipt4KQhOEg+8VEo9s7VTwuR+WwW5sur3SWKbUFIqDZCzw8BpnLsQvL
	fpS93eqUEi8O6J0pkhoywL1ZPf/0qSh0W+YaSc04Carva4PtfEMQMfgypYpk2m1M
	zloHlo/77jUrAhBB/Ndujs6uFkXcCAE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 13 Sep 2025 20:23:23 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D2360654D1;
	Sat, 13 Sep 2025 20:23:20 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 58DHN4dO029190;
	Sat, 13 Sep 2025 20:23:04 +0300
Date: Sat, 13 Sep 2025 20:23:04 +0300 (EEST)
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
Subject: Re: [PATCH v4] ipvs: Defer ip_vs_ftp unregister during netns
 cleanup
In-Reply-To: <20250911175759.474-1-slavin452@gmail.com>
Message-ID: <0effae4a-4b9d-552e-5de7-756af4627451@ssi.bg>
References:  <20250911175759.474-1-slavin452@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 12 Sep 2025, Slavin Liu wrote:

> On the netns cleanup path, __ip_vs_ftp_exit() may unregister ip_vs_ftp
> before connections with valid cp->app pointers are flushed, leading to a
> use-after-free.
> 
> Fix this by introducing a global `exiting_module` flag, set to true in
> ip_vs_ftp_exit() before unregistering the pernet subsystem. In
> __ip_vs_ftp_exit(), skip ip_vs_ftp unregister if called during netns
> cleanup (when module_removing is false) and defer it to

	Pablo, can you change here module_removing to exiting_module 
before applying?

> __ip_vs_cleanup_batch(), which unregisters all apps after all connections
> are flushed. If called during module exit, unregister ip_vs_ftp
> immediately.
> 
> Fixes: 61b1ab4583e2 ("IPVS: netns, add basic init per netns.")
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Slavin Liu <slavin452@gmail.com>

	Looks good to me for the nf tree after above text is
changed, thanks!

Signed-off-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_ftp.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index d8a284999544..206c6700e200 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -53,6 +53,7 @@ enum {
>  	IP_VS_FTP_EPSV,
>  };
>  
> +static bool exiting_module;
>  /*
>   * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
>   * First port is set to the default port.
> @@ -605,7 +606,7 @@ static void __ip_vs_ftp_exit(struct net *net)
>  {
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> -	if (!ipvs)
> +	if (!ipvs || !exiting_module)
>  		return;
>  
>  	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
> @@ -627,6 +628,7 @@ static int __init ip_vs_ftp_init(void)
>   */
>  static void __exit ip_vs_ftp_exit(void)
>  {
> +	exiting_module = true;
>  	unregister_pernet_subsys(&ip_vs_ftp_ops);
>  	/* rcu_barrier() is called by netns */
>  }
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

