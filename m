Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D63526281D;
	Tue, 11 Mar 2025 17:51:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741715473; cv=none; b=G3h8uUCb8fmVxx6fAe1l+qHl7QBRNJvJoNreGW0f9PnGnkZUXrERryPYloZfSaHDGklv4FmRiUU9j+XKReM3ycrV2+0kBJTUWUBApaazxM4vq0qwGbVdt2sS4BWd8sLP+9I+U/b2+kcez0S5iK3vkclDZvkv9oZfuTShx3EuPiI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741715473; c=relaxed/simple;
	bh=97ziDHSz4jTphXggUjofDFppHaKKaL/PAf3ldaxBHlo=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=pI9WUPsSMkQ5tAIbYe/BKpnOQ3yfiWUxq26/b/ho1w4oOJH2jRGIunVfJZw9sM/PHMXL1dcTn9d0nYdmD164tVvwwtpD7EvwDjLaME/UxTGWSJWzYpyESCiyJmuOR/+e4fASGAPHtw6KsTy6xFCfy4YG4soGrhPu+I+hHls4pRA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=bU6dToTW; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="bU6dToTW"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 7C0E121DFF;
	Tue, 11 Mar 2025 19:51:02 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=E09RZrwB1BdC0du6fZ4IpCQwzAeISVdOdjxVAsHSwMw=; b=bU6dToTWvmor
	3TlddTM1vheO9mN9vJwNEsHk0EeViWL+bPmkSQSn8s/A8LOi/pMHQ5PXkEv3LEz+
	xBjagkozLHrE9/J71xf/3oJH5+DVHkidzRgkFN3zQk+Xn7O+pHUuJo71R5/zo5Wv
	Vuvmc0jb6vv2Nas3nzx1GSoJbNLbYSk+T8E7pFQKRrLaPpd80bDTUVwksueYKhhC
	72caTYH+EN5B+GEls6r2rfFRBUGV8KTdp+MDSmjeEOAShVHg+AKuq+q3gXOqJlxe
	58YxDFlXC1VxC/AYmp5Z6JynTTkME+oq1ltBm59aSdxC1Ck/AKn5PYV3oAmaRZp8
	kDKXC21WL15D47muSOxRSuC9y1SCg8ubiwcRZ3qKDc+rvZEZUbXly1sWvOOvIe22
	5CtT34NvITOOdkfn+5VCtnLyzeCyuwrUsh0CWrOM1OyvPXjfp+VniOypY1nxMD5Z
	RrlGbYesRis2SfmfQ+Rsl3UXJxjmck1nguhks3NXJzy0kZwJCb9VZZ/plI01HsyW
	otmoWdpDLBjT9KMv+SSrr6uQeaRqFxde+Jbt4gOloSdAZ95GI0oziPM5H8Mzysmi
	P2LgmF3AlNAW+k9VCYuRqc1qWbc2QRVvzO1geLBxawpky4d6eETTqBC8XPcMxbO3
	eLjjBktm/JGF2Z+G6Hy7elyowIOyEmc=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 11 Mar 2025 19:51:01 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 1B53017069;
	Tue, 11 Mar 2025 19:50:54 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 52BHoivt047827;
	Tue, 11 Mar 2025 19:50:45 +0200
Date: Tue, 11 Mar 2025 19:50:44 +0200 (EET)
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
Subject: Re: [PATCH v2 net] ipvs: prevent integer overflow in
 do_ip_vs_get_ctl()
In-Reply-To: <1304e396-7249-4fb3-8337-0c2f88472693@stanley.mountain>
Message-ID: <262d87d6-9620-eef4-3d36-93d9e0dc478c@ssi.bg>
References: <1304e396-7249-4fb3-8337-0c2f88472693@stanley.mountain>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 10 Mar 2025, Dan Carpenter wrote:

> The get->num_services variable is an unsigned int which is controlled by
> the user.  The struct_size() function ensures that the size calculation
> does not overflow an unsigned long, however, we are saving the result to
> an int so the calculation can overflow.
> 
> Both "len" and "get->num_services" come from the user.  This check is
> just a sanity check to help the user and ensure they are using the API
> correctly.  An integer overflow here is not a big deal.  This has no
> security impact.
> 
> Save the result from struct_size() type size_t to fix this integer
> overflow bug.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Pablo, you can apply it to the nf tree.

> ---
> v2: fix %lu vs %zu in the printk().  It breaks the build on 32bit
>     systems.
>     Remove the CC stable.
> 
>  net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 7d13110ce188..0633276d96bf 100644
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
>  		if (*len != size) {
> -			pr_err("length: %u != %u\n", *len, size);
> +			pr_err("length: %u != %zu\n", *len, size);
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
> +			pr_err("length: %u != %zu\n", *len, size);
>  			ret = -EINVAL;
>  			goto out;
>  		}
> -- 
> 2.47.2

Regards

--
Julian Anastasov <ja@ssi.bg>

