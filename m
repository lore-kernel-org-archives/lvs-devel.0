Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F13C0208D0;
	Wed, 29 Apr 2026 05:16:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777439816; cv=none; b=Ef0XckXRm8LTQwSB9VJxu41FoJuz1lFLZQ2ZoorPJERBdQqe80r9mbWUhmC6Gre4XAmggMbvdpbrjxhlRdVYhq4Vh3qYdWBNvQNi9TaZAdG3zwl8MHXzeKHzz/hEg2doQZFnE4sjyLPf9l7BZSgiRRwcZgXoJmzpd+YlBTzP4yk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777439816; c=relaxed/simple;
	bh=d6SItQBhjhxfHzbQ3yzPPdKM7+1IIQe3nMP3RIuH2MA=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=SxlxWbHvLXykKcT6tEMgUqQ+8AfHiKHpK3nSvSCxYfdGPvkfatLDGZ67GzyaxhPz5Dm4RaHciKnvcvFMn7809lWy/aycW6KmNhvuYBV5xHbTmePjTVfiJ5nJNNlS45C8CfUnOhmYXwL+ubl8BXM4YT4gXq+dHFnIZbo1i5upx50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=7Fi/AMUz; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="7Fi/AMUz"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id EE1C5211C1;
	Wed, 29 Apr 2026 08:16:42 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=tv5gaK/rTp/1Rb5TMCDfyYjWr7gaWs6l6ycHei8mXEQ=; b=7Fi/AMUzrDEx
	/HWCxYN2mKK2trtR2mMFsDymKWcozv4VgU5TTnwhpvs4N1yzRrukrUirAWIai2xK
	MmNZ4XdJm/ZPUkckRHrZwv+YEzSMY185lWDAUtwj+fE580XmLFLX6mz0wP5fdhqv
	Vnrz8n97un1mJGp+PWYa5lwCt7SX5lc7oQEJYxY8XmeQCRJAo982FX/e9+DY1dnk
	uSJgCqL2KoOw2urh4xoUVURxp2IWJeqoODcH/8MFjyM3CrpoV8oj6GKpmvpI/oBr
	XKE38IW3/pIeOxCRVCmBNJT5VQcnGaWAX8X3e5+D+TLxUu841akBHApFrWKXiXGy
	Imx6GS/vVWsEuS8LtEnCRC2O+Ya3AVEwElLmo8QMGNhQwjyUI0hlGk+ZUunz3wd1
	0lzSC7LUDQcBVIZ9mS/r2QruFDOz+MZONbdlPNiH/k3mNqNWo0mf6EN5V4xQxlT3
	GsWbmAMBrW6apuYrXlDCHdtPDQdAmSe3inx0uo76BI96mPHcrv3aQjDWih1lI2Qp
	tLBjyPCj9x9VBabWyj3fxWEjyaxZYa2EExPgECxRWSVJCytSEc/0R8NJozAKKqs+
	oXF9TJa85xJ3Qoz0cm0GD35wJOAqxAEIC5biDCiwhJgO6/DY4hCXVj+4LUOUOa5Z
	me9AKCZt85guaUynmEvp66F+ASk6IMA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Apr 2026 08:16:41 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 35C0F6298F;
	Wed, 29 Apr 2026 08:16:39 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63T5GRgn009355;
	Wed, 29 Apr 2026 08:16:31 +0300
Date: Wed, 29 Apr 2026 08:16:27 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        Waiman Long <longman@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf 0/7] IPVS fixes for nf
In-Reply-To: <20260428175725.72050-1-ja@ssi.bg>
Message-ID: <0426d12f-17a1-aff8-69c8-39daea37abda@ssi.bg>
References: <20260428175725.72050-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 28 Apr 2026, Julian Anastasov wrote:

>         This patchset contains accumulated fixes for the nf tree:
> 
> 1-3) Fixes for the recently added resizable hash tables (v5)
> 
> 4) fixed races and locking for the estimation kthreads (v5)
> 
> 5) fix for wrong roundup_pow_of_two() usage in the resizable hash
>    tables
> 
> 6-7) v2 of the changes from Waiman Long to properly guard against
>   the housekeeping_cpumask() updates:
> 
>   https://lore.kernel.org/netfilter-devel/20260331165015.2777765-1-longman@redhat.com/
> 
>   I added Fixes tag to the 7th patch. The original description:
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
> Julian Anastasov (5):
>   ipvs: fixes for the new ip_vs_status info
>   ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
>   ipvs: fix the spin_lock usage for RT build
>   ipvs: fix races around est_mutex and est_cpulist
>   ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
> 
> Waiman Long (2):
>   sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
>   ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
> 
>  include/linux/sched/isolation.h |   6 +-
>  include/net/ip_vs.h             |  31 ++++++--
>  net/netfilter/ipvs/ip_vs_conn.c |  76 ++++++++++---------
>  net/netfilter/ipvs/ip_vs_core.c |   2 +-
>  net/netfilter/ipvs/ip_vs_ctl.c  | 127 ++++++++++++++++++++++++--------
>  net/netfilter/ipvs/ip_vs_est.c  |  83 ++++++++++++---------
>  6 files changed, 217 insertions(+), 108 deletions(-)

	Sashiko found some new issues to address, will
send v2 later today...

https://sashiko.dev/#/patchset/20260428175725.72050-1-ja%40ssi.bg

pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

