Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 869483C0A0B;
	Mon, 27 Jul 2026 18:48:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785178115; cv=none; b=T15GDn10g9dhkdUCgepkIWIZpYGA2wrzD15OyZVHNo0giQjxwTURso9cPKJQH5Yx3w/2b9/W0bMh9sfg4l4YmvHhR2i/oBzMIsQz1ZZzhkknk9motJJdrTa8JnhUZl2UmcarJaXf6k1TyL+l022e2+suhJGQUcE9WL2fx2XgD1Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785178115; c=relaxed/simple;
	bh=TU5ogNxKbtshG72poaCGTvJyj/fBnjHwuJc7zsJ8k1E=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=JJrNnDu14f7s7+64MtUFKk6GcqZEFN9QIuFqPQb+V6R3CgPM9XjAa4R6lOpAkkYVnD4JLciHTnGIlbzcFsmUu52TSx+mnx4AGAE0CGLcnVo+J/apjjER5L7Jqxpco3/cn7Tzd0wQd9XEe40+u//ytk5Fxp/cTSgmkXUQIQN/HWk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=XFAe7lKH; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="XFAe7lKH"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 39FC421B18;
	Mon, 27 Jul 2026 21:48:21 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Y4wtphUGWUZw1szvKD31Qm7APAEz6kQzgToq30gxKpI=; b=XFAe7lKHSNJL
	QcZZalmMrHGohxzH5XaKzNdBWFI41fLIqCgR3XIA6/lTvhLBCH/+URUThaREHTWV
	MVj2/BZGu6pzcS4gRvCGRDfe8qnbf0bMENLGxSrj/Tp1OMc1Nw+2bcQwSj0JNmeN
	ss3Aspt0Vrw9dqtOqcR9Ch6O8Ry6PddyJ2Howrhq91hPL8FrFp7D9a5ZzP0a/fRn
	xS+OTeQbjfBZBEAnEXUijfcVfpVNLTY3PFHd/TkmT2UrQKOk2eVChW0OPiRHnD94
	M12z+3xpV1EqprS2xRmeOVaHgXpYkmiqLouUjOhFYGVPlefa7VcZIOu5HXpTZWVS
	8eaWEiwAF1nLMPgMutCzelWQbXYr9CHUQmba04E6d6rcANdc6U5tXfz6CjbeTRmD
	e92ytomSqwhNB7lFkwieUNflnNCa0K1u+6k6ZAdIx8nljSQabJxOwwVfwviBBtxD
	cfU4EWrgoFf5pYaIoO7dTlMioYT4CkOejMqbADU2Gi1YS/tjLW+iFbTt3vYVjNkO
	+Q2gC7+zfnhMOEBtniF61/WiSp9Og/FHgi+8LfXXth/mD7LB7ju1vUb+vAze8bZ4
	K8mGu+I9lZLznvfoHlbdyprIK6kAJj9BbdjghMB7LwdFi58ZM63dRvvhFbFX+z/S
	P+Wa1IhHFADTrazubBl/iMPmlM4wkcs=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 27 Jul 2026 21:48:21 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id AD13860A18;
	Mon, 27 Jul 2026 21:48:21 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66RImJcu067357;
	Mon, 27 Jul 2026 21:48:19 +0300
Date: Mon, 27 Jul 2026 21:48:19 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Ren Wei <enjou1224z@gmail.com>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        jwiesner@suse.de, vega@nebusec.ai, zhilinz@nebusec.ai
Subject: Re: [PATCH nf 1/1] ipvs: guard estimator enqueue until limits are
 set
In-Reply-To: <6359e0031f0ee7cc969bae3483308de362d3c709.1784878022.git.zhilinz@nebusec.ai>
Message-ID: <d03e574c-f22b-4060-5fcc-98ae89e6af3a@ssi.bg>
References: <cover.1784878022.git.zhilinz@nebusec.ai> <6359e0031f0ee7cc969bae3483308de362d3c709.1784878022.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 28 Jul 2026, Ren Wei wrote:

> From: Zhiling Zou <zhilinz@nebusec.ai>
> 
> IPVS estimator kthread 0 starts with zeroed chain and tick limits until
> its initial calculation phase completes. If network namespace teardown
> clears ipvs->enable during that phase, ip_vs_est_calc_phase() can return
> without installing positive limits.
> 
> The kthread can then drain est_temp_list with zero chain_max, tick_max
> and est_max_count values. Each enqueue consumes one available tick row,
> but est_count never reaches the zero est_max_count value. After all rows
> are consumed, the row lookup returns IPVS_EST_NTICKS and
> ip_vs_enqueue_estimator() writes past the ticks and tick_len arrays.
> 
> Do not drain temporary estimators before est_chain_max is ready, and
> reject enqueue attempts that do not have valid per-kthread limits or a
> valid tick row.
> 
> Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
> Cc: stable@vger.kernel.org
> Reported-by: Vega <vega@nebusec.ai>
> Assisted-by: Codex:gpt-5.4
> Signed-off-by: Zhiling Zou <zhilinz@nebusec.ai>
> Signed-off-by: Ren Wei <enjou1224z@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_est.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index ab09f51829512..8c8bb2085d1e3 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -196,7 +196,8 @@ static int ip_vs_estimation_kthread(void *data)
>  	}
>  
>  	while (1) {
> -		if (!id && !hlist_empty(&ipvs->est_temp_list))
> +		if (!id && READ_ONCE(ipvs->est_chain_max) &&
> +		    !hlist_empty(&ipvs->est_temp_list))

	Checking it in loop should not be needed. It is determined
only once before the loop. Perhaps, we can detect the problem early:

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index ab09f5182951..86d20f19fe31 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -191,8 +191,11 @@ static int ip_vs_estimation_kthread(void *data)
 		}
 
 		/* kthread 0 will handle the calc phase */
-		if (ipvs->est_calc_phase)
+		if (ipvs->est_calc_phase) {
 			ip_vs_est_calc_phase(ipvs);
+			if (kthread_should_stop() || !READ_ONCE(ipvs->enable))
+				return 0;
+		}
 	}
 
 	while (1) {

	Or even to check ipvs->est_chain_max too but it should not be
needed.


>  			ip_vs_est_drain_temp_list(ipvs);
>  		set_current_state(TASK_IDLE);
>  		if (kthread_should_stop())
> @@ -421,6 +422,11 @@ static int ip_vs_enqueue_estimator(struct netns_ipvs *ipvs,
>  
>  add_est:
>  	ktid = kd->id;
> +	if (!kd->chain_max || !kd->tick_max || !kd->est_max_count) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
>  	/* For small number of estimators prefer to use few ticks,
>  	 * otherwise try to add into the last estimated row.
>  	 * est_row and add_row point after the row we should use
> @@ -450,6 +456,10 @@ static int ip_vs_enqueue_estimator(struct netns_ipvs *ipvs,
>  		if (row >= IPVS_EST_NTICKS)
>  			row = find_first_bit(kd->avail, IPVS_EST_NTICKS);
>  	}
> +	if (row >= IPVS_EST_NTICKS) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
>  
>  	td = rcu_dereference_protected(kd->ticks[row], 1);
>  	if (!td) {
> -- 
> 2.43.0
> 

Regards

--
Julian Anastasov <ja@ssi.bg>

