Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B83837FF60;
	Tue, 21 Apr 2026 10:35:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776767745; cv=none; b=NZS3xDZEvXM16Q9hq7tPEe3BzeRQucS0E1F46U+R45hJWChHeKCRbZFk16bhxrk0gYWZb5KvnHjYxoxPLRGQlu8r4WdyvvuiSu3I5xyrGS2GFSrH8hGYI19cou/ZrwuupMauFH998kZgO7Kkr23HQbjBctscGD9m4erRoahqkk4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776767745; c=relaxed/simple;
	bh=SFVGvlRu1+a2J1JiFNEEhv3LzRbzb1F3f/NQXWu1S+Q=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=gxeTvnbQ2oJArZntIOZlb/TGia8HMhKZs+aDSzg/q/Nu7+IUnEJiVSz5mZNWteiULn9A6Apq2ZRJHRpLSTyJEE155UtiepDIm9BheDW8yW4x9UzK54adnpQm64W1VUptwCi1+VhQg3bA3iw7DdD04uAo69/MhTFkCm78cIIUZL4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=aWEtfu05; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="aWEtfu05"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E68AD210D7;
	Tue, 21 Apr 2026 13:35:37 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=VggmHWZBy2TpVFmdo5qcHAI/a4r6mPtbzHzgYEUpatA=; b=aWEtfu05j+yf
	RuyPixbAMfZFd202vdXvhOjlbngKXH7nJUbV0f2dCEPdAGBq4qUKfvBpaSkDlC7p
	3rCcuUMw5TbYQxj95CVI11++1ztcjG93DiQ6N/reZnfHXsY1nlsrZu4M40hX7MFg
	xYO7w+FgbVCml3shsE/TE0iTXNkh044+y3yXkWW99eg3tJlc1M/f99hECSbRYEQt
	CD41SgWvSEbP+cg+Vng1yvw+HgZ8HweZ0Vsq6A1COYvSOohcm2azMHI7aAyW+UE2
	Sze7dYf85gxAu0fVm2dsP9fpD0x0yD1Jk3o3+ID2oocrNCljzAPvYhDGH3fatEOX
	dfyWj7d0ASy44kUNQ0Og2UNicLFDxz3mzas5nGQwRmCDu+c8P6XVMOM7LbmiVZGx
	T0pauxdM6MLqSH0dX5zkTZC0bP+kUbQaupZNxI27cYtDz8MjkpOUamAib+HaU/x+
	EdtlNWM7iXU3u0ff1FesfzUSH0SxF6x5F5kFXJ3GQNnrdJbqU8XJPmX1WuW/1TTc
	GbuCt+MuKnm4R7LJ9ntcKNwO62GfxJQhnGUOL4sDRmezR59cFPi96lMYDIVQXI/y
	ESH5pvhiIvNizMb4QvfVZpncewn/lB/KG/6pPiYs9dr6b38jLgudMVk6D1Ontjxb
	PhL+ripcVk06ctFTEZczGwvBhd3/WCA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 21 Apr 2026 13:35:36 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1A44A60A90;
	Tue, 21 Apr 2026 13:35:35 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63LAZYBs024962;
	Tue, 21 Apr 2026 13:35:34 +0300
Date: Tue, 21 Apr 2026 13:35:34 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH net] ipvs: fix races around est_mutex and est_cpulist
In-Reply-To: <20260420171308.87192-1-ja@ssi.bg>
Message-ID: <42f9cfbf-8189-2bba-0541-acf7a3536968@ssi.bg>
References: <20260420171308.87192-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 20 Apr 2026, Julian Anastasov wrote:

> Sashiko reports for races and possible crash around
> the usage of est_cpulist_valid and sysctl_est_cpulist.
> The problem is that we do not lock est_mutex in some
> places which can lead to wrong write ordering and
> as result problems when calling cpumask_weight()
> and cpumask_empty().
> 
> Fix them by moving the est_max_threads read/write under
> locked est_mutex. Do the same for one ip_vs_est_reload_start()
> call to protect the cpumask_empty() usage of sysctl_est_cpulist.
> 
> Link: https://sashiko.dev/#/patchset/20260331165015.2777765-1-longman%40redhat.com
> Fixes: f0be83d54217 ("ipvs: add est_cpulist and est_nice sysctl vars")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	According to Sashiko, this patch needs more
work, I'll send new version when I'm ready...

pw-bot: changes-requested


> ---
> 
>  Note that this patch complements v2 of patchset from 31-MAR-26
>  "ipvs: Fix incorrect use of HK_TYPE_KTHREAD housekeeping cpumask"
>  and can be applied before it to avoid the bad AI reviews:
> 
>  https://lore.kernel.org/all/20260331165015.2777765-1-longman@redhat.com/
> 
>  net/netfilter/ipvs/ip_vs_ctl.c |  5 +++++
>  net/netfilter/ipvs/ip_vs_est.c | 22 +++++++++++++++-------
>  2 files changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index caec516856e9..8778e174ef56 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1812,11 +1812,16 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  	*svc_p = svc;
>  
>  	if (!READ_ONCE(ipvs->enable)) {
> +		mutex_lock(&ipvs->est_mutex);
> +
>  		/* Now there is a service - full throttle */
>  		WRITE_ONCE(ipvs->enable, 1);
>  
> +		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
> +
>  		/* Start estimation for first time */
>  		ip_vs_est_reload_start(ipvs);
> +		mutex_unlock(&ipvs->est_mutex);
>  	}
>  
>  	return 0;
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index 433ba3cab58c..6c9981d5611e 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -68,6 +68,10 @@
>      and the limit of estimators per kthread
>    - est_add_ktid: ktid where to add new ests, can point to empty slot where
>      we should add kt data
> +  - data protected by service_mutex: est_temp_list, est_add_ktid
> +  - data protected by est_mutex: est_kt_count, est_kt_arr, est_max_threads,
> +    sysctl_est_cpulist, est_cpulist_valid, sysctl_est_nice, est_stopped,
> +    sysctl_run_estimation
>   */
>  
>  static struct lock_class_key __ipvs_est_key;
> @@ -229,6 +233,8 @@ static int ip_vs_estimation_kthread(void *data)
>  /* Schedule stop/start for kthread tasks */
>  void ip_vs_est_reload_start(struct netns_ipvs *ipvs)
>  {
> +	lockdep_assert_held(&ipvs->est_mutex);
> +
>  	/* Ignore reloads before first service is added */
>  	if (!READ_ONCE(ipvs->enable))
>  		return;
> @@ -304,12 +310,17 @@ static int ip_vs_est_add_kthread(struct netns_ipvs *ipvs)
>  	void *arr = NULL;
>  	int i;
>  
> -	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads &&
> -	    READ_ONCE(ipvs->enable) && ipvs->est_max_threads)
> -		return -EINVAL;
> -
>  	mutex_lock(&ipvs->est_mutex);
>  
> +	/* Allow kt 0 data to be created before the services are added
> +	 * and limit the kthreads when services are present.
> +	 */
> +	if ((unsigned long)ipvs->est_kt_count >= ipvs->est_max_threads &&
> +	    READ_ONCE(ipvs->enable) && ipvs->est_max_threads) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
>  	for (i = 0; i < id; i++) {
>  		if (!ipvs->est_kt_arr[i])
>  			break;
> @@ -485,9 +496,6 @@ int ip_vs_start_estimator(struct netns_ipvs *ipvs, struct ip_vs_stats *stats)
>  	struct ip_vs_estimator *est = &stats->est;
>  	int ret;
>  
> -	if (!ipvs->est_max_threads && READ_ONCE(ipvs->enable))
> -		ipvs->est_max_threads = ip_vs_est_max_threads(ipvs);
> -
>  	est->ktid = -1;
>  	est->ktrow = IPVS_EST_NTICKS - 1;	/* Initial delay */
>  
> -- 
> 2.53.0

Regards

--
Julian Anastasov <ja@ssi.bg>

