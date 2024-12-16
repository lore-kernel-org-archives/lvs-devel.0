Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14B71BA49;
	Mon, 16 Dec 2024 22:18:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1734387518; cv=none; b=fcWp4rGedw9CaXao/wUUyXj861EJPnAcvmTjtkBxu2GdgqsYdppAeSnMSNAE+KBurqTcTS2QoJ+yszzUdpffN6A6llyyc7l8XFhMmB2w71eflYycIYGyQso6INfabkHa/kbgV8/lO6j0SjKBnPQZOwH3vHYxDeHlv0yvroU3cA4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1734387518; c=relaxed/simple;
	bh=RroWU3dXYsEIKnrRQq/sEb58UjG+0rdx0yuK4kzjM0E=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=c8/f/aqCtCnRg2oMlP9jou5xsEPROKYGzwnFNXD9A7hi7BJlsOIKbwyiw9jSeyzPL/Ts39KAXEl6dNNy57XCMoQFGvS+uYRg/Zj6SpZLQ01T+ubDtBs/tpTGAosOXo1QaP8DCPhWtbf3F3jaSwTyiV66KeHlRbyk+z4sLg2+JGI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=EAFMYX0A; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="EAFMYX0A"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 02A5123564;
	Tue, 17 Dec 2024 00:18:27 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=P2PH9pRT7HgCd5Xu5gne/9j211rCmiQ1rBQxoRa7c10=; b=EAFMYX0AKai2
	D20CVrb/14WbDKGX+4Q+YEnPsoql+Pxb9dWa/9uorwtILHq6mZn/nlX565nuA5E4
	LoVjiPn8M/BYWYXyem2aWq+QsSDaSmjwrN2UV8mMDnjhMC5xTwCXOXuOzlseSn/i
	HixG8qAnxx4oZQLODB7y5QXGMRSiGoCojjhYq7cNX1z6XCoFVMGPepnLBNjt+iyZ
	wJ1en+WwEIBsrtuad5oz+ZqmtDFdpCqWPfNrheC0eELpfKmG8+LVa9Ej+y4Bo8wM
	8SdlsCCoXEU6Yb4NUBzzaisEsNK8DO6RFJGTj6KkQXBqltnQqNiWkq2JaReBoStV
	rSFlKq2n8vt40N3tvrb012csM/4UN2Uk06nIXglHrwp/tI4+QDy22rqV91ilhWdN
	TTponn6SuCaPKDT7/Rimiuo+zdBu+cenWwCIR7ALERNmbbCtK6E+msDIodCFcpKH
	0RdCodgxRAt1V+d3fWyk4b7uUK05LFKaISfT9My7y4mRcs2YKJ76uw0/OIc2e9Sx
	+Es5dtIwUlMQcd2aAi6rQGVAnRK1f7nIkFummQi0fJjUc/LQeHGsVwVaHOYuRt9I
	7f3CfM/jzMG+iL2tYI1/Ba1MoslmCu/FF3Dgv1n32xvaspyl/QOua40eJPhcdotU
	6MIbwEW40TfTASMOhrT9Ecpxtaf86Xc=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 17 Dec 2024 00:18:26 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 1122F15D48;
	Tue, 17 Dec 2024 00:18:11 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 4BGMI5p7081391;
	Tue, 17 Dec 2024 00:18:07 +0200
Date: Tue, 17 Dec 2024 00:18:05 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: David Laight <David.Laight@ACULAB.COM>
cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
        "'Naresh Kamboju'" <naresh.kamboju@linaro.org>,
        "'Dan Carpenter'" <dan.carpenter@linaro.org>,
        "'pablo@netfilter.org'" <pablo@netfilter.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "'open list'" <linux-kernel@vger.kernel.org>,
        "'lkft-triage@lists.linaro.org'" <lkft-triage@lists.linaro.org>,
        "'Linux Regressions'" <regressions@lists.linux.dev>,
        "'Linux ARM'" <linux-arm-kernel@lists.infradead.org>,
        "'netfilter-devel@vger.kernel.org'" <netfilter-devel@vger.kernel.org>,
        "'Arnd Bergmann'" <arnd@arndb.de>,
        "'Anders Roxell'" <anders.roxell@linaro.org>,
        "'Johannes Berg'" <johannes.berg@intel.com>,
        "'toke@kernel.org'" <toke@kernel.org>,
        "'Al Viro'" <viro@zeniv.linux.org.uk>,
        "'kernel@jfarr.cc'" <kernel@jfarr.cc>,
        "'kees@kernel.org'" <kees@kernel.org>,
        Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org
Subject: Re: [PATCH net-next] Fix clamp() of ip_vs_conn_tab on small memory
 systems.
In-Reply-To: <24a6bfd0811b4931b6ef40098b33c9ee@AcuMS.aculab.com>
Message-ID: <5e288aa5-5374-5542-b730-f3b923ba5a36@ssi.bg>
References: <24a6bfd0811b4931b6ef40098b33c9ee@AcuMS.aculab.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sat, 14 Dec 2024, David Laight wrote:

> The 'max_avail' value is calculated from the system memory
> size using order_base_2().
> order_base_2(x) is defined as '(x) ? fn(x) : 0'.
> The compiler generates two copies of the code that follows
> and then expands clamp(max, min, PAGE_SHIFT - 12) (11 on 32bit).
> This triggers a compile-time assert since min is 5.

	8 ?

> 
> In reality a system would have to have less than 512MB memory
> for the bounds passed to clamp to be reversed.
> 
> Swap the order of the arguments to clamp() to avoid the warning.
> 
> Replace the clamp_val() on the line below with clamp().
> clamp_val() is just 'an accident waiting to happen' and not needed here.
> 
> Detected by compile time checks added to clamp(), specifically:
> minmax.h: use BUILD_BUG_ON_MSG() for the lo < hi test in clamp()
> 
> Reported-by: Linux Kernel Functional Testing <lkft@linaro.org>
> Closes: https://lore.kernel.org/all/CA+G9fYsT34UkGFKxus63H6UVpYi5GRZkezT9MRLfAbM3f6ke0g@mail.gmail.com/
> Fixes: 4f325e26277b ("ipvs: dynamically limit the connection hash table")
> Tested-by: Bartosz Golaszewski <bartosz.golaszewski@linaro.org>
> Reviewed-by: Bartosz Golaszewski <bartosz.golaszewski@linaro.org>
> Signed-off-by: David Laight <david.laight@aculab.com>

	Looks good to me, thanks to everyone!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Pablo, Simon, probably, this should be applied
to the 'nf' tree as it fixes a build failure...

> ---
> 
> Julian seems to be waiting for a 'v2' from me.
> Changed target tree to 'net-next'.
> I've re-written the commit message.
> Copied Andrew Morton - he might want to take the change through the 'mm' tree.
> Plausibly the 'fixes' tag should refer to the minmax.h change?
> This will need back-porting if the minmax set get back-ported.
> 
> I'm not sure whether there ought to be an attribution to Dan Carpenter <dan.carpenter@linaro.org>
> 
>  net/netfilter/ipvs/ip_vs_conn.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 98d7dbe3d787..c0289f83f96d 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1495,8 +1495,8 @@ int __init ip_vs_conn_init(void)
>  	max_avail -= 2;		/* ~4 in hash row */
>  	max_avail -= 1;		/* IPVS up to 1/2 of mem */
>  	max_avail -= order_base_2(sizeof(struct ip_vs_conn));
> -	max = clamp(max, min, max_avail);
> -	ip_vs_conn_tab_bits = clamp_val(ip_vs_conn_tab_bits, min, max);
> +	max = clamp(max_avail, min, max);
> +	ip_vs_conn_tab_bits = clamp(ip_vs_conn_tab_bits, min, max);
>  	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;
>  	ip_vs_conn_tab_mask = ip_vs_conn_tab_size - 1;
>  
> -- 
> 2.17.1

Regards

--
Julian Anastasov <ja@ssi.bg>

