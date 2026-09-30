Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74D914D7D59;
	Wed, 30 Sep 2026 15:39:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790782760; cv=none; b=tn4YBWqmKp3HLjlP2v9eTi6h/XRIF0bK800NI+HD6tue8cZYlZ/lFpg6j83saShLGh5qE0YJ4nno4kaXfA5fqAjLbbOjbl5lC/tRtw5tfj0POdK5qe+Tjj4+dBfIO7B9Q4Lrts8sY0tVi5aB8ofk7vSs9y0reB9/Rs4D2riY+2k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790782760; c=relaxed/simple;
	bh=VcicJ3YX/UXJ4/si3fMKitkg0df0A/q4ji+gZn9CgGg=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=eJTLsoabL8XDe6sBIWmwY5LNo3JnYx1GGPPbSUFCDeinsuxszc+fZBYEgz52DvcAfqcQHxcxqOuhoPp7HWuK9aTdUnzpRF5lTbTYwk5UAm08wap134juXXB4ZdDNWVIJr/q60M/Q92XHNBeNDyEMiScS9tZf04qqgdUbnL++fl0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=1ifjt6Fr; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="1ifjt6Fr"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 7094322271;
	Wed, 30 Sep 2026 18:38:57 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=cNmTv4TtOPMC5q2qjvkw+1q58TUfw7qWbiEy3UveYaQ=; b=1ifjt6FrRwEv
	aX2GxxFU5iw7NFfCuDWrRsDTqFFtQOxOC6N+YZvx2HhmBsC4wY/rGZqUN3sGdKZ7
	PQKtqMH6+f9n3OW8Ji1a3YQT+0mWjQGDScV5dmjuRskV7NJUv7qqkzujX3wPjBT7
	nwZOp3JM4yDKdMVYBKL0bO0JRHhL9SuGDBPLCskCo0oZgx+Ob2bM/KDikajOVp7c
	U29BumzYQi03OE6f0M3IAbPJWzRq+tjbupT0G8ytqYrKwB8jO+bdjoznLm93Nddm
	gG1dn3eXXEaRTSt57HEwz48mWw7HSG+FHdByelOuXrTKlJI/n7gdQXHJF7qmd3Rg
	ApJGT2WWttW3QD/eZsdjBjvjdRu28l0+l6oiRpxyN8310hPRNPaHI4CXuIU71ZCP
	LxydnYLIM9ghX2YUoZ0ecC/LLvcj2VxxCHGh5Rdt7ILDf0Idd3+RgWAnAKW0dQhB
	lmhp+NyAqO4PFcjg97nZzcUeGaVZna3Pc44RI6O6QwyUFcnJLwT6Eq/fCfJ1jB+0
	G/RibZRT/MVjFZPFl86xv+hFMKVkgs876KpQhGbRjS6OJfhYy8RkuqGrQRjaSwy4
	PqDiumqIZH42iKZRlHaPjQkg3UEEhVFLasSfh5PjCqA7j7189kVcQ4qSMa5Mtep5
	oXc30sPOhBrO0dLLJoIZQMxY0iyeg1A=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 30 Sep 2026 18:38:57 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9542F60722;
	Wed, 30 Sep 2026 18:38:59 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68UFcoMG064203;
	Wed, 30 Sep 2026 18:38:51 +0300
Date: Wed, 30 Sep 2026 18:38:50 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: =?UTF-8?B?7ISx67OR7LCs?= <tjdqudcks0424@naver.com>
cc: horms@verge.net.au, pablo@netfilter.org, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        stable@vger.kernel.org
Subject: Re: [PATCH net] ipvs: prevent LBLCR destination leak after entry
 expiry
In-Reply-To: <20260929170747.503223-1-tjdqudcks0424@naver.com>
Message-ID: <3ed677db-8c85-a603-6c9e-3cf21535a488@ssi.bg>
References: <20260929170747.503223-1-tjdqudcks0424@naver.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-754341913-1790782732=:37112"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-754341913-1790782732=:37112
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Wed, 30 Sep 2026, tjdqudcks0424@naver.com wrote:

> From: 성병찬 <tjdqudcks0424@naver.com>
> 
> ip_vs_lblcr_schedule() looks up a cache entry under RCU before taking
> svc->sched_lock.  The expiry timer can remove that entry from the hash
> table and erase its destination set before the scheduler takes the lock.
> 
> RCU keeps the stale entry itself alive, so the scheduler can continue and
> insert a new destination-set element into it.  Since the entry is already
> unhashed and its set was already erased, no later path finds the new
> element.  Both the element and its destination reference are leaked when
> the parent entry is freed.
> 
> Recheck the address mapping while holding svc->sched_lock and update the
> set only when the hash table still maps the address to the entry obtained
> by the scheduler.
> 
> This was found during an AI-assisted source audit.  Diagnostic-only timing
> instrumentation forced expiry after lookup on a two-vCPU x86-64 QEMU
> guest.  The unmodified code inserted into the stale entry and left one
> element outstanding in each of three runs; kmemleak reported the related
> allocation in one run.  With this change, the same stale-entry condition
> was reached in three runs, but no stale insertion or outstanding element
> remained.
> 
> An unforced 679-second run processed 65,536 marked packets without hitting
> the race.  The result therefore confirms the lifetime leak and the effect
> of the fix under forced timing, but does not establish practical remote
> resource exhaustion.
> 
> Fixes: c5549571f975 ("ipvs: convert lblcr scheduler to rcu")
> Cc: stable@vger.kernel.org
> Signed-off-by: 성병찬 <tjdqudcks0424@naver.com>
> ---
>  net/netfilter/ipvs/ip_vs_lblcr.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index f53f05ceea36..ef18f3c9d5da 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -686,7 +686,8 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
>  
>  		/* Update our cache entry */
>  		spin_lock_bh(&svc->sched_lock);
> -		if (!tbl->dead)
> +		if (!tbl->dead &&
> +		    ip_vs_lblcr_get(svc->af, tbl, &iph->daddr) == en)

	ip_vs_dest_set_eraseall() does not update set->size, what if
we use atomic_set(&set->size, -1) there and to check it here to
avoid inserting dest into dying en? This should reduce the time
while we hold sched_lock.

		if (!tbl->dead && atomic_read(&en->set.size) >= 0)

>  			ip_vs_dest_set_insert(&en->set, dest, true);
>  		spin_unlock_bh(&svc->sched_lock);
>  		goto out;
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-754341913-1790782732=:37112--

