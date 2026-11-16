Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=217.70.190.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794826288;
	b=X8eiJiZr5f7viz/MHBvdhvO1Y+RrZc0MFP00lCBmMfF75Y3H6+r/WzdjhywSk7OCCjlh
	 wM4iLtrHwjF/uIa32oS1SWm21HTpzKnRN6+WeRFiqEgPCAcSfIU02SkPwNYVqhTG4+CNN
	 g8dZBHBnTe5pUDlsktdiDoPBtZOIT5V0nnaTeHapXTXt5w3zhDNWdAehNDe66oaYOHjMR
	 YX7L6W1gapM/VjUp13LcZ0UJOvW/pfkL6ax3/Vj/piejILS4dbFdK+cT9vCuPxiCDH2uY
	 7C16wGYoM3ERwJXNMWLjevOjf8hfeC9N5frboGRmwz9pDCkAqX95ORDU2pdcg5N6G0g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794826288;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Status:X-Spam-Checker-Version;
	bh=3zuBeh62F0goKLBBSQZ74NJDoh/EALPwFHfvTfhMEjI=;
	b=TXd1pYaVVtpcb5f0CaTTv3/uN3CfD6lpOvnE8A7juZyuQSzqfVXQVA9nQnG53pvJHQel
	 BA7J6PcOvU8Uty+myiwEmwo3lbIVd0bbB+yPyjeQolK1rvLxIyFh+KRmqLGaSgOmXnW38
	 XbTqdbL/caOyptFY0MoNSoKGjIOedWu6eTQnjW6Vg7AuElyppxkawU85CeLEdwwYwcrNY
	 TJ1jteh96tFGGIPv9gMDzjReD/g0rVkjVzmX0KR86yuYyzSGI7tDPoTQwiz6XxTspI8k+
	 YvBuaE1cVvIRDrCzTtz2uLW2HOkUrZjibV/C5QbleNrLGzGzPNnvbhj7ksbwvbEZMMA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=netfilter.org;
	spf=pass smtp.mailfrom=netfilter.org;
	dkim=pass header.d=netfilter.org header.i=@netfilter.org header.a=rsa-sha256 header.s=2025 header.b=tytOb2wC;
	arc=none smtp.remote-ip=217.70.190.124
Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 5CE3A606A31C;
	Mon, 16 Nov 2026 10:51:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5CE3A606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.a=rsa-sha256 header.s=2025 header.b=tytOb2wC
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1794826284;
	bh=3zuBeh62F0goKLBBSQZ74NJDoh/EALPwFHfvTfhMEjI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=tytOb2wCxBecChVYvF5oFCpUEwLOItiSxNbM05bzgA8BuO6keKMc9djPuMMR0doSK
	 TdvCdx5H6EP8ZvxEMM4gzr2LD9JtKEWL+XecXmd6zp9CD3zuMEJRQLEr9S0p6BbMuZ
	 EUknlRlBO+GxUYcNIsvmBFCw/Fo5iN5+xIWlr7uK+R89HUXVxnuW9Kg3VhadGnev5S
	 aCHgTIVn2x4Bl0du54cQhaysO1J2woySi3zAOjTek0qmgI4p1tfceccyKJv7cdlD91
	 kFfbF5xwf/rv9PnC9Kx5x860nkqDKQA/6QKSjGgccxlEyV37+n9Hze7dlMXHAOYi5J
	 ahHnm4BVws42w==
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id 4246A60055;
	Mon, 16 Nov 2026 11:51:24 +0100 (CET)
Date: Mon, 16 Nov 2026 11:51:21 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH nf v3] ipvs: ftp: do not link expectations to unconfirmed
 conntracks
Message-ID: <avrgKSO8nfTnv4iL@chamomile>
References: <20261116101506.98853-1-theodorlarionov@gmail.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261116101506.98853-1-theodorlarionov@gmail.com>

On Mon, Nov 16, 2026 at 01:15:06PM +0300, Theodor Arsenij Larionov Trichkine wrote:
> ip_vs_ftp_out() can link an expectation to an unconfirmed conntrack. A
> later extension add on the same packet, such as seqadj in
> ip_vs_update_conntrack() or NAT, then reallocates ct->ext and leaves the
> expectation pointing into the freed area:
> 
>   BUG: KASAN: slab-use-after-free in nf_ct_unlink_expect_report+0x490/0x4c0
>   Write of size 8 at addr ffff888004dd4e48 by task syz.2.17/649
> 
> Link the expectation only to a confirmed conntrack.
> 
> Fixes: b25adce16064 ("ipvs: correct usage/allocation of seqadj ext in ipvs")
> Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
> ---
> v3: skip unconfirmed conntracks, as suggested by Pablo; v2 did not
> cover NAT.
> v2: https://lore.kernel.org/netdev/20261113011447.2357709-8-pablo@netfilter.org/
> 
>  net/netfilter/ipvs/ip_vs_ftp.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 44de99f4d187..cb0cdc35a7c1 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -398,8 +398,10 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
>  						   end - start,
>  						   buf, buf_len);
>  		if (mangled) {
> -			ip_vs_nfct_expect_related(skb, ct, n_cp,
> -						  ipvsh->protocol, 0, 0);
> +			if (nf_ct_is_confirmed(ct))

I think this is coming a bit late?

Maybe it is possible to check this earlier in this path?

> +				ip_vs_nfct_expect_related(skb, ct, n_cp,
> +							  ipvsh->protocol,
> +							  0, 0);
>  			if (skb->ip_summed == CHECKSUM_COMPLETE)
>  				skb->ip_summed = CHECKSUM_UNNECESSARY;
>  			/* csum is updated */
> -- 
> 2.34.1
> 
