Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2EC5239194;
	Wed,  4 Dec 2024 18:15:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1733336119; cv=none; b=I1u6dOf63owzQoNJ7OqP1AB5Tka2RClfZhkkWfTIEuVsoY+Mz1O8sURmzR+Q7GYCffog0kqTq7VNllyb+fO0wiIYoH4vQ2wLUQO8DokReeSUS4DhOrlcLvTRJnY7/oetZDW/vFzTkHPWvz+VmKBkC1FZuqGH6dHVemIGCQRVL/Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1733336119; c=relaxed/simple;
	bh=fCWYLBudtP48uVyMNZ6vbzB8lThADSa0FPsaUtyIHqs=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=AJQVgLxTAGYZEWWdbbd7qDVdOIgoqrU0yDbHqPpn8zhcIMfq1RVf1lZghpOnAm964GsJ2Qw+2NDzVijvVDxLy6mwB9Ak/NvigpNp13eQciQ4tRMG0Pd2RRYPuxYzHT7rwA3/KLsvH5J7AR40N0KSuyArWAqcGkX3F78gI71nN4Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=vWvBpKlv; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="vWvBpKlv"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D223F242D9;
	Wed,  4 Dec 2024 20:09:58 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=wMLfpq7o72dbt9EKB82m0Efw/bUExwZqJxraR2ONnR0=; b=vWvBpKlvt2JQ
	SGKLg+tpFUPShpFDOzUC5GPtfxSjXuP1oUlLhmmBY/HICOfqKRrd9y2vwQNEbxcm
	5NyCrx1sElYDE2oYBzcmprHriKJLvOoF5mlCLSP6Ied2apaEuSVFBl62965kRuR7
	ecvDYnW9TgFhgi73Bl70FR7+PuPt0fEzzlgbaaTTMuubm9U6zH8rS927uKBiXqZ2
	oDDuc5rNft93zhS80wF9dRS8/3OqgpCpAEDQ+MVEp/0ObRM5jQdx2ySKuxOaNsrM
	D8sEUj3IhtGESvdsiJ4OwAXMBVCKbha5OmHkStHFMY/k5gzA4U8yf9Pxr6dYNBtf
	iuJT8LujghYbiWLrnmSEMMDdn+ha3igzrqa3SAbv25UjTM9dwLUcB1cGck3sWgas
	R2b4kXpnS1EodijsQuZUdvGfiV2N4oY3RcacGndlTPPYZBe3oP/Y+0u8f+59Y8Yo
	9BWubVYHHcQVrHPI+wu/Pe1/FgsI02nCZ8taPZ8eJH+uIZQInBTU318zxRCOhISb
	lwvl5zJv8cOsETc2W+nP0r0YBpwFd3PweFxP0KaC34VrDFV/9mbov82nxCbZHbTI
	TiT55Y/LgLRnealHq/tNoCoKR3qyWMSTDeP+yKKVobFh6oj/5b+Y/PqI+VoKuwTU
	3zYwZSC99bjOr79HtCPATZMHNP3uifE=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed,  4 Dec 2024 20:09:57 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 7965416EED;
	Wed,  4 Dec 2024 20:09:57 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 4B4I9rxA065623;
	Wed, 4 Dec 2024 20:09:55 +0200
Date: Wed, 4 Dec 2024 20:09:53 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Florian Westphal <fw@strlen.de>
cc: netfilter-devel@vger.kernel.org, horms@verge.net.au,
        lvs-devel@vger.kernel.org
Subject: Re: [PATCH nf-next] ipvs: speed up reads from ip_vs_conn proc file
In-Reply-To: <20241203110840.10411-1-fw@strlen.de>
Message-ID: <4c02e290-d9be-19f1-013e-9829821ae115@ssi.bg>
References: <20241203110840.10411-1-fw@strlen.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 3 Dec 2024, Florian Westphal wrote:

> Reading is very slow because ->start() performs a linear re-scan of the
> entire hash table until it finds the successor to the last dumped
> element.  The current implementation uses 'pos' as the 'number of
> elements to skip, then does linear iteration until it has skipped
> 'pos' entries.
> 
> Store the last bucket and the number of elements to skip in that
> bucket instead, so we can resume from bucket b directly.
> 
> before this patch, its possible to read ~35k entries in one second, but
> each read() gets slower as the number of entries to skip grows:
> 
> time timeout 60 cat /proc/net/ip_vs_conn > /tmp/all; wc -l /tmp/all
> real    1m0.007s
> user    0m0.003s
> sys     0m59.956s
> 140386 /tmp/all
> 
> Only ~100k more got read in remaining the remaining 59s, and did not get
> nowhere near the 1m entries that are stored at the time.
> 
> after this patch, dump completes very quickly:
> time cat /proc/net/ip_vs_conn > /tmp/all; wc -l /tmp/all
> real    0m2.286s
> user    0m0.004s
> sys     0m2.281s
> 1000001 /tmp/all
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

	Nice improvement, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 50 ++++++++++++++++++---------------
>  1 file changed, 28 insertions(+), 22 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 7aba4760bbff..73f3dac159bb 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1046,28 +1046,35 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
>  #ifdef CONFIG_PROC_FS
>  struct ip_vs_iter_state {
>  	struct seq_net_private	p;
> -	struct hlist_head	*l;
> +	unsigned int		bucket;
> +	unsigned int		skip_elems;
>  };
>  
> -static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
> +static void *ip_vs_conn_array(struct ip_vs_iter_state *iter)
>  {
>  	int idx;
>  	struct ip_vs_conn *cp;
> -	struct ip_vs_iter_state *iter = seq->private;
>  
> -	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> +	for (idx = iter->bucket; idx < ip_vs_conn_tab_size; idx++) {
> +		unsigned int skip = 0;
> +
>  		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
>  			/* __ip_vs_conn_get() is not needed by
>  			 * ip_vs_conn_seq_show and ip_vs_conn_sync_seq_show
>  			 */
> -			if (pos-- == 0) {
> -				iter->l = &ip_vs_conn_tab[idx];
> +			if (skip >= iter->skip_elems) {
> +				iter->bucket = idx;
>  				return cp;
>  			}
> +
> +			++skip;
>  		}
> +
> +		iter->skip_elems = 0;
>  		cond_resched_rcu();
>  	}
>  
> +	iter->bucket = idx;
>  	return NULL;
>  }
>  
> @@ -1076,9 +1083,14 @@ static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
>  {
>  	struct ip_vs_iter_state *iter = seq->private;
>  
> -	iter->l = NULL;
>  	rcu_read_lock();
> -	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;
> +	if (*pos == 0) {
> +		iter->skip_elems = 0;
> +		iter->bucket = 0;
> +		return SEQ_START_TOKEN;
> +	}
> +
> +	return ip_vs_conn_array(iter);
>  }
>  
>  static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> @@ -1086,28 +1098,22 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  	struct ip_vs_conn *cp = v;
>  	struct ip_vs_iter_state *iter = seq->private;
>  	struct hlist_node *e;
> -	struct hlist_head *l = iter->l;
> -	int idx;
>  
>  	++*pos;
>  	if (v == SEQ_START_TOKEN)
> -		return ip_vs_conn_array(seq, 0);
> +		return ip_vs_conn_array(iter);
>  
>  	/* more on same hash chain? */
>  	e = rcu_dereference(hlist_next_rcu(&cp->c_list));
> -	if (e)
> +	if (e) {
> +		iter->skip_elems++;
>  		return hlist_entry(e, struct ip_vs_conn, c_list);
> -
> -	idx = l - ip_vs_conn_tab;
> -	while (++idx < ip_vs_conn_tab_size) {
> -		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
> -			iter->l = &ip_vs_conn_tab[idx];
> -			return cp;
> -		}
> -		cond_resched_rcu();
>  	}
> -	iter->l = NULL;
> -	return NULL;
> +
> +	iter->skip_elems = 0;
> +	iter->bucket++;
> +
> +	return ip_vs_conn_array(iter);
>  }
>  
>  static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
> -- 
> 2.45.2

Regards

--
Julian Anastasov <ja@ssi.bg>

