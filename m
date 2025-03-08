Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA13C1311AC;
	Sat,  8 Mar 2025 12:16:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741436204; cv=none; b=YAMFUax+fIQ+KOM+H84Xf/6qkwuGkMhxlJUYjFksqhYBBfAMlxvs98dJDedwa5lVigZkQ6td9PggyoKryZ6AgBkU8RXDd05t+WWSf7k8I1bJQnLOMuB91ORLAgn3riGsnFsqZWgXXDxGC5AE+o2r+1u7IYHR8FnJl8Zu8bmJ+QE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741436204; c=relaxed/simple;
	bh=rqEFIO6+Aku7fuOhNVaBx9UgJ8RgIr/C4jx5w8qOKLg=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Wpab9Vrbcut7WmAgOTzLSES1wIFplt+YsRUzWU34VACGAEw94w5sN4Qu5D+/Vw5sYS4yQi0iuaFvuEOYi21Tv9oWlXMiQgEK/0skbU8s6ZbLBqFAn0q8SXAcb0VqvysQZ+4RDNoARRAUIBc4Yqs4vEtP7M4jlFTr1Bf8sW7FggE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=3CC8aR6M; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="3CC8aR6M"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 24AB921DFE;
	Sat,  8 Mar 2025 14:07:05 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2bJIGwQcMLBdAbj0n9muHb0asHjtoZ4ael8yDhOa+gE=; b=3CC8aR6MDm+x
	Dw3I5/m2s+VDUNl9xJtFwJkcnMSDz3k9GBHVBUMYNHrviq8xxuJLs4YK7WR0wSBV
	2p5gy9VCY1FibCsmZB0lOvMs04n5o1Kb0/gtb8fesWZdrMF3rfgU6Nxl3xHRSvkh
	0H7N1bkL3ryaJ4uID8j06ZxpjO6tM5dbxpaAnMOXKFpRcCNP+DXOyx2W1rdi6WDF
	gB+AdeU3z/FcmxQCc4MGcl2uinL5jWfjv6k/iuqTZzhsxwq+SRPaH3wHJQgLccUG
	CJsm0WwlMH/DrL197BhY5Q9g+RcXouFR6ThVyXyfafEhXZ7ACT7JYFi8TmVzLMDd
	A39UMPC0QZThShCCSb6CjZlu4qdmY/PvBOPW0ekpr6t8+oyvrq2TSFmFciX+Bl3s
	cc99lv2jYbQm4yiIxsYDILUuAoQTCPeNmuBTsOsS4HauQnpe1zcnHp/EM+KaXzHo
	K2TebXqHQoK5LzgmZQzHJEiTXJL5e1e5ItC+zws76QVK3e5EYLpSEjbuMk5oJbOr
	LqqcHRZTnhpY8UW68MqwRllg8BGzOarUyaZ9dPcrqDqLVzEWzJBh6bWvBw+G8J4X
	p4hCCA3/dH48tkcZLf4LegWEVs7Zv8CBQjUypFVEr2CQEgv2uHfEADCCfB3ozmps
	QQv0yKHMgv5V79027dQl2GX4dta0iQ8=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat,  8 Mar 2025 14:07:04 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 1E4E31706F;
	Sat,  8 Mar 2025 14:06:57 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 528C6r8G010965;
	Sat, 8 Mar 2025 14:06:54 +0200
Date: Sat, 8 Mar 2025 14:06:53 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Dan Carpenter <dan.carpenter@linaro.org>
cc: "Gustavo A. R. Silva" <gustavo@embeddedor.com>,
        Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [PATCH net] ipvs: prevent integer overflow in
 do_ip_vs_get_ctl()
In-Reply-To: <6dddcc45-78db-4659-80a2-3a2758f491a6@stanley.mountain>
Message-ID: <a89fe1a8-989d-c2b7-f039-63670d099b67@ssi.bg>
References: <6dddcc45-78db-4659-80a2-3a2758f491a6@stanley.mountain>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 7 Mar 2025, Dan Carpenter wrote:

> The get->num_services variable is an unsigned int which is controlled by
> the user.  The struct_size() function ensures that the size calculation
> does not overflow an unsigned long, however, we are saving the result to
> an int so the calculation can overflow.
> 
> Save the result from struct_size() type size_t to fix this integer
> overflow bug.
> 
> Cc: stable@vger.kernel.org
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 7d13110ce188..801d65fd8a81 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3091,12 +3091,12 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  	case IP_VS_SO_GET_SERVICES:
>  	{
>  		struct ip_vs_get_services *get;
> -		int size;
> +		size_t size;
>  
>  		get = (struct ip_vs_get_services *)arg;
>  		size = struct_size(get, entrytable, get->num_services);

	Both are GET operations. The problem that can happen only
on 64-bit platforms is that user will attempt copy_to_user() with
shorter buffer and will get EFAULT if there are so many entries to
return. On 32-bit size will be -1 and will not match *len (EINVAL).
So, I assume the issue is not critical, right?

>  		if (*len != size) {
> -			pr_err("length: %u != %u\n", *len, size);
> +			pr_err("length: %u != %lu\n", *len, size);

	%zu, %lu fails on 32-bit platforms. Please, send v2
fixing the format.

>  			ret = -EINVAL;
>  			goto out;
>  		}
> @@ -3132,12 +3132,12 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  	case IP_VS_SO_GET_DESTS:
>  	{
>  		struct ip_vs_get_dests *get;
> -		int size;
> +		size_t size;
>  
>  		get = (struct ip_vs_get_dests *)arg;
>  		size = struct_size(get, entrytable, get->num_dests);
>  		if (*len != size) {
> -			pr_err("length: %u != %u\n", *len, size);
> +			pr_err("length: %u != %lu\n", *len, size);
>  			ret = -EINVAL;
>  			goto out;
>  		}
> -- 
> 2.47.2

Regards

--
Julian Anastasov <ja@ssi.bg>

