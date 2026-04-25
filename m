Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B2FC86331;
	Sat, 25 Apr 2026 14:40:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777128021; cv=none; b=IEJOynhgY9KCIganftuLRAxO40A2DELROzeUlexGi4ef10+yiUvnU/2vgUqS7G4xu8xHZ0aVvhhmq4aYjfy9O6qBoeNzcpIY5Y0aomyTl1hqBVIprt0xfwzQm/qWTibHp7wcxyF9YUAi+v8g+eViHO7rPCSMSX4Lk5SwarYjadI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777128021; c=relaxed/simple;
	bh=3S59E+6wwY1pb8wN+u2QDClwuHlWMAbfkyohregNYMY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=BclfEQUTWuxuk3OJeM8yWZWE9ETlsQVTwtE1Usjz1DrAVb8aNH5mDsfKByD6EWgHnlO+MFqgVRkw761uHdP1cGB8wkAQedyfFM7h2j57g0C4hZWD+BWjThlmIzHxaeJ5sdhN01hTv2M0rEa4fI8N8jBFPD/5MKprhd3uWPNOZrE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=JgnLwuWE; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="JgnLwuWE"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 188312126B;
	Sat, 25 Apr 2026 17:40:14 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=t05NlVZq+mhhzTf2yK9v5tWBFrn5EElC1WzGhXz5mEE=; b=JgnLwuWEntx9
	MLwLZmT4msNuGAYQZ3lQZBdQ/S89n/Ea99/SoAfeKS6zij32wvA54Nw5pJ0m8ecl
	hXVaq1e9WRXk8Z6NshfueiIn6s9l12ANGUf+/pRqCnlPej6nYR4QfFTXHNAhvtZ4
	zHSgC2HfvJ1rgfOTFwBDTn+C/bhOvTfDreWD3JeXC+TOuEqKQ3GyhDoAbgIhdU77
	Dxv77cfJCA/G5/N7P4ZmNausANQNm2tFNBsKp0/fyckRfPOZB8uG0QfCFu6CJWX+
	mEnvP7V/N8/hJSq9btSCqjMi749+FzJdM/U/tnwPOTpRbSBZqnzay9NHil0ZY93y
	K9lwb0ocESdSQjwT5MUePz+o+qGueFFP5idLA2oGcQl2TCBr1g8NZ9OSYRavfRsj
	MT9zpX4wzDi4/zCbF7vB0UbT/pArPb8Ws0WTWwoTSvKViKNrkwxv2hrkiUCHpp6v
	P7oXXJgZuRElhoiiXv6VXVeHUtPjP4XLYQqKSkpdw5HAJO8fEZTN3p2QLC1xuFnf
	2aHljvZmIFQut3kWu4pUb5Q5oGCs6Rqzc8v7ThMH+t9V03gNsZ1UrWlgXbMXbMP9
	MtEwNc41RInUeqnQoZC+4PYz1Ujj12zl5OAAMUHz3dbiREfyYhA87dOxUnWHauwE
	tI8bXS1jlGlLsB6ym/vA9G77DiZJ+6Q=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 25 Apr 2026 17:40:12 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B128A6089D;
	Sat, 25 Apr 2026 17:40:11 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63PEe7Bc017270;
	Sat, 25 Apr 2026 17:40:10 +0300
Date: Sat, 25 Apr 2026 17:40:07 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCHv4 net] ipvs: fix races around est_mutex and est_cpulist
In-Reply-To: <20260425103918.7447-1-ja@ssi.bg>
Message-ID: <248dffc5-06ff-f9c2-7e39-c1ab991d2a16@ssi.bg>
References: <20260425103918.7447-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sat, 25 Apr 2026, Julian Anastasov wrote:

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
> To remove the chance of deadlock while stopping the
> estimation kthreads, keep the data structure for kthread 0
> even after last estimator is removed and do not hold mutexes
> while stopping this task. Now we will use a new flag 'needed'
> to know when kthread 0 should run. The kthreads above 0
> do not use mutexes, so stop them under est_mutex because
> their kthread data still can be destroyed if they do not
> serve estimators. Now all kthreads will be started by
> the est_reload_work to properly serialize the stop/start
> for kthread 0.
> 
> Reduce the use of service_mutex in ip_vs_est_calc_phase()
> because under est_mutex we can safely walk est_kt_arr to
> stop the kthreads above slot 0.
> 
> Finally, fix use-after-free for kd->est_row in
> ip_vs_est_calc_phase(). est->ktrow should simply switch to
> a delay value while estimator is linked to est_temp_list.
> 
> Link: https://sashiko.dev/#/patchset/20260331165015.2777765-1-longman%40redhat.com
> Link: https://sashiko.dev/#/patchset/20260420171308.87192-1-ja%40ssi.bg
> Link: https://sashiko.dev/#/patchset/20260422125123.40658-1-ja%40ssi.bg
> Link: https://sashiko.dev/#/patchset/20260424175858.54752-1-ja%40ssi.bg
> Fixes: f0be83d54217 ("ipvs: add est_cpulist and est_nice sysctl vars")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Sashiko found another missing mutex lock [1].
I'll send new patch version...

pw-bot: changes-requested

[1] https://sashiko.dev/#/patchset/20260425103918.7447-1-ja%40ssi.bg

Regards

--
Julian Anastasov <ja@ssi.bg>

