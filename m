Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FBEF281530;
	Sat, 19 Sep 2026 10:06:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789812411; cv=none; b=K3/qBDo4oXFByESqK1BDAdl3N8sRGbyCAc4pewZ+C67P6SEa+mmVOdmu4cUC5zq8eK69neQqhFmz5c7nRAz2KXgiLCcN8dNR/XN3vfns1WxKWVdUhcXS53a2YpboZ4J66qeagBBslKT62CkxSh5E5nhBTJJV4SpeU8hCp7yYDqs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789812411; c=relaxed/simple;
	bh=lz23xqOnfjK6hXIDMVyhpj3d8PiKZsDI4+InqbqJK3E=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=pQsAvRddowM9gmr83rch4dIcwdVlSsvS7vAy5lVX9iTWf1oVWg/4Fhv/HlNlIeB+FzBKmTyGjoU2Ng5tZSAlb2wRLub27tuo0eKhRAycB0NKOrK3VWoA6iz8h8+QZeJF7x+Y1tlzYGm310ugx7zUxF/WBuUraAcvytr27qmzLCw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=OVsL+GWk; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="OVsL+GWk"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 80645213A3;
	Sat, 19 Sep 2026 13:06:35 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=TI6KQVFy9rs3rUV5oFMqAw05s51sLh5J806913aCVYU=; b=OVsL+GWkG1zt
	2c3bKa4gnrSR77t6UHg5W5z4zzJdyNeIl91AJXuYrrviR0zylV5iI97RLYK7mW6d
	wEK5XN84V9vphAAo7Kml3v9FcfCeJSbILkIewxRScqVrrSqzhGHBYK9qfNYx9PV/
	pvxdW7tU67LSQW3spd7/M/awoGoa4EeNhopQm9RJCpGeGltlnARTBeX6Ei2PREmX
	xD4MdE5JmOrDDNLAlOEkleNtgSYbRLSdUIo2IEtofyapLS9YKtQ5APka6pxDt2ea
	R3n6nUYh2CaV8EluvBZsvNHIewqiHeJh6bwDVtts4bCudUvCkCGfXzizNdAedE/L
	dO0BfssvLa3zDtFtDEkhnd2oyqn7nNmfiEFwpTGk77EetOJInjXvu8sT9aBLcdX3
	5VSpPNs4NSRzbKjmh8HJ8VOU4aK/Pjzz/Wb3drLA9LUEuK6w5ETCXe58UWYH9Hoh
	VPc7LWLXg3SxIXM68x9il+jTtJE1MRM+hWydDhsk8rPuiNoEvPLrj+2HY612mnDn
	UWbwA88q3wfP9J5n+0SN0KdsnsikeWrESqvUGvQwJ9/1TdYiM5TUKVbM3VNbaAEo
	ZPSLfsbnsi+MmSwoMqVi78xHXH5X/KGfetLXcpg7cmvn+1tVVxaWCnQRVlh+I6/y
	0OZrdQSqnLxv+mLPuvnoMQ0hO+TGsoU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 19 Sep 2026 13:06:35 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 79F3D61E26;
	Sat, 19 Sep 2026 13:06:37 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68JA6NRO021632;
	Sat, 19 Sep 2026 13:06:24 +0300
Date: Sat, 19 Sep 2026 13:06:23 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zihan Xi <zihanx@nebusec.ai>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v2 1/2] ipvs: avoid stack overflow from recursive
 connection expiration
In-Reply-To: <c104a8ee-eebc-1e80-c685-3e22f23ffbc8@ssi.bg>
Message-ID: <1233faca-355c-b1b6-5c8d-9b36b4cc427a@ssi.bg>
References: <cover.1789435989.git.zihanx@nebusec.ai> <20260917030301.5502-1-zihanx@nebusec.ai> <c104a8ee-eebc-1e80-c685-3e22f23ffbc8@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 18 Sep 2026, Julian Anastasov wrote:

> On Thu, 17 Sep 2026, Zihan Xi wrote:
> 
> > When a controlled IPVS connection expires, its controller may be expired
> > synchronously if it has no remaining controlled connections. A chain of
> > controlled connections can then cause recursive calls to
> > ip_vs_conn_expire() and exhaust the kernel stack during namespace cleanup.
> > 
> > Make ip_vs_conn_del_put() report whether it deleted the controller timer.
> > When it succeeds, continue expiration with the controller instead of
> > calling ip_vs_conn_expire() recursively. This keeps chain cleanup
> > synchronous while using one stack frame for the whole chain.
> > 
> > Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
> > Cc: stable@vger.kernel.org
> > Reported-by: Vega <vega@nebusec.ai>
> > Assisted-by: LLM
> > Co-developed-by: Luxing Yin <root@tr0jan.top>
> > Signed-off-by: Luxing Yin <root@tr0jan.top>
> > Signed-off-by: Zihan Xi <zihanx@nebusec.ai>
> 
> 	Patch looks good to me for the nf tree, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

	In fact, Sashiko detects problem with connections
that are deleted and traffic that can restart the timer and
its callback deleteing the connection:

https://sashiko.dev/#/patchset/cover.1789435989.git.zihanx%40nebusec.ai

	Events are in this order:

CPU 1                   CPU 2
timer_delete,
refcnt is 1
                        find conn, get refcnt
                        mod_timer, put refcnt => 1

                        run timer callback
			and expire the conn,
			refcnt=0

touching cp->control is
safe under RCU,
but we mod_timer
with refcnt=0

	The problem is that the timer callback runs without
conn reference and not under RCU lock. OTOH, we delete the
connection only under RCU read lock and can take measures
if the callback removed the connection before us.

	Dropping conns only via timer callback is something we try
to avoid, we have to rethink this change.

pw-bot: changes-requested

> 	Next time use "nf"/"nf-next" tag for the IPVS patches.
> 
> > ---
> > changes in v2:
> >   - Use a repeat path for controller cleanup so expiration stays
> >     synchronous without recursive calls or extra timer ticks.
> >   - v1 Link:
> >     https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/
> > 
> >  net/netfilter/ipvs/ip_vs_conn.c | 17 ++++++++++++-----
> >  1 file changed, 12 insertions(+), 5 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index 6fa3e1dc534c3..c7b88ce1765dc 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -1331,17 +1331,18 @@ static void ip_vs_conn_del(struct ip_vs_conn *cp)
> >  }
> >  
> >  /* Try to delete connection while holding reference */
> > -static void ip_vs_conn_del_put(struct ip_vs_conn *cp)
> > +static bool ip_vs_conn_del_put(struct ip_vs_conn *cp)
> >  {
> >  	if (timer_delete(&cp->timer)) {
> >  		/* Drop cp->control chain too */
> >  		if (cp->control)
> >  			cp->timeout = 0;
> >  		__ip_vs_conn_put(cp);
> > -		ip_vs_conn_expire(&cp->timer);
> > -	} else {
> > -		__ip_vs_conn_put(cp);
> > +		return true;
> >  	}
> > +
> > +	__ip_vs_conn_put(cp);
> > +	return false;
> >  }
> >  
> >  static void ip_vs_conn_expire(struct timer_list *t)
> > @@ -1349,6 +1350,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
> >  	struct ip_vs_conn *cp = timer_container_of(cp, t, timer);
> >  	struct netns_ipvs *ipvs = cp->ipvs;
> >  
> > +repeat:
> >  	/*
> >  	 *	do I control anybody?
> >  	 */
> > @@ -1358,6 +1360,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
> >  	/* Unlink conn if not referenced anymore */
> >  	if (likely(ip_vs_conn_unlink(cp))) {
> >  		struct ip_vs_conn *ct = cp->control;
> > +		bool next = false;
> >  
> >  		/* delete the timer if it is activated by other users */
> >  		timer_delete(&cp->timer);
> > @@ -1372,7 +1375,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
> >  			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
> >  			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
> >  				IP_VS_DBG(4, "drop controlling connection\n");
> > -				ip_vs_conn_del_put(ct);
> > +				next = ip_vs_conn_del_put(ct);
> >  			} else if (has_ref) {
> >  				__ip_vs_conn_put(ct);
> >  			}
> > @@ -1402,6 +1405,10 @@ static void ip_vs_conn_expire(struct timer_list *t)
> >  		else
> >  			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
> >  		atomic_dec(&ipvs->conn_count);
> > +		if (next) {
> > +			cp = ct;
> > +			goto repeat;
> > +		}
> >  		return;
> >  	}
> >  
> > -- 
> > 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

