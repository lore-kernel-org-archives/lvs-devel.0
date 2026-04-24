Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF44A324B1F;
	Fri, 24 Apr 2026 19:42:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777059724; cv=none; b=U6Ljl6LBDSjP3/yiO6aSeUCZV16aAkQCbBH2cdVtU8KGtRvxXT+2Xh352pNA13qHNB59ZDdGFGLmdzJxad4JOYewYf0ocPLLMlkvAH6EuAy8VMUeCFGNtLTRqi9ih/5WHOF56RH/98I873k4/WEcOtg5llJH9pt3Uw1GR/l8Q/Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777059724; c=relaxed/simple;
	bh=J4V079oJH/X4SzK+eaSEG3TU+LTBhZnF0URApET19AY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=W4ZPpsm5yDU6toVmTH6ClIaZs4H+p/wpeus+OvIKKT3zrrp9Y537BH4bNPv4TyyKTUt/a5JPKBLag+gUeTsLQkFLHPvep8QXyhwOfTDWFwAIDl+ssJEqgk0krakFQdte30R7ns7brIpQdIUxiqhNjfO6JL3aX6KEDmxOgyd+6pU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=iiq54waw; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="iiq54waw"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CEB8221268;
	Fri, 24 Apr 2026 22:41:57 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=+lkcq51BXjlUl/RoV+HLZ1U3WWqXQCBySHt2szrrI3E=; b=iiq54wawWI33
	QcmNX30ozb30ozHm5Y0Dm27hrKgtl1GV6VYEOiZmX3YzzQUE0K6cgZLwPXantprS
	jQx2Jlv5i3wrxqz6pyiDqJakPfMP37UyQxcTrPU80yAlXyYyMcc5faJxkeH91ud5
	+JK2Xqx/hvfnx7Sbv4dsMGQsQcncCKyMxyLwEvhAVNihV9LHokplteirlg2d0Rvc
	PsDzkJlBlI1eRBL2x7asWmH8h9DARdj+hdf3UHsr/2WBXRylrCasFhIyGtmowL1D
	sZsNziN54ndmUvWcCrMHsr513z/vNz6Ki7KM/WSR5ow8Gc+888NwmJFlyFP9eg5R
	+wN3xGzcJ/QLIJPfievUFUYYsrDsSDSZs4Nc7kvLYR5KeZnes2BDgmvmGiDDS3yx
	KvdPGbENs/2psTWzrU/5Q9+GYzg5deGFbqX0SC/zXsnxDoM5fxgeswQOSrjPnaM4
	gkvJsBnxnGK/GX4vqyG8c/cuQenfZ5H8ZTWXUYr2DtDVQ8UaQxXQF0ZyXtIv69oz
	Z3JegWPAKxejgXtNYFx3yxzX59c4hUGRudtVMEMbZBTjXd6UrObC7dWt0yg0EGEO
	S520T2YhxoHzRQinEmXemkgrKykUcbZ8+UsBmewHb+Y9xXmxCrQVZnPdg96I5lsx
	/hGakdNVh7/COSqUlRnr7z3cklHJ2LE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 24 Apr 2026 22:41:56 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 47293608CE;
	Fri, 24 Apr 2026 22:41:56 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63OJfs4O061735;
	Fri, 24 Apr 2026 22:41:54 +0300
Date: Fri, 24 Apr 2026 22:41:54 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCHv3 net] ipvs: fix races around est_mutex and est_cpulist
In-Reply-To: <20260424175858.54752-1-ja@ssi.bg>
Message-ID: <a4f06cd8-c17e-d64d-8129-5797fe7b6452@ssi.bg>
References: <20260424175858.54752-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 24 Apr 2026, Julian Anastasov wrote:

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
> Reduce the use of service_mutex in ip_vs_est_calc_limits()
> because under est_mutex we can safely walk est_kt_arr to
> stop the kthreads above slot 0.
> 
> Link: https://sashiko.dev/#/patchset/20260331165015.2777765-1-longman%40redhat.com
> Link: https://sashiko.dev/#/patchset/20260420171308.87192-1-ja%40ssi.bg
> Link: https://sashiko.dev/#/patchset/20260422125123.40658-1-ja%40ssi.bg
> Fixes: f0be83d54217 ("ipvs: add est_cpulist and est_nice sysctl vars")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Sashiko found another use-after-free [1] that is easy to
fix here. I'll send new patch version tomorrow...

pw-bot: changes-requested

[1] https://sashiko.dev/#/patchset/20260424175858.54752-1-ja%40ssi.bg

Regards

--
Julian Anastasov <ja@ssi.bg>

