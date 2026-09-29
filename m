Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 439943A9605;
	Tue, 29 Sep 2026 17:05:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790701524; cv=none; b=QnM3e+7+h2LS+jzgnA5JhT7vxfuseyZVakBOWISEaNPL/brKRI6kfgiUWl7Efxc9I5VK3n9tj6ohz1Th5DM7pg3nM5zGHJKFDqUY6bjyk3cGg7/WcxSMwe6eiGuVba5oRkjVDtPTR4g/c9vfgGhQD1HYGSw5rrTiBt6aGnaGWWc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790701524; c=relaxed/simple;
	bh=N07Jxlk+L9e4+DxxhN/+UFoeIKA+2UejX7yTF/2OiPo=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=TMpNQ4GrCgKhYvHoBv2zDpEaczZTSNzezccQgitisopaNgE+5bATR0T9b+3K/oNupXt2GHcvCmrHVoizZalqaiNPOlL+Uf4KzWPOqghTrWUQreX7H+Sl62EgqQK/pt+yYMKEbfZf6CxhIjMFb7rbnAVjI/iJZo021G08pe2s5fg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Zgm9q+/R; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Zgm9q+/R"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3E0621F00893;
	Tue, 29 Sep 2026 17:05:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790701522;
	bh=VATHSPgwjQ4mMVZ0ZXNXHY6h4kHMnko8p43w0BU+fNU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Zgm9q+/RxrLs4KTnkWfBY6w3OYubYMJR6qUeIq41H64EbT/vfzClvIG9Rxdf47H97
	 0HBYDZirgxNMx5TvH/m62RRVAyPmuJ3ye82YT3N/HQUOgyOS6dIDJHYk1rnk8MKyIw
	 ULhVTGcWEpn5g6Q4TXnW9DMmX+yvFnAr9Rn/CvhgXzTY9t/RmFdEE2ZmyeBQlnIMvz
	 NUHwuWCO0/6RZn8iFY6TQ4YVJNVYKOhTjl0mrWXxswzM62qOVDyJbs68TBUjhYo1et
	 ytl367KuXsZOx28c95Ge1H4j2Ta8u2QyOap0poHDwKJEDT8lt6DehG8P3tICPQ7KQv
	 iZW8wx82KQKvg==
Subject: Re: [PATCH nf v5 2/3] ipvs: avoid stack overflow from recursive
 connection expiration
From: netdev-bot+sashiko@kernel.org
To: zihanx@nebusec.ai
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg,
 pablo@netfilter.org, fw@strlen.de, phil@nwl.cc, stable@vger.kernel.org,
 vega@nebusec.ai, root@tr0jan.top, kuba@kernel.org
Date: Tue, 29 Sep 2026 17:05:21 +0000
Message-ID: <179070152180.434549.1203847882645586636@kernel.org>
In-Reply-To:
 <6fddc010376e9670c59d2c2319c88d3529f42a2a.1790266803.git.zihanx@nebusec.ai>
References:
 <6fddc010376e9670c59d2c2319c88d3529f42a2a.1790266803.git.zihanx@nebusec.ai>
X-sashiko-severity: Critical
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 2 potential
issue(s) to consider.

Critical: 1 · High: 0 · Medium: 0 · Low: 1

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [Critical] ip_vs_conn_expire()'s chain walk (`cp = ct; my_cb = false;
  goto repeat`) can free a ONE_PACKET controller immediately while its…
- [Low] This patch carries Cc: stable and Fixes: f9200a52eedf, but it
  depends on the preceding series commit "ipvs: wait the running timer…

--

ipvs: avoid stack overflow from recursive connection expiration

This commit replaces the recursive ip_vs_conn_del(ct) call in
ip_vs_conn_expire() with an iterative walk. After the current connection
is freed, the walk continues with its controller. The whole walk runs
under one rcu_read_lock(), and each following controller is handled in
deletion mode (my_cb = false).

> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index eac185496a8a6..ec5c0c8ecde74 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1357,6 +1357,9 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  	struct ip_vs_conn *cp = timer_container_of(cp, t2, timer);
>  	struct netns_ipvs *ipvs = cp->ipvs;
>  
> +	rcu_read_lock();
> +
> +repeat:
>  	/*
>  	 *	do I control anybody?
>  	 */
> @@ -1366,19 +1369,20 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  	/* Unlink conn if not referenced anymore */
>  	if (likely(ip_vs_conn_unlink(cp, my_cb))) {

[Severity: Low]
This patch has Cc: stable and Fixes: f9200a52eedf, but it depends on the
previous commit, "ipvs: wait the running timer cb on conn deletion". That
commit adds my_cb, the tagged timer pointer in ip_vs_conn_del(),
ip_vs_conn_unlink(cp, my_cb) and the guarded expire_later path.

The prerequisite has a Fixes: tag but no Cc: stable. This commit message
only calls it "the preceding refcount fix", without its subject or a
dependency note.

If stable picks up this patch alone, will it fail to apply or build?
Could a manual backport also lose the deletion-mode revalidation that this
walk relies on?

Would it make sense to add Cc: stable to the prerequisite and name it
here, for example with a "# depends on" note?

>  		struct ip_vs_conn *ct = cp->control;
> +		bool next = false;
>  
>  		/* does anybody control me? */
>  		if (ct) {
> -			rcu_read_lock();
>  			ip_vs_control_del(cp);
>  			/* Drop CTL or non-assured TPL if not used anymore */
>  			if (!cp->timeout && !atomic_read(&ct->n_control) &&
>  			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
>  			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
>  				IP_VS_DBG(4, "drop controlling connection\n");
> -				ip_vs_conn_del(ct);
> +				if (ct->control)
> +					ct->timeout = 0;
> +				next = true;
>  			}
> -			rcu_read_unlock();
>  		}
>  
>  		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
> @@ -1405,7 +1409,12 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  		else
>  			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
>  		atomic_dec(&ipvs->conn_count);
> -		return;
> +		if (next) {
> +			cp = ct;
> +			my_cb = false;
> +			goto repeat;

[Severity: Critical]
Can this walk free a ONE_PACKET controller while its timer is still
queued?

The commit message says the walk stays under RCU and that the preceding
refcount fix handles the timer callback race. Neither seems to cover
IP_VS_CONN_F_ONE_PACKET conns.

For those conns, ip_vs_conn_unlink() returns before the
timer_delete()/my_cb revalidation:

net/netfilter/ipvs/ip_vs_conn.c:ip_vs_conn_unlink() {
    if (!refcount_dec_if_one(&cp->refcnt))
        return false;

    if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
        return true;
    ...
}

ip_vs_conn_expire() then frees them without waiting for an RCU grace
period:

    if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
        ip_vs_conn_rcu_free(&cp->rcu_head);

A ONE_PACKET template with an ordinary child looks reachable:

- ONE_PACKET is part of IP_VS_CONN_F_DEST_MASK, so __ip_vs_update_dest()
  accepts it from userspace.
- ip_vs_bind_dest() only strips it for non-UDP conns, so UDP persistence
  templates keep it.
- ip_vs_sched_persist() reads dest->conn_flags separately for the
  template and for the child. A concurrent dest edit can leave a hashed
  ordinary child cp controlled by a ONE_PACKET template ct.

While cp exists, ct's expire_later path keeps re-arming ct->timer through
__ip_vs_conn_put_timer(). For ONE_PACKET conns that function uses a
timeout of 0.

Suppose cp is then deleted, for example by ip_vs_conn_flush() during
netns teardown:

ip_vs_conn_del(cp)
  ip_vs_conn_expire(cp, my_cb = false)
    ip_vs_control_del(cp)          /* ct->n_control drops to 0 */
    next = true                    /* new template is not ASSURED */
    cp = ct; my_cb = false; goto repeat
    ip_vs_conn_unlink(ct, false)   /* returns true, no timer_delete() */
    ip_vs_conn_rcu_free(ct)        /* ct freed, ct->timer still queued */

Would the timer base then touch the freed ct, and later call
ip_vs_conn_expire() on it?

There also seems to be a second variant. Suppose ct's own timer callback
on another CPU sees n_control == 0 first. It frees ct synchronously while
this walker still reads ct->n_control, ct->flags, ct->state and
ct->control. The walker then goes back to repeat with the freed ct.

Before "ipvs: wait the running timer cb on conn deletion", the old code
had two protections:

    bool has_ref = !cp->timeout && __ip_vs_conn_get(ct);
    ...
    ip_vs_conn_del_put(ct);

ct was pinned before ip_vs_control_del(), and ip_vs_conn_del_put() only
went ahead if timer_delete() on ct's timer succeeded. That commit removed
both, and this patch keeps that behaviour in the iterative walk. The
remaining patch in the series only touches ip_vs_ftp.c.

A related point: ip_vs_conn_flush() and ip_vs_expire_nodest_conn_flush()
read cp_c->n_control after ip_vs_conn_del(cp), and rely on RCU for that:

    /* Rely on RCU grace period while accessing cp after ip_vs_conn_del */

Could that read also hit freed memory when cp_c is a ONE_PACKET
controller that this walk freed synchronously?

> +		}
> +		goto out;
>  	}
>  
>    expire_later:

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/cover.1790266803.git.zihanx%40nebusec.ai
