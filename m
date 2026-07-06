Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 65ED93DC852;
	Mon,  6 Jul 2026 10:50:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783335039; cv=none; b=Prn6p/T//RGlgsNcULoyUUh20y8lsdwGjcan+DOuaED461QzzjDow3yK2zeMrzV6LNItRZyQiERZvofzAmZj/9SD5pd/D/VhtG5Im6JOiD/mmd8PHZcMgqxlPJ/lcySngbw5J4Nb3SPr3QSdy9pMdMwHY5wkTwnD9sRtuNJZD4Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783335039; c=relaxed/simple;
	bh=Z4ELmo9MEWlYiApwu5QIhUGqOzqG193QuEkEslfhYjM=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=NGM4+ByrMlVhTeU8tWClwgagItpFjuKaVvAHJ6SX6jAqLUTJbqE9dX+RW3e5JyQbO7nIuY5OPOzGW8WjNE4yqtv3PRWXOpSM/rs+JiufTwZX5SxT2GBexkDtLjJrUO21NNph8pjRDg4ofTH7OYBDL/LVH2tospxACzGoUO/yeJc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Onzed0Ey; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Onzed0Ey"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0707F1F000E9;
	Mon,  6 Jul 2026 10:50:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783335037;
	bh=fGMnIZozpGLzsIivQPg0TjggSvulpvqr6PDXfZXNOzc=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc;
	b=Onzed0EynogY4zJYYVUfViJeUN19Hd8DJ8vAM6UE8XKkpetEhOqU6IpVV/TSBId/S
	 I9QjCNPdz8O0aHClC1XJ7Uu4ot4fG+CmKl/p3sxP0xzY1O6/YGE2/VflV/j1PjQLF0
	 +/qusJ7G93tjMn049UYbY5hzAGMAO71RLuaSp4eYogf//zKh3mGSzz+1gX8wa/Rul6
	 rG0B1F0vLhXpXhIedFu2sn54GZHKAcByS10kttafBzDcUghX9VQYjgj2RTrmtHzyGx
	 JvPBMBt8SdHq2DM0SwiMd3yzLbfztSp9TPxtFUpPSSagPKN2jhPjSKDx0BZjwVKTwX
	 KahNWrZgdxk0Q==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id D0A573ABD2A5;
	Mon,  6 Jul 2026 10:50:18 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH net] ipvs: reset full ip_vs_seq structs in ip_vs_conn_new
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <178333501739.500093.9836567879441424973.git-patchwork-notify@kernel.org>
Date: Mon, 06 Jul 2026 10:50:17 +0000
References: <20260702112837.81121-1-zhaoyz24@mails.tsinghua.edu.cn>
In-Reply-To: <20260702112837.81121-1-zhaoyz24@mails.tsinghua.edu.cn>
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

On Thu,  2 Jul 2026 19:28:36 +0800 you wrote:
> Commit 9a05475cebdd ("ipvs: avoid kmem_cache_zalloc in
> ip_vs_conn_new") changed ip_vs_conn_new() to allocate an ip_vs_conn
> object with kmem_cache_alloc().  The function then initializes many
> fields explicitly, but only resets in_seq.delta and out_seq.delta in the
> two struct ip_vs_seq members.
> 
> That leaves init_seq and previous_delta uninitialized.  This is normally
> harmless while the corresponding IP_VS_CONN_F_IN_SEQ or
> IP_VS_CONN_F_OUT_SEQ flag is clear.  For connections learned from a sync
> message, however, ip_vs_proc_conn() preserves those flags from
> IP_VS_CONN_F_BACKUP_MASK and passes opt=NULL when the message omits
> IPVS_OPT_SEQ_DATA.  In that case the new connection can be hashed with
> SEQ flags set but with the rest of in_seq/out_seq still containing stale
> slab data.
> 
> [...]

Here is the summary with links:
  - [net] ipvs: reset full ip_vs_seq structs in ip_vs_conn_new
    https://git.kernel.org/netdev/net/c/2975324d164c

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


