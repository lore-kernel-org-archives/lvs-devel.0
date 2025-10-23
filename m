Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6ABA3319879;
	Thu, 23 Oct 2025 13:34:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1761226451; cv=none; b=CFDeiOL7AxQty8n9F4OnB2HIfL+tIGvYsgxKX3sSutFUKujvhH2gV4XIp52B4tccqGhD3R+Emof6Ka8Crfc9Ht6D5qE14TgfLWoXgyjo2H/CyLACxTaezwu4Z0zHNVJgMm6vvqtfY+f+ZDHdw9/28FWYkAG5Kc8hvIMTVv9IWPo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1761226451; c=relaxed/simple;
	bh=EMWnoDvdouQEiems/UKWSZG4GWLIuTO1uGHdcr27QoU=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=BPGNTfI4gHuNLWjpFWdkQj5wKPMoGMgC32FE4bk9I2FjkG2NBRBeSGX1f6cr7ZDUjSrN9f7STHwvAZ7xt8y6bTGv/MUgircv7r386IvMWUZbNQl3jLhu66N/9tDh6oliVPisdudg9mfcvIPyT1CwEtspzqy/plD3IPy6J4ziSe0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=FM78i6gr; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="FM78i6gr"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 528AA21F08;
	Thu, 23 Oct 2025 16:33:57 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2FeQsBVcmNGXLtQpZPxtMa5+Gz5//4pX6/cnBqjt2s0=; b=FM78i6grLwkY
	p9j+yLYxdVcbqFp7Cl5IBwZRWyeS3um5EafN+wxO3/xla9ZeuGXnwTl/66Hq9s6i
	TH8ZUJfT4fN7IUWH86aj2xWn9PJ1OtUGMeO14uWSk67luWYM21V8CnzxZK42Z+zv
	hmNQUJoGFNUZcSVwl89rNgKTSfnda0vVwDr2OhpMVNhFSBn12J173FihdEeZWm8E
	QxFCYrHxs4eMVJoKrBVeRAR5OQtv87JnaWW43nI+U5MNCDzMq9LX6xmPCWBSWadB
	GVCwHiDDlidmIqSDNQFQCy7V41TI88MZrxu50unpujJIvkbu86Zx2TMaQcB5V1AL
	idT9nAUGPJvtfAIgM+fNdKmz58fcWy8ATsm2pNpywW6rRXnpRYJcNdrr//vnYPor
	vcmrFgAi62ms2dHodUcLXY5+Bm3B3zp7Z1amDH/HM9ataiWDF1pAB5NsbMtu2EE9
	2IzKJQj6xSmpoEv9lu7rkboJcAhMrpmwDIZ0npiKFfQMgXI0MhsC0RE7B7tT5809
	QxpnxVRBhMa8YF0r1X/lUdoZTh9VMO8zroB7/6rio29pf5FkrtkkzF2F03Wy+w0T
	lPVTqvigZ5kbHBkuKNS8HIvEhJCsprlsKupNagwMsX5WvMfcBk0cj9ytopYxexDI
	UNQRf+aif0gzS3NUA18nMrddsKbGVDY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 23 Oct 2025 16:33:56 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9B865652E5;
	Thu, 23 Oct 2025 16:33:54 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 59NDXjn5035080;
	Thu, 23 Oct 2025 16:33:45 +0300
Date: Thu, 23 Oct 2025 16:33:45 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Florian Westphal <fw@strlen.de>
cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 01/14] rculist_bl: add
 hlist_bl_for_each_entry_continue_rcu
In-Reply-To: <aPoVDMXeakOsRGK1@strlen.de>
Message-ID: <29389f3f-b101-3694-ca16-5b86b2fa619e@ssi.bg>
References: <20251019155711.67609-1-ja@ssi.bg> <20251019155711.67609-2-ja@ssi.bg> <aPoVDMXeakOsRGK1@strlen.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 23 Oct 2025, Florian Westphal wrote:

> Julian Anastasov <ja@ssi.bg> wrote:
> > Change the old hlist_bl_first_rcu to hlist_bl_first_rcu_dereference
> > to indicate that it is a RCU dereference.
> > 
> > Add hlist_bl_next_rcu and hlist_bl_first_rcu to use RCU pointers
> > and use them to fix sparse warnings.
> > 
> > Add hlist_bl_for_each_entry_continue_rcu.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  include/linux/rculist_bl.h | 49 +++++++++++++++++++++++++++++++-------
> >  1 file changed, 40 insertions(+), 9 deletions(-)
> 
> Are the RCU maintainers OK with this?
> An explicit Ack or RvB would be good to have.

	Paul McKenney requested on 15 Aug 2023 some changes
for 1st version:

https://archive.linuxvirtualserver.org/html/lvs-devel/2023-08/msg00044.html

	And they are now present in v2+:

https://archive.linuxvirtualserver.org/html/lvs-devel/2023-08/msg00057.html

	So, the RCU change is expected to be ack-ed after
the other patches are accepted. I'm also expecting review and
ack from Simon, so that we can finally include the patchset
to -next...

Regards

--
Julian Anastasov <ja@ssi.bg>

