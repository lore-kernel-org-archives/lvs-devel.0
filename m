Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C55A63A4F5E;
	Mon, 20 Apr 2026 17:25:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776705904; cv=none; b=KkYanUOsSEtqRDUtq0qQcOs5mu2VVTmNtGGUaIPeoaFSrIixEFnlAJUvkVQZk0/LXWwdygqsZAGSWgO8zNci3+Z2u1uk/B1A9FRmK3GSfUhEWsuiKtCCAb6T2LLlTjOfzgPKpfKjJF9CFwwpmnHIlW3qIXI86H6UrzU3fczexQY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776705904; c=relaxed/simple;
	bh=TkNIMoXK/7emKBB+Tva2Xpc9OFl608h0/Yc1KdtCpGM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=QcgSFuQXN+sKxMjcAN+UdW6zFmhUMML0JJo9P/bC8CNjIAZpGXgL/V0b0B8fCykqtwfM7ZcamvqWSZUn9q5o0JQ0mSkx4N3yfQXXNcFz6H/3buI5/y5Iyg+J4RouXUHO0vThAfYek2bn2GJdag/nk0qtBO0HEQMNSSuL7Vbm5QU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=qJQQ/vam; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="qJQQ/vam"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8B017210DF;
	Mon, 20 Apr 2026 20:25:00 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Eu2bW7WNFuuIEdpLyNA9bfyD9Dbu8t5W3z4YwWtWRb0=; b=qJQQ/vamjJmZ
	9N0AtKyV5TiaHgZDQRFQjblchPX/WtlLaWBUSeEW/neOR5MkuLj/yynqjz6HXdtn
	HlmjlqFbZ1pbqAgHxaL4hJZ/gP5fsxHfCnb67sapamieNieade8Gfs1VjhW4+mwq
	cHQs333YT8fjZRWwtv46303UB4w1XJg+l++R6vP/z5DgFi+tSoZAxD4borkv6hON
	wddv++UPU1e7fwz2H4NNOtmE8kR3bsJycXv+9XO8esgDgDxMkaFvkPwGBKCZjlw+
	EIaoI5QvOZ/AV/Tsqd3aEltcRjO0gc7qWaf4ps2Nq5Lax5Hbcx1btp64wDPEZ7+f
	HJEr7L6yZHgwGXgnrrSSjtAqHhhM0rlCGXkvc0dhqdvapA7IHxCh9fCgnfMWc4Ku
	aYfpq0I56jkaiqw3tCp3NCWyWKNNekolONb6xySqF0OxKtPPw3h1xgnoK46sfnh3
	53FR+neWI6Pu6NWjJt8fgsi84u7ux7ZfEX+gfk5yLGF2z4FLZRWugRy9Ib4qZJf3
	+XYcAT2l/zwTQ0j3FNBh2+ca7pTs1lFbzqqu453eJwsZ9BndxVAUT6mBh3DoTOH4
	qM/Qn0vFEoehkFKtJuploMnD4e0hLk3DPPB8OqwKafZ1fpU4oX/tE6PbdjoPLBTT
	lkhA4YrQWbmFJ1X6T0N00onwqnn8Vto=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 20 Apr 2026 20:24:59 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C6959628C8;
	Mon, 20 Apr 2026 20:24:57 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63KHOuZV088012;
	Mon, 20 Apr 2026 20:24:56 +0300
Date: Mon, 20 Apr 2026 20:24:56 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Waiman Long <longman@redhat.com>, Simon Horman <horms@verge.net.au>,
        "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>,
        Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        Frederic Weisbecker <frederic@kernel.org>,
        Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, sheviks <sheviks@gmail.com>
Subject: Re: [PATCH-next v2 0/2] ipvs: Fix incorrect use of HK_TYPE_KTHREAD
 housekeeping cpumask
In-Reply-To: <ac_OscBPYRwt73ic@lemonverbena>
Message-ID: <097db82c-c9d1-4532-694a-b7ecbdd67532@ssi.bg>
References: <20260331165015.2777765-1-longman@redhat.com> <cd9afe18-9862-6005-f7d9-d69425b7d4cf@ssi.bg> <ac_OscBPYRwt73ic@lemonverbena>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 3 Apr 2026, Pablo Neira Ayuso wrote:

> On Fri, Apr 03, 2026 at 05:15:50PM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Tue, 31 Mar 2026, Waiman Long wrote:
> > 
> > >  v2:
> > >   - Rebased on top of linux-next
> > > 
> > > Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
> > > affinity management"), the HK_TYPE_KTHREAD housekeeping cpumask may no
> > > longer be correct in showing the actual CPU affinity of kthreads that
> > > have no predefined CPU affinity. As the ipvs networking code is still
> > > using HK_TYPE_KTHREAD, we need to make HK_TYPE_KTHREAD reflect the
> > > reality.
> > > 
> > > This patch series makes HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> > > and uses RCU to protect access to the HK_TYPE_KTHREAD housekeeping
> > > cpumask.
> > > 
> > > Waiman Long (2):
> > >   sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> > >   ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
> > 
> > 	The patchset looks good to me for nf-next, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> > 
> > 	Pablo, Florian, as a bugfix this patchset missed
> > the chance to be applied before the changes that are in
> > nf-next in ip_vs.h, there is little fuzz there. If there
> > is no chance to resolve it somehow, we can apply it
> > on top of nf-next where it now applies successfully.
> 
> One way to handle this is to follow up with nf-next as you suggest,
> then send a backport that applies cleanly for -stable once it is
> released.
> 
> Else, let me know if I am misunderstanding.

	This patchset is now material for the net tree. To help it,
I just posted patch "ipvs: fix races around est_mutex and est_cpulist"
that can be applied before this patchset to the net tree.
Can we get this patchset for the net tree?

Regards

--
Julian Anastasov <ja@ssi.bg>

