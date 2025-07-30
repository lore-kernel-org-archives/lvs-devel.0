Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C430825291C;
	Wed, 30 Jul 2025 10:35:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1753871711; cv=none; b=gMoDSYC8JT1Lya/kr7ZVqQV2WyB4DRHJDAovMUx98Zh3Hzp++nhV+3X5LoprFVSMzO+NTdYBfscueiCWJr7P/STISVq8AN+aSUBIh0uIsGJI1LAsbKur8wFtOAbQsFA3Zs6bj4K3G/RFAee36S1QcLOfj/lc2z+pJhA3vRFHSNM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1753871711; c=relaxed/simple;
	bh=VCDnaWwQb4IAWf4f+Mw7mY5/oXqtwhIoiFyzW/Is5/w=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=QuzOFczZD4rt6Zbgu0v2xV4Yh6vmQkAgt/JPsTVPNhH7zBR1Imo8YpWpj2RFUeV6x1178DDmEFrvqujlTOpczwQd7bHyrlzMbjPK7/Z8doPDCBysVak/jm3x8LGUDJVRnUIoGNYA+ldOcakEQW5G04xxNuHUOTZOqAeRYKQJDuE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kmEFE8z6; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kmEFE8z6"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CA5FD23FB2;
	Wed, 30 Jul 2025 13:28:32 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=g1Z644tULtzZVidxSZOSdrcdRORvDM8i8A0Fz0op/zY=; b=kmEFE8z6yVyT
	VXkPRtMg/Gi7DjbDcK8+jQTCLGBQvLJMsMA92xpS3N73gcwTn/1VK6++r+YyEXCd
	Zs4ru/CfYdOZFa8jTE3DhWtuKecEiHR1bMgBdVdnyeOjnMfjk+ZgmF1MjcfSS0UB
	2rRqrGemEQH6QTAwjg3z0C2ZcJZJPui3VmpHwV2jcUytF+MzdhBrr+GHnuhS2Mw4
	j1scDhXyc5cCtqo8Y/SRGwWsQBG3vms0mJC0ZRl6DLUSXgFDHwGUG8hqLt6JrbQS
	APriImgzogsc3tlMEOn6Lk+G87BWr6F98k3H0taTueIZCa8V+S22lCzDbS16Rifc
	hF8MTB7DPlG8efSfjwAuCJohLw27bNsv1NVvpLNPZwH6uiPU+ZCe/WtHhrvMvjon
	otOQyHcca7g1dnLNTPmK0BJ5eBnbMafLqxbwNz5dPc6MyUSnFj8iSqZWBWAUTlHm
	FdWfRVF42Jf++qad/Hrvc7kfmk0YI1+AjPFmRJQcuETbX/udt2T9pKqg5H1xZCRT
	P++Bp1OFhGwwPk+l9eRf9SHmQZTq+DRgydboMSMsJJN2lsCej9QFtiKgAo9K1+MF
	OhOUMH01vSIC7l8SO4Kup+ye6ovEdTAarpnzgHNdjz7loM4BWPl7LDe0wVqL5o6e
	zD0ia0vvYexecfpQBm/Gbw0ZvYN1hvM=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 30 Jul 2025 13:28:31 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7C13D64D5C;
	Wed, 30 Jul 2025 13:28:30 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 56UASGpa011444;
	Wed, 30 Jul 2025 13:28:17 +0300
Date: Wed, 30 Jul 2025 13:28:16 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Frederic Weisbecker <frederic@kernel.org>
cc: LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsahern@kernel.org>, Simon Horman <horms@verge.net.au>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
Subject: Re: [PATCH v2 net] ipvs: Fix estimator kthreads preferred affinity
In-Reply-To: <20250729122611.247368-1-frederic@kernel.org>
Message-ID: <2d915ef6-46eb-7487-f235-6b6688e68c58@ssi.bg>
References: <20250729122611.247368-1-frederic@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 29 Jul 2025, Frederic Weisbecker wrote:

> The estimator kthreads' affinity are defined by sysctl overwritten
> preferences and applied through a plain call to the scheduler's affinity
> API.
> 
> However since the introduction of managed kthreads preferred affinity,
> such a practice shortcuts the kthreads core code which eventually
> overwrites the target to the default unbound affinity.
> 
> Fix this with using the appropriate kthread's API.
> 
> Fixes: d1a89197589c ("kthread: Default affine kthread to its preferred NUMA node")
> Signed-off-by: Frederic Weisbecker <frederic@kernel.org>

	Looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  include/net/ip_vs.h            | 13 +++++++++++++
>  kernel/kthread.c               |  1 +
>  net/netfilter/ipvs/ip_vs_est.c |  3 ++-
>  3 files changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index ff406ef4fd4a..29a36709e7f3 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1163,6 +1163,14 @@ static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
>  		return housekeeping_cpumask(HK_TYPE_KTHREAD);
>  }
>  
> +static inline const struct cpumask *sysctl_est_preferred_cpulist(struct netns_ipvs *ipvs)
> +{
> +	if (ipvs->est_cpulist_valid)
> +		return ipvs->sysctl_est_cpulist;
> +	else
> +		return NULL;
> +}
> +
>  static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
>  {
>  	return ipvs->sysctl_est_nice;
> @@ -1270,6 +1278,11 @@ static inline const struct cpumask *sysctl_est_cpulist(struct netns_ipvs *ipvs)
>  	return housekeeping_cpumask(HK_TYPE_KTHREAD);
>  }
>  
> +static inline const struct cpumask *sysctl_est_preferred_cpulist(struct netns_ipvs *ipvs)
> +{
> +	return NULL;
> +}
> +
>  static inline int sysctl_est_nice(struct netns_ipvs *ipvs)
>  {
>  	return IPVS_EST_NICE;
> diff --git a/kernel/kthread.c b/kernel/kthread.c
> index 85e29b250107..adf06196b844 100644
> --- a/kernel/kthread.c
> +++ b/kernel/kthread.c
> @@ -899,6 +899,7 @@ int kthread_affine_preferred(struct task_struct *p, const struct cpumask *mask)
>  
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(kthread_affine_preferred);
>  
>  static int kthreads_update_affinity(bool force)
>  {
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index f821ad2e19b3..15049b826732 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -265,7 +265,8 @@ int ip_vs_est_kthread_start(struct netns_ipvs *ipvs,
>  	}
>  
>  	set_user_nice(kd->task, sysctl_est_nice(ipvs));
> -	set_cpus_allowed_ptr(kd->task, sysctl_est_cpulist(ipvs));
> +	if (sysctl_est_preferred_cpulist(ipvs))
> +		kthread_affine_preferred(kd->task, sysctl_est_preferred_cpulist(ipvs));
>  
>  	pr_info("starting estimator thread %d...\n", kd->id);
>  	wake_up_process(kd->task);
> -- 
> 2.48.1

Regards

--
Julian Anastasov <ja@ssi.bg>

