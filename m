Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29B0747532E;
	Tue, 22 Sep 2026 16:52:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790095979; cv=none; b=OnFZTeDOU7dfVTLMpI6RUe50K94X7xG9n4xVmRvDn8pt2MXNYKiX0TvwYqLAetfevdxq6sfED0ZBCLROm9dGCYArS3cS+pvEdWsZh9U5wqAyTftuPI5ox37X0a/SzQ7L5QIm1Dgg7p4k4xq5NDuzh8RKBRfqkXF2gQiC8Q8DwuU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790095979; c=relaxed/simple;
	bh=Zx7JncGWk4TW7RfMzGAcjrtyj4qdjZAEcCxFpOv3g5Q=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=mq79B1BsLVMqvymjB1HVQLg0T3358wSP9KEzyJZpXzB4vw/GZEd+0zKlzHjzQ3yPcL1gIugTMEcgFVVqh9xjsPUaT1SQ+qxkKVAOlVapVfiYCRs7m071HqtH/dr4mYkfwhMTRJBV4dM7JM7byHu5d51BsriB2xT0zHoR/MJ0B8k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=xEnZmAQV; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="xEnZmAQV"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 59107213B0;
	Tue, 22 Sep 2026 19:52:42 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=VJI6C9siQ7JlQwwveoBhCM8yQghseBo9HlyzE9K3zp8=; b=xEnZmAQVw2Ay
	f+vi88MUk9lm16OcC2/SIhM9E/SS/ZtqMKztZOpwHFdAbajcJ49leIlfzRmnOlLe
	y1hyb7AhtAj/JoaY2IBQjk8lLdreBx8N8R6vPp8YRhEiX0M0k20P+UN35mSs/ODW
	OzWp40Fw6i4KuVhLUCl8UM5K6OZolVXTIqpHTZREldD9k3Lq4ynNwmN3uk0bOilr
	taGotiuzQRz1EuAcW0IXPOyc9o8lR9SpCBgOe5POhrF0vwpvlUuVOfkp8WX5ofeV
	ooZ11/ZYG7xXU8rpNhsk8q1KBqwYB9H4xkoNTxy+UovGiNYO7zSB46DEhjfDW0Jv
	ZpKwn6C+RbbrXDicg3FY0fenwrs/gv49xpGahh4ncvaAjN+YwjluUYrBuA/7yijG
	66PiKLFvdoLlYddqloyZrisYR4SSNTMCCN4FtuBpjacMKc7Tav8GV/Iw9Fineywg
	RVyG15MUzzDeK2Yp1qZcHe5txGe1ul3kULPq3aVvVGeID8rmKqb1SMwq7r17iDbE
	mH4G1L+eB6pbxujBGK9ltt6L+NRE/Rp0BdNBM+ZFI9UFZV3Gr8zqWV8L7B4E8Pj5
	vQlS/OyeVgxdTzvEjym46x+9821Veai4SNYLptG+ncpJ03bQCTEgL/GEAGsosShV
	V1fzvi2LdobxtHdI9IvprmYAiia0948=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 22 Sep 2026 19:52:42 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7E848607D6;
	Tue, 22 Sep 2026 19:52:44 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68MGqg5w049100;
	Tue, 22 Sep 2026 19:52:42 +0300
Date: Tue, 22 Sep 2026 19:52:42 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Joel Granados <joel.granados@kernel.org>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] ipvs: skip committing sync_threshold when proc_dointvec
 fails
In-Reply-To: <20260922-lklm-sysctl-retval-fix-v1-1-7290ea4253a4@kernel.org>
Message-ID: <2e6d674c-92d8-8178-3c34-475f7156946a@ssi.bg>
References: <20260922-lklm-sysctl-retval-fix-v1-1-7290ea4253a4@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 22 Sep 2026, Joel Granados wrote:

> Forward rc value and skip updating sysctl_sync_threshold when
> proc_dointvec fails. This targets a write such as "5 x" which would fail
> with -EINVAL but would store the first element anyway.
> 
> Signed-off-by: Joel Granados <joel.granados@kernel.org>

	Looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 4c1c739446b76ea455dab2958a844d05e31a46a7..7c260529238cd2015f1d30abd094d25b056b30fa 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2454,6 +2454,8 @@ proc_do_sync_threshold(const struct ctl_table *table, int write,
>  	mutex_lock(&ipvs->sync_mutex);
>  	memcpy(val, valp, sizeof(val));
>  	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
> +	if (rc)
> +		goto out;
>  	if (write) {
>  		if (val[0] < 0 || val[1] < 0 ||
>  		    (val[0] >= val[1] && val[1]))
> @@ -2461,6 +2463,7 @@ proc_do_sync_threshold(const struct ctl_table *table, int write,
>  		else
>  			memcpy(valp, val, sizeof(val));
>  	}
> +out:
>  	mutex_unlock(&ipvs->sync_mutex);
>  	return rc;
>  }
> 
> ---
> base-commit: 93f51579e7df248780214094418f205253383cc5
> change-id: 20260922-lklm-sysctl-retval-fix-abad29dc37bd
> 
> Best regards,
> -- 
> Joel Granados <joel.granados@kernel.org>

Regards

--
Julian Anastasov <ja@ssi.bg>

