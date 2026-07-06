Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E51613F39E8;
	Mon,  6 Jul 2026 10:50:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783335043; cv=none; b=ijkJC5Wsvzq93AK2G8SWX9thg8ZwRpVewOQ8/ynDIynQCAhjxZ+PKT30mxtka7Qvv2auSQrij4QC49AeonvviYwmsQq9n3zZOcYvNaTrTcvYssVZTmnQ9gv1mVICPXtcB4fVJX/oTtglUt2doBbqmoXWMrXVs4TxgCE9CRDEAVg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783335043; c=relaxed/simple;
	bh=yctoVFD91OFx4fFlRA1MPazNYejGlaXFotK29gkw3PE=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=JJLZ4WLeEpfQOBUIQjx+PhyZYn/heMQj1l5DPvu5DmDn/CGoP7j3olM74l9DcIfu0+6JCjs3xGpg45prqoNGp1BrYAAoBqOTmmxhurKUV/D3oQmCLfiMHhCrPsmd11VZP8cLWoA5z/cHeP4RdXn5jhR0Xj7EXPMnFajx0O7D5GM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W8tOvrpS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W8tOvrpS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 817EE1F000E9;
	Mon,  6 Jul 2026 10:50:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783335041;
	bh=yHJBd2n2Sa1J667oouse/pt4NTBKScB7z7klNN5CAW4=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc;
	b=W8tOvrpS0wE/XmOlbNX/4iDM9O9oBpzhAYZB9E4myqREVCZvlpm2ENicf4Umj1wgm
	 J+z78r96kEnsPoRAsugoIt0xPxGMxkje/OzsxYuTFeloZVOPjl6d4sGzE80X7ahbmC
	 9pQSe9gKu7dVDsuw7NolP6hD7mybDC+C6e8NImZHR30zndQ3Jv7RHJnbvThLjYsyLe
	 iFa/30wzdk4eqdYVWdX+vZbFnsjtNYNedX5FS4WnyioozbL4Jhs7SF6di65iWEG08/
	 dS7zZQVtGTbGDyqsx9bEOqnimCZiX8eKSM/SDGY0UXsRet013wt3w0TXdzg0gvGb3H
	 EiPO7dmRYfBaQ==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 56B3C3ABD2A5;
	Mon,  6 Jul 2026 10:50:23 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH net v2] ipvs: fix PMTU for GUE/GRE tunnel ICMP errors
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <178333502188.500093.18161993584904393152.git-patchwork-notify@kernel.org>
Date: Mon, 06 Jul 2026 10:50:21 +0000
References: <20260702073430.67680-1-zhaoyz24@mails.tsinghua.edu.cn>
In-Reply-To: <20260702073430.67680-1-zhaoyz24@mails.tsinghua.edu.cn>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Cc: netdev@vger.kernel.org, horms@verge.net.au, ja@ssi.bg,
 pablo@netfilter.org, fw@strlen.de, phil@nwl.cc, davem@davemloft.net,
 edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 yangyx22@mails.tsinghua.edu.cn, wangao@seu.edu.cn, fengxw06@126.com,
 qli01@tsinghua.edu.cn, xuke@tsinghua.edu.cn

Hello:

This patch was applied to netdev/net.git (main)
by Florian Westphal <fw@strlen.de>:

On Thu,  2 Jul 2026 15:34:28 +0800 you wrote:
> When an ICMP Fragmentation Needed error is received for a tunneled IPVS
> connection, ip_vs_in_icmp() recomputes the MTU that the original packet
> can use by subtracting the tunnel overhead from the reported next-hop
> MTU.
> 
> The current code always subtracts sizeof(struct iphdr), which is only
> the IPIP overhead. For GUE and GRE tunnels, ipvs_udp_decap() and
> ipvs_gre_decap() already compute the additional tunnel header length,
> but that value is scoped to the decapsulation block and is lost before
> the ICMP_FRAG_NEEDED handling. As a result, the ICMP error sent back to
> the client advertises an MTU that is too large, so PMTUD can fail to
> converge for GUE/GRE-tunneled real servers.
> 
> [...]

Here is the summary with links:
  - [net,v2] ipvs: fix PMTU for GUE/GRE tunnel ICMP errors
    https://git.kernel.org/netdev/net/c/6b335af0d0d1

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


