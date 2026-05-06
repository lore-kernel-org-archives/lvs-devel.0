Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5954B325726;
	Wed,  6 May 2026 08:56:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778057798; cv=none; b=IZXeuN4EWSJYWvkz0c3zPla0uM9EWKOpuCu6Bvnpyz2yxBR6bFvocY90mWa0uNDFSHnnliJevWDlYFDR5Or+rU+mDGTyhj++2YCnIqlK8c8dbzRHgFRNh6puhMgIIrXNs75jl6AZ4QKZCNkSQeAi34w1vx2qnZvla+hM8d1cAME=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778057798; c=relaxed/simple;
	bh=zp2C0hJkR85k7cWv/TIUOucqerZUGNvfBRqp4Qt805A=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=UqHbqOJJTqBRd/djaaNuf6RCuVSmjbdwOIHRaM0M42o/jdfrmwMxaxpo5ajR2EAuVEWBK00KPqvsQpWDr0HVyrTWT2iTiJ9J9USZTXdLZZcEEOp+11swYmaFsZzY19LQJ5uWszvp5U53CrhkexuDhilQQ0WjkM5u2X83XP55pNI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=VLkG+T4p; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="VLkG+T4p"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 129A322948;
	Wed, 06 May 2026 11:56:15 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=cmbRi41+gNhLJ/BoTacOk4rEd+O0aklpZLKmpm6lcJc=; b=VLkG+T4pGVIx
	F7JdOyPlUBLYiHb3/qzg5Sx5FQPmOdEdSlHoo9f3FTCO6NMk4Uqlj4WP2kBRZIpb
	MYslQxVpth/3s95+zQ17fBurmNumY2AdaxKHtnuZtTAVXN0x8u0ZndM1A+0KR+q0
	JXrkVoyg+jOATn39d3WDODFieX1fN/y02Ltzwr/Z20S1Oc6BvValJuM4aViNav9g
	ZDavOI4yPHAvUKFOnXSvnGbHEQS2oFKVM/tp1jITyKiFuep2ZglDIWg9Ak2mEC5l
	/syTOIQDhCWNqTWKhsk93Wno7bjlAStmVD0tT6f33EYYcFXQ/z6vl6SsYSehPq6h
	fVSFDvGjg/UESlE7uWgxeYC7Q96puvMhWRDvTehLbIS0pNwZ8VsQ1zYQLbDsWAAV
	D5zTVoX9b45uY/gz3rrJXvPMwaU37uGh9H7F7Jq60srHVh39pKnhifaRYtVfSstA
	4SZbOxQePnlyg/OHGBEmzn0QMk0+H+iuNuIiTDMYljkj/elxmN77pjRUrg8+iVRH
	nUOkE7GhIDkZPA6nd/qxrSZl9c3qMgGiBvYi3qdLjcylyTyJVAj0c1HY0BpNLKH+
	Pwxij9Tv2jnW2vu/oAkaVyYgzCJ2HoUinFT89NKeMSJdAMg+ToF9BdDAOdYWBd+g
	997Di2MF9p/Eg2ZKKPtI72GeQtjVuVc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 06 May 2026 11:56:14 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1D988608AE;
	Wed,  6 May 2026 11:56:13 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 6468u5i6022127;
	Wed, 6 May 2026 11:56:06 +0300
Date: Wed, 6 May 2026 11:56:05 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, kuba@kernel.org, pabeni@redhat.com,
        edumazet@google.com, fw@strlen.de, horms@kernel.org,
        longman@redhat.com, lvs-devel@vger.kernel.org
Subject: Re: [PATCH net 0/8] IPVS fixes for net
In-Reply-To: <20260505001648.360569-1-pablo@netfilter.org>
Message-ID: <bce80830-1e2d-43ad-ba7f-055cb352b348@ssi.bg>
References: <20260505001648.360569-1-pablo@netfilter.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 5 May 2026, Pablo Neira Ayuso wrote:

> Hi,
> 
> The following batch contains IPVS fixes for net to address issues
> from the latest net-next pull request.
> 
> Julian Anastasov made the following summary:
> 
> 1-3) Fixes for the recently added resizable hash tables
>  
> 4) dest from trash can be leaked if ip_vs_start_estimator() fails
>  
> 5) fixed races and locking for the estimation kthreads
>  
> 6) fix for wrong roundup_pow_of_two() usage in the resizable hash
>    tables
>  
> 7-8) v2 of the changes from Waiman Long to properly guard against
>   the housekeeping_cpumask() updates:
>  
>   https://lore.kernel.org/netfilter-devel/20260331165015.2777765-1-longman@redhat.com/
>  
>   I added missing Fixes tag. The original description:
>  
>   Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
>   affinity management"), the HK_TYPE_KTHREAD housekeeping cpumask may no
>   longer be correct in showing the actual CPU affinity of kthreads that
>   have no predefined CPU affinity. As the ipvs networking code is still
>   using HK_TYPE_KTHREAD, we need to make HK_TYPE_KTHREAD reflect the
>   reality.
>  
>   This patch series makes HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
>   and uses RCU to protect access to the HK_TYPE_KTHREAD housekeeping
>   cpumask.
> 
> Julian plans to post a nf-next patch to limit the connections by using
> "conn_max" sysctl. With Simon Horman, they agreed that this is an old
> problem that we do not have a limit of connections and it is not a
> stopper for this patchset.
> 
> Please, pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/netfilter/nf.git nf-26-05-05
> 
> Thanks.
> 
> ----------------------------------------------------------------
> 
> The following changes since commit bd3a4795d5744f59a1f485379f1303e5e606f377:
> 
>   selftests: tls: add test for data loss on small pipe (2026-05-02 18:27:14 -0700)
> 
> are available in the Git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/netfilter/nf.git tags/nf-26-05-05
> 
> for you to fetch changes up to 8f78b749f3da0f43990490b4c1193b5ede3eec0a:
> 
>   sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN (2026-05-05 01:52:55 +0200)
> 
> ----------------------------------------------------------------
> netfilter pull request 26-05-05
> 
> ----------------------------------------------------------------
> Julian Anastasov (6):
>       ipvs: fixes for the new ip_vs_status info
>       ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
>       ipvs: fix the spin_lock usage for RT build
>       ipvs: do not leak dest after get from dest trash
>       ipvs: fix races around est_mutex and est_cpulist
>       ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
> 
> Waiman Long (2):
>       ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
>       sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> 
>  include/linux/sched/isolation.h |   6 +-
>  include/net/ip_vs.h             |  31 ++++++--
>  net/netfilter/ipvs/ip_vs_conn.c |  76 ++++++++++---------
>  net/netfilter/ipvs/ip_vs_core.c |   2 +-
>  net/netfilter/ipvs/ip_vs_ctl.c  | 164 +++++++++++++++++++++++++++++-----------
>  net/netfilter/ipvs/ip_vs_est.c  |  83 +++++++++++---------
>  6 files changed, 241 insertions(+), 121 deletions(-)

	Here are some comments after the last review from
Sashiko:

https://sashiko.dev/#/patchset/20260505001648.360569-1-pablo%40netfilter.org

Patch 1:
- while ip_vs_dst_event() should loop and ensure all dev
references are released, single change of svc_table_changes
does not indicate the old references are dropped by ip_vs_flush() or
ip_vs_del_service(). I'll post new change to abort the loop
when we are sure the services are at least once released.

Patch 5:
- after executing ip_vs_est_calc_phase(), data can
remain only for kt0 because all estimators are stopped,
unlinked and the kt data structures for kt > 0 are empty
and as result freed and the kthread tasks stopped (which
happens early). After this, kt 0 calls
ip_vs_est_drain_temp_list() as part of its loop,
so it will eventually call ip_vs_est_add_kthread()
and ip_vs_est_reload_start() to request kthread tasks
to be started if data for new kthreads are created.
So, I don't see problem here.

Patch 6:
- we will add conn_max sysctl soon

Patch 7 and 8:
- I can not decide how valid are the concerns in the review.

Regards

--
Julian Anastasov <ja@ssi.bg>

