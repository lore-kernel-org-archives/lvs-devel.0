Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E82933A6E9;
	Fri,  3 Apr 2026 14:16:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775225783; cv=none; b=DgxzUZyWVdMpQpm5xSnaXERcnJhBycF7OaWub6kxrYAvuPV3B1NOXoslhCCBeu9zSEWvrbtTp1xzZX8TK6r2l3EaxWuWaLKxcqk1tQfQ6NQA03Vkit1PMOsqEgKwg9m6gsCvK0NaAd5amlSocbr5uXrltiZ6k1VK2JHQHYvz694=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775225783; c=relaxed/simple;
	bh=jYbzIB7KuDQXMF/BEXEFJ2HL31cx8w4RqmD2iW7hxek=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=JD3Of99hH0OHkMid4mliCoNs5+US9e6io7qdcq4jsIb0dqaJssEJc8tNfY5EYgdE/PwUNUQMIlhNrlwzDae9u2VCCTCXTTRKS22utubsD4SpkzDVuCgEV/ZVpvBdB4ARkSkoHK7IJdfxfTF8WMU6FcP3l1R+Egy26kXiMq5HuTw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=CsB/XVUc; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="CsB/XVUc"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A3F2A21C55;
	Fri, 03 Apr 2026 17:16:08 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=z6ZXzmDuiujBqpb4kye0eh62yZOclw7FyfwpE6HbmIo=; b=CsB/XVUc3GaQ
	JYI1TCpbD2vsZOoJhTV3X7xZvMeCGjSd78/rKrTCMQS4B6bdeIRCTdqTJ5Z+Xz9b
	cDLSBWsZcwcOWnjZY9V0FZVV+yvvaS5ijyeaVumD3ab5RBj73lfrJLTb7TLW0CJM
	P6k75XKtcJz7vArwuexM2l/rKIp1UaBNndgtxTDrgMxj14Yutl3iDALlSr5PNRCw
	Do+dhm1h+3uGduCD3jjMXS52As9WjDvWBIDmNEppc1oWmDn8+zjyf7B6h9tQWXSJ
	FN0vLHY3AXKJEDjSeJPmGdstSdYlIWiyqVtRckovikmENdRwkDzULdj8VmKJZgKS
	NHB1JJFcIRTpwgMajCcLj3b1Qgx6XFZ6UZWhi4Cli7BrHHEXSp3u5p9r28ktOUFH
	ApLpwIlsswdX0dNCxHKi12oRRnNKUErhD9kiUk2/dwB4IgQRzsILMjGrCMLhXEZA
	WbnzjtBJAvZB7p0TIlJw9yfeQ31d2F/8LEBw1DZix8XtB39CtNyja7rHnk0TeP07
	XijMpW3bengA26BwtAt5nI2Wncf7xWxO+eh44Oe3Vcssp44rXYFA5L+XPPqaf0/Q
	FBGqObhnncdLNoqtpS/NtyXlFDguNvQc5cHBTDQf1HKMREmebXJSMmydbsQFDAH0
	pegfKgEXBeBLrQ02FpbDQy9dDoZFqi8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 03 Apr 2026 17:16:07 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 33842609FA;
	Fri,  3 Apr 2026 17:16:06 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 633EFodQ036518;
	Fri, 3 Apr 2026 17:15:50 +0300
Date: Fri, 3 Apr 2026 17:15:50 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Waiman Long <longman@redhat.com>
cc: Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>,
        Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        Frederic Weisbecker <frederic@kernel.org>,
        Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, sheviks <sheviks@gmail.com>
Subject: Re: [PATCH-next v2 0/2] ipvs: Fix incorrect use of HK_TYPE_KTHREAD
 housekeeping cpumask
In-Reply-To: <20260331165015.2777765-1-longman@redhat.com>
Message-ID: <cd9afe18-9862-6005-f7d9-d69425b7d4cf@ssi.bg>
References: <20260331165015.2777765-1-longman@redhat.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 31 Mar 2026, Waiman Long wrote:

>  v2:
>   - Rebased on top of linux-next
> 
> Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
> affinity management"), the HK_TYPE_KTHREAD housekeeping cpumask may no
> longer be correct in showing the actual CPU affinity of kthreads that
> have no predefined CPU affinity. As the ipvs networking code is still
> using HK_TYPE_KTHREAD, we need to make HK_TYPE_KTHREAD reflect the
> reality.
> 
> This patch series makes HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> and uses RCU to protect access to the HK_TYPE_KTHREAD housekeeping
> cpumask.
> 
> Waiman Long (2):
>   sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
>   ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU

	The patchset looks good to me for nf-next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Pablo, Florian, as a bugfix this patchset missed
the chance to be applied before the changes that are in
nf-next in ip_vs.h, there is little fuzz there. If there
is no chance to resolve it somehow, we can apply it
on top of nf-next where it now applies successfully.

> 
>  include/linux/sched/isolation.h |  6 +++++-
>  include/net/ip_vs.h             | 20 ++++++++++++++++----
>  net/netfilter/ipvs/ip_vs_ctl.c  | 13 ++++++++-----
>  3 files changed, 29 insertions(+), 10 deletions(-)

Regards

--
Julian Anastasov <ja@ssi.bg>

