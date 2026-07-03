Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C62D02E65D;
	Fri,  3 Jul 2026 17:50:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783101027; cv=none; b=XEvD7hj/iTGeNY4nogT85RQPIW9praHVqext8V1N0GYcilzr0KbSrOLyuAQNIZZUUL+oKYWOT8JqLkAs5L+Z86CrszZFo+fYPLPB+YEpKOFuBB8JV2I9ZPF6k0WfuXUEAjfD/ZbEAQGhKOrkNnVuAJx5NssAKXxARlEUjI5lMyU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783101027; c=relaxed/simple;
	bh=XNY10VlSAsNcW1UZpUqX2cHR5kCif4Qb1vkXpzOQomw=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=tqQmtQ4BThYexS2KFNkjJwmdPyfGIS6pST25EclVq/pDE7iqlBubEtSA6ZpmNi75/FXsrt1Eu+GXTN+j9kDZsMMWU7icVTuQpz9tk0QnSTY8Ob9kfXXDrngzPRKlyD3sOwxEpYe3lHrk6y3CMY6CIZ/et2miPurLsMfZ+Zc/7KY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=jxTfnnh7; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="jxTfnnh7"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C0CD021062;
	Fri, 03 Jul 2026 20:50:11 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=WzUixPFbnBAwfBwijwe0GaTTubztee6+Drj+wooRJdA=; b=jxTfnnh76xjr
	aTxkpERuVP4FjWj1xGm00BrtDKlzMep6sHu6bqyQhN68SiZIbjXB9FRCsbXZMV5u
	KfMsydBNhmVfvJd3YGCX059Em7krOwEf6Y6azhDxYkDPXvrKDjDlC/saeEUp0e+n
	UIbNpEb0bD1iRHSntCJqQE1PFd1WR/ENULNfRSRwazYZ9BjTU6IvwLVadX/qHEB8
	Ojy/Ero2/KI+T+pHLoseW41HN5LWUHkqWR1RTeKhgp/9zjLUMo0vQON0aUtH8I/b
	3WbW+K2SbMv1zZYf6bR7fbPBmwf8H8pic/MrYPOJn+hdAEadA4/iVDQyj0wepoPn
	KkL0ma7gsWTJGmlubUxgAukSO/fLI9Zg1cDn+n9Fu71mzTwPSVcveCExSZnGuJPE
	NOfkFsbEQ7IotvNb+jSK1cgWFSuAT221DgGJYxtuKLpGjpeJ8DSl0B8ZI3QOgu8O
	nHOILMsMK2QmGpwjiMG3SDLiaywLJXP4FNFoUlBi7XWdT0LcsUj6RoLGwoZHWMfY
	rhPfr/s4F5+r3vuraBBlG9oz91XDJZO8rjrl8jIRnRYNlpGeG2sbQHmFbYIz5gQV
	of1zKd5o1CCW156HBn+I5MwTA3xGUDtI4TykSRpL0awUlt1boSHbiB7Q9qvdrskh
	xh7BG7Zy9hVupybyGLxriD7ayxiHSrY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 03 Jul 2026 20:50:11 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 680506008D;
	Fri,  3 Jul 2026 20:50:11 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 663HntcL065717;
	Fri, 3 Jul 2026 20:49:56 +0300
Date: Fri, 3 Jul 2026 20:49:55 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Ismael Luceno <iluceno@suse.de>
cc: linux-kernel@vger.kernel.org, Marco Crivellari <marco.crivellari@suse.com>,
        Tejun Heo <tj@kernel.org>, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        "open list:IPVS" <netdev@vger.kernel.org>,
        "open list:IPVS" <lvs-devel@vger.kernel.org>,
        "open list:NETFILTER" <netfilter-devel@vger.kernel.org>,
        "open list:NETFILTER" <coreteam@netfilter.org>
Subject: Re: [PATCH v2 nf-next] ipvs: Move defense_work and est_reload_work
 to system_dfl_long_wq
In-Reply-To: <20260702101100.24256-2-iluceno@suse.de>
Message-ID: <c55ca48c-1f38-7f59-1ea8-632177079dcf@ssi.bg>
References: <20260702101100.24256-2-iluceno@suse.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 2 Jul 2026, Ismael Luceno wrote:

> Under synflood conditions binding these handlers to system_long_wq may
> pin them to a saturated CPU.
> 
> We've observed improved throughtput on a DPDK/VPP application with this
> change, which we attribute to the reduced context switching.
> 
> Neither handler has per-CPU data dependencies nor cache locality
> requirements that would prevent this change.
> 
> Signed-off-by: Ismael Luceno <iluceno@suse.de>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> CC: Marco Crivellari <marco.crivellari@suse.com>
> CC: Tejun Heo <tj@kernel.org>
> 
> Changes since v1:
> * Rebased on nf-next
> * Reworded commit message
> 
>  net/netfilter/ipvs/ip_vs_ctl.c | 6 +++---
>  net/netfilter/ipvs/ip_vs_est.c | 2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index bcf40b8c41cf..d7e669efab4d 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -235,7 +235,7 @@ #define DEFENSE_TIMER_PERIOD	1*HZ
>  	update_defense_level(ipvs);
>  	if (atomic_read(&ipvs->dropentry))
>  		ip_vs_random_dropentry(ipvs);
> -	queue_delayed_work(system_long_wq, &ipvs->defense_work,
> +	queue_delayed_work(system_dfl_long_wq, &ipvs->defense_work,
>  			   DEFENSE_TIMER_PERIOD);
>  }
>  #endif
> @@ -290,7 +290,7 @@ #define DEFENSE_TIMER_PERIOD	1*HZ
>  	atomic_set(&ipvs->est_genid_done, genid);
>  
>  	if (repeat)
> -		queue_delayed_work(system_long_wq, &ipvs->est_reload_work,
> +		queue_delayed_work(system_dfl_long_wq, &ipvs->est_reload_work,
>  				   delay);
>  
>  unlock:
> @@ -5126,7 +5126,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  		goto err;
>  
>  	/* Schedule defense work */
> -	queue_delayed_work(system_long_wq, &ipvs->defense_work,
> +	queue_delayed_work(system_dfl_long_wq, &ipvs->defense_work,
>  			   DEFENSE_TIMER_PERIOD);
>  
>  	return 0;
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index ab09f5182951..78964aa861e9 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -243,7 +243,7 @@ #define pr_fmt(fmt) "IPVS: " fmt
>  	/* Bump the kthread configuration genid if stopping is requested */
>  	if (restart)
>  		atomic_inc(&ipvs->est_genid);
> -	queue_delayed_work(system_long_wq, &ipvs->est_reload_work, 0);
> +	queue_delayed_work(system_dfl_long_wq, &ipvs->est_reload_work, 0);
>  }
>  
>  /* Start kthread task with current configuration */

Regards

--
Julian Anastasov <ja@ssi.bg>

