Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 283436AFA9;
	Wed, 20 Mar 2024 18:04:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1710957847; cv=none; b=rT20W8QGeHbG6zJksLzcP++b/e2bvr8JIBcKGixtHO48bxsqFxhLPlFzKzWRSCMbWumEamCvCYdDEazyydML0bkLvsF2HTaGz5Xdu2yjPrvoGznZvjF6CMpVj2/CutP0T+okhRzm81q+Gh12mypibaNvMdZY2Ux97Hsgg5QP7mo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1710957847; c=relaxed/simple;
	bh=CHj1fVs2X1iupJRhrtJtKwO0NzXqGNnEz+FgrsbG5wA=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=H/Yz1DUXRQGC64cmsa+7iE7O8hUKCDeVMrUfDAcDnYVHfAqQlSPWAdOMsliQ5q6eAd56dbgGHdDeg3yLmRHvlW4aDRCwnI0fYtA81xpxYT0LrLtXVMkA8RPTW8l7wjtVl7/Q5Q5SgF7Eoo3aSGmPXRfUIO59nVQBxjOFsNfNBOQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ITC6L6Eo; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ITC6L6Eo"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 22CF236BB1;
	Wed, 20 Mar 2024 20:04:00 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS id 0D28536C8F;
	Wed, 20 Mar 2024 20:04:00 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id C388E3C043A;
	Wed, 20 Mar 2024 20:03:56 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1710957837; bh=CHj1fVs2X1iupJRhrtJtKwO0NzXqGNnEz+FgrsbG5wA=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=ITC6L6EompA9azN6B+w+3TEupmNaPE1/tiJZO8LPe5H4gMpuy1RDJMxx0iINdBEjE
	 ta5iqjaivwigoR1GqRByDXJB1r2xECs/8omLDtyljUPgm6fWCWGyCLsGUXJ9qVdm68
	 akfUAhLX7ahzy77qS9PXvJezWqwkxhSh615FpBhA=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 42KI3jIa090087;
	Wed, 20 Mar 2024 20:03:46 +0200
Date: Wed, 20 Mar 2024 20:03:45 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Zijie Zhao <zzjas98@gmail.com>
cc: horms@verge.net.au, davem@davemloft.net, dsahern@kernel.org,
        edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        chenyuan0y@gmail.com
Subject: Re: [net] Question about ipvs->sysctl_sync_threshold and READ_ONCE
In-Reply-To: <5fde8ace-a0ac-4870-a7fe-ec2a24697112@gmail.com>
Message-ID: <4ca70110-b6fb-3842-0d9c-538dbc8cfde3@ssi.bg>
References: <5fde8ace-a0ac-4870-a7fe-ec2a24697112@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 19 Mar 2024, Zijie Zhao wrote:

> Dear IPVS maintainers,
> 
> We encountered an unusual usage of sysctl parameter while analyzing kernel
> source code.
> 
> 
> In include/net/ip_vs.h, line 1062 - 1070:
> 
> ```
> static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
> {
> 	return ipvs->sysctl_sync_threshold[0];
> }
> 
> static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
> {
> 	return READ_ONCE(ipvs->sysctl_sync_threshold[1]);
> }
> ```
> 
> Here, sysctl_sync_threshold[1] is accessed behind `READ_ONCE`, but
> sysctl_sync_threshold[0] is not. Should sysctl_sync_threshold[0] also be
> guarded by `READ_ONCE`?
> 
> Please kindly let us know if we missed any key information and this is
> actually intended. We appreciate your information and time! Thanks!

	Difference comes from commit 749c42b620a9 where we protect us
from division by zero by using ACCESS_ONCE at that time. The idea was
to read the value only once. Nowadays, READ_ONCE also has the role to
avoid load tearing, so, yes, all sysctl vars should be accessed with
READ_ONCE but this is a low priority goal for now.

> Links to the code:
> https://elixir.bootlin.com/linux/v6.8.1/source/include/net/ip_vs.h#L1064
> https://elixir.bootlin.com/linux/v6.8.1/source/include/net/ip_vs.h#L1069
> 
> Best,
> Zijie

Regards

--
Julian Anastasov <ja@ssi.bg>

