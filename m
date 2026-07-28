Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C41F33D76;
	Tue, 28 Jul 2026 13:13:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785244408; cv=none; b=PWzzsoC/HRFHHfodXox/2FOA1kpQedhRDqWCaT/1AnbfnssnSuWfxCBpgiGy8n87vCt69G/cG8cEToPluJNdgWYH7gXPIXSwk4lsz4v5N6AnGpzWD1YEipw1EwRqgeBg2E6f32OX60CguQnhjhNtaxXT29T8Y4MKvI+mJ54QqL4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785244408; c=relaxed/simple;
	bh=niNG0rCQ3dlq8WFryVVNSBzxc+fvvqMvo3XYtl1MkH8=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=rsZqmRfqEASQI4ExEOqlf8Ki0+fm5ymwbgfEXNRHES9VJ1Z36GRCd4yBMDcSaay28Tx075wWJ7KA+WMhK3yeqAGA+U+53CYOuE0a9PfJKk1JEtutcl7xLkVS1jBKq4LNK2zBuEo8uhQ+eOOquE3hoqwqQatV00qKhYKF0QzZHTM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kkdXHENv; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kkdXHENv"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2748421312;
	Tue, 28 Jul 2026 16:04:56 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=v1tcBHoKObLs7h8JCBzGeAcPF0N5ESwmxnlfaoIjupw=; b=kkdXHENv2ZoP
	yTvuVWWvQ/zxA1uBL/fu2MJLbwRig+n+1R8JfpZe/t7LDPZDw8id5kEk52/6CnqO
	fHqYJy02ucWQ724NGvh5+GwrU1qoIdefw5sb4urWCBypiNd+FYQGiEY206AnNgpV
	fSUm7itVj0mY1JaL6vjLDMo+/1a/HTfyksMdotVCeNVk82niF0FOwDj+OIHsupMK
	Uahw4qcTx41otzssYzdQkQqzHKOJhD5wI31MNXVfeIiWMB8qs9ChgQlniQlLxiVk
	04BkjFaUQpgGgAQNqJ3GZ6LmdxlbUZKsE040j1e32z0hS2X4Y+CpJVujln0U3zdD
	a79grM4KqOA4f/2vlRxRT8iiVW7M76sFgt0oIUxPaPdQ9aoqctpoaDIr221tavg9
	pPomCs79zUj7vncfXEblhoG6SnWtIDAd+AwBhlPFE/Pcy2C8fkKYopQY09EmPzPN
	vGcqU6u3O47HvDV9Iq/GVldloaKjpern3z+Qx5N0YeNa8LcDIcZy9bQe6X0Kurxv
	xx9X/XmVVYQTC/GVrr5K8+FRXUYrEK8TpNStqi5bRWYO5T48gbDo72sn7fKaN98k
	Cdtb6qUt7wFERM/UT5OEF2NARiIAngqMX8hwDilYusu3/ALv3NRwNbEZINpHsGA6
	oxVpnl7b/e+02nrzxVKJvdzswa2nYsw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 28 Jul 2026 16:04:56 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B0AF560B9D;
	Tue, 28 Jul 2026 16:04:56 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66SD4o8C021690;
	Tue, 28 Jul 2026 16:04:50 +0300
Date: Tue, 28 Jul 2026 16:04:50 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zhiling Zou <zhilinz@nebusec.ai>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        jwiesner@suse.de, vega@nebusec.ai
Subject: Re: [PATCH nf v2 1/1] ipvs: stop estimator after disabled calc
 phase
In-Reply-To: <03a7ee4873f9dfc51add97df5b67bf0b0d793dbe.1785211268.git.zhilinz@nebusec.ai>
Message-ID: <88204013-1cbb-faa4-289b-4038cf5b52c4@ssi.bg>
References: <03a7ee4873f9dfc51add97df5b67bf0b0d793dbe.1785211268.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 28 Jul 2026, Zhiling Zou wrote:

> IPVS estimator kthread 0 starts with zeroed chain and tick limits until
> its initial calculation phase completes. If network namespace teardown
> clears ipvs->enable during that phase, ip_vs_est_calc_phase() can return
> without installing positive limits.
> 
> The kthread can then continue into its main loop and drain
> est_temp_list with zero chain_max, tick_max and est_max_count values.
> Each enqueue consumes one available tick row, but est_count never
> reaches the zero est_max_count value. After all rows are consumed, the
> row lookup returns IPVS_EST_NTICKS and ip_vs_enqueue_estimator() writes
> past the ticks and tick_len arrays.
> 
> Exit kthread 0 after the calculation phase if the kthread is stopping or
> IPVS has been disabled. That keeps temporary estimators from being
> drained after the limits failed to initialize.
> 
> Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
> Cc: stable@vger.kernel.org
> Reported-by: Vega <vega@nebusec.ai>
> Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
> ---
> changes in v2:
> - Exit the estimator kthread after the calculation phase if IPVS
>   has been disabled or the kthread is stopping, as suggested by
>   Julian Anastasov.
> - Drop the later enqueue and drain guards from v1.
> - v1 Link: https://lore.kernel.org/all/6359e0031f0ee7cc969bae3483308de362d3c709.1784878022.git.zhilinz@nebusec.ai
> 
>  net/netfilter/ipvs/ip_vs_est.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index ab09f51829512..86d20f19fe317 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -191,8 +191,11 @@ static int ip_vs_estimation_kthread(void *data)
>  		}
>  
>  		/* kthread 0 will handle the calc phase */
> -		if (ipvs->est_calc_phase)
> +		if (ipvs->est_calc_phase) {
>  			ip_vs_est_calc_phase(ipvs);
> +			if (kthread_should_stop() || !READ_ONCE(ipvs->enable))
> +				return 0;
> +		}
>  	}
>  
>  	while (1) {
> -- 
> 2.43.0

	After the comments from Sashiko:

https://sashiko.dev/#/patchset/03a7ee4873f9dfc51add97df5b67bf0b0d793dbe.1785211268.git.zhilinz%40nebusec.ai

	we have two options:

1. don't try to exit early by checking ipvs->enable in
ip_vs_est_calc_limits, ip_vs_est_calc_phase and now in
ip_vs_estimation_kthread

2. As ip_vs_estimation_kthread() can exit if ipvs->est_chain_max
is 0 for id > 0, we can call:

get_task_struct(kd->task);
after kthread_create() in ip_vs_est_kthread_start() and
then to use kthread_stop_put() instead of kthread_stop()
everywhere in ip_vs_est.c

	May be we should go with option 2?

Regards

--
Julian Anastasov <ja@ssi.bg>

