Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 071983D3008;
	Tue, 29 Sep 2026 15:40:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790696442; cv=none; b=RtOq2s4JhTaqEmP+NvNPvVHgfn3JNy6PJ5KIMJkP5SNh72xLRMXsLTkWInVR9cSMR/jYxdJ/iGkUPP7lAh0J8x3njS44YNbJlSyZlR7AcpK62LkbmatoeJwAoCSroEwbNlhSi0+Euq+1y1tIskYamU7EEGYrFIsZaHO1E4/Nqbo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790696442; c=relaxed/simple;
	bh=8oZvkVUf2V+gk2Uu/lUv/NwDSxjvHbsrGmM/+th4F/w=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=feakBgyJK95IvaxNQhDXjVxQW9AIHkYMBmqlcfJJEpeHEHV+Gld3QTvLfvn2L44JYBPd2Hgfz0T8U4hM1yo5y92OfUaEdES1w5593rCUJnT6p+XvJIRRYPftUINrEZnAoq0YwL1cTXbIAFBItBS1ftWm506bFinF5ytM4XhRNtU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Jppbl6Qo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Jppbl6Qo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ECC9C1F000FF;
	Tue, 29 Sep 2026 15:40:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790696440;
	bh=TI/xXToTOEBcYAWcn46fJFhNOb2NaUUrbJWEAnd5OGM=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Jppbl6QoqsktVwqpBgVbumU0mwxDPjdX2+1/8E/f48rhbIz9ZgUI2pAc/+68lSrzm
	 xp/naV5gZ6OUZ7tkq1e48NPB4bsibo5F56Ndtliik/jLh0AFrSVOxWDYUBlbi60Gij
	 Xdc4dwKeAL6Bn99/WnEQ6iwCnlmIsuBruNBDiQjuVIbuo0oWCNPUtYJWoLO6y4oSes
	 FGM24INBe4WF4TDr4kTtw7e+ya3fUxPux9FS0jpECvcURkgSzqloyaPYIdhG2UEwcg
	 WrSP5KtjWRWgXGLP54opdEpwDGV3/n77+kT4ERipgJMSKbQrnEJivpHbyyvdBDFtkr
	 kApwTaeo/36tw==
Subject: Re: [PATCH nf 1/2] ipvs: validate cport in received sync records
From: netdev-bot+sashiko@kernel.org
To: axel.mierczuk@1password.com
Cc: ja@ssi.bg, horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
 coreteam@netfilter.org, netdev@vger.kernel.org, w@1wt.eu,
 keith.hoodlet@1password.com, stable@vger.kernel.org, kuba@kernel.org
Date: Tue, 29 Sep 2026 15:40:39 +0000
Message-ID: <179069643951.434549.3382665015308925440@kernel.org>
In-Reply-To: <20260925141115.16126-2-axel.mierczuk@1password.com>
References: <20260925141115.16126-2-axel.mierczuk@1password.com>
X-sashiko-severity: Medium
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

Critical: 0 · High: 0 · Medium: 1 · Low: 1

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [Medium] The new check in ip_vs_proc_conn()
  (net/netfilter/ipvs/ip_vs_sync.c) is incomplete for templates.
- [Low] The new comment and rejection in ip_vs_proc_conn() say ordinary
  connections must have NO_CPORT exactly when cport is 0, and records…

--

ipvs: validate cport in received sync records

This patch adds cport checks to ip_vs_proc_conn() for sync records
received by the backup. Templates with a nonzero cport are dropped.
Ordinary connections are dropped unless IP_VS_CONN_F_NO_CPORT is set
exactly when cport is 0.

> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 5383aeafb0aed..3998e9a0a391c 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -848,6 +848,25 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
>  	struct ip_vs_dest *dest;
>  	struct ip_vs_conn *cp;
>  
> +	/* Templates require cport 0. Ordinary connections require
> +	 * NO_CPORT exactly when cport is 0.
> +	 */
> +	if (flags & IP_VS_CONN_F_TEMPLATE) {
> +		if (param->cport) {
> +			IP_VS_DBG(2, "BACKUP, template with cport dropped\n");
> +			kfree(param->pe_data);
> +			return;
> +		}

[Severity: Medium]
Should the template branch also reject IP_VS_CONN_F_NO_CPORT?

A template with cport 0 and IP_VS_CONN_F_NO_CPORT set passes this check.
The commit message leaves that case to "ipvs: filter some flags received
in the backup server". That patch is not in this tree, and this one is
tagged for stable.

In this tree, IP_VS_CONN_F_BACKUP_MASK still includes both NO_CPORT and
TEMPLATE, so ip_vs_proc_sync_conn() lets the combination through. The v0
parser applies no mask at all:

net/netfilter/ipvs/ip_vs_sync.c:ip_vs_process_message_v0() {
    ...
		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
		flags &= ~IP_VS_CONN_F_HASHED;
    ...
}

A companion fix that only changes IP_VS_CONN_F_BACKUP_MASK would
therefore not cover v0 records.

If ip_vs_ct_in_get() misses, ip_vs_conn_new() hashes the template and
turns on the cport-zero fallback:

net/netfilter/ipvs/ip_vs_conn.c:ip_vs_conn_new() {
    ...
	if (unlikely(flags & IP_VS_CONN_F_NO_CPORT)) {
		int af_id = ip_vs_af_index(cp->af);

		atomic_inc(&ipvs->no_cport_conns[af_id]);
	}
    ...
}

A later packet from that client, from any source port, misses the first
lookup. ip_vs_conn_in_get() then retries with cport 0. The match in
__ip_vs_conn_in_get() has no IP_VS_CONN_F_TEMPLATE exclusion, so the
retry returns the template:

				    (!p->cport ^
				     (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&

The datapath then treats the template as an ordinary connection:

ip_vs_in_hook()
  ip_vs_conn_in_get()        /* returns the template */
  ip_vs_set_state()
  cp->packet_xmit()
    ip_vs_conn_fill_cport()  /* NAT: rewrites cport, clears NO_CPORT */

After fill_cport rehashes the template, ip_vs_ct_in_get() no longer finds
it, which breaks persistence for that client.

set_tcp_state() also changes dest->activeconns for the template, based
only on IP_VS_CONN_F_INACTIVE. For templates, ip_vs_bind_dest() and
ip_vs_unbind_dest() only adjust persistconns, so activeconns on the real
server can drift.

Template state is validated now, so this does not seem to lead to
out-of-bounds reads. Still, isn't this the same class of problem the
commit message describes, a template reaching the protocol state machine
through ip_vs_conn_in_get()?

Would adding "|| (flags & IP_VS_CONN_F_NO_CPORT)" to the template check
make this patch self-contained and cover the v0 path as well?

> +	} else if (!param->cport && !(flags & IP_VS_CONN_F_NO_CPORT)) {
> +		IP_VS_DBG(2, "BACKUP, conn without cport dropped\n");
> +		kfree(param->pe_data);
> +		return;
> +	} else if (param->cport && (flags & IP_VS_CONN_F_NO_CPORT)) {
> +		IP_VS_DBG(2, "BACKUP, conn with cport and NO_CPORT dropped\n");
> +		kfree(param->pe_data);
> +		return;
> +	}

[Severity: Low]
Can the master itself briefly send a record with a nonzero cport and
IP_VS_CONN_F_NO_CPORT still set?

ip_vs_conn_fill_cport() can use hn1 (use2, e.g. NAT/FTP data
connections). In that case the dir 1 pass sets cport while the flag stays
set. cp->lock is then released, and only the dir 0 pass clears the flag:

net/netfilter/ipvs/ip_vs_conn.c:ip_vs_conn_fill_cport() {
    ...
	if (cp->flags & IP_VS_CONN_F_NO_CPORT && (!cp->cport || by_me)) {
		/* If we race with resizing make sure cport is set for dir 1 */
		if (!cp->cport) {
			cp->cport = cport;
			by_me = true;
		}
		if (!dir) {
			atomic_dec(&ipvs->no_cport_conns[af_id]);
			cp->flags &= ~IP_VS_CONN_F_NO_CPORT;
		}
    ...
}

In that window, another CPU can handle a packet of the same connection
and call ip_vs_sync_conn(). That function copies cp->flags and cp->cport
without taking cp->lock:

net/netfilter/ipvs/ip_vs_sync.c:ip_vs_sync_conn() {
    ...
	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);
	s->v4.state = htons(cp->state);
	s->v4.protocol = cp->protocol;
	s->v4.cport = cp->cport;
    ...
}

Before this patch, the backup matched such a record to its existing
cport 0 NO_CPORT connection through the cport-zero fallback. It then
updated that connection's INACTIVE/SEQ flags and seq options. Now the
record is dropped.

The next sync record restores the state, so the effect looks small. Is
the comment "NO_CPORT exactly when cport is 0" accurate, given what the
master can send in this window?

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
