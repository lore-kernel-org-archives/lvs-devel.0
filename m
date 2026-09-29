Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF7B73D9670;
	Tue, 29 Sep 2026 17:47:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790704079; cv=none; b=UC4IPIOWs5ZfqyME0Irux4UF2erQJ6sOlHRWeBHl5owmIRh0tfGH6uIDgyDScoK4cgGRISe7O+0KwtXjn72VqKySG0F/Udu2Z0+JMIC3KRdi7an0sDGlL603b7WBW7QxeIW8CND7WFkIEk2hqtuglJJwzNbXwcZ1yBUw/YKVYKA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790704079; c=relaxed/simple;
	bh=ZvC9qdwXTWTOqOTiPeJScGaoSpJpcPyTlpVsE2dOXXo=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=hVV/iWp7seFy4JS+tVM7WdM+LCszlEL99E/+PCb0tjWY6q9ytls+5zOV7xkEH15fCPrReW9axNrSV84kPg6maeq4wHonXF3kCty8EoSqEPzwU32b1biGXb2LaqKQ2ZVcztR0ytpmzVWyEIpEBOfs9PJ3O1C6mD4o+ihAXGQCxLA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=SX8RL13S; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="SX8RL13S"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 12042213E5;
	Tue, 29 Sep 2026 20:47:49 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=nBfBhUVW7tf2p40fK0KiGZVej/m6dXBXVjeUMlOZDDk=; b=SX8RL13STzNU
	q3zjSOfI6B/v81yJ4NccximUZiORFI4eXuGiJ01R4rcVWdtriXIqyW/TeJ/cU7m9
	9BwaCJWeZKQIjXzGFiIpTA0ZAa5qaBU9e8YwVyV846t/zy/GVxMJThvSPsQBrhPV
	lJYGZ+35BD74nWw9HVYyUZWbVLsYL+fQ0wYb6kxH81Syqx59M1ASGnKbBBAbAtSD
	I9CwUJ9AsC0zBKxc+JIHBwfq0lTCkJb86kJVIe7LXywQEzzmpFSb+dpPADt2CnEU
	0G4FNbiin5d8OxHAxgdXy0+9JEzCsW1ISfkAgPp9I557ZadsObu+73l8JnANOL05
	1arpwtDGJUyjEnT3zIgnt7PPc556qViVnL8wlcSCbBNMitzxd6tOzaXJXxuyHsF7
	BMK9TPD7Z3Y8oqCq9YP+JLSX4MmbBbRRn+WeYA4EEOML8DVhjwxTFFm0slIwzPr1
	+Kc2WqPHsLMFGYGNYWiWtmUTsoo4oamS8LffzW6MlbKYpn3bcYz6YFvX0TR/IaP6
	nc4kpCin36XH5RcppjOV/1SgI7dMrqmGCHwAxN3oHdGb58+Q/op14rgZy3XGamHx
	S+BVZmHKr1/17DSG1FW4/nhhZL2zIzgg4zwRxrun4/AodVvCY/s2ocOXeuEeAcin
	K/E7m61rHMcbw4MCPW9VqYqnKaXf/3s=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 29 Sep 2026 20:47:48 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 368C660450;
	Tue, 29 Sep 2026 20:47:51 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68THljjd077059;
	Tue, 29 Sep 2026 20:47:45 +0300
Date: Tue, 29 Sep 2026 20:47:45 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: netdev-bot+sashiko@kernel.org
cc: axel.mierczuk@1password.com, horms@verge.net.au, pablo@netfilter.org,
        fw@strlen.de, phil@nwl.cc, netfilter-devel@vger.kernel.org,
        lvs-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, w@1wt.eu, keith.hoodlet@1password.com,
        stable@vger.kernel.org, kuba@kernel.org
Subject: Re: [PATCH nf 1/2] ipvs: validate cport in received sync records
In-Reply-To: <179069643951.434549.3382665015308925440@kernel.org>
Message-ID: <0c29566c-b595-7955-c32e-7937c9a1232a@ssi.bg>
References: <20260925141115.16126-2-axel.mierczuk@1password.com> <179069643951.434549.3382665015308925440@kernel.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-16744191-1790704069=:5433"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-16744191-1790704069=:5433
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Tue, 29 Sep 2026, netdev-bot+sashiko@kernel.org wrote:

> Thank you for your contribution! Sashiko AI review found 2 potential
> issue(s) to consider.
> 
> Critical: 0 · High: 0 · Medium: 1 · Low: 1
> 
> If you believe none of the issues are legitimate, please reply to each
> issue of Medium severity or higher and explain why the AI is wrong.
> If any of them are legitimate and you plan to respin, please let patchwork
> know by including "pw-bot: cr" as a separate line at the end of your reply
> (one such reply per series is enough).
> 
> - [Medium] The new check in ip_vs_proc_conn()
>   (net/netfilter/ipvs/ip_vs_sync.c) is incomplete for templates.
> - [Low] The new comment and rejection in ip_vs_proc_conn() say ordinary
>   connections must have NO_CPORT exactly when cport is 0, and records…

	The patch is fine. I'll reply to both concerns below.

> --
> 
> ipvs: validate cport in received sync records
> 
> This patch adds cport checks to ip_vs_proc_conn() for sync records
> received by the backup. Templates with a nonzero cport are dropped.
> Ordinary connections are dropped unless IP_VS_CONN_F_NO_CPORT is set
> exactly when cport is 0.
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > index 5383aeafb0aed..3998e9a0a391c 100644
> > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > @@ -848,6 +848,25 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
> >  	struct ip_vs_dest *dest;
> >  	struct ip_vs_conn *cp;
> >  
> > +	/* Templates require cport 0. Ordinary connections require
> > +	 * NO_CPORT exactly when cport is 0.
> > +	 */
> > +	if (flags & IP_VS_CONN_F_TEMPLATE) {
> > +		if (param->cport) {
> > +			IP_VS_DBG(2, "BACKUP, template with cport dropped\n");
> > +			kfree(param->pe_data);
> > +			return;
> > +		}
> 
> [Severity: Medium]
> Should the template branch also reject IP_VS_CONN_F_NO_CPORT?
> 
> A template with cport 0 and IP_VS_CONN_F_NO_CPORT set passes this check.
> The commit message leaves that case to "ipvs: filter some flags received
> in the backup server". That patch is not in this tree, and this one is
> tagged for stable.
> 
> In this tree, IP_VS_CONN_F_BACKUP_MASK still includes both NO_CPORT and
> TEMPLATE, so ip_vs_proc_sync_conn() lets the combination through. The v0
> parser applies no mask at all:
> 
> net/netfilter/ipvs/ip_vs_sync.c:ip_vs_process_message_v0() {
>     ...
> 		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
> 		flags &= ~IP_VS_CONN_F_HASHED;
>     ...
> }
> 
> A companion fix that only changes IP_VS_CONN_F_BACKUP_MASK would
> therefore not cover v0 records.
> 
> If ip_vs_ct_in_get() misses, ip_vs_conn_new() hashes the template and
> turns on the cport-zero fallback:
> 
> net/netfilter/ipvs/ip_vs_conn.c:ip_vs_conn_new() {
>     ...
> 	if (unlikely(flags & IP_VS_CONN_F_NO_CPORT)) {
> 		int af_id = ip_vs_af_index(cp->af);
> 
> 		atomic_inc(&ipvs->no_cport_conns[af_id]);
> 	}
>     ...
> }
> 
> A later packet from that client, from any source port, misses the first
> lookup. ip_vs_conn_in_get() then retries with cport 0. The match in
> __ip_vs_conn_in_get() has no IP_VS_CONN_F_TEMPLATE exclusion, so the
> retry returns the template:
> 
> 				    (!p->cport ^
> 				     (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
> 
> The datapath then treats the template as an ordinary connection:
> 
> ip_vs_in_hook()
>   ip_vs_conn_in_get()        /* returns the template */
>   ip_vs_set_state()
>   cp->packet_xmit()
>     ip_vs_conn_fill_cport()  /* NAT: rewrites cport, clears NO_CPORT */
> 
> After fill_cport rehashes the template, ip_vs_ct_in_get() no longer finds
> it, which breaks persistence for that client.
> 
> set_tcp_state() also changes dest->activeconns for the template, based
> only on IP_VS_CONN_F_INACTIVE. For templates, ip_vs_bind_dest() and
> ip_vs_unbind_dest() only adjust persistconns, so activeconns on the real
> server can drift.
> 
> Template state is validated now, so this does not seem to lead to
> out-of-bounds reads. Still, isn't this the same class of problem the
> commit message describes, a template reaching the protocol state machine
> through ip_vs_conn_in_get()?
> 
> Would adding "|| (flags & IP_VS_CONN_F_NO_CPORT)" to the template check
> make this patch self-contained and cover the v0 path as well?

	No, "ipvs: filter some flags received in the backup server"
should handle the above problems.

> 
> > +	} else if (!param->cport && !(flags & IP_VS_CONN_F_NO_CPORT)) {
> > +		IP_VS_DBG(2, "BACKUP, conn without cport dropped\n");
> > +		kfree(param->pe_data);
> > +		return;
> > +	} else if (param->cport && (flags & IP_VS_CONN_F_NO_CPORT)) {
> > +		IP_VS_DBG(2, "BACKUP, conn with cport and NO_CPORT dropped\n");
> > +		kfree(param->pe_data);
> > +		return;
> > +	}
> 
> [Severity: Low]
> Can the master itself briefly send a record with a nonzero cport and
> IP_VS_CONN_F_NO_CPORT still set?
> 
> ip_vs_conn_fill_cport() can use hn1 (use2, e.g. NAT/FTP data
> connections). In that case the dir 1 pass sets cport while the flag stays
> set. cp->lock is then released, and only the dir 0 pass clears the flag:
> 
> net/netfilter/ipvs/ip_vs_conn.c:ip_vs_conn_fill_cport() {
>     ...
> 	if (cp->flags & IP_VS_CONN_F_NO_CPORT && (!cp->cport || by_me)) {
> 		/* If we race with resizing make sure cport is set for dir 1 */
> 		if (!cp->cport) {
> 			cp->cport = cport;
> 			by_me = true;
> 		}
> 		if (!dir) {
> 			atomic_dec(&ipvs->no_cport_conns[af_id]);
> 			cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
> 		}
>     ...
> }
> 
> In that window, another CPU can handle a packet of the same connection
> and call ip_vs_sync_conn(). That function copies cp->flags and cp->cport
> without taking cp->lock:
> 
> net/netfilter/ipvs/ip_vs_sync.c:ip_vs_sync_conn() {
>     ...
> 	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);
> 	s->v4.state = htons(cp->state);
> 	s->v4.protocol = cp->protocol;
> 	s->v4.cport = cp->cport;
>     ...
> }
> 
> Before this patch, the backup matched such a record to its existing
> cport 0 NO_CPORT connection through the cport-zero fallback. It then
> updated that connection's INACTIVE/SEQ flags and seq options. Now the
> record is dropped.
> 
> The next sync record restores the state, so the effect looks small. Is
> the comment "NO_CPORT exactly when cport is 0" accurate, given what the
> master can send in this window?

	TCP conns before establishment are not synced by master,
so such race can not occur. And it is normal the backup to drop
inconsistent cport and NO_CPORT flag.

> Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-16744191-1790704069=:5433--

