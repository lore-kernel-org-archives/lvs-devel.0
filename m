Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4155A29A322;
	Mon, 24 Nov 2025 15:35:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1763998521; cv=none; b=E3ExYfu/fxTjjqFylcOK96sydCugd3WA3KcUbe0/18FOEgKlGylgRF2lzfMJaouUz/9BJ3ZYVMyvUb99OPSh/z0Ky1dckCT0GBWru3wddBkdITrYcrFCuvJXm0ElUyNGNYoq36ViqQ0pFavIwvDuZz6KGkLt4Bd8Ft9WatbLHSA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1763998521; c=relaxed/simple;
	bh=Cgy1jSGdvXKofvHzDc7wqhKqOmo64bHdMx1gZPWfGCc=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=DjWbdguznzxTrci/CoE7jiw8BNOYo4BOYVyvl16Ka3oNdArHKh6f8A+91LyFt3s5+TS8L4C3vbyYO+ceMQO+bw4UoHQ3/rfA/JbQyoq9VO5OtMS2lSNofPb3RSbcYHmpL7NQeQ8WvGsFsf21cCgHf2jJ3/XADI1Z/VM46ZzT9pU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=36mJOIwP; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="36mJOIwP"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id BD671211AB;
	Mon, 24 Nov 2025 17:35:07 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=gdxKfmy94OiIU4Ge1eb4/bVO0IJ+/rgl6uTSYrP7bzI=; b=36mJOIwPNHs1
	dDZzRCkNURh9jWNFAjD78AFE03vo0wjFSfFAMEUS9gAdmwHicdFOdkqukU5XN6l9
	iIbBb2PyuTM5NKHwc3qE7zgkT/AKNbuWQjHGF8H2hYTq6g+f7xHUmY8jNpIXXDna
	DVc1qwED48N/cTwlf9USiHs/D9MwyJEeh3gXXEYYoJ63UZdL4Sb7wNIB1Y4NcZOs
	Bd1hcleyRLvhnGUtXx1rblmSh2OQe9aGX+DMNgI2MmWFcIMDSb5QmLzDKNd4Zgdv
	ami+keJOV6gQRoDDLHL6Dz6ABlbXd0G3Fq246X7I95M1kn34SpCNAaG/WMDosDBX
	/29Ngp3CIVnm6cS7obytx4mPooQJoNCnWAWR9jWoIITubNOM6sT0ffQseOuNxGaY
	+DMjHIMSlNhRqfL5rws35buV0DdSVaPlMReqX5nDef/fw1+cQ4RFfc0iRuSpHLy5
	rh++bl4gWY6nknCyyzo2MWMB1v3fp3arBj9/qg29pf3hgNgYtn9LaFSOHbbX1Eco
	gslnrIlUriqJ06wjICsfheDuhq8fRg+aBCKs0UmhwedKxEiB7hUpBDvS8EldSyAv
	iTTVu2+zUfx1TruLrIxrJCdG0xBYLrU2AFj+dBDvuI86tR42C/y1cYjuJvC4u7zo
	0syDnRCujxg+rPBXajvRnHW3bPMZb5A=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 24 Nov 2025 17:35:06 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6B569601D6;
	Mon, 24 Nov 2025 17:35:04 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 5AOFYlCj025431;
	Mon, 24 Nov 2025 17:34:48 +0200
Date: Mon, 24 Nov 2025 17:34:47 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Slavin Liu <slavin452@gmail.com>
cc: horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org,
        fw@strlen.de, phil@nwl.cc, davem@davemloft.net, edumazet@google.com,
        kuba@kernel.org, pabeni@redhat.com, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
Subject: Re: [PATCH net v2] ipvs: fix ipv4 null-ptr-deref in route error
 path
In-Reply-To: <20251121085213.1660-1-slavin452@gmail.com>
Message-ID: <e0ecac84-29b4-477e-8e40-2603ca7b1154@ssi.bg>
References: <20251120190313.1051-1-slavin452@gmail.com> <20251121085213.1660-1-slavin452@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-1733670800-1763998496=:3133"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1733670800-1763998496=:3133
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Fri, 21 Nov 2025, Slavin Liu wrote:

> The IPv4 code path in __ip_vs_get_out_rt() calls dst_link_failure()
> without ensuring skb->dev is set, leading to a NULL pointer dereference
> in fib_compute_spec_dst() when ipv4_link_failure() attempts to send
> ICMP destination unreachable messages.
> 
> The issue emerged after commit ed0de45a1008 ("ipv4: recompile ip options
> in ipv4_link_failure") started calling __ip_options_compile() from
> ipv4_link_failure(). This code path eventually calls fib_compute_spec_dst()
> which dereferences skb->dev. An attempt was made to fix the NULL skb->dev
> dereference in commit 0113d9c9d1cc ("ipv4: fix null-deref in
> ipv4_link_failure"), but it only addressed the immediate dev_net(skb->dev)
> dereference by using a fallback device. The fix was incomplete because
> fib_compute_spec_dst() later in the call chain still accesses skb->dev
> directly, which remains NULL when IPVS calls dst_link_failure().
> 
> The crash occurs when:
> 1. IPVS processes a packet in NAT mode with a misconfigured destination
> 2. Route lookup fails in __ip_vs_get_out_rt() before establishing a route
> 3. The error path calls dst_link_failure(skb) with skb->dev == NULL
> 4. ipv4_link_failure() → ipv4_send_dest_unreach() →
>    __ip_options_compile() → fib_compute_spec_dst()
> 5. fib_compute_spec_dst() dereferences NULL skb->dev
> 
> Apply the same fix used for IPv6 in commit 326bf17ea5d4 ("ipvs: fix
> ipv6 route unreach panic"): set skb->dev from skb_dst(skb)->dev before
> calling dst_link_failure().
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
> Fixes: ed0de45a1008 ("ipv4: recompile ip options in ipv4_link_failure")
> Signed-off-by: Slavin Liu <slavin452@gmail.com>

	Looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

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
---1463811672-1733670800-1763998496=:3133--

