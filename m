Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9ECD63EFFB9;
	Sun, 27 Sep 2026 14:07:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790518037; cv=none; b=GAxfSGU4HUEOtK4OFePMDE2zuuIdkI2jhLSRnR0EUM5bZObWY3EAqXrMaPybHjdfAYfNyPu21Vh00hh6o4abOeuUm3wdQilvynZMR8OB+ioTgrB8g7KbCsOt5VbkxZ1G841N4xRBGkT6+KFbUfPvrZd2IqEvzQe9bppImQkpoas=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790518037; c=relaxed/simple;
	bh=ei33wHQIJuPwIMvHn69UNmwgT0J7foNqftP+llX67tQ=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=OdF5Tx8fBCd+hJmdCI1vSSUJemVX+RA+aFs8cLeGK/BpJhTtuvPbvnYYYdUq9/Kjkfiav20IY84zfQEADoOLfkgKyE0byOVAKqAsf1pcoGDjrolZma9EunWHdj5ZonSzxkadn9CWoryCrsnE0MoXTxLGKIUlMnl3j0WvmyiXc2w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=iU11ICNH; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="iU11ICNH"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 65548213B9;
	Sun, 27 Sep 2026 17:07:09 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=826f0LRPtnVWStruqhrlddsdYzfjFuwQpLZYDpuV8bM=; b=iU11ICNH/AbK
	UcAFAXE87CTIGEDYj4eh8T+7TBYCNXJG712RHw5XcQ8jnyjNvVDauZJ7+Lfk/i3s
	f0jhZXsIKzwKOTkprinUK/UzHBaHKtMNuu+JfCdrLk3AIRi/d3PTNUE6bQ+FdLIQ
	dR3VdMKLd/h/pV9K3XJ3O8t9ZfxvilY3/o3aL45zjMSsdl0WFp940E89/8g4BTsD
	WPTjdKAmAxPmULnMfZtT/H0rz6vIJO3cD9spssMXJx/sFoOUHMpYZCa+XohVk5pT
	PFyDYr2ueaOrHdYWBsASY8b9DQNK2ldG5p77vv6wSAlG0xYmz3IHwPX/SmdgTuFq
	06L8uawr9GF0kAKKzU1biaXW3G1tkq1QJ9RtRKWSgjYvkk4wjnqanZ/NYIyrlN/W
	SUsI8ur4A4VaFHp2NHnQKWFTFf15xbx5gnNhmw3SxnmNOLrJrtFNFa2MAFUZxG9L
	ItZK6pKKULfeKbIX5zuepy2K0vdfKnd/7TB+F545uhn+HFaBpjnNaTPeG8FIOKvA
	OnVGN72CGHaBRWXrC/d3Wv8SPDX7ERxokYiwQNMoCvmUwJg5ZEoDh0U02Wuh0ETN
	/+k76zwQXKcsTw+DL8W+etvlBtqwHVHW3LVMa75EqzitB7SbUJ6fnoUtcfbYVqpS
	QVoyIcuDUh9wO2kj/BG0i6jEEpIzUTE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 27 Sep 2026 17:07:09 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A9828605F3;
	Sun, 27 Sep 2026 17:07:11 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68RE7AZn049344;
	Sun, 27 Sep 2026 17:07:10 +0300
Date: Sun, 27 Sep 2026 17:07:10 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zihan Xi <zihanx@nebusec.ai>
cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, horms@verge.net.au,
        pablo@netfilter.org, fw@strlen.de, phil@nwl.cc
Subject: Re: [PATCH nf v5 0/3] ipvs: avoid stack overflow from recursive
 connection expiration
In-Reply-To: <cover.1790266803.git.zihanx@nebusec.ai>
Message-ID: <ce3d490f-4be4-7eaa-0993-c1e4d1fd863c@ssi.bg>
References: <cover.1790266803.git.zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 25 Sep 2026, Zihan Xi wrote:

> Hi Linux kernel maintainers,
> 
> We found and validated an issue in
> net/netfilter/ipvs/ip_vs_ftp.c and net/netfilter/ipvs/ip_vs_conn.c. The
> bug is reachable by a non-root user via a user namespace and a network
> namespace.
> We've tested it, and it should not affect any other functionality.
> 
> This series contains 3 patches:
> 
>   1/3 Fix the timer callback race during IPVS connection deletion.
>   2/3 Replace recursive controller expiration with an iterative cleanup
>       path.
>   3/3 Reject zero and configured FTP control ports as data ports.
> 
> We will provide detailed information about the bug
> in this email, along with PoCs to trigger it.

	There are some valid concerns in the Sashiko review
that we should solve with v6, so we are dropping v5.

pw-bot: changes-requested

> Best regards,
> Zihan Xi
> 
> Julian Anastasov (1):
>   ipvs: wait the running timer cb on conn deletion
> 
> Zihan Xi (2):
>   ipvs: avoid stack overflow from recursive connection expiration
>   ipvs: reject FTP control ports as data ports
> 
>  net/netfilter/ipvs/ip_vs_conn.c | 117 ++++++++++++++++++--------------
>  net/netfilter/ipvs/ip_vs_ftp.c  |  18 +++++
>  2 files changed, 85 insertions(+), 50 deletions(-)
> 
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

