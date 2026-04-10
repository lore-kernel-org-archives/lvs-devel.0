Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F41F3264FF;
	Fri, 10 Apr 2026 06:52:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775803928; cv=none; b=MJRy9+5dHXcFLbY8uNsGt1ECxf3ek115RLMh6HZX5HHwkp9NXW5aaXWEBZC3+j0pkp7maVxwEUfuVh2ftG2oBmACm9R+pBGfQEi6SZ6czmwIfQY6u9yvXax8W5VaDoNQiKQGqNRvjZ06fkqdXNoYj2oh1Q1mfsTbL1Cgtkq2IC4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775803928; c=relaxed/simple;
	bh=1PoxhyRSV7JrRuAtwTi+CblKJwRESpqiBPV+2q1EFPU=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=I+Tr9vdUCsTWlW66yyLqKijEwRlDNIhOllM2s6oFzi7E8jnolCXei0uCSL0Vcb6i7j6da6T4slfPl2H5T0+qSzzMloA3Eays0KEj08TwjoYyUlmQJ3LDoewTkQDV94ZmXVOVdDPdocNz/qUdfR2350bOrNpVS6I09GIe08Y7AO8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=evB2pfiA; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="evB2pfiA"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 6BD8921CC0;
	Fri, 10 Apr 2026 09:51:53 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=dpthAZ+MnRKjRDQ0XeJ9wZ/6Fb5SFuCP4ejYX5TNaLw=; b=evB2pfiAfE+S
	n6qD2bu+JvPghX8UZEugmYXY7dHkPRrgr7n/DklFBvzme1U5zfwgryyYHDp3Or86
	Q6XBEkSRyWGwIsDEykciCU0d/xQVbkeAhN98blFJDv7mv1LTVkuUfwhhLc+XUg7j
	0xUMyQ1P0Qyi16/L+PrIVIa58wvKnZtlfRANx0ENwTyq2VGgn/QMdsUuXZXW7wza
	+jyNy2rUdpTNOt969xJZKd1sYYjI2rV1weo4P7dCVdDwh3rPmxDnD4dw+R4lHX49
	yiFYYAe9fdufhNd0BhT3o6NLLwPFaxV5wh5k9A3xdMIAXt70Lmf/UCvwkRLFx6yV
	H9r526JX/OXtp6GnfF+q5h4nMaxbaxC8HcfQPy3qIN1znFDkXryrOVL6L33YJJn5
	mK/5p96qP4QK83tJ9Q+AzwTuRPN2GP+7YN/a7aN8z5rry9e4fCISbPuGqRaOZrkN
	OoJHlMVQDfoPmIl/9vnnfcvxafVOa6aOD5lQd4uuKZz1qSk8d9hd5aR5EVOavA3y
	NfJ3qm6SJi8uggkTbQX7tWAMyAP7Pl6SU9rWj4vlUCY177wz56L/GlKv/0URQ2t5
	CIxeVhb9CwnIuBrLCvz5d5FtbIGgdpGOtTf2qh/tB6/DmcDMNgFMJqqgoI+Fqrna
	QgTtJme7cf5kP4X5Gxs+zHSA78I4pw0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 10 Apr 2026 09:51:52 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 2FDBA6098D;
	Fri, 10 Apr 2026 09:51:48 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63A6pVLA014912;
	Fri, 10 Apr 2026 09:51:32 +0300
Date: Fri, 10 Apr 2026 09:51:31 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Yingnan Zhang <342144303@qq.com>, horms@verge.net.au, fw@strlen.de,
        phil@nwl.cc, davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
        pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v3] ipvs: fix MTU check for GSO packets in tunnel
 mode
In-Reply-To: <adhOOC6hF_vNDl1g@chamomile>
Message-ID: <f8946f64-2d31-d792-e23a-3bd7566f0f17@ssi.bg>
References: <tencent_73010FBD5FA1C05C3BC23A07A50B11CEC90A@qq.com> <adhOOC6hF_vNDl1g@chamomile>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 10 Apr 2026, Pablo Neira Ayuso wrote:

> On Thu, Apr 02, 2026 at 10:46:16PM +0800, Yingnan Zhang wrote:
> > +	} else if (skb->len > mtu &&
> > +		   !(skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))) {
> 
> Maybe helper function helps make this more readable?
> 
> /* Based on ip_exceeds_mtu(). */
> static bool ip_vs_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
> {
>         if (skb->len <= mtu)
>                 return false;
> 
>         if (skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))
>                 return false;
> 
>         return true;
> }

	Good idea! Yingnan Zhang, please send v4 by adding
this new function before __mtu_check_toobig_v6()...

Regards

--
Julian Anastasov <ja@ssi.bg>

