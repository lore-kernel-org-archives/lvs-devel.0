Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A565A30C359;
	Thu, 28 May 2026 10:29:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779964173; cv=none; b=bukKeBEYd4xD0RpMyXBLiAWfWq1QZPWvzm6gUEirf/s1f0pd9xgG+iZlWPIeQeUiRhZySSNUFrMVa3x1w6PPjod2E7gMTpmIKOKca7GbjJCxQm9lhhJ61joGmFGj+MTdZUqw5du8/W+Dkyy/piIorxfFvFL+DUR+i72kRghf5ZA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779964173; c=relaxed/simple;
	bh=JTt807Qy7bn1+1XqPQYWbpkGmyn4635Qbiems4WwloQ=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=cumhlUGfTUpcoyIZ6d8Ci9CI6vZsgFy+63+JxRAW5QVpYgQeenOjPVdr6TsVlgpmVVwHaYv4E8nv1EVpn6xXkjunzS0wOna//x4ozqj0q/a6IC6GPNN740nDqWngweM3y/QSs50YL/kDANDWoepEgoPQMVpL5h111FdZipcRIgU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ZnkrZz5+; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ZnkrZz5+"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 46BE421108;
	Thu, 28 May 2026 13:29:27 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=+MAlYPIe9hB3K5acB14N7+FZdX7wf1HTiLIubdRiq8Q=; b=ZnkrZz5+xFt4
	0RhHbpxE39ZfvrGiV4BNylloI129EiKRNo6Bak7G8J34v876kBvhzzabOZ4KUp15
	K5s8PID1yxg5eVNQS+EG5jzUXlQ0eYk9+9cnt0C0NM9re5xPeDrUuKXqx/zNkx46
	CCXwf/l9sEo1j0bnxyUxhWIDgi79RZGhe3Cs4S1pa8A15bEAL+SFRqUmm4BON3V8
	0H0e9sqvKPzYJhej3C7ToCXGvbULo/6+ynrHXFQo9IJBt/odGmBArCV2LDjbzUdr
	KbJydSv1YO0k2S38bTC++tUa4pCk/7Nf6LPOXFDvfQ7v726djfoWICzrw7oF9QHJ
	vrBfe9o2xUpItcBvyqvKwIGYIE0a4LROTCQWaJCyu3BcxSoPmcvpbeCZFYofm444
	jWbZRnWa26t/ThwJNG0hbmgMChgn1Q9M8aDlraJr9X6eU68eymDDLlg4Q/7Avz1K
	IQortVsc7QLw8BojrX0LIZ6/w8apEqUgXaPeWTqZ2bvkUrTsSkNhbKKMLNxbqpwy
	+4ONjy9nux/wOIf3pTWsKniy+12ku4AsUCO3vYG64ELlH2AK/GgWxhIIvFF4QxCk
	SxzloCr3O9ds7cwM2Opj4W/AEovVtFaWpm27N3bSTz4Fw1CT/lK9aO0mxpAy0jvV
	+/xefDvi09VTs3ZrbcMd2Tj8VpAhyDk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 28 May 2026 13:29:27 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 897BD609E9;
	Thu, 28 May 2026 13:29:26 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64SATPsG030077;
	Thu, 28 May 2026 13:29:25 +0300
Date: Thu, 28 May 2026 13:29:25 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Wentao Liang <vulab@iscas.ac.cn>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Phil Sutter <phil@nwl.cc>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] netfilter: ipvs: fix ct refcount leak when template is
 invalid
In-Reply-To: <20260528072100.1163109-1-vulab@iscas.ac.cn>
Message-ID: <155bcc31-033b-18ec-8ff1-bb0d32e4b44a@ssi.bg>
References: <20260528072100.1163109-1-vulab@iscas.ac.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 28 May 2026, Wentao Liang wrote:

> ip_vs_sched_persist() calls ip_vs_ct_in_get() to look up an existing
> connection template, which returns ct with a reference held. If the
> template exists but fails the ip_vs_check_template() validation, the
> function can leak the reference in two ways:

	You missed the __ip_vs_conn_put(ct) in ip_vs_check_template()
when 0 is returned :) So, there is no leak.

> 
> 1. If no destination is found (scheduler returns NULL), the function
>    returns NULL at the !dest check without calling ip_vs_conn_put(ct).
> 
> 2. If a destination is found and a new template is created via
>    ip_vs_conn_new(), the old ct pointer is overwritten without its
>    reference being released.
> 
> Fix this by adding ip_vs_conn_put(ct) before the early return when no
> destination is found, and before overwriting ct with the new template.
> 
> Cc: stable@vger.kernel.org
> Fixes: 5b57a98c1f0d ("IPVS: compact ip_vs_sched_persist()")
> Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index d40b404c1bf6..bdc3f296876a 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -536,6 +536,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  			IP_VS_DBG(1, "p-schedule: no dest found.\n");
>  			kfree(param.pe_data);
>  			*ignored = 0;
> +			ip_vs_conn_put(ct);
>  			return NULL;
>  		}
>  
> @@ -551,6 +552,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  		if (ct == NULL) {
>  			kfree(param.pe_data);
>  			*ignored = -1;
> +			ip_vs_conn_put(ct);
>  			return NULL;
>  		}
>  
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

