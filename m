Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91AE228506A;
	Thu, 26 Mar 2026 08:33:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774513992; cv=none; b=Y1uASaZ1JYQcPrqDCANoxiiTj+OTJQsFfHO/kuM8Hghszr/YUtuRtD4LP1s4t1Oefqn81G08s7Nk3VEvpnFVPlAHtONjtnMGUWLvJIWT/LXDQUl5W4enVTtccHn4d2T0LK6sC87vHxvrx1vfgQc5vYnaVm3FGs+ZDwvX0TODHP4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774513992; c=relaxed/simple;
	bh=zFJihH7S9d8lhKpyC2+Bj5Ej46SSk23yPU+CPIQQYUE=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=m0SB2BY4IzLQ0StuDexTp7OKDGiu2rom8YsBzYI3LJD4OO+uD816t4ssoXdx1t7TxwlTzcf0utZY8fnV2S735ABF1pw8o62tfPdDDhZOoDxnIj+8Tjc8iXWbwsWWLkepiLrWJHhvwsnVtnx93xQqui4V8scKpEkaHRS5F2VQam8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=6x1g62Px; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="6x1g62Px"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id AE496217FB;
	Thu, 26 Mar 2026 10:32:58 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=6I+plcb8eOm5Rjsl7JTC/dDFJZWTUZs1pJqBClmoxnY=; b=6x1g62PxtaJ5
	6OLKZjPRJgm6jTTJcMJpNEZp4NzgLpDi/qV2pNgBFuOznW/AXHkxEdUa6sf1sIv4
	j0RU6iPROIk2MwNfmayVyrqRxxMFSJd29M0fhX9omsUmSle64/AmRTKYOgG76cv2
	FcQJ0TUEJACdv37EanZ4cTqxNK8Hi52eoHjc5dynIDSOzd7nPugIhPttDol9WBCw
	fjQXBy+qAFDI7oe4t29m3NUgoWODi5OmWcqaW7ybLweEgY8eTEdWLEs9ZwvUiafW
	9WXg3Y2jiobhwDJipqXguKzHahKZmLWztcNGUHl+nVSltJ0umq2KLdUL+Jd3pQp7
	ReOnt/hkBoartRKRdqb7mJn/zy3DLXgmBal3yaUqlGESMeBkLUu4ySImkqm7SD7p
	awFjygPVOuWNmj72BjyMhluRcnkW+Vs3RdxQXnylhjPp1vmp2c/orNkdp4J7kkAp
	YPkERJu/BK8R83g/HMlVTV9RSUnfGD0njkq1XqRctNXVM9J2A95kgIAR74B3Lt3Q
	ZftPuqwMGEOyQq1ZitAkYTmjCHIII9Gn62tsGQFY9ntbiMI7AMlCjSHmsX0gB7/5
	0R9blgeQ1Up3YlC6eXmY2iK/GgVHrIpKTI/zQUHU/y56xkkujVY7QehFAU3eXeSN
	GaI7bb9svpczZ5LSCr/U6f6iEhqTUGE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 26 Mar 2026 10:32:57 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1088560A78;
	Thu, 26 Mar 2026 10:32:54 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 62Q8WjID021116;
	Thu, 26 Mar 2026 10:32:45 +0200
Date: Thu, 26 Mar 2026 10:32:45 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Waiman Long <longman@redhat.com>
cc: Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>,
        Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        Frederic Weisbecker <frederic@kernel.org>,
        Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, sheviks <sheviks@gmail.com>
Subject: Re: [PATCH 2/2] ipvs: Guard access of HK_TYPE_KTHREAD cpumask with
 RCU
In-Reply-To: <20260324151827.2006656-3-longman@redhat.com>
Message-ID: <6b8f1536-444c-e75a-c4b3-d5cbe7c1786e@ssi.bg>
References: <20260324151827.2006656-1-longman@redhat.com> <20260324151827.2006656-3-longman@redhat.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 24 Mar 2026, Waiman Long wrote:

> The ip_vs_ctl.c file and the associated ip_vs.h file are the only places
> in the kernel where HK_TYPE_KTHREAD cpumask is being retrieved and used.
> Now that HK_TYPE_KTHREAD/HK_TYPE_DOMAIN cpumask can be changed at run
> time. We need to use RCU to guard access to this cpumask to avoid a
> potential UAF problem as the returned cpumask may be freed before it
> is being used.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  include/net/ip_vs.h            | 20 ++++++++++++++++----
>  net/netfilter/ipvs/ip_vs_ctl.c | 13 ++++++++-----
>  2 files changed, 24 insertions(+), 9 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 29a36709e7f3..17c85a575ef4 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1155,7 +1155,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>  	return ipvs->sysctl_run_estimation;
>  }
>  
> -static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
> +static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
>  {
>  	if (ipvs->est_cpulist_valid)
>  		return ipvs->sysctl_est_cpulist;
> @@ -1273,7 +1273,7 @@ static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
>  	return 1;
>  }
>  
> -static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
> +static inline const struct cpumask *__sysctl_est_cpulist(struct netns_ipvs *ipvs)
>  {
>  	return housekeeping_cpumask(HK_TYPE_KTHREAD);
>  }
> @@ -1290,6 +1290,18 @@ static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
>  
>  #endif
>  

	May be there is little fuzz here, due to the recent
changes in the nf-next tree. If this is a bugfix due to the
missing RCU protection, may be you should add Fixes line too
and use the nf tree. Probably, there will be fuzz/collisions with
the changes in the nf-next tree...

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
> @@ -1604,7 +1616,7 @@ static inline void ip_vs_est_stopped_recalc(struct netns_ipvs *ipvs)
>  	/* Stop tasks while cpulist is empty or if disabled with flag */
>  	ipvs->est_stopped = !sysctl_run_estimation(ipvs) ||
>  			    (ipvs->est_cpulist_valid &&
> -			     cpumask_empty(sysctl_est_cpulist(ipvs)));
> +			     sysctl_est_cpulist_empty(ipvs));
>  #endif
>  }
>  
> @@ -1620,7 +1632,7 @@ static inline bool ip_vs_est_stopped(struct netns_ipvs *ipvs)
>  static inline int ip_vs_est_max_threads(struct netns_ipvs *ipvs)
>  {
>  	unsigned int limit = IPVS_EST_CPU_KTHREADS *
> -			     cpumask_weight(sysctl_est_cpulist(ipvs));
> +			     sysctl_est_cpulist_weight(ipvs);
>  
>  	return max(1U, limit);
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 35642de2a0fe..f38a2e2a9dc5 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1973,11 +1973,14 @@ static int ipvs_proc_est_cpumask_get(const struct ctl_table *table,
>  
>  	mutex_lock(&ipvs->est_mutex);
>  
> -	if (ipvs->est_cpulist_valid)
> -		mask = *valp;
> -	else
> -		mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
> -	ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
> +	/* HK_TYPE_KTHREAD cpumask needs RCU protection */

	Can we switch IPVS to use HK_TYPE_DOMAIN? The initial
intention was to follow the code in kthread.c. Then you can 
reconsider if HK_TYPE_KTHREAD should be alias to HK_TYPE_DOMAIN,
may be not if there are no other users...

> +	scoped_guard(rcu) {
> +		if (ipvs->est_cpulist_valid)
> +			mask = *valp;
> +		else
> +			mask = (struct cpumask *)housekeeping_cpumask(HK_TYPE_KTHREAD);
> +		ret = scnprintf(buffer, size, "%*pbl\n", cpumask_pr_args(mask));
> +	}
>  
>  	mutex_unlock(&ipvs->est_mutex);
>  
> -- 
> 2.53.0

Regards

--
Julian Anastasov <ja@ssi.bg>

