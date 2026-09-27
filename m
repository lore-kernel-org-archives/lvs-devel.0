Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57ADC2F7ACE;
	Sun, 27 Sep 2026 14:48:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790520535; cv=none; b=TU/+fjt3vXq5db1AVHRl1KzCEDd0DOYqWyWZN4umRc/LzJbUVS9Amv/PEfHR0Vunz/Ul9NhC+doeNVn0BO8vKrjS9+KYez38nxp5rKi9iZVi43fBXYVao1Q5iw7qRlXb6LslfMxEZ4PsNM3OBZI2xs9JlxtbCdNZPmPuWIDmjO4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790520535; c=relaxed/simple;
	bh=ozbyqlC2DBJd72KTH8NRRMfdc4a/vuqU9rOajj5L3HQ=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=rhkQYkQs04TdGENNm8/ZzZOT5JVrOegHoY6tNyyCpwiNtnEQ8V6GmKLXaz4Lb00b7eLG/j/VlGu/7Vz1HNpe68qx1NL46w5h0jwl/lUKqLXZlUMJOBGy7amQ/SsBToKuYRgmYqMSTnLXUCw0SKHXQDfiu1PjxcMMPtN91NevqTk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=2Bwq5GGF; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="2Bwq5GGF"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E0F33213BE;
	Sun, 27 Sep 2026 17:48:47 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2WiLvXZu4GBQecSW6ui7N+bobF5nLW9Ftw3xpU/4h7E=; b=2Bwq5GGF++Hs
	C77lH6cDrHkl+I319JGt7+coJJ5bVkdmVSD06tDJDJA6coBRWImWbffpqugE+DMr
	NvfC48YMZ/MimZRBjVTV4UiZvwEx/HkqetrK+Ek+WnRvGOBfIcWF/q7Lfg7l0Xiv
	+i6vDbi9nM9u99A+g+UMNFLoxzLm9CWs8Pt5HQPqRCJD3gSnsv2nnxd4aT7JFg5A
	lbv6xBl10+jmbF02C7s54oN7K9oIhT5Jx8qyEQkN3n2JufATLnYMWIOcuCb+rwF+
	8NjRRbHrvphCFgm6yGHHEyZqYOp/4+03CN4e8T5cgp6uj8rIX6RCcA+MTpGt3xu6
	pjtiAJUgjM+54Mfd93GZMoFYMzsKmufHSbdXQxwH0mtJF61/kUv3TBQSR66d6EH5
	CWHNLTZD1qyUp8cxKPmNEa4O0mpkHDhLuSBvICImNMfqMn00cyVWnRSao3HSK3zg
	Bp+U98GLBygPqyWINCo0Nf14uIRteDwou089tQmkrpy5s1w5NcaD0GEgFWRpZ1uF
	y1JRGMYAaEF/YDGDochW+VPyXv48ybm2un167uYvOaom40NiDT9HMCp9FqWwPKX2
	ihomaKe/jIrZiHXhXPW0P5mi/ccXWGainzW9kO1RKvXojrrE3TYX85+dVObIqB5I
	6ma0+2jd2GqCEJ9bZIWeybDwtvdCRd4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 27 Sep 2026 17:48:47 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id E08BE605F3;
	Sun, 27 Sep 2026 17:48:49 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68REmj0E052077;
	Sun, 27 Sep 2026 17:48:46 +0300
Date: Sun, 27 Sep 2026 17:48:45 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: netdev-bot+sashiko@kernel.org
cc: zihanx@nebusec.ai, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, horms@verge.net.au, pablo@netfilter.org,
        fw@strlen.de, phil@nwl.cc, davem@davemloft.net, edumazet@google.com,
        kuba@kernel.org, pabeni@redhat.com, stable@vger.kernel.org,
        vega@nebusec.ai, root@tr0jan.top
Subject: Re: [PATCH nf v4 2/3] ipvs: avoid stack overflow from recursive
 connection expiration
In-Reply-To: <179050451719.2160803.1412992654069939250@kernel.org>
Message-ID: <090268f6-d0bb-95b8-679c-4f2b021e0a31@ssi.bg>
References: <8d33e2a83fa6f2fb6419b3f34cd3ff8677684a31.1790146910.git.zihanx@nebusec.ai> <179050451719.2160803.1412992654069939250@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-117216017-1790520528=:44912"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-117216017-1790520528=:44912
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sun, 27 Sep 2026, netdev-bot+sashiko@kernel.org wrote:

> Thank you for your contribution! Sashiko AI review found 3 potential
> issue(s) to consider.
> 
> Critical: 0 · High: 2 · Medium: 0 · Low: 1
> 
> If you believe none of the issues are legitimate, please reply to each
> issue of Medium severity or higher and explain why the AI is wrong.
> If any of them are legitimate and you plan to respin, please let patchwork
> know by including "pw-bot: cr" as a separate line at the end of your reply
> (one such reply per series is enough).
> 
> - [High] The failure path in ip_vs_conn_unlink() saturates the refcount
>   instead of restoring it.
> - [High] The controller walk in ip_vs_conn_expire() relies on RCU to keep
>   ct alive.
> - [Low] An undeclared stable dependency.
> 
> --
> 
> ipvs: avoid stack overflow from recursive connection expiration
> 
> This commit removes the recursive ip_vs_conn_del(ct) call in
> ip_vs_conn_expire(). Instead, once the current connection is cleaned up,
> the function carries on expiring its controller in a loop. The whole walk
> runs under one rcu_read_lock(), and every later iteration runs with my_cb
> set to false (deletion mode).
> 
> > This keeps controlled-connection cleanup synchronous while using one stack
> > frame for the whole chain. The timer callback race during connection
> > deletion is handled by the preceding refcount fix.
> >
> > Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
> > Cc: stable@vger.kernel.org
> 
> [Severity: Low]
> This patch is tagged for stable, but it only works on top of the
> preceding patch, "ipvs: wait the running timer cb on conn deletion".
> That patch adds:
> 
>   - ip_vs_conn_unlink(cp, my_cb)
>   - the tagged-pointer my_cb decoding in ip_vs_conn_expire()
>   - the new ip_vs_conn_del()
>   - the timer callback revalidation
> 
> The prerequisite has a Fixes: tag but no Cc: stable. This commit message
> only calls it "the preceding refcount fix".
> 
> Could the prerequisite also be tagged for stable, and named here by title
> or as a stable dependency?
> 
> If this loop were backported alone, or adapted onto the old
> ip_vs_conn_del()/ip_vs_conn_del_put() layout, ct would be expired
> synchronously with my_cb set to false. Nothing would then guard against
> ct's own timer callback running at the same time.
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index 32cfc02aa2912..f85752e79ed92 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -1357,6 +1357,9 @@ static void ip_vs_conn_expire(struct timer_list *t)
> >  	struct ip_vs_conn *cp = timer_container_of(cp, t2, timer);
> >  	struct netns_ipvs *ipvs = cp->ipvs;
> >  
> > +	rcu_read_lock();
> > +
> > +repeat:
> >  	/*
> >  	 *	do I control anybody?
> >  	 */
> > @@ -1366,19 +1369,20 @@ static void ip_vs_conn_expire(struct timer_list *t)
> >  	/* Unlink conn if not referenced anymore */
> >  	if (likely(ip_vs_conn_unlink(cp, my_cb))) {
> >  		struct ip_vs_conn *ct = cp->control;
> > +		bool next = false;
> >  
> >  		/* does anybody control me? */
> >  		if (ct) {
> > -			rcu_read_lock();
> >  			ip_vs_control_del(cp);
> >  			/* Drop CTL or non-assured TPL if not used anymore */
> >  			if (!cp->timeout && !atomic_read(&ct->n_control) &&
> >  			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
> >  			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
> >  				IP_VS_DBG(4, "drop controlling connection\n");
> > -				ip_vs_conn_del(ct);
> > +				if (ct->control)
> > +					ct->timeout = 0;
> > +				next = true;
> 
> [Severity: High]
> Is RCU enough to keep ct alive here when the controller has
> IP_VS_CONN_F_ONE_PACKET set?
> 
> After ip_vs_control_del() drops ct->n_control to zero, the walk keeps
> using ct without holding a reference. It touches n_control, flags, state
> and timeout, and later refcnt via ip_vs_conn_unlink(). A ONE_PACKET
> connection is freed right away, not after a grace period:
> 
> 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
> 		ip_vs_conn_rcu_free(&cp->rcu_head);
> 	else
> 		call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
> 
> Such a controller can be built. IP_VS_CONN_F_DEST_MASK includes
> IP_VS_CONN_F_ONE_PACKET, and the legacy sockopt path copies the flags
> unfiltered in ip_vs_copy_udest_compat():
> 
> 	udest->conn_flags	= udest_compat->conn_flags;
> 
> ip_vs_bind_dest() then passes dest->conn_flags on to UDP persistence
> templates.
> 
> Suppose a destination update clears the flag between the template's and
> the child's ip_vs_conn_new() calls in ip_vs_sched_persist(). An unhashed
> ONE_PACKET template then controls a hashed normal child. While n_control
> is above zero, the template's timer is re-armed every jiffy, because
> __ip_vs_conn_put_timer() uses a timeout of 0 for ONE_PACKET.
> 
> Now suppose the child is deleted through ip_vs_conn_del() by flush,
> drop_entry or nodest. cp->timeout is 0, so next is set and the walk calls
> ip_vs_conn_unlink(ct, false). For ONE_PACKET, that function returns true
> right after refcount_dec_if_one() and never calls timer_delete():
> 
> 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
> 		return true;
> 
> Would the walk then free ct at once, while ct->timer is still pending in
> the timer wheel?
> 
> There is also the other order. If ct's own timer callback on another CPU
> frees it first, wouldn't the walk read and write ct->n_control, flags,
> state, timeout and refcnt on freed memory?
> 
> Before the series, the code took a reference on ct (has_ref) and gated
> deletion on timer_delete() in ip_vs_conn_del_put(). The preceding patch,
> "ipvs: wait the running timer cb on conn deletion", replaced that with
> rcu_read_lock(). This patch keeps that approach and widens the window to
> cover the whole cp cleanup before goto repeat.

	With the pending patch "ipvs: do not create invisible templates"
we should disallow ONE_PACKET for templates. Other patches do the same
for the SYNC conns. In short, we should not see ONE_PACKET for
templates and in the cp->control chain. Hopefully, the mentioned patches 
should go before this patchset.

> >  			}
> > -			rcu_read_unlock();
> >  		}
> >  
> >  		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
> > @@ -1405,7 +1409,12 @@ static void ip_vs_conn_expire(struct timer_list *t)
> >  		else
> >  			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
> >  		atomic_dec(&ipvs->conn_count);
> > -		return;
> > +		if (next) {
> > +			cp = ct;
> > +			my_cb = false;
> > +			goto repeat;
> > +		}
> 
> [Severity: High]
> With my_cb now false, every controller in the chain goes through
> ip_vs_conn_unlink(ct, false). Can the failure path there leave ct with a
> saturated refcount?
> 
> ip_vs_conn_unlink() drops the count to zero before it revalidates:
> 
> net/netfilter/ipvs/ip_vs_conn.c:ip_vs_conn_unlink() {
> 	if (!refcount_dec_if_one(&cp->refcnt))
> 		return false;
> 	...
> 	if (atomic_read(&cp->n_control) ||
> 	    (!timer_delete(&cp->timer) && !my_cb)) {
> 		...
> 		refcount_inc(&cp->refcnt);
> 		return false;
> 	}
> 	...
> }
> 
> Calling refcount_inc() on zero goes through __refcount_add(). That sees
> old == 0 and calls refcount_warn_saturate(r, REFCOUNT_ADD_UAF), which
> warns "addition on 0; use-after-free". The counter is left at
> REFCOUNT_SATURATED instead of going back to 1.
> 
> The new loop seems to reach this in two ways:
> 
>   - ct's own timer callback is already running on another CPU, so
>     timer_delete() returns 0 while my_cb is false.
> 
>   - A packet takes ct with __ip_vs_conn_get(), then calls
>     ip_vs_control_add() and ip_vs_conn_put(), between the n_control
>     check at repeat: and refcount_dec_if_one(). This can also happen on
>     the plain timer path of a persistence template while a new client
>     connection arrives.
> 
> Once the counter is saturated, refcount_dec_if_one() can never succeed,
> but __ip_vs_conn_get() still does. The connection keeps going through
> expire_later and getting re-armed, and it is never freed.
> 
> Wouldn't ip_vs_conn_flush() then loop forever during netns cleanup?
> 
> net/netfilter/ipvs/ip_vs_conn.c:ip_vs_conn_flush() {
> 	...
> 	if (atomic_read(&ipvs->conn_count) != 0) {
> 		schedule();
> 		goto flush_again;
> 	}
> 	...
> }
> 
> This restore path came from the preceding patch in the series, "ipvs:
> wait the running timer cb on conn deletion", and this commit message
> relies on it. The later patch, "ipvs: reject FTP control ports as data
> ports", doesn't touch ip_vs_conn.c.
> 
> Every lookup uses refcount_inc_not_zero(). Would refcount_set(&cp->refcnt,
> 1) be a safe way to restore the count here?

	This is solved in patch 1 from v5

> > +		goto out;
> >  	}
> >  
> >    expire_later:
> 
> [ ... ]
> 
> -- 
> Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/cover.1790146910.git.zihanx%40nebusec.ai
> 

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-117216017-1790520528=:44912--

