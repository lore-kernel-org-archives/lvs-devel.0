Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8CC02D9EE4;
	Tue, 12 May 2026 04:22:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778559772; cv=none; b=jCz5rwrN9Pobi/pxqcUX9opfz275ojplg7MTbVAFXY4MngGZQ1UkoPic0r6llc2057XkgXtVny/WFQyw9aLNfQBeUn0P0Hh7/t9YMq/qrtjTXsFQSxdXW2j77HeVyzNs68cMQLn1IuT5E56sEe5MZZEtB8NbX6hIz1I32nQXr/U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778559772; c=relaxed/simple;
	bh=Plo8mlr6rowS/NyVjwGyUCLbyQ5h3qQGIUmvYL2DR1A=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=D/dyHBrgQy5R/I0PSqQEgkb5ge6vT9exmtBpe54TizUcD/EBnm/ykNel6s5fLvE8+Ghm7RCltJUmTLMwi71m2UNPa1lWsKH4gLv5ZCFetBQXJGvy0L3w5feIaU64u1nOZnZfJlaIWALgoYlSx8vdvQsyjy8EKa7CFH+trzWqQ8w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=r0MYbtAl; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="r0MYbtAl"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 01E70210AB;
	Tue, 12 May 2026 07:22:38 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Wol3Wx9KU7gCeTBf/zFj0geFCUBKFbXdayy9bNvZ924=; b=r0MYbtAl/Pv8
	AkDshua9gyLyQTLJiLFWnrfKT1JEbCVnnNrk+a1wCEoTnWu/+omrAY8Cd8lP/Yi7
	95xB43vqgAQpVChFynNnQE1n/glDEvSoSw6Nhp+5712Qvpzr4oWQd/2FiYO50jby
	obB1+i3jve1RMlC7NCn0fONJmbox0qMz0QI56YxI7q6Lr47zeYjz0zMzleiKS3GR
	yUG9/oLuq0ljumdtPRAr1j9DOq9dQa4hsY3ZbrsEFWRrRRHlBLhHoVEMqQtR9pRZ
	LJ1Exgu4YQzyKljdi11g15VvWmcZY9SxKjt/wejPdL6X8IvHjZhX12ti+2FFKsu6
	OUOwYqiF9GPcAAyKx7dsrkKbJnZqWaIQpkHEqgYz7nW7/r/Jc5ziE241Qph2TJPI
	KlbWQx3YFig8ey2QhaKVIeU52HxcXefHLiaoNHwlsTuW5ibDMNhcMuc5eN3WouWG
	K9+ZIrQpCVmv3GsOjoBBCkVYHalMFyQU310//hqNyaw6lcbQtexuqH0q3ZzZKSjq
	1/jV/xl1dw/PXTCgktwzWGSCygaUWgi/wFXEyS6C0pvimLqxB5gi9EI7D5VqmP1y
	ORAEHl2M4CP4DiaCKsk7r/w43hziVEgx0GNT8CVTuXQERSiOZIZQu592O0tZ0ViN
	w39BvZU7McWOFK6FKasCQ7+7brK/7kI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 12 May 2026 07:22:37 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B66166289E;
	Tue, 12 May 2026 07:22:35 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64C4MQUt007775;
	Tue, 12 May 2026 07:22:27 +0300
Date: Tue, 12 May 2026 07:22:26 +0300 (EEST)
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
Subject: Re: [PATCH net-next 2/2] ipvs: Replace use of system_unbound_wq with
 system_dfl_wq
In-Reply-To: <20260511134744.277032-3-marco.crivellari@suse.com>
Message-ID: <734b9aa0-3af4-819a-49fe-8bba7035856f@ssi.bg>
References: <20260511134744.277032-1-marco.crivellari@suse.com> <20260511134744.277032-3-marco.crivellari@suse.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 11 May 2026, Marco Crivellari wrote:

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

	Sorry that such change was delayed but there were
many changes in IPVS for the last month. The last that may
delay this patch is:

v3 of "ipvs: avoid possible loop in ip_vs_dst_event on resizing"
https://lore.kernel.org/lvs-devel/20260510104605.24218-1-ja@ssi.bg/T/#u

	May be we have to wait this change to reach net and
net-next. Also, we can reconsider which queue to use, these works
resize hash tables and call synchronize_rcu(), should we switch to
system_dfl_long_wq if such job is considered "long" ?

> ---
>  net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
>  net/netfilter/ipvs/ip_vs_ctl.c  | 10 +++++-----
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 9ea6b4fa78bf..2625c0379556 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -285,7 +285,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  	/* Schedule resizing if load increases */
>  	if (atomic_read(&ipvs->conn_count) > t->u_thresh &&
>  	    !test_and_set_bit(IP_VS_WORK_CONN_RESIZE, &ipvs->work_flags))
> -		mod_delayed_work(system_unbound_wq, &ipvs->conn_resize_work, 0);
> +		mod_delayed_work(system_dfl_wq, &ipvs->conn_resize_work, 0);
>  
>  	return ret;
>  }
> @@ -916,7 +916,7 @@ static void conn_resize_work_handler(struct work_struct *work)
>  
>  out:
>  	/* Monitor if we need to shrink table */
> -	queue_delayed_work(system_unbound_wq, &ipvs->conn_resize_work,
> +	queue_delayed_work(system_dfl_wq, &ipvs->conn_resize_work,
>  			   more_work ? 1 : 2 * HZ);
>  }
>  
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index c7c7f6a7a9f6..f8fe1c8981d8 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -800,7 +800,7 @@ static void svc_resize_work_handler(struct work_struct *work)
>  	if (!READ_ONCE(ipvs->enable) || !more_work ||
>  	    test_bit(IP_VS_WORK_SVC_NORESIZE, &ipvs->work_flags))
>  		return;
> -	queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work, 1);
> +	queue_delayed_work(system_dfl_wq, &ipvs->svc_resize_work, 1);
>  }
>  
>  static inline void
> @@ -1833,7 +1833,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  	/* Schedule resize work */
>  	if (t && ip_vs_get_num_services(ipvs) > t->u_thresh &&
>  	    !test_and_set_bit(IP_VS_WORK_SVC_RESIZE, &ipvs->work_flags))
> -		queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work,
> +		queue_delayed_work(system_dfl_wq, &ipvs->svc_resize_work,
>  				   1);
>  
>  	*svc_p = svc;
> @@ -2078,7 +2078,7 @@ static int ip_vs_del_service(struct ip_vs_service *svc)
>  	} else if (ns <= t->l_thresh &&
>  		   !test_and_set_bit(IP_VS_WORK_SVC_RESIZE,
>  				     &ipvs->work_flags)) {
> -		queue_delayed_work(system_unbound_wq, &ipvs->svc_resize_work,
> +		queue_delayed_work(system_dfl_wq, &ipvs->svc_resize_work,
>  				   1);
>  	}
>  	return 0;
> @@ -2511,7 +2511,7 @@ static int ipvs_proc_conn_lfactor(const struct ctl_table *table, int write,
>  		} else {
>  			WRITE_ONCE(*valp, val);
>  			if (rcu_access_pointer(ipvs->conn_tab))
> -				mod_delayed_work(system_unbound_wq,
> +				mod_delayed_work(system_dfl_wq,
>  						 &ipvs->conn_resize_work, 0);
>  		}
>  	}
> @@ -2543,7 +2543,7 @@ static int ipvs_proc_svc_lfactor(const struct ctl_table *table, int write,
>  			    READ_ONCE(ipvs->enable) &&
>  			    !test_bit(IP_VS_WORK_SVC_NORESIZE,
>  				      &ipvs->work_flags))
> -				mod_delayed_work(system_unbound_wq,
> +				mod_delayed_work(system_dfl_wq,
>  						 &ipvs->svc_resize_work, 0);
>  			mutex_unlock(&ipvs->service_mutex);
>  		}
> -- 
> 2.54.0

Regards

--
Julian Anastasov <ja@ssi.bg>

