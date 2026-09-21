Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C863B1A6834;
	Mon, 21 Sep 2026 05:50:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789969803; cv=none; b=UbGAY+hzJGT9yTJCUA6ZDfDbUILWJeWK3G54enmZsvbRPfUh42CM26AphuKtIhjnQT/S6dWCyv7wIWAZiTOm6putXrDSzeLGusydg85+Wn3SVSnSxeI1cir5wiK0YF4cllWPCqLtRwfhF1n0wyIpKqP0SjmO3j8T63y2HVvY4no=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789969803; c=relaxed/simple;
	bh=dkINHfLTmxdp2mRix7RnRFS1H+g7khJ/x6i8otC0CuM=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=qG9syM1XzugwsBG10wfSKpqiRfY3rqvdRVvMUa1vb+UvFMUWmnSWTuqQikhG2nlYTmQHj6y4JvZElKLDk+L65okYy5HaHWM1mVwXS0Hu0xpaovsVPgCfbcH86ZKXAkTcEh/lf+BDR+CxGfRWtgAXL2yNvhDvjTByFXV58R7tBGE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lbKJ7A47; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lbKJ7A47"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2EB2C1F00898;
	Mon, 21 Sep 2026 05:50:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789969801;
	bh=uI5RhMZWgvksjQWirrNZiZd2LgJw0zWd0IvXSG4KiZU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=lbKJ7A47K2bBneOHu39xXNZQtKQjAx0yEQA6dS4KoOHs/m0xMJBJ8kfwJnco5zLVH
	 B4hGJDSm3hrqmpAbqSwQdRsBV2+UzSbr3J/zc9OdSE8+9GbHdHO9hVSjgZIkaB2vlq
	 LhSbuiyt2a5SRzg/VjVmhm5KbTmB2UDS4Hn51UPzr02e0BIJbWndwYgPBkC+OKcXYU
	 C2UDaOqdaUcOlwTKHLcXuv8mERNEkT3nb0ZA8CMuINA9lQPGp0t1IAmBrv1kf3obX2
	 /ejrsIzgj0hQ+qjEurBQk4YfkZALcTUcYwHlAXNG15rsy1lHH1kryBItJcrxx6cEG5
	 gCKfepS8v2xxQ==
Subject: Re: [PATCH v4 nf-next 1/3] ipvs: add flags for per-service secure TCP
 state table
From: netdev-bot+sashiko@kernel.org
To: adrianox@gmail.com
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, fw@strlen.de,
 netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kuba@kernel.org
Date: Mon, 21 Sep 2026 05:50:00 +0000
Message-ID: <178996980075.2160803.16809206765369582768@kernel.org>
In-Reply-To: <20260920054708.988867-2-adrianox@gmail.com>
References: <20260920054708.988867-2-adrianox@gmail.com>
X-sashiko-severity: Low
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found more severe
issue(s) in other patches of this series. This mail is only an FYI, in case
you want to address the nit picks below when you respin.

Low priority / nit picks for your consideration:

- [Low] Reported for policy completeness only; my verification concludes
  this is NOT a defect in the series.

Pre-existing issues:
- [Low] Reported for policy completeness only; verified as a pre-existing
  cosmetic discrepancy with no functional effect.

--

ipvs: add flags for per-service secure TCP state table

This adds the uAPI bits IP_VS_SVC_F_SECURE_TCP (0x0100) and
IP_VS_CONN_F_SECURE_TCP (1 << 17), and stamps the connection flag in
ip_vs_bind_dest() for connections bound to a destination whose service
carries the service flag, plus in the cache_bypass path of ip_vs_leave().

A couple of small observations on the new header bits below.

> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index 2c37c6ac7525..ade170109ff4 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -27,6 +27,7 @@
>  
>  #define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
>  #define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
> +#define IP_VS_SVC_F_SECURE_TCP	0x0100		/* use the hardened TCP table */

[Severity: Low]
Both new bits are documented as "use the hardened TCP table", but nothing
in this commit reads either of them, so in this tree state the bits are
accepted from user space and stamped onto connections without changing
behaviour.

Checking the rest of the series, the consumer does arrive in the following
patch, "ipvs: tcp: enable per-connection secure_tcp in state machine",
which changes set_tcp_state() in net/netfilter/ipvs/ip_vs_proto_tcp.c to:

	table = pd->tcp_state_table;
	if (cp->flags & IP_VS_CONN_F_SECURE_TCP)
		table = tcp_states_dos;
	new_state = table[state_off + state_idx].next_state[cp->state];

So by the end of the series the header comment matches the implementation
and this looks like a plain producer/consumer split rather than a defect.
Noting it only in case the intermediate state matters for bisect, since the
bit is settable by CAP_NET_ADMIN through ip_vs_ctl.c before it has any
effect.

>  
>  /*
>   *      IPVS sync daemon states
> @@ -105,6 +106,7 @@
>  
>  /* Flags that are not sent to backup server start from bit 16 */
>  #define IP_VS_CONN_F_NFCT	(1 << 16)	/* use netfilter conntrack */
> +#define IP_VS_CONN_F_SECURE_TCP	(1 << 17)	/* use the hardened TCP table */

[Severity: Low]
This isn't an issue introduced by this patch, but the new bit lands under
the comment saying these flags are not sent to the backup server, while the
v1 serializer actually puts the whole flags word on the wire.

net/netfilter/ipvs/ip_vs_sync.c:ip_vs_sync_conn()

	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);

So a connection carrying IP_VS_CONN_F_SECURE_TCP does transmit bit 17.

The receiving side drops it again in ip_vs_process_message_v1():

	flags  = ntohl(s->v4.flags) & IP_VS_CONN_F_BACKUP_MASK;

and IP_VS_CONN_F_BACKUP_MASK only contains FWD_MASK, NOOUTPUT, INACTIVE,
SEQ_MASK, NO_CPORT and TEMPLATE, so no high bit survives on the backup.

IP_VS_CONN_F_NFCT at bit 16 is already transmitted the same way, so the
mismatch between the comment and the wire format predates this change; this
just adds one more flag to it. Would it be worth adjusting the comment to
say the backup masks these bits off on receive rather than that they are not
sent?

>  
>  /* Connection flags from destination that can be changed by user space */
>  #define IP_VS_CONN_F_DEST_MASK (IP_VS_CONN_F_FWD_MASK | \

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260920054708.988867-1-adrianox%40gmail.com
