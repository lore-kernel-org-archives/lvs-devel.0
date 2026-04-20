Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A30763A6F0D;
	Mon, 20 Apr 2026 17:46:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776707164; cv=none; b=nUOFbz3Q/5pPsGLv7euWjgWTzusXmpQlQtu0FUF8DTaCyqa6lnR6a7F5ZUi79qPtFbOO5pZ0ZH9e2Q9Rd8uc7ipZxFphPcq6uvwmf6whdETV3XDZQ9Ow9y9gTU5qnBFnimztbx05NnzyIP99H1COKMEM6EhX+ddMKozvTyRjBws=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776707164; c=relaxed/simple;
	bh=oNFX4KUO1ItZiCtOYTlFMArxOrnxTg95jUZll16W3MA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Y+X6aWYv6fTNjXnEOJ5wRcnR728j+rfMOaWDJPpCZOIg+28nU0bVcOEjV7otMju51fKQ0uuQeIYmxAl9uRoYxDrqxFJGFRgg+/lDAExEjnaVeVk4VkbNBSDSwl7jtkR4JF38bULvLq+97FqeHQGl1Bogb8n3WVvY9Pr9RaIKwM8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=Jm8p/b0I; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="Jm8p/b0I"
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id 0F3AB60179;
	Mon, 20 Apr 2026 19:46:00 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1776707160;
	bh=X3epYX1rysX/3m+xlaYJE67jStRzHCmy2a51UfkBjfc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Jm8p/b0Irdzdqmq5Fd3teIM/PdGeAAahj0meT+twZZW5c5Af/bd1tUJDb9sszOEiN
	 sCzToNG0ktWIwKh5qG7pXMVVu8GXJHai2xv7TTFO5TJka02H5nr2UpVkKimcINXrsG
	 4gH/F6PBMK10OHnf2aNK7RYy6TLoQwD3sY/1bzpSH9tfoDL0H/eUl8Cyces6pvEZY8
	 LA0izXQhFFR/GbBRn0mj7okXfRZBKRiQhyE+Kgal2TjtkmxdrBdzcpq2QPLh91gWBz
	 cx8p1FBtqaUPGowwTA/fHhAmyRmqrXdJO2CIKEu6bnDQHcAInuUj2D0d2jz+eWOHVe
	 /LwHVEDtpXHZA==
Date: Mon, 20 Apr 2026 19:45:56 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Waiman Long <longman@redhat.com>, Simon Horman <horms@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	Frederic Weisbecker <frederic@kernel.org>,
	Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, sheviks <sheviks@gmail.com>
Subject: Re: [PATCH-next v2 0/2] ipvs: Fix incorrect use of HK_TYPE_KTHREAD
 housekeeping cpumask
Message-ID: <aeZmVMaMymU6ZS5S@chamomile>
References: <20260331165015.2777765-1-longman@redhat.com>
 <cd9afe18-9862-6005-f7d9-d69425b7d4cf@ssi.bg>
 <ac_OscBPYRwt73ic@lemonverbena>
 <097db82c-c9d1-4532-694a-b7ecbdd67532@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <097db82c-c9d1-4532-694a-b7ecbdd67532@ssi.bg>

On Mon, Apr 20, 2026 at 08:24:56PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 3 Apr 2026, Pablo Neira Ayuso wrote:
> 
> > On Fri, Apr 03, 2026 at 05:15:50PM +0300, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Tue, 31 Mar 2026, Waiman Long wrote:
> > > 
> > > >  v2:
> > > >   - Rebased on top of linux-next
> > > > 
> > > > Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
> > > > affinity management"), the HK_TYPE_KTHREAD housekeeping cpumask may no
> > > > longer be correct in showing the actual CPU affinity of kthreads that
> > > > have no predefined CPU affinity. As the ipvs networking code is still
> > > > using HK_TYPE_KTHREAD, we need to make HK_TYPE_KTHREAD reflect the
> > > > reality.
> > > > 
> > > > This patch series makes HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> > > > and uses RCU to protect access to the HK_TYPE_KTHREAD housekeeping
> > > > cpumask.
> > > > 
> > > > Waiman Long (2):
> > > >   sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> > > >   ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
> > > 
> > > 	The patchset looks good to me for nf-next, thanks!
> > > 
> > > Acked-by: Julian Anastasov <ja@ssi.bg>
> > > 
> > > 	Pablo, Florian, as a bugfix this patchset missed
> > > the chance to be applied before the changes that are in
> > > nf-next in ip_vs.h, there is little fuzz there. If there
> > > is no chance to resolve it somehow, we can apply it
> > > on top of nf-next where it now applies successfully.
> > 
> > One way to handle this is to follow up with nf-next as you suggest,
> > then send a backport that applies cleanly for -stable once it is
> > released.
> > 
> > Else, let me know if I am misunderstanding.
> 
> 	This patchset is now material for the net tree. To help it,
> I just posted patch "ipvs: fix races around est_mutex and est_cpulist"
> that can be applied before this patchset to the net tree.
> Can we get this patchset for the net tree?

Yes, I am preparing a PR.

BTW, did you get look at the report provided by the AI assistant?

https://sashiko.dev/#/?list=org.kernel.vger.netfilter-devel

If not, please repost to get initial feedback from it.

Thanks.
