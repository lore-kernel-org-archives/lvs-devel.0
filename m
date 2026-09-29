Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AE343DAAA9;
	Tue, 29 Sep 2026 17:05:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790701523; cv=none; b=Ag1zrekAQNeEHmYgEFFvPIrqJQvYOUUJSCEteq34ZpnCQez5vIJXbquC7dZP9VgZgMVD2ljOFuHfdMC61H9yHVe7lSEYaKROsFp1pA4u9gM+ryD5mYBj+5q2y99JV+Izj9RO548/Zj3hBrGbI6Y+GPW6c5sdRBxiDgOsLKHpDLc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790701523; c=relaxed/simple;
	bh=V8zbmpTST+99uh1U81+MiMYyQUJaonnra9kDa93BysA=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=p4qBJvFULTwHivN3Su0e+ieR2v0gjW8nl+T73vmPlpf5Vv2oTPyXGsrk9NeabKUwKHjc4BYEquL+4IEi94bDGO7wiJp91S+hwb66j7lje8xMfIFbNeQuxpKio1ZmGBncZGeNPpv9WBpaR+cpN1da5PRQ9R4DmCr4FYmN3O1A8Ys=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iANNZ4QZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iANNZ4QZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E73481F000FF;
	Tue, 29 Sep 2026 17:05:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790701521;
	bh=m8ep1+iZNd0a3IKJC2WdXm9g+WF+/69hCkbLovv1KKE=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=iANNZ4QZocLAMsygEruE9j/oOSYIhulxwifD5rX/olXWXzfvsPzqQ00h5YxEnk556
	 JxOhfIyHtuLQViQ+3c9OBfZvDqkvHngFzrNt3kJs/XKD4ZDXIR2gDrxK7GpvBHiY2C
	 aO66oYtb5haTPDsQBU/n2rx4tGyt+ECfxOw3Hxxk9Bf6zhSUuoXoOjJ9Fu0gb/ovJv
	 w0iw3rnrmRxz236RXDrhY+RVyuiSS3udhdcsIcwFdCwUM2xEh5Du51gtWpGRpO5V45
	 Km4IQ7topKPm/vBtCaePq7XyJA1frJ9PMg7y7o13jVj7m8afSmYXxAOivbApAa5Ne5
	 0XIy1qCD14ewA==
Subject:
 Re: [PATCH nf v5 1/3] ipvs: wait the running timer cb on conn deletion
From: netdev-bot+sashiko@kernel.org
To: zihanx@nebusec.ai
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
 netfilter-devel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg,
 pablo@netfilter.org, fw@strlen.de, phil@nwl.cc, stable@vger.kernel.org,
 vega@nebusec.ai, root@tr0jan.top, kuba@kernel.org
Date: Tue, 29 Sep 2026 17:05:20 +0000
Message-ID: <179070152045.434549.3979737603463597210@kernel.org>
In-Reply-To:
 <77588fc74c9f2051fefa31be15e86ab6ce657ffd.1790266803.git.zihanx@nebusec.ai>
References:
 <77588fc74c9f2051fefa31be15e86ab6ce657ffd.1790266803.git.zihanx@nebusec.ai>
X-sashiko-severity: Medium
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 8 potential
issue(s) to consider.

Critical: 0 · High: 0 · Medium: 1 · Low: 7

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [Medium] The new check in ip_vs_conn_unlink() that the conn no longer
  controls others is not ordered after the refcount transition it…
- [Low] A comment in ip_vs_conn_expire_now() is now stale.
- [Low] Whether the caller is the timer callback is encoded in bit 0 of
  the struct timer_list pointer passed to ip_vs_conn_expire().
- [Low] The concern is that expire_later's `if (cp->timeout ||
  atomic_read(&cp->n_control)) cp->timeout = 60 * HZ;` can overwrite a…
- [Low] The new comment in ip_vs_conn_unlink() says the code revalidates
  that there is "no pending/running timer callback", and the…
- [Low] Regression in the race between a deleter and a running timer
  callback: a connection that has already timed out and is also being…
- [Low] ip_vs_conn_unlink() now drops refcnt to 0 with
  refcount_dec_if_one() before deciding whether the conn will really be…
- [Low] Because expire_later now keeps cp->timeout == 0, the sync master
  can send timeout 0 to the backup.

--

ipvs: wait the running timer cb on conn deletion

This patch changes ip_vs_conn_unlink() so it first drops refcnt from 1 to
0, then rechecks n_control and the timer state. If a timer callback may
still be running, it puts refcnt back to 1. ip_vs_conn_del() and
ip_vs_conn_del_put() are merged into one ip_vs_conn_del(). It tags bit 0
of the timer pointer so that ip_vs_conn_expire() knows it is not running
as the timer callback, and expire_later now tries to keep cp->timeout == 0
as a request to drop the control chain.

Link: https://sashiko.dev/#/patchset/cover.1789435989.git.zihanx%40nebusec.ai

> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 6fa3e1dc534c3..eac185496a8a6 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -313,17 +313,34 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)

[ ... ]

> +	if (!refcount_dec_if_one(&cp->refcnt))
> +		return false;
> +
>  	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
> -		return refcount_dec_if_one(&cp->refcnt);
> +		return true;
> +
> +	/* Revalidate after conn is excluded from traffic:
> +	 * - not controlling other conns
> +	 * - no pending/running timer callback
> +	 *
> +	 * And the winner is ...
> +	 */

[Severity: Low]
Is the "no pending/running timer callback" part of this comment accurate?
The new header comment on ip_vs_conn_expire() says the same thing.

The check only uses the return value of timer_delete(). The documentation
in kernel/time/timer.c says it:

 * ... does not take into account whether the timer's
 * callback function is concurrently executed on a different CPU or not.

For example, cp's callback is running on CPU A. A packet holder re-arms
the timer with __ip_vs_conn_put_timer() and drops its reference. A deleter
on CPU B then wins refcount_dec_if_one() and gets timer_delete() == 1
while A's callback is still running. B goes on to unlink the conn and
call call_rcu().

This does not look like a use-after-free. A's refcount_dec_if_one() and
__ip_vs_conn_get() both fail on refcnt 0, and A runs in softirq under RCU.
But the guarantee comes from refcount exclusion plus RCU, not from there
being no running callback.

Could the comments describe it that way instead?

> +	if (atomic_read(&cp->n_control) ||

[Severity: Medium]
Is this n_control read ordered after the refcount_dec_if_one() above?

refcount_dec_if_one() is atomic_try_cmpxchg_release(), so it only gives
release ordering. Nothing before this atomic_read() provides acquire
ordering or smp_acquire__after_ctrl_dep(), which refcount_dec_and_test()
does include.

Take a packet in ip_vs_sched_persist() that attaches a new conn to the
template ct and then drops its reference:

CPU1 (packet)
  ip_vs_control_add(newcp, ct)        /* ct->n_control 0 -> 1 */
  ip_vs_conn_put(ct)                  /* ct->refcnt 2 -> 1 */

CPU2 (ct timer callback or deleter)
  ip_vs_conn_unlink(ct, ...)
    refcount_dec_if_one(&ct->refcnt)  /* 1 -> 0, succeeds */
    atomic_read(&ct->n_control)       /* can this still read 0? */

On weakly ordered architectures such as arm64, or under LKMM, can CPU2
read the old value of 0 here? If it does, it goes on to timer_delete(),
unlinks ct and calls call_rcu() while newcp->control still points at ct.
The later ip_vs_control_del(newcp), or the atomic_read(&ct->n_control) in
ip_vs_conn_expire(), would then be a use-after-free.

A related point: the patch also removes this recheck under the bucket
lock:

-		if (use2 == ip_vs_conn_use_hash2(cp) &&
-		    refcount_dec_if_one(&cp->refcnt)) {

That recheck protected against ip_vs_conn_change_fwd_mask() adding or
removing hn1. Now use2 is read outside the bucket lock, and only refcnt
exclusion orders it. The base lock taken in timer_delete() probably orders
it on real hardware, but LKMM does not guarantee that.

Would adding smp_acquire__after_ctrl_dep() after a successful
refcount_dec_if_one(), or keeping the use2 recheck under the bucket lock,
close this?

> +	    (!timer_delete(&cp->timer) && !my_cb)) {
> +		/* Not me? Give the timer callback another chance, even
> +		 * if one is concurrently running during the conn deletion.
> +		 */
> +		refcount_set(&cp->refcnt, 1);
> +		return false;
> +	}

[Severity: Low]
With this order, refcnt drops to 0 before the code knows the conn is being
removed, and this path can bring it back with refcount_set(&cp->refcnt, 1).
Throughout that window the conn is still hashed with refcnt 0.

Lookups such as __ip_vs_conn_in_get() use __ip_vs_conn_get(), which is
refcount_inc_not_zero():

	if (__ip_vs_conn_get(cp)) {
		/* HIT */
		rcu_read_unlock();
		return cp;
	}

Can a concurrent lookup miss a live conn or template here and handle the
packet as a new flow? A new conn or template could then be inserted next
to the original, which gets restored and kept, leaving duplicate entries.

The window covers the n_control read and timer_delete(). The
ip_vs_conn_del() callers run in process context under rcu_read_lock(), so
with preemptible RCU they can be preempted inside it. Before the patch,
refcnt only reached 0 under the bucket lock, right before an unlink that
could not be undone.

[ ... ]

> @@ -1319,34 +1332,29 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)

[ ... ]

>  static void ip_vs_conn_del(struct ip_vs_conn *cp)
>  {

[ ... ]

> +	struct timer_list *t = (void *)((unsigned long)(&cp->timer) | 1UL);

[ ... ]

> +	/* Drop cp->control chain too */
> +	if (cp->control)
> +		cp->timeout = 0;
> +	ip_vs_conn_expire(t);
>  }
>  
> +/* Connection is removed in the following steps:
> + * - timer expires or connection is deleted
> + * - there should be no more references (n_control>0 and refcnt>1)
> + * - there should be no pending timer or a running timer callback (on deletion)
> + */
>  static void ip_vs_conn_expire(struct timer_list *t)
>  {
> -	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
> +	bool my_cb = !((unsigned long)t & 1);

[Severity: Low]
This isn't a bug, but whether the caller is the timer callback is now
stored in bit 0 of the timer_list pointer. Any caller that passes an
untagged pointer is treated as the callback.

ip_vs_conn_put() calls ip_vs_conn_expire() directly from packet context
with an untagged pointer:

	if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) &&
	    (refcount_read(&cp->refcnt) == 1) &&
	    !timer_pending(&cp->timer))
		/* expire connection immediately */
		ip_vs_conn_expire(&cp->timer);

So my_cb is true there even though no timer callback is running. This is
harmless today only because ip_vs_conn_unlink() returns true for
IP_VS_CONN_F_ONE_PACKET before it reads my_cb.

Would an explicit bool parameter, or a separate wrapper used as the timer
callback, make this dependency visible? Right now it rests on two
ONE_PACKET tests in different functions.

> +	struct timer_list *t2 = (void *)((unsigned long)t & ~1UL);
> +	struct ip_vs_conn *cp = timer_container_of(cp, t2, timer);
>  	struct netns_ipvs *ipvs = cp->ipvs;
>  
>  	/*
> @@ -1356,26 +1364,21 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  		goto expire_later;
>  
>  	/* Unlink conn if not referenced anymore */
> -	if (likely(ip_vs_conn_unlink(cp))) {
> +	if (likely(ip_vs_conn_unlink(cp, my_cb))) {
>  		struct ip_vs_conn *ct = cp->control;
>  
> -		/* delete the timer if it is activated by other users */
> -		timer_delete(&cp->timer);
> -

[Severity: Low]
With this timer_delete() removed, the comment in ip_vs_conn_expire_now()
looks stale:

	/* Using mod_timer_pending will ensure the timer is not
	 * modified after the final timer_delete in ip_vs_conn_expire.
	 */

The only timer_delete() left is in ip_vs_conn_unlink(). It runs only
after refcount_dec_if_one() succeeds, and only for conns that are not
ONE_PACKET and have n_control == 0. When it returns 0 for a caller that is
not the callback, the timer is re-armed, so it is not the final one.

The guarantee itself still seems to hold. Should the comment point at
ip_vs_conn_unlink() and describe the new conditions?

[ ... ]

> @@ -1410,13 +1413,15 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  		  refcount_read(&cp->refcnt),
>  		  atomic_read(&cp->n_control));
>  
> -	refcount_inc(&cp->refcnt);
> -	cp->timeout = 60*HZ;
> +	if (__ip_vs_conn_get(cp)) {
> +		if (cp->timeout || atomic_read(&cp->n_control))
> +			cp->timeout = 60 * HZ;

[Severity: Low]
Can a conn that has already timed out, and is also being deleted, survive
another 60 seconds here?

CPU A runs cp's timer callback (my_cb is true and the timer is no longer
pending). CPU B calls ip_vs_conn_del(cp) from ip_vs_random_dropentry() or
ip_vs_expire_nodest_conn_flush(). cp->control is NULL, so cp->timeout
stays non-zero:

CPU B
  ip_vs_conn_unlink(cp, false)
    refcount_dec_if_one()          /* 1 -> 0, wins */
CPU A
  ip_vs_conn_unlink(cp, true)
    refcount_dec_if_one()          /* fails */
  expire_later:
    __ip_vs_conn_get(cp)           /* fails on 0, does nothing */
CPU B
    timer_delete()                 /* returns 0, my_cb is false */
    refcount_set(&cp->refcnt, 1)
  expire_later:
    cp->timeout = 60 * HZ;
    __ip_vs_conn_put_timer(cp)     /* re-arms at jiffies + 60*HZ */

The commit message says "we will schedule new timer callback to expire the
connection after the running one finishes". Here, though, the expiry comes
60 seconds later, not right after. In the baseline, B's timer_delete()
failed and B did nothing, while A freed the conn.

One-shot callers such as ip_vs_random_dropentry() and the nodest flush do
not retry, so the conn stays hashed and bound to its dest until then.
ip_vs_conn_flush() recovers because it loops.

[Severity: Low]
This check still replaces a cp->timeout == 0 chain drop request with
60 * HZ whenever n_control != 0. The check-then-set also races with a
concurrent ip_vs_conn_del() writing 0. Is that intended?

It looks intentional. Leaving timeout at 0 with live children would make
__ip_vs_conn_put_timer() re-arm at jiffies + 0 and fire again every jiffy.
Also, every ip_vs_conn_del() caller checks n_control == 0 first.

The baseline set 60*HZ here unconditionally, so the race can only delay
the expiry. A short comment next to this check might still help.

> -	if (ipvs->sync_state & IP_VS_STATE_MASTER)
> -		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
> +		if (ipvs->sync_state & IP_VS_STATE_MASTER)
> +			ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));

[Severity: Low]
Since cp->timeout can now stay 0 on this path, can the sync master send a
timeout of 0 to the backup?

The path is:

- ip_vs_conn_del() on a conn with cp->control set writes
  cp->timeout = 0.
- ip_vs_conn_unlink() fails because a packet holds a reference.
- expire_later keeps 0 because n_control == 0, then calls
  ip_vs_sync_conn().

The v1 sync message then carries:

	s->v4.timeout = htonl(cp->timeout / HZ);

On the backup, ip_vs_proc_conn() treats 0 as unspecified:

	} else {
		...
		if (!(flags & IP_VS_CONN_F_TEMPLATE) && pd && pd->timeout_table)
			cp->timeout = pd->timeout_table[state];

For an established TCP conn that means 15 minutes. The baseline always
sent 60 seconds from this path.

Is this change in the replicated timeout intended?

> -	__ip_vs_conn_put_timer(cp);
> +		__ip_vs_conn_put_timer(cp);
> +	}
>  }

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/cover.1790266803.git.zihanx%40nebusec.ai
