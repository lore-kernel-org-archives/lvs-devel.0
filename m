Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07179149C6F;
	Wed,  6 May 2026 01:11:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778029866; cv=none; b=IgXHtoZM1i8paLrBRrGnKZp6Do2pV/NuT1xohbm0qW0DqW0Vt65jyTqUz2UbUtuFViP0UqBI87ggpNdoZKGud1cilVfC9SbX+8zo+IKr99YaucVEjHOOfbh9PguHgCXZmAci2todFKUL8GSwYfFl08cmCxx7l4nBOc6qCtpNZ0s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778029866; c=relaxed/simple;
	bh=goToXI9H6Xp4VYMlJrLNpWDyb6Q1NyOxaY3l0jvHZ9s=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=D2ap8Mg8cAqtcYgd2C6ishrlW6PVZK7wE2ShqjUbSsbg2jV8My7JNZ0rhQCG8wRhPtMuzJCi0RjS5n1g3sHzOgMf8uct+U8YTTq2XHxjUosDVsAaVqvX2YwiIDy6Cp9s5ZVOjEZarojDUBdCHcJvqMkZcp91THH9nsqs6SraXrU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ll7K5q0A; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ll7K5q0A"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98C2CC2BCB4;
	Wed,  6 May 2026 01:11:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1778029865;
	bh=goToXI9H6Xp4VYMlJrLNpWDyb6Q1NyOxaY3l0jvHZ9s=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=ll7K5q0AzEM8gZ03P8Zu9Iy83m25lcvK13DpZYmtJjKs9HncXSk07va3ENwxysglP
	 7HAf/HcvIx+wrPhVX8gXO27HB4KXvG6qMcZMvRSdbKNr23cK8PmjM/EDcKXbisd0NR
	 JfI3GAzO1Ur3Lmg6axtsVCX9ALISuv6BIu34orHQ4L75yZtiM/7VPNMvgTkiMBLx6k
	 ce0jQcbBpWc6HyHZ6MFNKd0cAzZT2dIClq3CkutKgsBHH0FA8QJXaD+p2HJvZ+6rPj
	 Z/b1p/ERHLFxN/SOje03s7axT+sJdABYAKdnT5aWjYzj3oG/kE/IhcAsq4KbeD72La
	 1LKXGTnGjDFow==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 02D343930780;
	Wed,  6 May 2026 01:10:17 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH net 1/8] ipvs: fixes for the new ip_vs_status info
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <177802981580.2332967.9254644733543379445.git-patchwork-notify@kernel.org>
Date: Wed, 06 May 2026 01:10:15 +0000
References: <20260505001648.360569-2-pablo@netfilter.org>
In-Reply-To: <20260505001648.360569-2-pablo@netfilter.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
 netdev@vger.kernel.org, kuba@kernel.org, pabeni@redhat.com,
 edumazet@google.com, fw@strlen.de, horms@kernel.org, ja@ssi.bg,
 longman@redhat.com, lvs-devel@vger.kernel.org

Hello:

This series was applied to netdev/net.git (main)
by Pablo Neira Ayuso <pablo@netfilter.org>:

On Tue,  5 May 2026 02:16:41 +0200 you wrote:
> From: Julian Anastasov <ja@ssi.bg>
> 
> Sashiko reports some problems for the recently added
> /proc/net/ip_vs_status:
> 
> * ip_vs_status_show() as a table reader may run long after the
> conn_tab and svc_table table are released. While ip_vs_conn_flush()
> properly changes the conn_tab_changes counter when conn_tab is removed,
> ip_vs_del_service() and ip_vs_flush() were missing such change for
> the svc_table_changes counter. As result, readers like
> ip_vs_dst_event() and ip_vs_status_show() may continue to use
> a freed table after a cond_resched_rcu() call.
> 
> [...]

Here is the summary with links:
  - [net,1/8] ipvs: fixes for the new ip_vs_status info
    https://git.kernel.org/netdev/net/c/afbd961305eb
  - [net,2/8] ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
    https://git.kernel.org/netdev/net/c/f2da9a96abb4
  - [net,3/8] ipvs: fix the spin_lock usage for RT build
    https://git.kernel.org/netdev/net/c/d493d9de1c21
  - [net,4/8] ipvs: do not leak dest after get from dest trash
    https://git.kernel.org/netdev/net/c/fbe1e01e818e
  - [net,5/8] ipvs: fix races around est_mutex and est_cpulist
    https://git.kernel.org/netdev/net/c/2fd109238925
  - [net,6/8] ipvs: fix shift-out-of-bounds in ip_vs_rht_desired_size
    https://git.kernel.org/netdev/net/c/4ee52b7021a7
  - [net,7/8] ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
    https://git.kernel.org/netdev/net/c/aa6065206987
  - [net,8/8] sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
    https://git.kernel.org/netdev/net/c/8f78b749f3da

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


