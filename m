Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C7823BB9F5;
	Fri, 22 May 2026 17:12:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779469967; cv=none; b=NQrVqatqznmqCjDSfFVbXZWCKQdAlsIIs1CyIWmTphK34yg57Ziy/chlhozS42Ynzgue4lNQQ7ucyjyeOxv/YzNulqWcN53Xl1d47M9G+TNpbfef++lvW0WU8kiIUb0RNagUibXh7umBB8dCQXwryUj86EB8xM4kIYrjf08iR1I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779469967; c=relaxed/simple;
	bh=9TD24qnXKMXs/pwYGcu89Ppk3LT3Qlww+EtwloKv0jc=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=czAx0pL8f8VgI/Ij7BXQ/HftW8UjlLuEiivo8Xc0Wac3Yn7JPSjkFi/tEHpnzd69qr3B02tRt84tWkBajr927yMC0yQqGhX7Nk0woWMDWjPRkr9qk7vaT2L9EkQQcgHhKIwfPvUkE+4oRMUHL9g7tgGl3KPu0XY1tOlYSs6fGSs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=7YKXerUf; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="7YKXerUf"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 615EB20FC0;
	Fri, 22 May 2026 20:12:40 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=TX52SlEc4bVbz/ss6p+x7zupauqWfmmslyf1wMLcJLg=; b=7YKXerUfjbCU
	VDT+Kaw1fiLv/MLa7/F6AHqli/LfcbrmUjQvgCoaVtLuJeKZ1ttnzem6+ls77fn9
	BY0K3NFR5pIcZFYRTBe7rHSUlPv3QdowAXHLLB8v+HRIqc5YRTjkGbMXLm7aCfnE
	O9XFnm1Q8iEhcrOUlLuN7hkZgjUfPaErp+6W29GwzhpToq+s+bPZGXAZUS1cbQmC
	J4t7AsRpGdccHDxU5yfRBhgPAGIXiswtjOZ37LShFVCOM9pYqh2/og3FQYqxL1EU
	cKnILzBBa8Zl9midBNDORa7pv3BfZy6s/oJOT6P3XDoD1aUTSRLK5I8/w8i89An6
	S2xuKpWEKzZmIdGRxfiKDNInaUz7gOVhjNPT043atWhcYe2nmW38QsOzPjanumvr
	STXEQ7evJqysHVXk5I6aoUVeUtk6RTlzHyVnjksompsXRJAhMqu0Bu8UI7Y4qEgJ
	pglvCcJYtLHeUMLJrFK2Veat1u3wPyU/S+Y8PX8CqH0trDEWjdNvB4KHrZzmRJEz
	VZzE5qChc+UeGqijDgREvAjtipVp8DmKZgFF8+gkp3hubcfmBxxnR2RhWmXQ0Ca3
	3+GKvR5U20rua/2DQC1QV6PKRfZre1O2PF9frvBUBGBtJFWuVxFVRaqfqxOEEIGj
	wE5+BUh02F8NTMmUZ1X7d7IpRE1rCj4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 22 May 2026 20:12:40 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3482F60400;
	Fri, 22 May 2026 20:12:38 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64MHCW9P042584;
	Fri, 22 May 2026 20:12:32 +0300
Date: Fri, 22 May 2026 20:12:31 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Rosen Penev <rosenp@gmail.com>
cc: netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        "open list:IPVS" <netdev@vger.kernel.org>,
        "open list:IPVS" <lvs-devel@vger.kernel.org>,
        "open list:NETFILTER" <coreteam@netfilter.org>,
        open list <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] ipvs: Use flexible array for MH lookup table
In-Reply-To: <20260519015506.634185-1-rosenp@gmail.com>
Message-ID: <ae2ed619-0562-afd8-1141-56116e9da68d@ssi.bg>
References: <20260519015506.634185-1-rosenp@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 18 May 2026, Rosen Penev wrote:

> Store the Maglev hash lookup table in the scheduler state
> allocation instead of allocating it separately.
> 
> This keeps the lookup table tied to the RCU-freed state lifetime and
> simplifies the allocation and cleanup paths.
> 
> Assisted-by: Codex:GPT-5.5
> Signed-off-by: Rosen Penev <rosenp@gmail.com>

	Thanks for the efforts but it is better to keep the table 
allocated separately. As Sashiko [1] points out, the table size is
properly selected and we risk double-sized allocations if we apply
this patch.

	As for the problem in ip_vs_edit_service(), I have to
provide separate bugfix...

[1]:
https://sashiko.dev/#/patchset/20260519015506.634185-1-rosenp%40gmail.com

Regards

--
Julian Anastasov <ja@ssi.bg>

