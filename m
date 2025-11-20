Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FC7134FF7B;
	Thu, 20 Nov 2025 22:05:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1763676312; cv=none; b=D8wgtEEQlnUcT4syyc0OWtTHLqhJwfI51ZoCUMJv+jUBBf68t6X6uM57T/SZJ7nOQcaBZc4Ibn0Xts5+LA5jZiXGsNWTPY7dOnBz/UHAMJeD/cpQ7xU6utVIm9qMfVw8LpxVj2TiJIR9H6MMH4Hq7E55+aZykHQiitZfebp8ZUo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1763676312; c=relaxed/simple;
	bh=ZRDytxpt/zqMuU9SJD79Kue0YqZleDCHOurXE4WDacQ=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Xznz989E/aoyfwINqAQEE+0WPqqkgQPiLuVx/ggLiW3t08EQD03xL20i/sTGVzMCxPjX7aKW1asyc9tPfuxYzYiu+CDBBhhl82H0dggSw/bsTluNVmZzNhZuIDkiYTUc66HKyPESX/3uG32DetRa+0mcgRvJWjWpLzfzsNl0Jt4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Ed2H+/Mh; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Ed2H+/Mh"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D70A0211A4;
	Thu, 20 Nov 2025 23:59:36 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=YsyWFNZjlULkeSGVnGvh/CrGBK0Cirq99eqdZO8Cfuo=; b=Ed2H+/Mh5QA6
	022Ks8ZITIcTmyUCWZu2mDn9jGERvScYVRCHH3+NA8bydzIsrmRerJkN2BEzfwIj
	AeXVTUGyVpmveMWrFg5DLGlFxHFpLliBCdkcNzaBbfEdDtgY4z6h3brhFSmJeHZo
	IV++kBUCL2JRk097WVv6iXqUa3p97qoVHW88bBKbgWE6RTfuQYHMsmJQAtKJ/B3U
	GffL3CAbugfKWB3pxTYfasGHQjH1yM67/28+kVYZFm1KWNJhOSvrVdb5gQd/mnX2
	zOTPG7tVnUIJY66zpJjK3u5sb41R5F/wbCc4DkI6EvitGekMD8cnBHugSad82iPT
	gVSIryfCc4OTVN0pPTHYdXuDf30dgBvZKzwWDMab9PcYTXd70r3PSVm7ANZiuc+I
	MYxYZbFBMgVygSjEO3onPBDEccvZa9Q27Qk7fvfrqrwfeGfcuGlPze8x7PIQ1HDx
	LaZGTKVZxugApIRlfXLGiiUG8ewYXe8eG1XGYi0NeiXTzePHc7eq/kuGUE3ERSDL
	BTSuOHEI3ADS28ag8x1e4oVMmUOxOhzko2vFiRskQ40KSrCmLYNb9RD2B5RmpbPh
	WARqvOkRjIroeetJ3f/I/HX0tDbrMEwg/7CHu4ftTOoBDLiPA/SaFyiNBa+qBK82
	vk+CSCOyoafZD2bce2c4Two+fXDU6Rk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 20 Nov 2025 23:59:35 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id EDFC866745;
	Thu, 20 Nov 2025 23:59:33 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 5AKLxNdg047491;
	Thu, 20 Nov 2025 23:59:24 +0200
Date: Thu, 20 Nov 2025 23:59:23 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Slavin Liu <slavin452@gmail.com>
cc: horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org,
        fw@strlen.de, phil@nwl.cc, davem@davemloft.net, edumazet@google.com,
        kuba@kernel.org, pabeni@redhat.com, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
Subject: Re: [PATCH net] ipvs: fix ipv4 null-ptr-deref in route error path
In-Reply-To: <20251120190313.1051-1-slavin452@gmail.com>
Message-ID: <a05775db-fe29-ed82-d87e-b3f7588c2c84@ssi.bg>
References: <20251120190313.1051-1-slavin452@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-2017688460-1763675972=:9175"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-2017688460-1763675972=:9175
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Fri, 21 Nov 2025, Slavin Liu wrote:

> The IPv4 code path in __ip_vs_get_out_rt() calls dst_link_failure()
> without ensuring skb->dev is set, leading to a NULL pointer dereference
> in fib_compute_spec_dst() when ipv4_link_failure() attempts to send
> ICMP destination unreachable messages.
> 
> The bug was introduced in commit 4115ded13164 ("ipvs: consolidate all
> dst checks on transmit in one place") which added the err_unreach error
> path with a dst_link_failure(skb) call to both __ip_vs_get_out_rt() and
> __ip_vs_get_out_rt_v6(). The IPv6 version was subsequently fixed by
> commit 326bf17ea5d4 ("ipvs: fix ipv6 route unreach panic"), but the
> fix was never applied to the IPv4 code path.

	It was not needed for IPv4 at that time because
icmp_send() was safe to use when skb->dev is NULL.

> The crash occurs when:
> 1. IPVS processes a packet in NAT mode with a misconfigured destination
> 2. Route lookup fails in __ip_vs_get_out_rt() before establishing a route
> 3. The error path calls dst_link_failure(skb) with skb->dev == NULL
> 4. ipv4_link_failure() → ipv4_send_dest_unreach() →
>    __ip_options_compile() → fib_compute_spec_dst()
> 5. fib_compute_spec_dst() dereferences NULL skb->dev
> 
> Apply the same fix used for IPv6: set skb->dev from skb_dst(skb)->dev
> before calling dst_link_failure().
> 
> KASAN: null-ptr-deref in range [0x0000000000000328-0x000000000000032f]
> CPU: 1 PID: 12732 Comm: syz.1.3469 Not tainted 6.6.114 #2
> RIP: 0010:__in_dev_get_rcu include/linux/inetdevice.h:233
> RIP: 0010:fib_compute_spec_dst+0x17a/0x9f0 net/ipv4/fib_frontend.c:285
> Call Trace:
>   <TASK>
>   spec_dst_fill net/ipv4/ip_options.c:232
>   spec_dst_fill net/ipv4/ip_options.c:229
>   __ip_options_compile+0x13a1/0x17d0 net/ipv4/ip_options.c:330
>   ipv4_send_dest_unreach net/ipv4/route.c:1252
>   ipv4_link_failure+0x702/0xb80 net/ipv4/route.c:1265
>   dst_link_failure include/net/dst.h:437
>   __ip_vs_get_out_rt+0x15fd/0x19e0 net/netfilter/ipvs/ip_vs_xmit.c:412
>   ip_vs_nat_xmit+0x1d8/0xc80 net/netfilter/ipvs/ip_vs_xmit.c:764
> 
> Fixes: 4115ded13164 ("ipvs: consolidate all dst checks on transmit in one place")

	I guess, this is a followup to commit 0113d9c9d1cc.
Looks like the problem comes from commit ed0de45a1008 which
starts to use __ip_options_compile(), so the problem is more
recent because we used to call dst_link_failure() even before
commit 4115ded13164. But it is better to fix the problem in
IPVS. Just send v2 with commit ed0de45a1008 in the Fixes tag
and explain that it started to use __ip_options_compile(),
commit 4115ded13164 should not be the culprit.

> Signed-off-by: Slavin Liu <slavin452@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 95af252b2939..618fbe1240b5 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -409,6 +409,9 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
>  	return -1;
>  
>  err_unreach:
> +	if (!skb->dev)
> +		skb->dev = skb_dst(skb)->dev;
> +
>  	dst_link_failure(skb);
>  	return -1;
>  }
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-2017688460-1763675972=:9175--

