Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D37318F2F0;
	Wed, 26 Jun 2024 18:01:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719424875; cv=none; b=uUqtOOPmekskXKSBtKEbpOoQW8RmZBgkxhzfstLjPP2ba1YcdMQYyOgetHOOsXX3XJt94QK6ySj+dYguBz2zTTS+rDUfwCNiZplMmFuYGORERRKG9izluGlnRbHCA44Q9nuMNCvjOivXWz6x0DlqUxyD1oSeKupWTiLjbM0w/5w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719424875; c=relaxed/simple;
	bh=8nOGA/lGYq2Bgz7KD7dOJ21ukJ+JyTrXrRLfbT32HE8=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=ZesEmrz/T1lQWMyvyhAD/wucNJ1dFpUKYKwrNo5rr5N2YDAXuwOLkLPRdjd+GDXgaO5vcDiYZw6/QTjxSy95Jm6ePz85ezGGt00yGSqKWkJlULv5WzAz4XcZkSlZ30HabBNVwpe2m0dWgVN7IJgg3yuw+1BjJxJa1gOyhVDWD14=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=HP2bgXQf; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="HP2bgXQf"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id CEEB4D32C;
	Wed, 26 Jun 2024 20:54:12 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Wed, 26 Jun 2024 20:54:12 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id F4145900697;
	Wed, 26 Jun 2024 20:54:07 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1719424449; bh=8nOGA/lGYq2Bgz7KD7dOJ21ukJ+JyTrXrRLfbT32HE8=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=HP2bgXQfn69q2qygNWf6w6xqBih2NOSuthDkWX885mlA9bvIvWb4IR51NUuJayz07
	 jtGil2WRdsHSlCfgq3W1qa+V1XqukuAL5XYpNiCXTCDK7uK4HGFbHIC9r6q4suTuBQ
	 EP0VIy5gPSYfxhfxtMD1EmWfAVW843Qa8Y5p5IBM=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 45QHrx9D056385;
	Wed, 26 Jun 2024 20:53:59 +0300
Date: Wed, 26 Jun 2024 20:53:59 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Chen Hanxiao <chenhx.fnst@fujitsu.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH net-next] ipvs: properly dereference pe in
 ip_vs_add_service
In-Reply-To: <20240626081159.1405-1-chenhx.fnst@fujitsu.com>
Message-ID: <721791d7-4070-a680-2dff-f56d10467494@ssi.bg>
References: <20240626081159.1405-1-chenhx.fnst@fujitsu.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 26 Jun 2024, Chen Hanxiao wrote:

> Use rcu_dereference_protected to resolve sparse warning:
> 
>   net/netfilter/ipvs/ip_vs_ctl.c:1471:27: warning: dereference of noderef expression
> 
> Fixes: 39b972231536 ("ipvs: handle connections started by real-servers")
> Signed-off-by: Chen Hanxiao <chenhx.fnst@fujitsu.com>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index b6d0dcf3a5c3..925e2143ba15 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1369,7 +1369,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  {
>  	int ret = 0;
>  	struct ip_vs_scheduler *sched = NULL;
> -	struct ip_vs_pe *pe = NULL;
> +	struct ip_vs_pe *pe = NULL, *tmp_pe = NULL;

	NULL init is not needed

>  	struct ip_vs_service *svc = NULL;
>  	int ret_hooks = -1;
>  
> @@ -1468,7 +1468,8 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  		atomic_inc(&ipvs->ftpsvc_counter);
>  	else if (svc->port == 0)
>  		atomic_inc(&ipvs->nullsvc_counter);
> -	if (svc->pe && svc->pe->conn_out)
> +	tmp_pe = rcu_dereference_protected(svc->pe, 1);
> +	if (tmp_pe && tmp_pe->conn_out)
>  		atomic_inc(&ipvs->conn_out_counter);

	Alternative option would be to use 'pe' above and to move
the RCU_INIT_POINTER and pe = NULL with their comment here.
It is up to you to decide which option is better...

Regards

--
Julian Anastasov <ja@ssi.bg>

