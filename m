Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6CEB245012;
	Mon, 21 Sep 2026 06:50:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789973459; cv=none; b=qbIm44O/UDr3k6VoUKlF2g6SET9/b02RUIu0yBJf7nsh0rz7L9HK6P/TGtsU12hY2uB8B+7o9/QF1FntIEeu1C+s3t1zYSy5DeK42iWNJUddpzAzlpGAylPoJQEF5vob9E781nauSatoED9JTULYckdD/bNbIl4GOIcLUyaM/cM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789973459; c=relaxed/simple;
	bh=6f0eCkeGFCciTpnm1HOobpxQ0s5oxwvG28Sv0p2qS48=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=WDrvyIb0xzTUHvWoMf7YHJTZh2aAJ8Ff2h3z0xpOFE5OkDd7JgEevSqRzt8t2iPpr8A4WjH+gKCPgH15r1/F1G+fo2D08bzi+SQKED/6aKX7llBE8+5DqdH8n2TFjolsJCKVPjJIhXrfh7jPQXyxMR9w2JSw4RELxLSYhRmK1T0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=FKf24MKD; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="FKf24MKD"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9D6D9213B0;
	Mon, 21 Sep 2026 09:50:48 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=RfTcnOOoHbgriPhJ1Vzr0zRBmP8UA0p7+omFHNT3LAA=; b=FKf24MKDRyB6
	KlwVQpo0abcsTAu/7Csc8mX7LoUxjLwpzZGDxCQ9idlr62p0F8pL/kCWKl/iaN7r
	/GMYKI4wI3Q3BYCyykrmmc537gLjBqHHMEaoE9SXdoHtmmPAfIMqTpi12p9MSnbf
	2V6gBQD0hVqLJ60YPfOLZ+PDjIKBYTOd+AowTdO3vb7uTiZDVzK5TFWM8pSPjbll
	m+JAFjAGhJM77lxj6Y5Hx5ZiA1//TdWkEDWhvYcy1pOAncMjC1gNb5m3kRvBWgXL
	LIZPYDmABa7l75bptlmsQjDHEUARuKcgKgC0LuTw/XQSdKMfoM2tdKRM14ndDKm+
	JDXqWRGw5dByrjm9zK0h7YuAVD1ZGHJ+wG//JWgqWaOmgLA0/GhNBw2Hg40waVus
	a4uoFBVEzueFbEz0ZLDxfCLuFaybY7enQ85Ez5zhOWXfXD9KzvSezgLfEBZhw030
	921SJZxBqE/5HCAb3dWrkUKK586QLVCGtG+IZI01RAxRG+Lv938k5x4fPvw0BGCf
	v40WARMo9DmRBK2A/IbwJE5uaP7te+FClSciLl6DsSnfOVy1ZkIqe+a1YioG/710
	fmSBEjKDxN2LRPJGEWTLbrgk5Lrb2HRjVkg7qunuVe/iZT6kUu3JaUa1DP5Y7Pib
	PtRuGJrJ881BcqETVEbDotnjjDUIHIE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 21 Sep 2026 09:50:48 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6F7F8605C2;
	Mon, 21 Sep 2026 09:50:50 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68L6omnT015991;
	Mon, 21 Sep 2026 09:50:48 +0300
Date: Mon, 21 Sep 2026 09:50:48 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: netdev-bot+sashiko@kernel.org
cc: zihanx@nebusec.ai, horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
        phil@nwl.cc, davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
        pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v2 1/2] ipvs: avoid stack overflow from recursive
 connection expiration
In-Reply-To: <178996076640.2160803.16028832049809238100@kernel.org>
Message-ID: <e1efae34-24a7-3b24-22b0-6a838aa93d52@ssi.bg>
References: <20260917030301.5502-1-zihanx@nebusec.ai> <178996076640.2160803.16028832049809238100@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-861824406-1789973449=:8320"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-861824406-1789973449=:8320
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Mon, 21 Sep 2026, netdev-bot+sashiko@kernel.org wrote:

> Thank you for your contribution! Sashiko AI review found 2 potential
> issue(s) to consider.
> 
> Critical: 0 · High: 1 (1) · Medium: 0 · Low: 1
> 
> If you believe none of the issues are legitimate, please reply to each
> issue of Medium severity or higher and explain why the AI is wrong.
> If any of them are legitimate and you plan to respin, please let patchwork
> know by including "pw-bot: cr" as a separate line at the end of your reply
> (one such reply per series is enough).
> 
> - [High] ipvs: use-after-free in ip_vs_conn_expire() due to timer re-
>   arming race
> - [Low] ip_vs_conn_del_put() (net/netfilter/ipvs/ip_vs_conn.c:1333-1346)
>   keeps its old comment "Try to delete connection while holding…
> 
> Pre-existing issues:
> - [High] ip_vs_conn_del_put() (net/netfilter/ipvs/ip_vs_conn.c:1336-1341)
>   cancels the controller's timer, drops the caller's only reference on…
> 
> --
> 
> ipvs: avoid stack overflow from recursive connection expiration
> 
> This changes ip_vs_conn_del_put() to return whether it managed to delete
> the controller's timer, and makes ip_vs_conn_expire() loop back with the
> controller instead of recursing into itself.  The stated goal is to keep
> chain cleanup synchronous while using a single stack frame.
> 
> v1 Link: https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/

	Zihan, IPVS has conn refcounting which does not look
natural: the hash table has reference and the timer callback
has no reference. Let me try today to change the refcounting,
so that unhashing occurs after last reference is dropped,
the conn lookups already use inc_not_zero, so we will try
to consider the timer_delete as successful stealing of
the refcnt from the timer callback (yes, the callback should
hold refcnt, not the hashing). But first let me try if the
idea would be successful. As result, your change should
be small as before, we should be able to delete conns safely.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-861824406-1789973449=:8320--

