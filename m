Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECE123A3816;
	Wed, 30 Sep 2026 07:44:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790754266; cv=none; b=o0mxStsfnLLF2JBagfiImgHlB5NC0tRgDrg9dkUSZ/hhhUSJHU8F73R53m327auIjaLj0zDrOvIo/9+sPwW3yN8GS4pNIPKjt+zfiH6uInlDfU83MlmLBvtEnFGitZUbVN0EtOJS2OgagtokRtkEjoF5JqYhJEhUpOI+N7eRB/M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790754266; c=relaxed/simple;
	bh=/weW6rnVijy8vSTemtwP1eLFyLUfnmqKLwbzit3/6oA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XN9rSGIkIGp3Y8lXIqIZXsda6bHTtp135dtyXIFVEd0GZz22XAlxng8zTtWpr+eR9GZ8kordjH59+ZgRiTti10XLQlP/2VVhKa4HwTbRYkZcHOvXkyKfHEjnu1DFiNfTPhO48xhtqZ/0S9y4Ms1E2U5ufVcnnnd2Cxin7AAMBMg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=YSnhgYPl; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="YSnhgYPl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1790754261;
	bh=Ge8bwGslcUKX3/2Xkn6n3BQLAuDJsMDCpJIOuOrcxt4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=YSnhgYPlFgDzPEadIKqNJ1Fs0uET8Yr4uUIP/+YV5jQKX7T3tL8LEswYe+DyMzAnr
	 ndFzhirkFtrOwh9dXSXMz6u4klK96e3wPVfNsbflHZo0GX1UklZol9m9nrjo6hiqD1
	 vWVZfp/ZpfBX8BcWbmqd07OeJG9xDVfs0oi2j0SGLLVNLdpi5LXkqAXbpZfF0ZH/mJ
	 bzUyWktZedoscAIZP/vVbc1zHiEPgnPEBzk2oMNCgGZWg/sWvqrOWIko0rVUQGjqXl
	 0E7JHt8RNuflOLqgQU6FsmkJxQlVKPPcwMXYrUKI10gF+DCpdbFDX6KXlr3y3jwjhu
	 PmpNi6VUGBZQA==
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id 3E8B1608AC;
	Wed, 30 Sep 2026 09:44:21 +0200 (CEST)
Date: Wed, 30 Sep 2026 09:44:18 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: tjdqudcks0424@naver.com
Cc: horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH net] ipvs: prevent LBLCR destination leak after entry
 expiry
Message-ID: <ary90qdwBnCVwv0p@chamomile>
References: <20260929170747.503223-1-tjdqudcks0424@naver.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260929170747.503223-1-tjdqudcks0424@naver.com>

Please, stop posting fixes for patches that already exist.

If you want to use a LLM to fix bugs that's great, but you have to
track what is going on the mailing list already.

Thank you.

On Wed, Sep 30, 2026 at 02:07:46AM +0900, tjdqudcks0424@naver.com wrote:
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
>  			ip_vs_dest_set_insert(&en->set, dest, true);
>  		spin_unlock_bh(&svc->sched_lock);
>  		goto out;
> -- 
> 2.43.0
> 
