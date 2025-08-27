Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47B892D5C6A;
	Wed, 27 Aug 2025 06:49:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756277348; cv=none; b=NdLWH0bc78HjZsC/7p18qVbOQPlX400snrOo9F4Hp5mjaPFpTGmnk+lArckYEDfIIY1FYdFYoBs0HAJAAJcAxhDsANXWCOKbFIVkVgBfmMWDhyFXWf9oZawVq2xMDeb3uBRCxZhF5avoNJWE7h0RsR0Dm+5yzPFXkMz77xAgIt8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756277348; c=relaxed/simple;
	bh=ZDJ9qya7W2eNFQ9JLr3trKiiPrcYJLqo4npzCihza3o=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=iSNCvdeeSt97ZnThhK9AnrKQWipeyfnWStqsaWkTlc4r3Vh5U8vAzAkekWqJGCfZOp+UEM/G9hVQWqzC57yI73HCwq3bo5+GbtLx1o0iKsF6SaSHu8xKkWyB37gpFVWVIJoj5p7XdQG+diVcip6andD28/s8njtDPe3ujOFD6pA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=hnVoE6lT; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="hnVoE6lT"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id EBF6023FF2;
	Wed, 27 Aug 2025 09:49:00 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=ldqgjxlwsXSiyb3bVgSob5ZK1Wuh4zfY+yYX7oVbV+I=; b=hnVoE6lT/itF
	ypIgxDMz1KxQY6yATn0lUAUY5wRDskTzoUUNwolytdYZ7Uh4YCSV8YDhErY2nrWn
	VprpQEJGgC+su5vC0RMH2yyCMQbFSvUZE2tu2FIZSgy8ccy12EjBWIKp5HbcC59V
	5UdBE3CvJcV8nnmMQGu9qhUA3qCHtgwihhhmd8Co5hGe9Xei7Gcv+mJOrUc48cIG
	wC/gWOSg1J5Twg7IKr9GJq7g0S10NVgTRVEyfNlDzLzDhUjB+85LLiG5lZCnfGac
	XQfg6xMJPMsdytC97J+x4dj5fgrEsS0rFs39752I01Y+pGL64uJ7z+P9sexyKtGd
	x6zUvMU7eXTpjEjHDQVsezjVH6j81o7KvGJu04cwLkB6dup6cjXZAuROtaEG/yTn
	wiP2qHI2hsC0jSEzgmybLE/O+WrQb0EB9iGJ8MaXnSlGoKoAqnWKZs6GUEBIyZlz
	GsMAShlOx8cpUQ7R10g/gjOued2EkKU9sRUvjnTtNGCz2nBpaTGVJLUN8ep6HTEs
	CKAJ6ZXLw437yRbMcX2yJZZebwy4EvHp+3kmiB+YlFsMDcnt5bIAHht19jH4Eqr4
	p6OMt0kG02UKyrNMI6yGcDrB3KqeMRNFaGEUr+rIC356UM9YSt3W3xsRbxMbh+XB
	ULtprqWBlT2GW15MygFtL+46QXm4qg4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 27 Aug 2025 09:48:59 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A899765A10;
	Wed, 27 Aug 2025 09:48:57 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 57R6mixv009832;
	Wed, 27 Aug 2025 09:48:45 +0300
Date: Wed, 27 Aug 2025 09:48:44 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zhang Tengfei <zhtfdev@gmail.com>
cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S . Miller" <davem@davemloft.net>,
        David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>,
        Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        coreteam@netfilter.org,
        syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Subject: Re: [PATCH] net/netfilter/ipvs: Fix data-race in ip_vs_add_service
 / ip_vs_out_hook
In-Reply-To: <20250826133104.212975-1-zhtfdev@gmail.com>
Message-ID: <2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg>
References: <20250826133104.212975-1-zhtfdev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 26 Aug 2025, Zhang Tengfei wrote:

> A data-race was detected by KCSAN between ip_vs_add_service() which
> acts as a writer, and ip_vs_out_hook() which acts as a reader. This
> can lead to unpredictable behavior and crashes. One observed symptom
> is the "no destination available" error when processing packets.
> 
> The race occurs on the `enable` flag within the `netns_ipvs`
> struct. This flag was being written in the configuration path without
> any protection, while concurrently being read in the packet processing
> path. This lack of synchronization means a reader on one CPU could see a
> partially initialized service, leading to incorrect behavior.
> 
> To fix this, convert the `enable` flag from a plain integer to an
> atomic_t. This ensures that all reads and writes to the flag are atomic.
> More importantly, using atomic_set() and atomic_read() provides the
> necessary memory barriers to guarantee that changes to other fields of
> the service are visible to the reader CPU before the service is marked
> as enabled.
> 
> Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
> Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>
> ---
>  include/net/ip_vs.h             |  2 +-
>  net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
>  net/netfilter/ipvs/ip_vs_core.c | 10 +++++-----
>  net/netfilter/ipvs/ip_vs_ctl.c  |  6 +++---
>  net/netfilter/ipvs/ip_vs_est.c  | 16 ++++++++--------
>  5 files changed, 19 insertions(+), 19 deletions(-)
> 

> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index 15049b826732..c5aa2660de92 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
...
> @@ -757,7 +757,7 @@ static void ip_vs_est_calc_phase(struct netns_ipvs *ipvs)
>  	mutex_lock(&ipvs->est_mutex);
>  	for (id = 1; id < ipvs->est_kt_count; id++) {
>  		/* netns clean up started, abort */
> -		if (!ipvs->enable)
> +		if (!atomic_read(&ipvs->enable))
>  			goto unlock2;

	It is a simple flag but as it is checked in loops
in a few places in ip_vs_est.c, lets use READ_ONCE/WRITE_ONCE as
suggested by Florian and Eric. The 3 checks in hooks in ip_vs_core.c
can be simply removed: in ip_vs_out_hook, ip_vs_in_hook and
ip_vs_forward_icmp. We can see enable=0 in rare cases which is
not fatal. It is a flying packet in two possible cases:

1. after hooks are registered but before the flag is set
2. after the hooks are unregistered on cleanup_net

Regards

--
Julian Anastasov <ja@ssi.bg>

