Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1184A15B0E1;
	Wed, 29 May 2024 02:57:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716951422; cv=none; b=qJ/pHaTRbS+moU8MytfJqhkpQ+XYuudjsHitD+6MIWbQQ9NtqxS8YNH5jzoafAlKSxgQfPkpdTN6GFvC9XaWiFE2mHpcJo1p8QZsYv0jh9VJUo3yJd729ZbnxT7BCOxIjt6wWMiAVvVWvMqDqa9MpkZIKFU3z9iULSN9dMd7SW8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716951422; c=relaxed/simple;
	bh=kCbn1M2QOr3tg0aboBFXxUAzlVonui9TIyWgU01m2Nk=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=QuTaIHQocP6Yw9F+/N3K2Svn81apA8QP048D4EEfibf27YECWq1ZE9ut2OlMM7K/dj84aGIQR5wSM532dWS9l4T0ow0016mzDxVcUIzg/nuBpX5cAefJWWLhxRsNPfnwRq9+eEputW90onxkBwGXexUFI1VfEAto8Hmxx+GvcQw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DRmgg0lO; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DRmgg0lO"
Received: by smtp.kernel.org (Postfix) with ESMTPS id D33A3C3277B;
	Wed, 29 May 2024 02:57:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1716951421;
	bh=kCbn1M2QOr3tg0aboBFXxUAzlVonui9TIyWgU01m2Nk=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=DRmgg0lOo0L4ifi/LB0XfpRsqdBtydGjIX7my18yNfwjQcriNscOSRuXWMTpY698I
	 /IqfHdL1yOtMsed78VDH4bmSQuPwzBjY3mnG9w02jlq3ENJbUhu02IE2EWdJEQ2HvW
	 /9Wq/al86Tjq0iP/2riknMLNxtywD/lcgRc7EICaMsb1fht8oACq/Q51UFY7BQRwI6
	 OgcxXl43pCi88QZEfctytaFUFYmkdD6clS8EHbWTH9t4DC5/llQ67cU/1RNCCOx/Ds
	 1Ld2V11RyMpLP9FFPtKDZz4q30HN5OeFkhRTeIuJxuqhn/ar2XSaceTVsQ7A4ljoxx
	 uCJHpvVBVXA8A==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
	by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id C79F3C4361C;
	Wed, 29 May 2024 02:57:01 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH net-next 0/5] net: constify ctl_table arguments of utility
 functions
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <171695142181.13406.6878241525958954105.git-patchwork-notify@kernel.org>
Date: Wed, 29 May 2024 02:57:01 +0000
References: <20240527-sysctl-const-handler-net-v1-0-16523767d0b2@weissschuh.net>
In-Reply-To: <20240527-sysctl-const-handler-net-v1-0-16523767d0b2@weissschuh.net>
To: =?utf-8?q?Thomas_Wei=C3=9Fschuh_=3Clinux=40weissschuh=2Enet=3E?=@ci.codeaurora.org
Cc: davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
 pabeni@redhat.com, dsahern@kernel.org, horms@verge.net.au, ja@ssi.bg,
 pablo@netfilter.org, kadlec@netfilter.org, j.granados@samsung.com,
 mcgrof@kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org

Hello:

This series was applied to netdev/net-next.git (main)
by Jakub Kicinski <kuba@kernel.org>:

On Mon, 27 May 2024 19:04:18 +0200 you wrote:
> The sysctl core is preparing to only expose instances of
> struct ctl_table as "const".
> This will also affect the ctl_table argument of sysctl handlers.
> 
> As the function prototype of all sysctl handlers throughout the tree
> needs to stay consistent that change will be done in one commit.
> 
> [...]

Here is the summary with links:
  - [net-next,1/5] net/neighbour: constify ctl_table arguments of utility function
    https://git.kernel.org/netdev/net-next/c/874aa96d78c7
  - [net-next,2/5] net/ipv4/sysctl: constify ctl_table arguments of utility functions
    https://git.kernel.org/netdev/net-next/c/551814313f11
  - [net-next,3/5] net/ipv6/addrconf: constify ctl_table arguments of utility functions
    https://git.kernel.org/netdev/net-next/c/c55eb03765f4
  - [net-next,4/5] net/ipv6/ndisc: constify ctl_table arguments of utility function
    https://git.kernel.org/netdev/net-next/c/7a20cd1e71d8
  - [net-next,5/5] ipvs: constify ctl_table arguments of utility functions
    https://git.kernel.org/netdev/net-next/c/0a9f788fdde4

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


