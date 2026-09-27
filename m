Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83C3939BFFA;
	Sun, 27 Sep 2026 10:21:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790504518; cv=none; b=nqC7dFmwKrk3ndOwHoOgCzq1iuIclbe5VmWiq3Bfaa/JDkDkR2ypJp5U1CcTdzrFCQ3IaxdvPKy+C4ppqD1gk7PhmuVwzyCPEEuJwL5qzszJDePq9PffRgS8dWjv5wMGY0snp2TDIaDvpBH4NZbdlVA475N+/kQxM7IUUYCSmXI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790504518; c=relaxed/simple;
	bh=ecJJrjF+eb/v318TWPHE0Fg3G8ajSdRhYmEMCS2RLEE=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=H56nM95RSFotZe1k/m+kRvsp9pQo7bl6w3702bRDKAFh9OpWNQ9QAAY7A6sUmhsfgbW3Rpp6t+eAtkoK+dYqVzzT25vhVS0Yw93AqE6dXpd+FaEWR/wQiQrv0PMXND5MvCSyZV72WaCmm+XgRItWsP34C8B93HSA2uSRgmMm43U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HAkO6c28; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HAkO6c28"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0BEE01F000FF;
	Sun, 27 Sep 2026 10:21:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790504517;
	bh=UA6Y9oe/SxYAD3bxQq1WzruuX/Xvec+oInjKyiJwXHs=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=HAkO6c28YOsxWMSYGUKffsJMQswoxkdAkVWd8uKYXw25PgMgDVUm8rNk0zASU44cM
	 rqqECyjD/nM7b1LEO4nGfdgqKsPyv9BZf2+aWd4xGEvvluH74rnriYfLTKu2zniVHf
	 to+SXfIgNEJOlbTmhlLfFd3QP9nmRlXeBbOqup8e1+RC5xtUC9XU0bw/BokYp/YmDn
	 AwVUIjKaB9+6j7VlHolBGkKoNyRJYD6eq1UxF1syZJxAI1JLjX6Q0hUaMcV9IfA3lc
	 3CZBRxcoyDHe7edftheRRn7kQZG6e+LaXMujpK2vZ0EvnDkctUTAEJY8+aDx3XtGBl
	 vMISvSNKwNecA==
Subject:
 Re: [PATCH nf v4 1/3] ipvs: wait the running timer cb on conn deletion
From: netdev-bot+sashiko@kernel.org
To: zihanx@nebusec.ai
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
 lvs-devel@vger.kernel.org, coreteam@netfilter.org,
 linux-kernel@vger.kernel.org, horms@verge.net.au, ja@ssi.bg,
 pablo@netfilter.org, fw@strlen.de, phil@nwl.cc, davem@davemloft.net,
 edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
 stable@vger.kernel.org, vega@nebusec.ai, root@tr0jan.top
Date: Sun, 27 Sep 2026 10:21:55 +0000
Message-ID: <179050451553.2160803.14284987040537808908@kernel.org>
In-Reply-To:
 <dfc9f33299baa890537aacdc3082c85e1a6eccc9.1790146910.git.zihanx@nebusec.ai>
References:
 <dfc9f33299baa890537aacdc3082c85e1a6eccc9.1790146910.git.zihanx@nebusec.ai>
X-sashiko-severity: High
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 5 potential
issue(s) to consider.

Critical: 0 · High: 1 · Medium: 2 · Low: 2

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [High] In ip_vs_conn_unlink() (net/netfilter/ipvs/ip_vs_conn.c), the
  new abort path tries to put the refcount back to 1 with…
- [Medium] In ip_vs_conn_unlink(), the new check of
  atomic_read(&cp->n_control) after the decrement has no acquire…
- [Medium] ip_vs_conn_unlink() now does refcount_dec_if_one() before its
  revalidation, and on the restore path the connection stays alive.
- [Low] Commit message accuracy.
- [Low] The comment in ip_vs_conn_expire_now() still refers to "the final
  timer_delete in ip_vs_conn_expire".

--

ipvs: wait the running timer cb on conn deletion

This patch changes ip_vs_conn_unlink() to drop the refcount from 1 to 0
first. It then rechecks n_control and timer_delete(), and if either check
fails it restores the refcount and returns false. ip_vs_conn_del() now
always calls ip_vs_conn_expire() with a tagged timer pointer to mark the
deletion path, and ip_vs_conn_del_put() is replaced by RCU protection for
the cp->control chain.

Link: https://sashiko.dev/#/patchset/cover.1789435989.git.zihanx%40nebusec.ai

> ipvs: wait the running timer cb on conn deletion

[Severity: Low]

This isn't a bug, but the subject says the deletion path waits for the
running timer callback. ip_vs_conn_unlink() doesn't wait, since there is no
timer_delete_sync(). It fails and leaves the work to a later timer run, as
the body describes. Would a word like "defer" describe this better?

> As ip_vs_conn_del*() run under RCU lock
> there is no risk accessing a freed connection by
> concurrent timer callback as Sashiko warns, may
> be only if our timer expires and we try to delete
> the cp->control chain.

This seems to contradict the sentence before it, which says the callback
risked accessing the deleted connection after it was freed. Could it be
reworded?

The body also doesn't say that ip_vs_conn_del() now calls
ip_vs_conn_expire() without first needing timer_delete() to succeed. Could
that be mentioned?

> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 6fa3e1dc534c3..32cfc02aa2912 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -313,17 +313,34 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  /* Try to unlink ip_vs_conn from conn_tab.
>   * returns bool success.
>   */
> -static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
> +static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp, bool my_cb)
>  {

[ ... ]

> +	if (!refcount_dec_if_one(&cp->refcnt))
> +		return false;
> +

[Severity: Medium]

The decrement now happens before the revalidation. That means a conn that
is still hashed, and may end up staying alive, briefly has refcnt == 0.
Can lookups miss it during that window?

__ip_vs_conn_in_get() and ip_vs_ct_in_get() skip entries where
__ip_vs_conn_get() fails:

	if (__ip_vs_conn_get(cp)) {
		/* HIT */

Take a template or FTP control conn whose timer fires while it is gaining
a controlled conn. The n_control check below restores the refcount and the
conn stays alive.

A packet arriving in that window could miss the template and create a
duplicate one, possibly for a different real server. A mid-stream packet
could also miss its FTP control conn.

Before this patch, a successful refcount_dec_if_one() always led straight
to the unlink under the bucket lock. A failed lookup could only affect a
conn that was really going away.

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
> +	if (atomic_read(&cp->n_control) ||
> +	    (!timer_delete(&cp->timer) && !my_cb)) {
> +		/* Not me? Give the timer callback another chance, even
> +		 * if one is concurrently running during the conn deletion.
> +		 */
> +		refcount_inc(&cp->refcnt);
> +		return false;
> +	}

[Severity: High]

Does this refcount_inc() actually bring refcnt back to 1?
refcount_dec_if_one() has already moved it from 1 to 0, and refcount_t
does not allow an increment from 0:

include/linux/refcount.h:__refcount_add() {
	int old = atomic_fetch_add_relaxed(i, &r->refs);
	...
	if (unlikely(!old))
		refcount_warn_saturate(r, REFCOUNT_ADD_UAF);
	...
}

This prints "refcount_t: addition on 0; use-after-free".
refcount_warn_saturate() then sets refcnt to REFCOUNT_SATURATED, not 1.

>From then on, refcount_dec_if_one() can never succeed for this conn, so
neither the timer path nor ip_vs_conn_del() can free it.

When the timer runs, the __ip_vs_conn_get() in expire_later succeeds on
the saturated value, and __ip_vs_conn_put_timer() re-arms the timer for
60*HZ. The conn never reaches call_rcu(), and ipvs->conn_count is never
decremented. The dest, conntrack and app references are never dropped
either.

Wouldn't ip_vs_conn_flush() then loop forever at netns teardown?

	if (atomic_read(&ipvs->conn_count) != 0) {
		schedule();
		goto flush_again;
	}

There seem to be two ways to get here. The first is the race this patch
is meant to fix:

CPU X                         CPU Y
cp->timer fires               ip_vs_conn_del(cp)
ip_vs_conn_expire(cp)           ip_vs_conn_expire()
                                  ip_vs_conn_unlink(cp, false)
                                    refcount_dec_if_one() 1 -> 0
                                    timer_delete() returns 0
                                    refcount_inc() on refcnt 0

CPU Y can be in ip_vs_conn_flush(), ip_vs_random_dropentry() or the
expire_nodest_conn flush.

The second is a template or FTP control conn ct:

- Its timer passes the early n_control == 0 check.
- Meanwhile another CPU runs ip_vs_ct_in_get()->ip_vs_control_add() and
  then ip_vs_conn_put(ct).
- The timer's refcount_dec_if_one() then succeeds, but n_control is now
  non-zero.
- refcount_inc() then runs on 0 again.

Both cases in the commit message ("One of two things can happen when we
detect the running callback") assume refcnt goes back to 1.

Was refcount_set(&cp->refcnt, 1) intended here? While refcnt is 0,
refcount_inc_not_zero() and refcount_dec_if_one() fail in every other
context.

[Severity: Medium]

Is the atomic_read(&cp->n_control) recheck ordered after
refcount_dec_if_one()? That function is only a release cmpxchg:

lib/refcount.c:refcount_dec_if_one() {
	...
	return atomic_try_cmpxchg_release(&r->refs, &val, 0);
}

A control dependency on its result orders later stores but not later
loads. Unlike refcount_dec_and_test(), there is no
smp_acquire__after_ctrl_dep() here.

Consider a template ct with refcnt 2:

CPU B                               CPU A (ct timer callback)
                                    ip_vs_conn_expire(ct)
                                      n_control == 0 check passes
ip_vs_control_add(cp2, ct)
  atomic_inc(&ct->n_control)
ip_vs_conn_put(ct)
  mod_timer()
  refcnt 2 -> 1 (release)
                                    ip_vs_conn_unlink(ct, true)
                                      refcount_dec_if_one() 1 -> 0
                                      atomic_read(&ct->n_control)
                                        may still observe 0

On arm64 or powerpc, can ct then be unlinked and passed to call_rcu()
while cp2->control still points at it? When cp2 later expires,
ip_vs_control_del(cp2) would read and decrement ct->n_control in freed
memory.

Is an smp_acquire__after_ctrl_dep() (or smp_rmb()) needed after a
successful refcount_dec_if_one() and before reading n_control?

[ ... ]

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

This isn't a bug, but a comment in ip_vs_conn_expire_now() still refers to
this call:

	/* Using mod_timer_pending will ensure the timer is not
	 * modified after the final timer_delete in ip_vs_conn_expire.
	 */

With this timer_delete() removed, the one that remains is the conditional
call in ip_vs_conn_unlink(). Could the comment be updated to point there?

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/cover.1790146910.git.zihanx%40nebusec.ai
