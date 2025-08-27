Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C3BE30DD14;
	Wed, 27 Aug 2025 21:38:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756330730; cv=none; b=R8nSe/AEuIDYrkWUWIROGFRJyRuSuu+lHb2kheivHzwbBm97PJwbeptmxgULOtyYxddcvSinjYf0SoaSFW8LBMXtU38s5Sijw3LPcqZuM537DIjxsAgqHj+clPqNmk+1Uzq/K+XrhDNXgZi8fe14NRIiCZupTghryMcuY691PS8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756330730; c=relaxed/simple;
	bh=p5bHqFMfdYWypgdwX2ndTsW60HZCWq5xOpxYn3CdyDs=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=i1d+V5E2MigrqAf+xb9b9macEc+z83f6FtRqUwmz5bBcLrmPRpdBdcXQ/xkHXVnYD/KCKs3wBBnsVCMaPVgSqiRqLqldFtqhUUaxtsz2RwC2/ehAjaviec5M90WNr9yN+vcp6QXpVN2ByYvaD6UkR/enHPQ7ZE0BbybjjYMyLk0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=MgiDHpTK; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=HD+PWB3I; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="MgiDHpTK";
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="HD+PWB3I"
Received: by mail.netfilter.org (Postfix, from userid 109)
	id 901A4607B4; Wed, 27 Aug 2025 23:38:46 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1756330726;
	bh=VC1X2cnylbEpt7B0aqU/bdmAhdb5uGGW2wGYvucZSfo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=MgiDHpTKA6eVpUe6xtBaGt97zvJCwTMvtGyolpfUqDwPj3QL5KbCag+vXhzhI8NJ3
	 o2wKyVsAimsGNyuG5eMzt8CStDn9U5WIGZ78iQuzIvdBQOFNrfx2q7bnyCgHcJsVLX
	 NHUW20isqHMjboLNLIkXxm7ckjrQORqMYSVuR1MbuzXXUWDigjlwq1TAoMQ21od56C
	 f4TDWyG6JUlvWDA0sangfhQEEpwLRrM9j8AVgC3SqNqBbRgr5igZ2sBAxYpd6U8Omg
	 p8PeaKdpHUxiJXlbAP2g5bikZUY7qVbfKJzAxd7fVO46GmKEJT2NVl/nAI7WcgZft8
	 /omZ1ekpzcglQ==
X-Spam-Level: 
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 2037A602AC;
	Wed, 27 Aug 2025 23:37:08 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1756330628;
	bh=VC1X2cnylbEpt7B0aqU/bdmAhdb5uGGW2wGYvucZSfo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=HD+PWB3Itnjki9qdOXq/cXfn0rwNMpqMWZW+y6+oAxfgTGdc0RXaQVtte60/6asfU
	 VL+Ye7HPfgi7GpamFMCaBIOVtzXixI+AYy3FYc69pjSgDyjFqczV9YkikNuV5heFIL
	 V/tudDNXWHCTwGa8W6XWj63j6HW30ShX9J8ytUJKsYlqhxvGinUWwizbRChTSlu4Ja
	 p4vcdSYx/q4GZEpBxbi7PWRYYINB01RoNK1jkKrg1xJ48UpPcyQVs9Qmba8XVeXGci
	 bnwt2gSXj/wQzA7niaWHCec20+szHrKcOKi5pmNSrla9iVmlp1iKeJs66rBkJLaU7L
	 eDujie/P0XxFQ==
Date: Wed, 27 Aug 2025 23:37:05 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Zhang Tengfei <zhtfdev@gmail.com>
Cc: ja@ssi.bg, coreteam@netfilter.org, davem@davemloft.net,
	dsahern@kernel.org, edumazet@google.com, fw@strlen.de,
	horms@verge.net.au, kadlec@netfilter.org, kuba@kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pabeni@redhat.com,
	syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Subject: Re:
Message-ID: <aK96gZBMvbJ73e_e@calendula>
References: <2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg>
 <20250827144337.34792-1-zhtfdev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20250827144337.34792-1-zhtfdev@gmail.com>

On Wed, Aug 27, 2025 at 10:43:42PM +0800, Zhang Tengfei wrote:
> Hi everyone,
> 
> Here is the v2 patch that incorporates the feedback.

Patch without subject will not fly too far, I'm afraid you will have
to resubmit. One more comment below.

> Many thanks to Julian for his thorough review and for providing 
> the detailed plan for this new version, and thanks to Florian 
> and Eric for suggestions.
> 
> Subject: [PATCH v2] net/netfilter/ipvs: Use READ_ONCE/WRITE_ONCE for
>  ipvs->enable
> 
> KCSAN reported a data-race on the `ipvs->enable` flag, which is
> written in the control path and read concurrently from many other
> contexts.
> 
> Following a suggestion by Julian, this patch fixes the race by
> converting all accesses to use `WRITE_ONCE()/READ_ONCE()`.
> This lightweight approach ensures atomic access and acts as a
> compiler barrier, preventing unsafe optimizations where the flag
> is checked in loops (e.g., in ip_vs_est.c).
> 
> Additionally, the now-obsolete `enable` checks in the fast path
> hooks (`ip_vs_in_hook`, `ip_vs_out_hook`, `ip_vs_forward_icmp`)
> are removed. These are unnecessary since commit 857ca89711de
> ("ipvs: register hooks only with services").
> 
> Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Link: https://lore.kernel.org/lvs-devel/2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg/
> Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>
> 
> ---
> v2:
> - Switched from atomic_t to the suggested READ_ONCE()/WRITE_ONCE().
> - Removed obsolete checks from the packet processing hooks.
> - Polished commit message based on feedback.
> ---
>  net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
>  net/netfilter/ipvs/ip_vs_core.c | 11 ++++-------
>  net/netfilter/ipvs/ip_vs_ctl.c  |  6 +++---
>  net/netfilter/ipvs/ip_vs_est.c  | 16 ++++++++--------
>  4 files changed, 17 insertions(+), 20 deletions(-)
[...]
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index c7a8a08b7..5ea7ab8bf 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1353,9 +1353,6 @@ ip_vs_out_hook(void *priv, struct sk_buff *skb, const struct nf_hook_state *stat
>  	if (unlikely(!skb_dst(skb)))
>  		return NF_ACCEPT;
>  
> -	if (!ipvs->enable)
> -		return NF_ACCEPT;

Patch does say why is this going away? If you think this is not
necessary, then make a separated patch and example why this is needed?

Thanks

>  	ip_vs_fill_iph_skb(af, skb, false, &iph);
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (af == AF_INET6) {
