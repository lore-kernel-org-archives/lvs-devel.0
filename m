Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794759010;
	b=B6yLWqyGNAvkmzZ+KVdlmXpSm6DDyM1W7bJN3jzOBTYTKVT/O2mdOcQ+g/bmft3nhCRd
	 00jDbnDp1kBy9lJ7LknaI3n+Hp/ifFvb5Sv8X/VgOQ/3KHQBMKuFhkxw7AXnYCI/yh/Vs
	 iMAygBmTKP1xOnP0NGcIEtg9GGPltb7a9f7Vb3lq4mOobI8a5HY+bfitzhA1dI9COa2JE
	 hUoRE72IoLG3xJ20DBvHAKHs/d1xVOSh0UtTFADMg5LjbhrLV0VMhQjoFUqLemDNonI7B
	 sRLFAa+KRgTWK1qMRCZAH3F5TDrW3V6uiKFn27DH8dIjSFQrT5X8vThX8faSIIk284g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794759010;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=w38rqGNrGDLCqa74mPssK7iYVtNKY8BC2nJHasK7eRI=;
	b=nI8xU3sb6NEfIPqixLR3XAGCDd1/r9cP+VbvncOeQXz82Gh+l86sUbM+SLNov48mLSHx
	 ehbumSPVkC5W7XX0S01rmXDZnBM7VM0U1809lpKEIomjGvTHNmnrxpn7rs5L8x8BduMfK
	 UWf29HbYXJtshVgolsXHXMORAtoFiCW+mP+kyF9Jv6RLhtn6T98XtWcwYtEiiHmdW3ohv
	 xjDuvcQ6rq/gTnzesvVh7MWcdZN5Rg3u70w7BTLC9pMl9uMgN88MimX48xAKeBo2WfaaT
	 otzf9O0Z7Uz2V3f4XcetoPj19tZuDqo88zj0+ZndOBxElJDiZKOodiJIF/O583zndrA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=VLfjhweh;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EDC0606A31E;
	Sun, 15 Nov 2026 16:10:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4EDC0606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=VLfjhweh
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 03348213FD;
	Sun, 15 Nov 2026 18:10:05 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=w38rqGNrGDLCqa74mPssK7iYVtNKY8BC2nJHasK7eRI=; b=VLfjhwehPmzT
	waBTOCTGdOoc65YijRE9PDgaJm2duQHE3fmvO0Q48dy64sHwUp9l/KIZaQBVJVLD
	ogbTgQYIgaDZ/yhYnM8TOPuo9OJFB+oeLry0g3+xp60o80mN6UAALb5s1ednSQrZ
	oswcMUUbMQSH+WMVAr5xNM1RywFXFJw+NDl9npRj9uCkcEPBH/AJlF7TBK/dD8lL
	eR+ZITyXnu+t7WeOw02qWqojZ1sVleJ+UG6NM7Eotavid8A51oSdKMnKNKOTsR44
	Urc8xOOCDP36TZiqYh22uJOPg5LojfNqKJiWyhGglCgFRECn+tH6ZKyTB/QEREdi
	ybnfZp1L9D2Eqw0upOxxvG1Cd3XSPlc3vqljXbHilKmKCRZjUfWQ1W97d3RX2BCP
	JxIEV3zAODejaqplIs3gDmzTEWb6wufy4KzvyDB38pCTKotfM/k7L7sPF+hgU8Yd
	Ncfd15W2uRIkt9RNs11bkkAvMWVrWkdFDFUi6ZSr3JmOJ4k6P3wL5dBLlex1Gwu4
	NXgB5EdyGv+4TA4tw0vJXzSzxIUZpyeyA6fXfVC3QDA0h7+0RpbInHfPd1MMAM+f
	wOObpGtv2uf+KCK/V+nzR53tc902weizEXvEWEGPuDvFKrpnZ4A/ejttVfeAUMiK
	uyCjweLi4HygwvKpcyEZH/Hlge/O/QA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 15 Nov 2026 18:10:04 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 416C160121;
	Sun, 15 Nov 2026 18:10:04 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AFG9uRb118090;
	Sun, 15 Nov 2026 18:09:57 +0200
Date: Sun, 15 Nov 2026 18:09:56 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
cc: Simon Horman <horms@verge.net.au>, pablo@netfilter.org, fw@strlen.de,
        phil@nwl.cc, "David S. Miller" <davem@davemloft.net>,
        edumazet@kernel.org, kuba@kernel.org, pabeni@redhat.com,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel <linux-kernel@vger.kernel.org>, skhan@linuxfoundation.org,
        syzbot+84e27adb95fd2a1fe9bb@syzkaller.appspotmail.com,
        stable@vger.kernel.org, Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] ipvs: wait for RCU callbacks before dst_ops
 teardown
In-Reply-To: <20261114195410.96503-1-pavankumaryalagada@gmail.com>
Message-ID: <8473d38d-2d50-ad77-18c1-29bbdda56616@ssi.bg>
References: <20261114195410.96503-1-pavankumaryalagada@gmail.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

	Adding Wei Wang to the CC list...

On Sun, 15 Nov 2026, pavankumaryalagada@gmail.com wrote:

> From: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
> 
> During network namespace cleanup, IPVS releases cached destinations
> using RCU callbacks. However, ip6_route_net_exit() destroys the
> per-CPU destination counters before these callbacks complete.
> The RCU callbacks call dst_release(), which updates the destroyed
> counters and causes a NULL pointer dereference in
> percpu_counter_add_batch().
> 
> Call rcu_barrier() at the end of __ip_vs_cleanup_batch() to make
> sure all pending IPVS RCU callbacks finish before the destination
> counters are destroyed.

	What you see is a result of more fundamental problem.
IPVS is supposed to catch all NETDEV_DOWN events coming from the
pernet device phase which come before the pernet subsys phase.
So, on cleanup_net IPVS is supposed to run its subsys cleanup
with no traffic, no devs, no cached dsts, no netfilter hooks, etc.

	But in my tests free_fib_info_rcu -> fib_nh_release ->
fib_nh_common_release -> rt_fibinfo_free_cpus calls
dst_dev_put() where the dst device that IPVS listens for is replaced
with a blackhole_netdev. This happens before the NETDEV_DOWN
event and as result IPVS misses the event because dst->dev is
already replaced and does not match. When such dst_cache
remains for the pernet subsys cleanup you see these crashes
because IPVS has another problem that it does not call
dst_release immediately but from RCU callback.

	I now created a change to call dst_release immediately
but the problem with the blackholing before NETDEV_DOWN remains.
It can hurt other event listeners.

	My tests were with tools/testing/selftests/net/netfilter/ipvs.sh
where I modify it to run only the NAT test. What I see is veth12
to be blackholed before its NETDEV_DOWN event and ip_vs_forget_dev()
missed it. Trying to find more information...

> 
> Reported-by: syzbot+84e27adb95fd2a1fe9bb@syzkaller.appspotmail.com
> Link: https://lore.kernel.org/all/6af795e2.98e60839.1e023a.00d4.GAE@google.com/T/
> Closes: https://syzkaller.appspot.com/bug?extid=84e27adb95fd2a1fe9bb
> Fixes: 026ace060dfe ("ipvs: optimize dst usage for real server")
> Cc: stable@vger.kernel.org
> Signed-off-by: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 8a3c880fdb26..9c456efe13c7 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -2553,6 +2553,11 @@ static void __net_exit __ip_vs_cleanup_batch(struct list_head *net_list)
>  		IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
>  		net->ipvs = NULL;
>  	}
> +
> +	/*
> +	 * Wait for ip_vs_dest_dst_rcu_free() callbacks before dst_ops teardown
> +	 */
> +	rcu_barrier();
>  }
>  
>  static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

