Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0AA6A265CA8;
	Mon, 21 Sep 2026 03:19:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789960769; cv=none; b=ewnAvnlMGHYWVjJJz4RDk9iIz7mO+0VOw5ePxfu27G9bfKMaM4dK2FgfYnxFLfngaE3AKonZjfxk8QEq8AS3Co9dZ+Tgzk0Kk9oETpiyJei5wP0N8nhZKMmWhcUYC5UJMpPiM1w/k+C8XD8xKZwJDT7cLfttlnI3m76t2f77l6I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789960769; c=relaxed/simple;
	bh=bqQaukvhg78Ca6HNMV5apQSeh0bro/hBfvXt4eFHCyQ=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=ggnFzMDW8yJVMKNxKLU2BrOJ4QhaQzDgRjpFPOhANe3HOBJGETpMgVJy1tkh00wMYEzSBYrWafpEkDx8mXKr8msH+jxTVai77osLG/h+8mzcQQ0t3RIRv1ntd5sUzU1PihyIoBgG2m98EThETwulzfeaqBxwoXACMVn+IWm/FpM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=InFS6M8f; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="InFS6M8f"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D5E0A1F000FF;
	Mon, 21 Sep 2026 03:19:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789960767;
	bh=2qeg5nnX+L5JOV2Dy1e+zPJIv2gvFRCgZzcKI163yME=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=InFS6M8fNERaJAosZxAnHojUSgolbH+DQpf5A6ETRVDvka+ytF0TrFgU+t340W7zj
	 IBXON4Q5p+S5SHTe4W4hT5hmSeW7VHV8nYbTnDN4+mRceUtjD9/s6Bx9+v+vco9nbC
	 lIN9YFOzQ8s2qrQWG3z+FkxONVWKxKVpIyD4QPlARqapZKkPadBAxB0m6OlSB0iPkr
	 afEaNDSxzFhOJ7H8kdGHqHuCDAOB00rQFJI3UWW0va2FriFhJFSK+ocoo1YgoSiCdH
	 DWPxlJPhhgxcGPIoAFqxEv1gu1VcsWdLscga7YQh9ye0/UhFr8s/eZWZe6Afe4+eRI
	 vlP32IYhZ0QiQ==
Subject: Re: [PATCH net v2 1/2] ipvs: avoid stack overflow from recursive
 connection expiration
From: netdev-bot+sashiko@kernel.org
To: zihanx@nebusec.ai
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
 pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
 linux-kernel@vger.kernel.org
Date: Mon, 21 Sep 2026 03:19:26 +0000
Message-ID: <178996076640.2160803.16028832049809238100@kernel.org>
In-Reply-To: <20260917030301.5502-1-zihanx@nebusec.ai>
References: <20260917030301.5502-1-zihanx@nebusec.ai>
X-sashiko-severity: High
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

Critical: 0 · High: 1 (1) · Medium: 0 · Low: 1

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [High] ipvs: use-after-free in ip_vs_conn_expire() due to timer re-
  arming race
- [Low] ip_vs_conn_del_put() (net/netfilter/ipvs/ip_vs_conn.c:1333-1346)
  keeps its old comment "Try to delete connection while holding…

Pre-existing issues:
- [High] ip_vs_conn_del_put() (net/netfilter/ipvs/ip_vs_conn.c:1336-1341)
  cancels the controller's timer, drops the caller's only reference on…

--

ipvs: avoid stack overflow from recursive connection expiration

This changes ip_vs_conn_del_put() to return whether it managed to delete
the controller's timer, and makes ip_vs_conn_expire() loop back with the
controller instead of recursing into itself.  The stated goal is to keep
chain cleanup synchronous while using a single stack frame.

v1 Link: https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/

> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 6fa3e1dc534c3..c7b88ce1765dc 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1331,17 +1331,18 @@ static void ip_vs_conn_del(struct ip_vs_conn *cp)
>  }
>  
>  /* Try to delete connection while holding reference */
> -static void ip_vs_conn_del_put(struct ip_vs_conn *cp)
> +static bool ip_vs_conn_del_put(struct ip_vs_conn *cp)
>  {
>  	if (timer_delete(&cp->timer)) {
>  		/* Drop cp->control chain too */
>  		if (cp->control)
>  			cp->timeout = 0;
>  		__ip_vs_conn_put(cp);
> -		ip_vs_conn_expire(&cp->timer);
> -	} else {
> -		__ip_vs_conn_put(cp);
> +		return true;
>  	}
> +
> +	__ip_vs_conn_put(cp);
> +	return false;
>  }

[Severity: Low]
This isn't a bug, but should the comment above ip_vs_conn_del_put() be
updated?  On the success path the helper no longer deletes or expires the
connection, it just cancels the timer, drops the caller's reference and
hands the expiration back to the caller.

The sibling helper still keeps a nearly identical comment while doing the
expiration itself:

	/* Try to delete connection while not holding reference */
	static void ip_vs_conn_del(struct ip_vs_conn *cp)
	{
		if (timer_delete(&cp->timer)) {
			...
			ip_vs_conn_expire(&cp->timer);
		}
	}

Could the new return value be documented, e.g. "returns true if the timer
was cancelled and the caller must continue expiring @cp"?  Otherwise a
future caller of ip_vs_conn_del_put() written against the current comment,
like the ip_vs_conn_del() users in ip_vs_random_dropentry() and
expire_nodest_conn_handler(), would cancel the timer and drop the reference
while leaving the conn hashed and never expired.

>  
>  static void ip_vs_conn_expire(struct timer_list *t)
> @@ -1349,6 +1350,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
>  	struct netns_ipvs *ipvs = cp->ipvs;
>  
> +repeat:
>  	/*
>  	 *	do I control anybody?
>  	 */
> @@ -1358,6 +1360,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  	/* Unlink conn if not referenced anymore */
>  	if (likely(ip_vs_conn_unlink(cp))) {
>  		struct ip_vs_conn *ct = cp->control;
> +		bool next = false;
>  
>  		/* delete the timer if it is activated by other users */
>  		timer_delete(&cp->timer);
> @@ -1372,7 +1375,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
>  			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
>  				IP_VS_DBG(4, "drop controlling connection\n");
> -				ip_vs_conn_del_put(ct);
> +				next = ip_vs_conn_del_put(ct);
>  			} else if (has_ref) {
>  				__ip_vs_conn_put(ct);
>  			}
> @@ -1402,6 +1405,10 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  		else
>  			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
>  		atomic_dec(&ipvs->conn_count);
> +		if (next) {
> +			cp = ct;
> +			goto repeat;
> +		}
>  		return;
>  	}

[Severity: High]
One more angle on the deferral window, from the packet path side.

After ip_vs_conn_del_put(ct) returns true we own ct only by
convention: its timer has been cancelled, our reference has already
been dropped by the __ip_vs_conn_put(ct) inside the helper, and ct is
still hashed and still findable by ip_vs_conn_in_get() /
ip_vs_conn_out_get().  Nothing in ct's state records that this context
intends to come back and expire it.

So while we finish tearing down cp -- ip_vs_conn_drop_conntrack(),
ip_vs_unbind_app(), ip_vs_unbind_dest(), call_rcu() and the
atomic_dec(&ipvs->conn_count) -- a packet arriving on another CPU can
look ct up, take a reference, and then release it through
ip_vs_conn_put(), which re-arms the timer unconditionally via
mod_timer(&cp->timer, jiffies + cp->timeout).  With ct->timeout forced
to 0 by ip_vs_conn_del_put() when ct has a controller of its own, that
timer is due immediately, so ip_vs_conn_expire() can run for ct on that
CPU, win the refcount_dec_if_one() in ip_vs_conn_unlink(), and hand ct
to call_rcu(&ct->rcu_head, ip_vs_conn_rcu_free).

When this context then does "cp = ct; goto repeat;", the first thing it
touches is atomic_read(&cp->n_control) on a connection that has already
been unlinked and queued for freeing -- and since the entries via
ip_vs_random_dropentry() and expire_nodest_conn_handler() reach
ip_vs_conn_expire() from process context, the deferral is preemptible
and the grace period can complete before we get there.  Before the
patch the recursive ip_vs_conn_expire(&ct->timer) call ran immediately
after the timer_delete(), so this window was a few instructions wide;
now it spans the entire teardown of cp.

The timer_delete() under the "delete the timer if it is activated by
other users" comment does not help here either: it only catches a
re-armed timer that has not fired yet, not a callback already running
or completed on another CPU.

How do you want to close this?  Keeping a reference on ct across the
deferral (i.e. not dropping it in ip_vs_conn_del_put() when the caller
asked to continue) or re-establishing ownership at the repeat label by
re-checking and re-deleting ct's timer both look plausible, but the
refcount bookkeeping differs quite a bit -- which one matches the
intended invariant?

[Severity: High]
This isn't a race introduced by this patch, the old code also dropped the
reference on ct before recursing, but does the deferral here widen the
window considerably?  Between ip_vs_conn_del_put(ct) returning true and
"cp = ct; goto repeat;", ct is still hashed, has no pending timer, and is
referenced by nobody, while the whole teardown of the previous conn runs in
between (ip_vs_conn_drop_conntrack(), ip_vs_unbind_app(),
ip_vs_unbind_dest(), call_rcu(), atomic_dec()).

Note that ip_vs_conn_del_put() forces ct->timeout = 0 when ct itself has a
controller:

		if (cp->control)
			cp->timeout = 0;

So a concurrent reference holder finishing with ct re-arms the timer to fire
on the next tick:

	static void __ip_vs_conn_put_timer(struct ip_vs_conn *cp)
	{
		unsigned long t = (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
			0 : cp->timeout;
		mod_timer(&cp->timer, jiffies+t);

		__ip_vs_conn_put(cp);
	}

Can that leave two contexts in ip_vs_conn_expire() for the same conn, with
only one winning refcount_dec_if_one() inside ip_vs_conn_unlink()?

CPU0 (deferring context)                CPU1 (packet path / timer)
  next = ip_vs_conn_del_put(ct)
    timer_delete(&ct->timer) ok
    ct->timeout = 0
    __ip_vs_conn_put(ct)   /* refcnt 1 */
  ... teardown of cp ...
                                        ip_vs_conn_put(ct)
                                          mod_timer(&ct->timer, jiffies+0)
                                        ip_vs_conn_expire(&ct->timer)
                                          ip_vs_conn_unlink(ct) -> true
                                          call_rcu(&ct->rcu_head, ...)
  cp = ct; goto repeat;
  ip_vs_conn_unlink(ct) -> false  /* HASHED already cleared */
  expire_later:
    refcount_inc(&ct->refcnt);   /* was zero */
    ct->timeout = 60*HZ;
    __ip_vs_conn_put_timer(ct);  /* mod_timer on freed-pending conn */

Does the refcount_inc() on a refcount that already reached zero trigger
refcount_warn_saturate, and does the subsequent mod_timer() touch a conn
already queued for kmem_cache_free() by ip_vs_conn_rcu_free()?

The "delete the timer if it is activated by other users" timer_delete()
after a successful unlink only covers a re-armed timer that has not fired
yet, not a callback already running on another CPU.  The comment in
ip_vs_conn_expire_now() ("Using mod_timer_pending will ensure the timer is
not modified after the final timer_delete in ip_vs_conn_expire") suggests
the code relies on a "timer not pending means I own this conn" invariant
that the plain mod_timer() in __ip_vs_conn_put_timer() does not honour.

For the process-context entries into this path, ip_vs_random_dropentry()
and expire_nodest_conn_handler() both reach ip_vs_conn_del() ->
ip_vs_conn_expire() with cp->timeout forced to 0 while traffic is flowing,
so the deferral is also preemptible.  Can the RCU grace period complete and
free ct before the repeat iteration reads ct->n_control?

Would it work to keep a reference on ct across the deferral, or to
re-establish ownership at the repeat entry by re-checking and re-deleting
the timer?

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/cover.1789435989.git.zihanx%40nebusec.ai
