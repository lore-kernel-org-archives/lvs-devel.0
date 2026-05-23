Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 548B72EBB8D;
	Sat, 23 May 2026 20:44:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779569070; cv=none; b=LE6OB7GSHBVgHxzNfD0tdkmiIr14doXT7OaybGP1EAKrs5ONB99NCm57htQpwLyk4LjhbtFQs4CmLUOLWK6dBsyFqBSCvcyv/Laaf2Mhk4rUNnGJ+jENqLHHHgOkO5LhXsodoVkLowJRBCII+dLi8kdP6UEyIv1KVfjX/RLYWbU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779569070; c=relaxed/simple;
	bh=zW+kan34DnvGHTOaRdhL3+KqewB3VL4yPpHrvUDieZY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=WVutgM+WhuwsjWb5yvaGNvZJZ0qV8l9r9961IUsRYo/eSijSxzEm3Hn54LY3X9lT0/m6eEB/Rqy0jKOg0260Zi9AErbwzl7u+fHUHVF5cuSz+TjuHRzGdcPvMw9JoDiDd1MmRPRHrp/sBD1fBI5eC9o2zUJWtbh4wv4PK9CkoQ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kufrN8mZ; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kufrN8mZ"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id A832920FBC;
	Sat, 23 May 2026 23:44:22 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=AsR2Se73bPR4yUGzlAFGke5IinGUOBqX5SEMz7qz3kQ=; b=kufrN8mZUqnW
	F/k5RiTuVC8DqQ6b/ABKctFpiiyxwyuhae27DhyZyQRzBCMoof5EnDbO/vO3FIQH
	M67pOre0AJQGvGr8amqrahMPnbj0E0622+d3Y9gwump1SIVdV/FPtnta/j3cnFbD
	n+dSP2B8xUxepvALrQYmef2iO6YtOHJ/sSBi8WkGbj0+zvGKS8BzXTK1a9Whzgdi
	gko7T1afBIEZVCOpvuP8x1sicepIve+vja498Ue1wilZavSfqD60uOtSf3U0kgRX
	Tkcf2XqBwTXbd45UpxlQEV92RxickJAx3uX1iDNUsPo+7RZFtO/pyTIKbCdhJoiZ
	fLYk6S/aP63mmHvK7E6GZNZhPmKWjqhZgp8F0VJHLFszmNm6KsaPtKlfzDG38Zgl
	u5NTRDNYfe4+VI7NV6aNOGGs6VSzEY7DdRVWOkJ0hIUR3E/u4WsVIyfOz19tPxyH
	VCR+fYxEWKg+sRGAOJ6NQjcASG+Pm4EddI0cgUD8SWbIi+11cU3VpGUthrhlNk2P
	Yf/MNWQjwj8d+IgnR6zdH1TpDMw+IVKNaX1KR7afyD4aNVACsET5W2dDe5SKjRzd
	HFWU80JFOC89+eF3YZSTZRTwIorb4KGMfoFuc7R1sXpHZDR8BEi/Ttup/QeZyQHA
	wjTmTfDmKI5CHcvKktYtJvf6B2aOhDk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 23 May 2026 23:44:22 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id CF31D60A45;
	Sat, 23 May 2026 23:44:21 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64NKiG3k105103;
	Sat, 23 May 2026 23:44:19 +0300
Date: Sat, 23 May 2026 23:44:16 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH v2 nf-next] ipvs: add conn_max sysctl to limit
 connections
In-Reply-To: <20260523172715.94795-1-ja@ssi.bg>
Message-ID: <37b05da0-e852-916d-f4b9-a276d0645383@ssi.bg>
References: <20260523172715.94795-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sat, 23 May 2026, Julian Anastasov wrote:

> Currently, we are using atomic_t to track the number of
> connections. On 64-bit setups with large memory there is
> a risk this counter to overflow. Also, setups with many
> containers may need to tune the limit for connections.
> 
> Add sysctl control to limit the number of connections to
> 1,073,741,824 (64-bit) and 16,777,216 (32-bit).
> Depending on the admin's privilege, the value is
> used to change a soft or hard limit allowing
> unprivileged admins to change the soft limit in
> range determined by privileged admins.
> 
> Link: https://sashiko.dev/#/patchset/20260430074420.26697-7-ja%40ssi.bg
> Link: https://sashiko.dev/#/patchset/20260522105546.13732-1-ja%40ssi.bg
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Forgot that writers should be serialized. Will send v3.

https://sashiko.dev/#/patchset/20260523172715.94795-1-ja%40ssi.bg

pw-bot: changes-requested

> +	if (write && !rc && val != unset) {
> +		struct netns_ipvs *ipvs = table->extra2;
> +		bool priv = capable(CAP_NET_ADMIN);
> +		/* Unprivileged admins can not go above the hard limit */
> +		int max = priv ? IP_VS_CONN_MAX : ipvs->conn_max_limit;
> +
> +		if (val < 0 || val > max) {
> +			rc = -EINVAL;
> +		} else {
> +			/* Privileged admin changes both limits */
> +			if (priv)
> +				ipvs->conn_max_limit = val;
> +			WRITE_ONCE(*valp, val);
> +		}

Regards

--
Julian Anastasov <ja@ssi.bg>

