Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81DE53A3E78;
	Wed,  1 Apr 2026 12:43:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775047427; cv=none; b=nD/QqmSqE8d3V1ljAHpUDcMp+MVm6FzwrGnxW16Q5NCtHAXZgbCqyqoPIJnJ6xMBBhro0yjYRrPNtfRhItMe4h2+JIRo3L0XsxvtZvlwkOf3T3QLWP2nMJKxXazaCIIeU7KYLNJcWujo7dXjCszvE18lVfefL7cNIZdAfqARKzs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775047427; c=relaxed/simple;
	bh=KHI2K+l7tSjNi1087IObTtszedNleMVSgBaM63sh8qU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=DC4eb/gLp9BFLhGSS5jvwhJlLIpqJxhiUd0MwR/e90g90RIISJkdFrC+Q9MXMwLC2/3k+ExtNe30IShHoQbvqaTX+g5+mXpX7vktgpZadDtH0bS/Rwys9OUMxefFlaJc9JZITlUhSGJpZKJfFC4m9/lxTx8emFKHZa/uDrGQ2U0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KIXgY4iQ; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KIXgY4iQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 96489C4CEF7;
	Wed,  1 Apr 2026 12:43:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775047427;
	bh=KHI2K+l7tSjNi1087IObTtszedNleMVSgBaM63sh8qU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=KIXgY4iQge5ViOxgSVFpeZ5ZpCCZ2Q6wVL4HG7hBYfxQCD2wLBeQ3t6fA0+lXnoWS
	 ARtvusEwpfH/jupy4XTJ5XqL0s93to9ReSyVubSi7KPY4IvUhhcALvgs5MQyaC0sQq
	 VQrurG1lFfBpin69lWjZrgqUVavQOkLC5MIEd/el6WP32ZtORWDhS43gbHrWekFYIC
	 P/hlPUZ3BpKXwdmkQIzOa4UNRA30I5rKkRaaAhmlT3pu55VO+IIiNkXk/8Klf/zLvP
	 EoW1wadKcJWTl9R2txBUmHcb38H+i3ZhqXbWB0dqgD7Myn2ySB0eVYVK+jzuCUFV4u
	 7fL10W+DiZXZg==
Date: Wed, 1 Apr 2026 14:43:44 +0200
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
Subject: Re: [PATCH-next v2 1/2] sched/isolation: Make HK_TYPE_KTHREAD an
 alias of HK_TYPE_DOMAIN
Message-ID: <ac0TAA0J-S9K_p8Z@localhost.localdomain>
References: <20260331165015.2777765-1-longman@redhat.com>
 <20260331165015.2777765-2-longman@redhat.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260331165015.2777765-2-longman@redhat.com>

Le Tue, Mar 31, 2026 at 12:50:14PM -0400, Waiman Long a écrit :
> Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
> affinity management"), kthreads default to use the HK_TYPE_DOMAIN
> cpumask. IOW, it is no longer affected by the setting of the nohz_full
> boot kernel parameter.
> 
> That means HK_TYPE_KTHREAD should now be an alias of HK_TYPE_DOMAIN
> instead of HK_TYPE_KERNEL_NOISE to correctly reflect the current kthread
> behavior. Make the change as HK_TYPE_KTHREAD is still being used in
> some networking code.
> 
> Fixes: 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred affinity management")
> Signed-off-by: Waiman Long <longman@redhat.com>

This makes ipvs_proc_est_cpumask_get() racy because now without RCU locked the
mask pointer can be released at any point.

Other users:

sysctl_est_cpulist() -> ip_vs_est_stopped_recalc() -> ip_vs_est_reload_start()

Here sysctl_est_cpulist() is only invoked if ->est_cpulist_valid
(->est_mutex makes it stable). So housekeeping_cpumask() should not be called.

But ip_vs_est_max_threads() is more complicated. And it's a sign we should
probably call something like ipvs_proc_est_cpumask_set() when the HK_TYPE_DOMAIN
is modified (and ipvs->est_cpulist_valid is 0) in order to update the ipvs
kthreads accordingly.

Thanks.

-- 
Frederic Weisbecker
SUSE Labs
