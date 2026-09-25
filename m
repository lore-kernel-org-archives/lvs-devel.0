Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9CC7A260565;
	Fri, 25 Sep 2026 17:39:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790358004; cv=none; b=eLQm8Zw5v9vmXPk6Rbfns/GCYTA8gAs5+PrfOFoEavJfJBTEhpai++NFWgjEUJpDI5sGdJnxmEtumBSarSnR9dBv3zKbnyT0k9Bu2Sldn7bERx7UNyaltOwYrQy7OU9Z6gqyqCJnb8vHGo9qXZkKyCLWUuwq47cXbFjNo6YOgQc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790358004; c=relaxed/simple;
	bh=GhDNidlFHrThfGqQi/XDRyTyEtdTnq9aqdJdLqU1IYQ=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=kYktkF3A6sQmrapLC5gUDmF0xKhNmKVZdJkyS5RHN34PyC8pdVk52QnlmN1eFnboXoWA5HgfDqGz5RGRviQWqJe5bq9058fP0HR8Z4XYFf4VW5As3XBnW9MqEUWxt5K/hG7RFktx8HDrLVs92CnRvOpT3h2fpb+5fvUvI+o7Wp8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Uo2ZHcOm; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Uo2ZHcOm"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 74DBC213B9;
	Fri, 25 Sep 2026 20:39:47 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=+PcCajEBXplZ2eLt0w3DMNcOLfql4XBK2jgd0snxQgI=; b=Uo2ZHcOmVYG9
	No8tM77Cw+F9S1o+miTlbtE9xv4O8UiQrSD+tpvfl2CnSaQpqaDG9R4/8woRZNJv
	t4VkFIiPEuebvflhv6cp8xZ0Nrpo1xCuQms95wMpQx620R9GBwzMsuL5EA7WI5m3
	mXSdMNCm0Lnh5pTaETk6eRdCKpJ4v6vDTSMzX+SkcYEb/RVhTRwfq/JgvWXoaioL
	j/a01dxaXL3KuEVFIPKmDGS3qxBpfowHxN8+9S7BPKG6uLdribdurijuq5pA45UH
	1/X1sGHy0Yh3YNrl4jHOc5ReomeSnmMJt6V1MaQjv3F1xeLHaK4+dYxwoPpC2y70
	3l7UCbJAv18z9quFLQo0cjvpRJ4Sq9l44GQC50x+/SQHv5d/5jJrLClgAjYNARzN
	kXCJm+cQPqng0K6WgOAJSDGY92rv9dJJ+hvtNK2jJFv38VZGBI8tVzZmdIFDqzf0
	3Y0pwxvJJF0fCoADEb8Jdr0SxvSnA2bj3triM95lUPPDIv0J8aKUz2x5vzShjCzJ
	n+HFrjBVxOQtYFelIQZ4jegqQig8sda3JO9uUvIvEf9aJ4xalERj8x81Vx2+b10D
	5FzsLts/T1VNWd6xyE8DdGIneBfUtEWX9iUoeRPd5dHLBZLOmgAc6lCiVmeAhBz2
	uPG612SWz6l046nN49SjVz054v05z3c=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 25 Sep 2026 20:39:47 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6D20361C35;
	Fri, 25 Sep 2026 20:39:49 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68PHddaa062536;
	Fri, 25 Sep 2026 20:39:40 +0300
Date: Fri, 25 Sep 2026 20:39:39 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Axel Mierczuk <axel.mierczuk@1password.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        Willy Tarreau <w@1wt.eu>, Keith Hoodlet <keith.hoodlet@1password.com>
Subject: Re: [PATCH nf 0/2] ipvs: keep templates and cport 0 conns away from
 packet lookups
In-Reply-To: <20260925141115.16126-1-axel.mierczuk@1password.com>
Message-ID: <526c67cd-fe1b-0110-8bb4-5b51542bcd2a@ssi.bg>
References: <20260925141115.16126-1-axel.mierczuk@1password.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 25 Sep 2026, Axel Mierczuk wrote:

> A template received over the unauthenticated sync protocol with a
> nonzero cport is matched by data packets in ip_vs_conn_in_get() and
> the protocol state machine runs on it. Patch 1 rejects sync records
> with inconsistent cport and IP_VS_CONN_F_NO_CPORT combinations on
> the backup.
> 
> Patch 2 requires a nonzero cp->cport in ip_vs_conn_out_get() so that
> templates and connections still waiting for their cport cannot be
> matched through the out hook.
> 
> The companion patch "ipvs: filter some flags received in the backup
> server" rejects template records carrying IP_VS_CONN_F_NO_CPORT.
> 
> Axel Mierczuk (2):
>   ipvs: validate cport in received sync records
>   ipvs: skip cport 0 connections in ip_vs_conn_out_get()

	Both patches look good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> 
>  net/netfilter/ipvs/ip_vs_conn.c |  3 ++-
>  net/netfilter/ipvs/ip_vs_sync.c | 19 +++++++++++++++++++
>  2 files changed, 21 insertions(+), 1 deletion(-)
> 
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

