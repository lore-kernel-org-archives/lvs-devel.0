Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AACE35FF6E;
	Fri,  3 Apr 2026 15:00:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775228430; cv=none; b=Ec9wjWZfEorbDSZNH6SgPN4pEJuYsNoD7FjYGqw3qGtMWvAB9ySP+S00jJZ9s+zIrOZvDEC+K0BbyzgI54X4g/YVn9Scdw0m8EULbdpuY/f+ujAXjXxmREg6L29yDs48hdVnMmS0w+OacQ+9oi0PEqWzb5y+ih9gdHAkrLR8Nq4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775228430; c=relaxed/simple;
	bh=lSwJJxyQQljcNC56R90Y+9rYHYcNxQz8zzmHR9mf2cY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Hil9LC9LljGLeUyoUWL274FogZQuE/9JM9wTY9yWHtGac45OZ7O0d96DqlqmAe6v7HsVusBKRM1JHGuMg3as4yceAJ9exOdnjMhF8dG2yR2KADJe9jYiMsxnYNw02VuNRdologJkZUaz848Q5H019KVFA0btK4pLoj7ZXoQD0TI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=3WnOA2y0; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="3WnOA2y0"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 181A621C55;
	Fri, 03 Apr 2026 18:00:25 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=ADBT3o7QluRm1wTycq7vwPTpj9WJ5zsXj9jd4emz3zM=; b=3WnOA2y0aAyA
	uZRfPuNqM6T+zdrBJqGItzw32ewbpLS4T9lYLGQSql9fdpPzJpFqz+tEKXQbN5eH
	FfKLTvLe4ZOcBljt8VzVOa7ECZhnJ5JbR4bBnVOC8gBlRMjbHYDjf4xj7fxos/+s
	KeV4qyyJ/GKcCQa8AITPecZOfz4xmYB0UWC+TzOpXOgV6ahRgD3U+bjI/iyJVtn2
	E/lsekiiKz6/0TiNFU3Rm2+sBYi9nFkdBXuppbCYglzEpzpn2lxFI1YqGECf5dYv
	7TP/lxVgpcpfu4HX2q9UT0uSdjeNaLHY2bsezQS3HUMbBpADApUUSjZeQwrY8VC+
	DWFctHRkAXybdbIbq13RlqKtoBNvxzVIaykKbDXkYqXKXlavuGI/tWfcg5hl8Dw3
	+1GDw94qTdBYBXK/57nA6bQ/a/+ZyokDFQ3IygD7vLEnQuTKF4k9U3cM6CifJNHJ
	RNbRw3YJYZc0/9J/U49bQspJSbODtanEW8j23AONzE0Oqe2JGCgYh2UD8kizMkco
	UVYJEJV/nZ/sZt+F+0NPdC3tFW8u9I49IRwUdfVRXMNrHQmVJDVkyx4N4DO9jiIS
	fxI/qrXrVSNhUwBG2omLqoC0usJT+F5A9RlMRIW5e8Qi0liY8GDrB/Znb5V9xNeb
	1Ns5gXhgAI937mdVV6y9eEYdyyt3IW8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 03 Apr 2026 18:00:23 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7A3E8608A6;
	Fri,  3 Apr 2026 18:00:22 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 633F0Ix5040894;
	Fri, 3 Apr 2026 18:00:18 +0300
Date: Fri, 3 Apr 2026 18:00:18 +0300 (EEST)
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
Message-ID: <06fafbe9-1326-e596-46b7-df46ac29861e@ssi.bg>
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

	Lets do it this way, thanks!

> Else, let me know if I am misunderstanding.

Regards

--
Julian Anastasov <ja@ssi.bg>

