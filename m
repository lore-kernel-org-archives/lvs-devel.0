Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA6928248E;
	Wed,  8 May 2024 11:30:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715167829; cv=none; b=LGPjmHh5bENFHPvb6iQ7zYehG1T69mV/pwHRVPh2Voq/JZtP4Ulyo5RvBBfXc9YPqLBbzWnsPH7wui6vTFSD/UcWZ/O2s6bV59qiG9O9y1REJnodBIscBNpvas4Q9zR5Z1y6lj5MKlwdlswIwGp1vU7vS+8cMtNEWMqaJsoEdSo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715167829; c=relaxed/simple;
	bh=ZWwvIlpDfXjQiHlFpfVwvKlXouqi+uWHU0X/OwSj8eA=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=jIjcAldLNF+XiIEmbYYF+NfjoDjJS33K41/umrIBzCvxo2FpbqujvRWkoWOrPkfAL36I8Z1DpxJV6Vdmd1BfUBhitz9FS7lNWzsjyRoxPAKWhAvK0q1nZNeLtG/SgXIyMIP3DQemDGd9nSwhZ2X11Fdo4JIIe0PU1yCmB11pa8c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RFbOiohp; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RFbOiohp"
Received: by smtp.kernel.org (Postfix) with ESMTPS id A6D14C4DDE1;
	Wed,  8 May 2024 11:30:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1715167828;
	bh=ZWwvIlpDfXjQiHlFpfVwvKlXouqi+uWHU0X/OwSj8eA=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=RFbOiohp7ndeulJ/85d8ir4PvJ2UFBFYNR1PwRR1ORHWpSuE9NqZdLrsYfb1LatKh
	 ssBELM9UwJo8hXN+Y34a5N8+NzFfp/S1mbDLle2EOk43LioXFNa8Kce8oWPoQmRDrg
	 us4iF+YiAmGBLkMvQIN+CDvDWLRJijazf0Zz57OeE83zIKWpsUISIKD6rb1zrE0J2R
	 eHr0/94245mqt3WGyhDBLTrhxBVgM7zBR5yPgb3w9+utbKHr+gmiiULg5j3aHP8/Xg
	 F3fGZNaYZKa4Z3RLSJ7/wl042pY8+EptX2D9CbBqAFYKy2kbT4Dd+Wf9jYptv+WtI6
	 HXHwnmCVm70Gg==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
	by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 964ADC3275C;
	Wed,  8 May 2024 11:30:28 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v4 1/2] ipvs: add READ_ONCE barrier for
 ipvs->sysctl_amemthresh
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <171516782861.10113.14484359490290066834.git-patchwork-notify@kernel.org>
Date: Wed, 08 May 2024 11:30:28 +0000
References: <20240506141444.145946-1-aleksandr.mikhalitsyn@canonical.com>
In-Reply-To: <20240506141444.145946-1-aleksandr.mikhalitsyn@canonical.com>
To: Aleksandr Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
Cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, ja@ssi.bg,
 pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de

Hello:

This series was applied to netdev/net-next.git (main)
by David S. Miller <davem@davemloft.net>:

On Mon,  6 May 2024 16:14:43 +0200 you wrote:
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
> Cc: Florian Westphal <fw@strlen.de>
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
> 
> [...]

Here is the summary with links:
  - [v4,1/2] ipvs: add READ_ONCE barrier for ipvs->sysctl_amemthresh
    https://git.kernel.org/netdev/net-next/c/643bb5dbaef7
  - [v4,2/2] ipvs: allow some sysctls in non-init user namespaces
    https://git.kernel.org/netdev/net-next/c/2b696a2a101d

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


