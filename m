Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4119943B3F8;
	Thu, 30 Jul 2026 14:44:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785422667; cv=none; b=T5BZBHQgEisD/ZjNI9+x21d4oRHECRWkq60p8HJ3LrfzebTNGHZ/tWPHfTe+Owk697iA1JZwPaN3K1aoDfjeM/STJSw35hHHMfePa7vY7rBK0JLSpvr4xlTDyMjZU3PPV7Z64o/D/Yguux8bIRZV3f/w4V+DRHndwEqfQ6FMYto=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785422667; c=relaxed/simple;
	bh=W+/aSC2R5cXk5kZ6lsCYIa4lo31PvrlkMjSR9YZsjMw=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=fP/gWznPQvzs1wzliY2Jnlc91GGZxjJm0wBNK4iEQCLptvs+w8yiUBRGj4zpKOPNUzB6DYFVVPEwwGTTgY4cflW9mr/vY8OOilOogVpyY3HFCBbANpWlfJ31TbudEa6L8ogBfoyJ8Nl1ClO484Tfo0QoBPvZbTB1BJkc3JnPJuw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=mjnqzjnj; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="mjnqzjnj"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id B752A216C7;
	Thu, 30 Jul 2026 17:44:10 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=MgmBiVqiJsGJ4+M4YUx3zL6CGfPnHRbPLAt31VVBsec=; b=mjnqzjnj5lbg
	1VFh4C+4Y0a+LlkD9TlmQK+e9Y44vCscY9/D7Wru/mCGh/SyTnTBxZN6WwLNaIDR
	5hGGPJ+mtHEkfWI0/A1b3a+3D0HNorenRv03RPNMRGkyKJ0urHqDsUK+/S/WdG4E
	BdZzgu0tkeJwfo+P3HaF3UqzVPNgBpgqRjpPNXs3I4Upx4me60YS6QZQPfbx+a16
	fFdP4nq9A4zx+/5ML0A9EqAIrphlYQ7Jwj5h5BUOJHCbFTcR+3xVFVtSw/HJ/90g
	p1mfaLldurLw9pCffa3Kw6WlO+z69G9CO48UD1wBM0S2NKCuL+avvpMNpaBt9GNm
	+1Nhid6YHaIZwWuoXd81ifFdEujDltmQBjiXhomXhtSlijW4TLf6hEsYNyz0hQQG
	3TW5pATN0VCGCXZqzqjQSbWh7s277MkFj9DQm7MHp6DK8aPcMAJdRhYUmUZWIx8Q
	5SFUxbwm+6U+DHVOKPF1giAQyTYKjOewHw83EYldXfIvvxmnVM2F/vmmvVCSeRbZ
	mpi0/Tm8whj8uMjHoRwhJkOCIB+FakNorcXlaJ3LQBou+4JpnOU97jnS6qX8tJSv
	3kGiwxPqIJAesL3KdsPrZQzcPMa1STFyup6POTEX7SFD96uqEawXPWlTX67nWcQB
	3zcWc21NCvybTcRfj4JmWBWNi4cPWD0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Jul 2026 17:44:10 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A9DAD602E8;
	Thu, 30 Jul 2026 17:44:11 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66UEi4gR065900;
	Thu, 30 Jul 2026 17:44:04 +0300
Date: Thu, 30 Jul 2026 17:44:04 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zhiling Zou <zhilinz@nebusec.ai>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, horms@verge.net.au, pablo@netfilter.org,
        fw@strlen.de, phil@nwl.cc, davem@davemloft.net, edumazet@google.com,
        kuba@kernel.org, pabeni@redhat.com, jwiesner@suse.de, vega@nebusec.ai
Subject: Re: [PATCH nf v3 1/1] ipvs: stop estimator after disabled calc
 phase
In-Reply-To: <154d1474f8c36c34d9b86c7ca1b33d73f5435241.1785289432.git.zhilinz@nebusec.ai>
Message-ID: <37114c4f-3441-41ab-6a13-bfadfb80eda3@ssi.bg>
References: <154d1474f8c36c34d9b86c7ca1b33d73f5435241.1785289432.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 29 Jul 2026, Zhiling Zou wrote:

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
> Estimator kthreads can now self-exit before teardown or reload stops
> kd->task. Keep an extra task reference after creation and release it
> with kthread_stop_put(), so kd->task remains valid until the stop paths
> consume that reference.
> 
> Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
> Cc: stable@vger.kernel.org
> Reported-by: Vega <vega@nebusec.ai>
> Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> changes in v3:
> - Keep an extra task_struct reference for estimator kthreads and
>   release it with kthread_stop_put(), as suggested by Julian
>   Anastasov, so self-exiting kthreads do not leave kd->task dangling.
> - v2 Link: https://lore.kernel.org/all/03a7ee4873f9dfc51add97df5b67bf0b0d793dbe.1785211268.git.zhilinz@nebusec.ai
> 
> changes in v2:
> - Exit the estimator kthread after the calculation phase if IPVS
>   has been disabled or the kthread is stopping, as suggested by
>   Julian Anastasov.
> - Drop the later enqueue and drain guards from v1.
> - v1 Link: https://lore.kernel.org/all/6359e0031f0ee7cc969bae3483308de362d3c709.1784878022.git.zhilinz@nebusec.ai
> 
>  net/netfilter/ipvs/ip_vs_est.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index ab09f51829512..05a216a47b45e 100644
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
> @@ -270,6 +273,7 @@ int ip_vs_est_kthread_start(struct netns_ipvs *ipvs,
>  		kd->task = NULL;
>  		goto out;
>  	}
> +	get_task_struct(kd->task);
>  
>  	set_user_nice(kd->task, sysctl_est_nice(ipvs));
>  	if (sysctl_est_preferred_cpulist(ipvs))
> @@ -286,7 +290,7 @@ void ip_vs_est_kthread_stop(struct ip_vs_est_kt_data *kd)
>  {
>  	if (kd->task) {
>  		pr_info("stopping estimator thread %d...\n", kd->id);
> -		kthread_stop(kd->task);
> +		kthread_stop_put(kd->task);
>  		kd->task = NULL;
>  	}
>  }
> @@ -526,7 +530,7 @@ static void ip_vs_est_kthread_destroy(struct ip_vs_est_kt_data *kd)
>  	if (kd) {
>  		if (kd->task) {
>  			pr_info("stop unused estimator thread %d...\n", kd->id);
> -			kthread_stop(kd->task);
> +			kthread_stop_put(kd->task);
>  		}
>  		ip_vs_stats_free(kd->calc_stats);
>  		kfree(kd);
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

