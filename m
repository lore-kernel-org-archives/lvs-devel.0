Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3707F405ABE;
	Wed,  1 Apr 2026 12:54:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775048063; cv=none; b=QsW0sQMZs3XGzOZrnYCxSkFSbK2rBhuCJ4Y8r8bA8+2DF23IhiaOuBMgvddY8yWOJkWGDhBConFXo6LeECwFmnG6ao8V8LOtDTfrqdPCVpEX2Ncmpbgv8r9xkFmRvecOp3yWO6yuETFh96T38dcVrVON5xQ8zFKYQNKeACXy5DI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775048063; c=relaxed/simple;
	bh=FlhZRZdq6n/vz7LDAF+uUuhTAP88A7gBM+WGCqzHIJw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=YcdyNPi/29cpjZllDA5/643vdVEoI8iOWXwg2HZQeq4QtSlVcJEQrdljjDsF4VJhv0EGgq0op4Gym7nZmZgiLiqX0PWHZEyPYF+4RJhyNizwDc5tGQ2c2PL4I4mhrL4vA7gEZhf3SzxlBCV6UB/hXuB3++PunRwcnrn+veheGIs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dE9qenm7; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dE9qenm7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 75C96C4CEF7;
	Wed,  1 Apr 2026 12:54:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775048062;
	bh=FlhZRZdq6n/vz7LDAF+uUuhTAP88A7gBM+WGCqzHIJw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=dE9qenm7GQTd/0YjD1k5c5nr/1GVFv7H4Jwtd1kmtUgfXnijnz/k8LITsKw94OlHz
	 zkcdIgID0w8UnCP6X1+3y6d8neFeGfBGFoyTGnxB8jdLdWJ3Nj1PWNpO19LUkoFg/7
	 tGCFGoim5CL9OZVw5USxEtlAmB9mLV1Fe1+Hjz6NftEBSrRYqSvfGeXOfeE0yijLci
	 bnzvAcPn7uIa0bUdML2iqcnJB3eMhgK/+84ca5Y0V/y52DF3ISduR8lEZYw9RcKdmF
	 ZdTxj949sIYVnC7+3Cp2QhlDgbcQoaf2ImFy9oHspjkr5rGZetXtOKDsAVrE0vL8FY
	 Nm3GFC0WSfu9g==
Date: Wed, 1 Apr 2026 14:54:20 +0200
From: Frederic Weisbecker <frederic@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, sheviks <sheviks@gmail.com>
Subject: Re: [PATCH-next v2 2/2] ipvs: Guard access of HK_TYPE_KTHREAD
 cpumask with RCU
Message-ID: <ac0VfO3XiD_F1gv-@localhost.localdomain>
References: <20260331165015.2777765-1-longman@redhat.com>
 <20260331165015.2777765-3-longman@redhat.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260331165015.2777765-3-longman@redhat.com>

Le Tue, Mar 31, 2026 at 12:50:15PM -0400, Waiman Long a écrit :
> The ip_vs_ctl.c file and the associated ip_vs.h file are the only places
> in the kernel where HK_TYPE_KTHREAD cpumask is being retrieved and used.
> Now that HK_TYPE_KTHREAD/HK_TYPE_DOMAIN cpumask can be changed at run
> time. We need to use RCU to guard access to this cpumask to avoid a
> potential UAF problem as the returned cpumask may be freed before it
> is being used.
> 
> We can replace HK_TYPE_KTHREAD by HK_TYPE_DOMAIN as they are aliases
> of each other, but keeping the HK_TYPE_KTHREAD name can highlight the
> fact that it is the kthread initiated by ipvs that is being controlled.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>

Oh I see you're handling a few concerns here. But it's too late, the previous
patch broke bisection.

> ---
>  include/net/ip_vs.h            | 20 ++++++++++++++++----
>  net/netfilter/ipvs/ip_vs_ctl.c | 13 ++++++++-----
>  2 files changed, 24 insertions(+), 9 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 72d325c81313..7bda92fd3fe6 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1411,7 +1411,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>  	return ipvs->sysctl_run_estimation;
>  }
>  
> -static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
> +static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
>  {
>  	if (ipvs->est_cpulist_valid)
>  		return ipvs->sysctl_est_cpulist;
> @@ -1529,7 +1529,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>  	return 1;
>  }
>  
> -static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
> +static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
>  {
>  	return housekeeping_cpumask(HK_TYPE_KTHREAD);
>  }
> @@ -1564,6 +1564,18 @@ static inline int sysctl_svc_lfactor(struct netns_ipvs *ipvs)
>  	return READ_ONCE(ipvs->sysctl_svc_lfactor);
>  }
>  
> +static inline bool sysctl_est_cpulist_empty(struct netns_ipvs *ipvs)
> +{
> +	guard(rcu)();
> +	return cpumask_empty(__sysctl_est_cpulist(ipvs));
> +}
> +
> +static inline unsigned int sysctl_est_cpulist_weight(struct netns_ipvs *ipvs)
> +{
> +	guard(rcu)();
> +	return cpumask_weight(__sysctl_est_cpulist(ipvs));
> +}
> +
>  /* IPVS core functions
>   * (from ip_vs_core.c)
>   */
> @@ -1895,7 +1907,7 @@ static inline void ip_vs_est_stopped_recalc(struct netns_ipvs *ipvs)
>  	/* Stop tasks while cpulist is empty or if disabled with flag */
>  	ipvs->est_stopped = !sysctl_run_estimation(ipvs) ||
>  			    (ipvs->est_cpulist_valid &&
> -			     cpumask_empty(sysctl_est_cpulist(ipvs)));
> +			     sysctl_est_cpulist_empty(ipvs));

It's not needed, if ipvs->est_cpulist_valid, sysctl_est_cpulist() doesn't
refer to housekeeping.

>  #endif
>  }
>  
> @@ -1911,7 +1923,7 @@ static inline bool ip_vs_est_stopped(struct netns_ipvs *ipvs)
>  static inline int ip_vs_est_max_threads(struct netns_ipvs *ipvs)
>  {
>  	unsigned int limit = IPVS_EST_CPU_KTHREADS *
> -			     cpumask_weight(sysctl_est_cpulist(ipvs));
> +			     sysctl_est_cpulist_weight(ipvs);

That probably works for callers ip_vs_start_estimator().

But this is not handling the core issue that related kthreads should be updated,
as is done in ipvs_proc_est_cpumask_set(), when HK_TYPE_DOMAIN mask changes.

>  
>  	return max(1U, limit);
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 032425025d88..e253a1ceef48 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2338,11 +2338,14 @@ static int ipvs_proc_est_cpumask_get(const struct ctl_table *table,
>  
>  	mutex_lock(&ipvs->est_mutex);
>  
> -	if (ipvs->est_cpulist_valid)
> -		mask = *valp;
> -	else
> -		mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
> -	ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
> +	/* HK_TYPE_KTHREAD cpumask needs RCU protection */
> +	scoped_guard(rcu) {
> +		if (ipvs->est_cpulist_valid)
> +			mask = *valp;
> +		else
> +			mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
> +		ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
> +	}

And that works.

Thanks.

>  
>  	mutex_unlock(&ipvs->est_mutex);
>  
> -- 
> 2.53.0
> 

-- 
Frederic Weisbecker
SUSE Labs
