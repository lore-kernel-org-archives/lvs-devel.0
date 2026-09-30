Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73A2250B437;
	Wed, 30 Sep 2026 17:21:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790788900; cv=none; b=tEPUQl3p07SaEvXAq6gBhMlBcy+hE+L4soeIOCi7cpJa2Bdr1gppeMMJZ4SK+cr86obCf2vrrFPPhK/qwhT5tkIMQh35xgAfWb7c0g23sugnqwYp5oteF7FMBIW89Gk/9+cpmnGHSxmXQLjgczlPLgEuSMKoCelXwONa12HEwAA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790788900; c=relaxed/simple;
	bh=O91up9cKLfq1yAkVS5D0svGMkwIPZJyx5NtZh9lyJgQ=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=amTHezdb9UYMgUrTIp2314zL4rVkg4V6i6uMvUdtp48jRM8rYfUddOEIstY+LYZoCLlw1OywZc+YQShBWQQV6/lrcDnGuCa2NvAP27Y5b3XJLpmjU4g3u7ttOwDazJ6n4yY39vG+Jf881MnDMblFWI+bgtKUfc+ckk9pvLpLQZc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=KEu52Ayg; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="KEu52Ayg"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 1BE6C21ABA;
	Wed, 30 Sep 2026 20:21:29 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=9vru5qMhx4CcvEMqoQz8FCpM9tsoA8yIWs8W5fu45qg=; b=KEu52Ayg5km7
	1+zcz95S/6y+tNb5d8ZoQPksv6ohAzj+pQ0RTtFF0X0e4jmyAuqmoJXcE4SgoZct
	HPEmkZa1qTt9xBQkhw7Gesc2OPX5vaK/qyYBOyqc5XEL+FAtuCAnQV5YhaO27ImB
	nRn6mnDhMqfMur/6rygKU4Z+FCQ0cyP9DkHO+PDx3ZNKmSUIRtcDipOT3DbzOQAK
	rCHenZtRPj7GRtOc3qULkRXObqH5fTXqgLGYxmonsvdzxojZcmAsv8BFMs/in0ns
	In/EL+zKgyNYd1hqhs9yBk7IFOrTHmLBHz+ECIqEnxUWD1BP8PeogGFmqR0wF/8Q
	glJz1mg+uc4Uzk/cX0DZXGY73Gk4gttpLbmNtc2C1x+jMDoQiIs9Vd7tvtj52MTm
	Ik1ZlOCd9uhi17EcwsOOcAIYQzhzvcIl4RoZqTtmWMtbA1yP0BlBUQNWKaVj2ozD
	TeSfirsTeq0W/DCThpMNDEeC1VNIygtrf5w0YIH2XZHQKxihrSg8GRqubZNL74px
	73bD+BZn1941ngPnxtAXVsG5wI3nVZyWASuRkeuwg3kxCnsSGn/nG4RVgw9ya9PL
	5Bg5ItIIxrThR9/nM9CR/y9f0deQm+7omJOyr+Sae8ksqupdML2DbYZZ8EyfN6yN
	N9y+GNRTqqTb5YD4br0JETMKUPW+Iy4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 30 Sep 2026 20:21:28 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 66BE560BB3;
	Wed, 30 Sep 2026 20:21:31 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68UHLOUW073270;
	Wed, 30 Sep 2026 20:21:25 +0300
Date: Wed, 30 Sep 2026 20:21:24 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Chengfeng Ye <nicoyip.dev@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        Hans Schillstrom <hans.schillstrom@ericsson.com>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH net] ipvs: fix protocol data lifetime during namespace
 teardown
In-Reply-To: <20260927062435.3690129-1-nicoyip.dev@gmail.com>
Message-ID: <be9d490c-f295-2119-b504-80842011ecce@ssi.bg>
References: <20260927062435.3690129-1-nicoyip.dev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sun, 27 Sep 2026, Chengfeng Ye wrote:

> IPVS frees its per-net protocol data before control cleanup cancels
> defense work and unregisters the sysctl table. A defense worker can load
> a protocol data pointer, then namespace cleanup can unlink and free that
> object before the worker dereferences pd->pp or pd->next. The worker's
> securetcp_lock does not serialize with protocol cleanup. A concurrent
> defense-mode sysctl write can reach the same timeout update path.
> 
> KASAN reported:
> 
>   BUG: KASAN: slab-use-after-free in ip_vs_protocol_timeout_change
>   Workqueue: events_long defense_work_handler
>   Call Trace:
>    ip_vs_protocol_timeout_change+0x1b4/0x1e0
>    update_defense_level+0x63e/0xd80
>    defense_work_handler+0x1e/0xc0
>   Allocated by task 125:
>    ip_vs_protocol_net_init+0xda/0x2f0
>    __ip_vs_init+0x16b/0x240
>    setup_net+0xfc/0x310
>   Freed by task 12:
>    ip_vs_protocol_net_cleanup+0x1d6/0x2e0
>    __ip_vs_cleanup_batch+0x7d/0x100
>    cleanup_net+0x38c/0x770
> 
> Run control cleanup before protocol cleanup so that defense work and
> active sysctl handlers have finished before their protocol data is freed.
> Initialize protocols before exposing the control interface, and unwind
> in reverse order, to enforce the same lifetime on initialization failure.
> Protocol initialization and exit do not depend on control state.
> 
> Fixes: 9330419d9aa4 ("IPVS: netns, use ip_vs_proto_data as param.")
> Cc: stable@vger.kernel.org
> Signed-off-by: Chengfeng Ye <nicoyip.dev@gmail.com>

	Patch looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	If you want to change the order of ip_vs_protocol_init()
and ip_vs_control_init() in ip_vs_init() for consistency, you
have to send another version or a nf-next patch.

> ---
>  net/netfilter/ipvs/ip_vs_core.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index fd503f0efb57..8a3c880fdb26 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -2502,12 +2502,12 @@ static int __net_init __ip_vs_init(struct net *net)
>  	if (ip_vs_estimator_net_init(ipvs) < 0)
>  		goto estimator_fail;
>  
> -	if (ip_vs_control_net_init(ipvs) < 0)
> -		goto control_fail;
> -
>  	if (ip_vs_protocol_net_init(ipvs) < 0)
>  		goto protocol_fail;
>  
> +	if (ip_vs_control_net_init(ipvs) < 0)
> +		goto control_fail;
> +
>  	if (ip_vs_app_net_init(ipvs) < 0)
>  		goto app_fail;
>  
> @@ -2527,10 +2527,10 @@ static int __net_init __ip_vs_init(struct net *net)
>  conn_fail:
>  	ip_vs_app_net_cleanup(ipvs);
>  app_fail:
> -	ip_vs_protocol_net_cleanup(ipvs);
> -protocol_fail:
>  	ip_vs_control_net_cleanup(ipvs);
>  control_fail:
> +	ip_vs_protocol_net_cleanup(ipvs);
> +protocol_fail:
>  	ip_vs_estimator_net_cleanup(ipvs);
>  estimator_fail:
>  	net->ipvs = NULL;
> @@ -2547,8 +2547,8 @@ static void __net_exit __ip_vs_cleanup_batch(struct list_head *net_list)
>  		ipvs = net_ipvs(net);
>  		ip_vs_conn_net_cleanup(ipvs);
>  		ip_vs_app_net_cleanup(ipvs);
> -		ip_vs_protocol_net_cleanup(ipvs);
>  		ip_vs_control_net_cleanup(ipvs);
> +		ip_vs_protocol_net_cleanup(ipvs);
>  		ip_vs_estimator_net_cleanup(ipvs);
>  		IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
>  		net->ipvs = NULL;
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

