Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20113303A0A;
	Thu, 30 Apr 2026 07:23:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777533797; cv=none; b=kho3bt6uVjasPd+mciGJQo0ReVt1ywAkBFvbGZMqs0Qi7BOEoeY+O2ShC1rGYYzdT0vI5z+AAlWVQIqaemMxQwMGpDHUxnbqjCDzEKTXHzOC3XNZ20ZYQasd5Zsp+c+2qiTt20wFwlNTkFaetB/U09bDX2i1tuMT1BDFtyIyhI4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777533797; c=relaxed/simple;
	bh=xPaJ/ZXjzS4GfvjdDE0wnhyM30xSS1h2NiHuRVJJSBY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=QgxFgRBSmBwND5aNhXlVdHqiJrve3jO4T9TtQ5dhz0d7isdgFDT0P/g23A3TkuO8JDYz6ybHT+X+bQr1/Ik0SiX+LLoVBRMm6Xatinre31vT2GIeGZasCsEzCtEZSCm35WZurh+3e8YEsEHJLQrgN/N0I+yZ3hta+7rEyE5LKr0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=UO6elbPW; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="UO6elbPW"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 6EC0021C55;
	Thu, 30 Apr 2026 10:23:05 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=uKZyYCqVWiEnoxXjcFYc1S/imjC36fjluOjuhr7410Q=; b=UO6elbPWwGX9
	KU2uIEGW6cF7RWfhvZqoyPtXA7GKJY3oIoDL1HgzCjtgPefXepBT88YDNPWe2dGW
	lkLdLfaHwVun+KfRQxopTpz6DbsZSKz8xh7HG7+Qg7xtm8idnnaE5M18K7ZpaPo9
	IPTmBXUKNeO4a6cxT/mAfYlZXwRrt9y1KZVQ8P76SrgX3Qmv0GkGDm3rB5hI7hsg
	zlbdnWgsNjjVCVvWDtLhBWjEUorzZEJYdUOv/Ym4AvDcFoT7Prt9jJd2HEmjpMka
	itGFprmkOSHwhY0cKp6PWppHKjkw3lz1W7A6gOqqTXjEoY4Wk5K12nRwTOd6jKlV
	DZjyOmdxGgk893/FvFT/ByxeZqfzCwOzJivlmsRnfMLuVKnejPLuOYcFfC7cRL62
	l9tTCXmBDz9x1J99Rh63F/Hio6xVSldHFU6PPwQLrwMvjIj2NlyAEMaFCedM33SC
	1tNj3npfYJ42u6mZda3ZgIG1Q/8BFU6fnOakOQQ06QVXRqpNYfBUxRRRvjgNmcvB
	QFogvws4f1gAqFVMS6wfRsqwX2SyU4FNqZ69xVbLTlY67IymITO9Qh+lxLFFw5ya
	ydxp9+lPe7ZLP51YhQy33xX/4jVfP7nfRcCH+HETn2kNULEMO+fBUQSy1JktTKUR
	VpmlSLn2kZWsvpmwEYDZgAfLrpALpn0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Apr 2026 10:23:04 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A465F628DD;
	Thu, 30 Apr 2026 10:23:02 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63U7Ms8a022534;
	Thu, 30 Apr 2026 10:22:55 +0300
Date: Thu, 30 Apr 2026 10:22:54 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: Re: [PATCHv2 nf 0/8] IPVS fixes for nf
In-Reply-To: <20260429141055.85052-1-ja@ssi.bg>
Message-ID: <2343bb8d-c6b0-66b7-f6be-5f7761944f96@ssi.bg>
References: <20260429141055.85052-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 29 Apr 2026, Julian Anastasov wrote:

>         This patchset contains accumulated fixes for the nf tree:
> 
> 1-3) Fixes for the recently added resizable hash tables (v5)
> 
> 4) dest from trash can be leaked if ip_vs_start_estimator() fails
> 
> 5) fixed races and locking for the estimation kthreads (v5)
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
> v2:
> * Reports: https://sashiko.dev/#/patchset/20260428175725.72050-1-ja%40ssi.bg
> * introduce new patch at position 4 (dest leak)
> * patch 6: check for n > 1 before roundup_pow_of_two
> * patch 7 and 8 are now in reverse order to help bisection
> 
> Julian Anastasov (6):
>   ipvs: fixes for the new ip_vs_status info
>   ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
>   ipvs: fix the spin_lock usage for RT build
>   ipvs: do not leak dest after get from dest trash
>   ipvs: fix races around est_mutex and est_cpulist
>   ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
> 
> Waiman Long (2):
>   ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
>   sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> 
>  include/linux/sched/isolation.h |   6 +-
>  include/net/ip_vs.h             |  31 +++++-
>  net/netfilter/ipvs/ip_vs_conn.c |  76 ++++++++-------
>  net/netfilter/ipvs/ip_vs_core.c |   2 +-
>  net/netfilter/ipvs/ip_vs_ctl.c  | 164 +++++++++++++++++++++++---------
>  net/netfilter/ipvs/ip_vs_est.c  |  83 +++++++++-------
>  6 files changed, 241 insertions(+), 121 deletions(-)
> 
> -- 
> 2.53.0

	Will send v3 after rebase...
	
pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

