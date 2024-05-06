Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D0D3155359;
	Mon,  6 May 2024 15:10:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715008259; cv=none; b=Z6IwnMvg7OUF575r+Hp+2LUs5bG1aMemuLPxmegt6GkuCeJoLHdNQKLePT0NlbsNc1JLd58N6JmztNOruCFUh6aDFx2JIAtSqfkFWh/E8ic1yUi/6gvXuHX0i7LbHfrlPuT97lvLSwuf4fL9cKxihLYWroCDv4Eew+lAyXUwijQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715008259; c=relaxed/simple;
	bh=4GiSVYh4x9KeVson8ItHpsAVoJh6K8EW/0O1qGhT8po=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=EcHnbkXg3UgIu0XGQp5BLdMG3rJU/eJnDTwoZo7OGBp+Ea1nvvS7O/ZcYfvGlJS+kJM7u8s5FYF9sPWhwoWSMI9lTPlQMf/iO84iuiNtkp+88lLzDP4xOJJRC4Cv+VhSFKZ9yMymCcm7RTugHH8cf/ULl18ckgzR8eU+E5SyI5I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=eLRcbtUG; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="eLRcbtUG"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 1220B1869B;
	Mon,  6 May 2024 18:10:55 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Mon,  6 May 2024 18:10:54 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 099F490029B;
	Mon,  6 May 2024 18:10:51 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1715008251; bh=4GiSVYh4x9KeVson8ItHpsAVoJh6K8EW/0O1qGhT8po=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=eLRcbtUGw+C9SzrTpUki2HLLsg7JesmNEWMS+LNaKBvnB6rj+l+5W+r5i4swu9jY5
	 KwT3ynSfREruGdm5XX2yytJQEzIPs7PDIJNCsXlAum0PNzhZoi5KFSqUK+cYIc9mg7
	 CJATREbYYBgsyH9ufx1I603qjfmhxRo5Wce8Xm+E=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 446FAm9P093351;
	Mon, 6 May 2024 18:10:48 +0300
Date: Mon, 6 May 2024 18:10:48 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v4 2/2] ipvs: allow some sysctls in non-init user
 namespaces
In-Reply-To: <20240506141444.145946-2-aleksandr.mikhalitsyn@canonical.com>
Message-ID: <bc5e74db-75ca-328e-a2d6-00d3ed69cf45@ssi.bg>
References: <20240506141444.145946-1-aleksandr.mikhalitsyn@canonical.com> <20240506141444.145946-2-aleksandr.mikhalitsyn@canonical.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 6 May 2024, Alexander Mikhalitsyn wrote:

> Let's make all IPVS sysctls writtable even when
> network namespace is owned by non-initial user namespace.
> 
> Let's make a few sysctls to be read-only for non-privileged users:
> - sync_qlen_max
> - sync_sock_size
> - run_estimation
> - est_cpulist
> - est_nice
> 
> I'm trying to be conservative with this to prevent
> introducing any security issues in there. Maybe,
> we can allow more sysctls to be writable, but let's
> do this on-demand and when we see real use-case.
> 
> This patch is motivated by user request in the LXC
> project [1]. Having this can help with running some
> Kubernetes [2] or Docker Swarm [3] workloads inside the system
> containers.
> 
> Link: https://github.com/lxc/lxc/issues/4278 [1]
> Link: https://github.com/kubernetes/kubernetes/blob/b722d017a34b300a2284b890448e5a605f21d01e/pkg/proxy/ipvs/proxier.go#L103 [2]
> Link: https://github.com/moby/libnetwork/blob/3797618f9a38372e8107d8c06f6ae199e1133ae8/osl/namespace_linux.go#L682 [3]
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
> Cc: Florian Westphal <fw@strlen.de>
> Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>

	Looks good to me for net-next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 19 +++++++++++++++----
>  1 file changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index e122fa367b81..b6d0dcf3a5c3 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -4269,6 +4269,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>  	struct ctl_table *tbl;
>  	int idx, ret;
>  	size_t ctl_table_size = ARRAY_SIZE(vs_vars);
> +	bool unpriv = net->user_ns != &init_user_ns;
>  
>  	atomic_set(&ipvs->dropentry, 0);
>  	spin_lock_init(&ipvs->dropentry_lock);
> @@ -4283,10 +4284,6 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>  		tbl = kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
>  		if (tbl == NULL)
>  			return -ENOMEM;
> -
> -		/* Don't export sysctls to unprivileged users */
> -		if (net->user_ns != &init_user_ns)
> -			ctl_table_size = 0;
>  	} else
>  		tbl = vs_vars;
>  	/* Initialize sysctl defaults */
> @@ -4312,10 +4309,17 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>  	ipvs->sysctl_sync_ports = 1;
>  	tbl[idx++].data = &ipvs->sysctl_sync_ports;
>  	tbl[idx++].data = &ipvs->sysctl_sync_persist_mode;
> +
>  	ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
> +	if (unpriv)
> +		tbl[idx].mode = 0444;
>  	tbl[idx++].data = &ipvs->sysctl_sync_qlen_max;
> +
>  	ipvs->sysctl_sync_sock_size = 0;
> +	if (unpriv)
> +		tbl[idx].mode = 0444;
>  	tbl[idx++].data = &ipvs->sysctl_sync_sock_size;
> +
>  	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
>  	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
>  	tbl[idx++].data = &ipvs->sysctl_sloppy_tcp;
> @@ -4338,15 +4342,22 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>  	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
>  	tbl[idx++].data = &ipvs->sysctl_schedule_icmp;
>  	tbl[idx++].data = &ipvs->sysctl_ignore_tunneled;
> +
>  	ipvs->sysctl_run_estimation = 1;
> +	if (unpriv)
> +		tbl[idx].mode = 0444;
>  	tbl[idx].extra2 = ipvs;
>  	tbl[idx++].data = &ipvs->sysctl_run_estimation;
>  
>  	ipvs->est_cpulist_valid = 0;
> +	if (unpriv)
> +		tbl[idx].mode = 0444;
>  	tbl[idx].extra2 = ipvs;
>  	tbl[idx++].data = &ipvs->sysctl_est_cpulist;
>  
>  	ipvs->sysctl_est_nice = IPVS_EST_NICE;
> +	if (unpriv)
> +		tbl[idx].mode = 0444;
>  	tbl[idx].extra2 = ipvs;
>  	tbl[idx++].data = &ipvs->sysctl_est_nice;
>  
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

