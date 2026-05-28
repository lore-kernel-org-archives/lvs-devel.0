Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DA943AE189;
	Thu, 28 May 2026 10:20:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779963617; cv=none; b=MOkljpL1nUSGVc7Lb0v8VQShQj3EQfzMBXYT7ilRQ5pFF6XQwWd7KBvVcdWGYaNOdqcNtvmnqvc9hxQpSe/bSf8g0bgyeEXxtRLKXwLEoh9wAFnQ3eSnoWSXuqyY9paTod2gzjdlskXULoG7hCNMKsDRvsMmb6DUvwP7jlZXYiY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779963617; c=relaxed/simple;
	bh=mHitKn8/RQUXFe4XCPU2rzvflbeoc0QV+Fw4MFn0u2k=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=A2/a0wnFnCpx5yK/bbSLEne7948QoI166oG7cHafFWworYJlpQr+snlemUrAafm+SeBGswuG2fIAKjREFGEG0I9KU4yZBgAxykE8PpuQZTjpe6ses5otdJ9YfcDMtQ4UPo+afLP9NzED1NASowmFIxRdeJPDb9Q634ozwHiH1vI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=JPEAt6wW; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="JPEAt6wW"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9AD5821108;
	Thu, 28 May 2026 13:20:03 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2LJERRdyVHL0X2Qcd5pFYIMAKNoFz88LQYmU/lTedPs=; b=JPEAt6wWVjYJ
	M8umsGQZHLVu9idqH9ZEyeh0Vshw/j+9bYKI8QlczJAIU+p8IOfrCBVuWTqSruMG
	FZ5vJOwBUmrdtzwZ0gIJjMxeeG0OK01muiMPg6doDZFczkS/0MF47stOUsClRp0C
	cTGnbEjOE3XYo7L57C/gv2oTRO5KZtItnRilSnM5GiaQT1BDjF7t/I69aZ4/0ikl
	Ra//f4ZveImz6zJMg0iIfmWo4IdkGApTSJIBIOr3X0/PuOHtLalOP76pQG7xFI+L
	i7iZG0/8BK2iIkC48tojmP4KfB0Ggof8qwBowJrekc43TG2VGhX4QH3uErbjA/lc
	UeJHE+Pks4sF96aICSqVr1fGFypY42Q8G9YFzaSrIYuES4xnEAG1XDE42gtu/m0H
	9OSc6BvICtrrR104UEWRoSxssmk/kjhRPdIUtrOrracRKsxP8BFwg8Llsn2d5yK7
	TwFJuPD6iDQWIZyESwrOswHtws3KqUdzHAB+yqxatZuO/WAet5ESjdQWeP77/por
	wc846UhQr+Nk1SEaH7zHBJQ8Xe+x+hIY+omeu/EAhCNdb9laWE/Ss0wZkp14XUYO
	CbBVydPRUv+5fYtUAXFreSd6ROQXRpISTxfLEWqJmlJoBN6fXnt3YTMXXmrH8bTc
	9Jld6ArJTLWqu8O1ZnjUP4UZenSq5dc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 28 May 2026 13:20:03 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A1CC360983;
	Thu, 28 May 2026 13:20:01 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64SAJlJq028963;
	Thu, 28 May 2026 13:19:47 +0300
Date: Thu, 28 May 2026 13:19:47 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Marco Crivellari <marco.crivellari@suse.com>
cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>,
        Frederic Weisbecker <frederic@kernel.org>,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        Michal Hocko <mhocko@suse.com>, Simon Horman <horms@verge.net.au>,
        Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
Subject: Re: [PATCH v3] ipvs: Replace use of system_unbound_wq with
 system_dfl_long_wq
In-Reply-To: <20260527081834.86987-1-marco.crivellari@suse.com>
Message-ID: <5f6d330c-43be-d1d7-fe0c-e687b1dec015@ssi.bg>
References: <20260527081834.86987-1-marco.crivellari@suse.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 27 May 2026, Marco Crivellari wrote:

> This patch continues the effort to refactor workqueue APIs, which has begun
> with the changes introducing new workqueues and a new alloc_workqueue flag:
> 
>    commit 128ea9f6ccfb ("workqueue: Add system_percpu_wq and system_dfl_wq")
>    commit 930c2ea566af ("workqueue: Add new WQ_PERCPU flag")
> 
> The point of the refactoring is to eventually alter the default behavior of
> workqueues to become unbound by default so that their workload placement is
> optimized by the scheduler.
> 
> Before that to happen, workqueue users must be converted to the better named
> new workqueues with no intended behaviour changes:
> 
>    system_wq -> system_percpu_wq
>    system_unbound_wq -> system_dfl_wq
> 
> This way the old obsolete workqueues (system_wq, system_unbound_wq) can be
> removed in the future.
> 
> This specific work is considered long, so enqueue it using
> system_dfl_long_wq instead of system_dfl_wq.
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Phil Sutter <phil@nwl.cc>
> Cc: lvs-devel@vger.kernel.org
> Cc: netfilter-devel@vger.kernel.org
> Cc: coreteam@netfilter.org
> Link: https://lore.kernel.org/all/20250221112003.1dSuoGyc@linutronix.de/
> Suggested-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Marco Crivellari <marco.crivellari@suse.com>

	Looks good to me for nf-next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> Changes in v3:
> - removed 1/2 "ipmr: Replace use of system_unbound_wq with system_dfl_wq" because
>   already merged.
> 
> Changes in v2:
> - this is considered a long work, so change the workqueue with system_dfl_long_wq
> 
>  net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
>  net/netfilter/ipvs/ip_vs_ctl.c  | 10 +++++-----
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 9ea6b4fa78bf..4a5c6762489c 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -285,7 +285,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  	/* Schedule resizing if load increases */
>  	if (atomic_read(&ipvs->conn_count) > t->u_thresh &&
>  	    !test_and_set_bit(IP_VS_WORK_CONN_RESIZE, &ipvs->work_flags))
> -		mod_delayed_work(system_unbound_wq, &ipvs->conn_resize_work, 0);
> +		mod_delayed_work(system_dfl_long_wq, &ipvs->conn_resize_work, 0);
>  
>  	return ret;
>  }
> @@ -916,7 +916,7 @@ static void conn_resize_work_handler(struct work_struct *work)
>  
>  out:
>  	/* Monitor if we need to shrink table */
> -	queue_delayed_work(system_unbound_wq, &ipvs->conn_resize_work,
> +	queue_delayed_work(system_dfl_long_wq, &ipvs->conn_resize_work,
>  			   more_work ? 1 : 2 * HZ);
>  }
>  
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index bd9cae44d214..2b53562c8605 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -821,7 +821,7 @@ static void svc_resize_work_handler(struct work_struct *work)
>  	if (!READ_ONCE(ipvs->enable) || !more_work ||
>  	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
>  		return;
> -	queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work, 1);
> +	queue_delayed_work(system_dfl_long_wq, &ipvs->svc_resize_work, 1);
>  	return;
>  
>  unlock_m:
> @@ -1869,7 +1869,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  
>  	/* Schedule resize work */
>  	if (grow && !test_and_set_bit(IP_VS_WORK_SVC_RESIZE, &ipvs->work_flags))
> -		queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work,
> +		queue_delayed_work(system_dfl_long_wq, &ipvs->svc_resize_work,
>  				   1);
>  
>  	*svc_p = svc;
> @@ -2122,7 +2122,7 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
>  		rcu_read_unlock();
>  		if (shrink && !test_and_set_bit(IP_VS_WORK_SVC_RESIZE,
>  						&ipvs->work_flags))
> -			queue_delayed_work(system_unbound_wq,
> +			queue_delayed_work(system_dfl_long_wq,
>  					   &ipvs->svc_resize_work, 1);
>  	}
>  	return 0;
> @@ -2564,7 +2564,7 @@ static int ipvs_proc_conn_lfactor(const struct ctl_table *table, int write,
>  		} else {
>  			WRITE_ONCE(*valp, val);
>  			if (rcu_access_pointer(ipvs->conn_tab))
> -				mod_delayed_work(system_unbound_wq,
> +				mod_delayed_work(system_dfl_long_wq,
>  						 &ipvs->conn_resize_work, 0);
>  		}
>  	}
> @@ -2596,7 +2596,7 @@ static int ipvs_proc_svc_lfactor(const struct ctl_table *table, int write,
>  			    READ_ONCE(ipvs->enable) &&
>  			    !test_bit(IP_VS_WORK_SVC_NORESIZE,
>  				      &ipvs->work_flags))
> -				mod_delayed_work(system_unbound_wq,
> +				mod_delayed_work(system_dfl_long_wq,
>  						 &ipvs->svc_resize_work, 0);
>  			mutex_unlock(&ipvs->service_mutex);
>  		}
> -- 
> 2.54.0

Regards

--
Julian Anastasov <ja@ssi.bg>

