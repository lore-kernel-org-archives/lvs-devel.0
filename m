Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2F3442BC45;
	Tue,  4 Aug 2026 07:54:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785830097; cv=none; b=XMpWoZzFzE68QsrFAtGE63qgfkeASzrNI9f3yUWXpTbFGPKZ01cv61VjU9Mz1CBtQtp9zGb5+yRSZbiNvxPr/WWoVF7SaptbCJMx13kJUod8Etx6GtJrRO7UB//WyLonoh2Oid98HerlfZ5NxiOm0hIysRWD/ksCid+8QJFigPU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785830097; c=relaxed/simple;
	bh=E1kWG1uHm/uN2Er4tihZjGr9qGMdABFmHit7Zv79agA=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Cs1vywdETRv8j9JHI0Lkg2C9AUw+YwhlSh4O4MF6wzlD8avyq7slfwIc59tXzlK8vpaqkKkujPi/DelAw4VR/D/ozN50k3BuDL3pAMYcxyhUOMLFK0PdK7yHGBZ6Fc99kpUvfJxGdNFAsmbEHTT2w1QKF9jQCE7mGDpBAzmv/Do=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=bmSvA7v0; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="bmSvA7v0"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3EDA021CD4;
	Tue, 04 Aug 2026 10:54:38 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=vbzLnRrjwW4/yN490Jf2P42lWBieB/9dHIcKbB4UuCs=; b=bmSvA7v0ypxZ
	vetC+thg4AP2w+r+L6QbOaVrbnkCbtWd4Fp/5AwtpRFbI66mpSxHSxjn+ZDslM7t
	HxKHY5zMxsbZT91VtGY41ifeH89945xRdpaHsBTRPkvkxBOQsKTo4Tf0bODmxDJ7
	ClyC4VfAl8hv0A4O96DLQLM77rMQOq6UmvYevapb+gRijkdLxRTB0cP0vUIV1pQ3
	Q9PeDNFjNtcHQP7insVeZ8MOu6cVRv7jLQ8FdHFPT7KvugU4o1HJV11PZd/Sgiam
	BphPTJ2ErowGgSlKOUswu9Fyfgi7F6KbqvcfjV05ndjsVAuDoRtI92PjIKoHmcNc
	RymQPNsrNw0NZ7iELqhzmLvW8BwBzNdFU790mXe0hGuNfFTpnyqm/b/ahufnmdye
	MAK1F3NAvOyxqWi/tTgfG0vjG5n4i93plkUEP426hXDquRFGFw75FXGjdZQQz446
	JN9FtlpVQ3sWYS70n5eq218sA1IIpIFuM/RLB77sGsc6Q1K4zrr+/v62btkH/oiV
	g6+S08TnKGkgWeGRNDRtDXM1Ca1I5aqmFk3Raj+sw8bj2t8epRQIrybihHKA7XyY
	FCKG4CVJj59r4fAeS1ynziFs5wXkI53JrOgPUtj5gqBKpEZeyqu3oc0VG2CyGyI2
	pxu+I//OUHNfX3ImbPrgHxwzVtDVWjo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 04 Aug 2026 10:54:38 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C365061E56;
	Tue,  4 Aug 2026 10:54:38 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6747sUSw018857;
	Tue, 4 Aug 2026 10:54:30 +0300
Date: Tue, 4 Aug 2026 10:54:30 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: David Lee <david.lee@trailofbits.com>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, davem@davemloft.net,
        edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
        Kyle Zeng <kylebot@openai.com>,
        "Dominik 'Disconnect3d' Czarnota" <dominik.czarnota@trailofbits.com>,
        Sven Eckelmann <sven@narfation.org>, phil@nwl.cc,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH nf v2] ipvs: clear IPv4 options after rebasing tunnel
 ICMP errors
In-Reply-To: <20260804061055.711402-1-david.lee@trailofbits.com>
Message-ID: <32d90953-67ed-e133-5703-7c63b2ec7ed6@ssi.bg>
References: <20260804061055.711402-1-david.lee@trailofbits.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 4 Aug 2026, David Lee wrote:

> From: Kyle Zeng <kylebot@openai.com>
> 
> ip_vs_in_icmp() rebases an skb from the outer ICMP packet to the
> quoted original request before passing it to icmp_send(). However,
> IPCB(skb)->opt still describes the outer IPv4 header.
> 
> A timestamp option in the outer header can therefore leave an offset
> that points into the quoted transport header after the rebase.
> __ip_options_echo() treats a byte at that stale location as the option
> length and copies it into the fixed-size option storage on the
> __icmp_send() stack, causing a stack out-of-bounds write.
> 
> Clear the stale option metadata after resetting the network header.
> Keep the remaining control block fields, including the ingress
> interface used by the ICMP response path.
> 
> Fixes: f2edb9f7706d ("ipvs: implement passive PMTUD for IPIP packets")
> Cc: stable@vger.kernel.org
> Assisted-by: Codex:gpt-5.6-sol Codex:gpt-5.5-cyber
> Signed-off-by: Kyle Zeng <kylebot@openai.com>
> Co-developed-by: David Lee <david.lee@trailofbits.com>
> Signed-off-by: David Lee <david.lee@trailofbits.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> Changes in v2:
> - Add the nf tree prefix to the subject.
> - Restore Kyle Zeng as the patch author and correct the sign-off chain.
> - Move the research credit below the commit-message separator.
> 
> v1: https://lore.kernel.org/netdev/20260731140822.567128-1-david.lee@trailofbits.com/
> 
> Bug found and triaged by OpenAI Security Research and
> validated by Trail of Bits.
> 
> Trail of Bits has a reproducer for this bug that triggers a
> KASAN stack-out-of-bounds write in __ip_options_echo() and can share
> if needed.
> 
>  net/netfilter/ipvs/ip_vs_core.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index bafab9345..fe06c380c 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1951,6 +1951,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  		if (pskb_pull(skb, offset2) == NULL)
>  			goto ignore_tunnel;
>  		skb_reset_network_header(skb);
> +		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>  		/* Ensure the IP header is present in headroom */
>  		if (!pskb_may_pull(skb, hlen_orig))
>  			goto ignore_tunnel;
> -- 
> 2.53.0

Regards

--
Julian Anastasov <ja@ssi.bg>

