Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794290010;
	b=EqbPdJYpyADYVifRCwkK7IHjR31v20+UwsnP5sThUtx+/CK8ZLQF8WQ6lIU30o83KJoO
	 b9guRVp+lGxc08wMGf//hqgb9zi+ph1MsQsjxI0GVeJykn673MOPKiBQ9tV215hWEfQuu
	 QFNDt5Fcey6uWktTbjrB/C/pcqfZPYyp/id+1k9vv0XovUVhzGjYd2pAfQbts+IbpTkEy
	 ssreaKri334ezK2AUOUeASWvEWMiXgGYknSSoY/V/v9A30SrLAbzNndrSWC683HEhluzZ
	 aBGi5ZfYIVENgdSs2lzkx3Chi+Bx+/Vvu9DlQERuK6Ab2/uC5X4/rdRRbWMWaiyimMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794290010;
	h=Received:DKIM-Signature:Subject:From:To:Cc:Date:Message-ID:
	 In-Reply-To:References:X-sashiko-severity:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=8V0k+iw19zvXaLESLiauhTFUIPKFwj+4KEkYMPQAdqc=;
	b=nywPOrWVA5Fg55/BZkKygu412b+wxHIwCdRWH9GYGlu9819BqoHbJ1Yzvf63xUQRHqUU
	 CTpexQEXBjvKis4mbAxadnrZqd6pgCVb9L5/zGQf/AGIDadTff7/xbcjqANJlz550lazJ
	 s78koLcQqlyHoZiLXNpECOZ3jozAboQZ4DBE5U2VWIhKt6BWQWL2inZudO/Ofz8StxkWT
	 uFNCccAgvd6gjxD3yn6+WGLDo9kUTSqVWe10kT/C9MJbOwzsFBNQOMzDA9Lp2iDOKJMSb
	 nk9grGdB68ee5/C0r9mpS5IjJXfRG3IuuFXnipKHXd3UNy48Iki5s5xJUJ7UY45DDew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CbDlQSck;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BBB660A383F;
	Tue, 10 Nov 2026 05:53:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CbDlQSck
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B6FCD1F008A5;
	Tue, 10 Nov 2026 05:53:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794290009;
	bh=8V0k+iw19zvXaLESLiauhTFUIPKFwj+4KEkYMPQAdqc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=CbDlQScksFDvh8HswxMT3tPBBs7R8XnTHT5ameNeUHFadHwC7aJYkIKS6hddhg7lS
	 JJuEyxEq7mbF16KPolFw4Bby4uq1VZ8vkd9AxspBcb8oODjFIvva5EJVhwZH//yZId
	 EiRA1cMNkue4zvVQCbC/jDlJxWU05Gkh9w2cJxOhodHgjmv8FcF3yZN/r2vVj+kUxQ
	 PGzpTN8Q7wdD3av8OisjnFDpQ1Jwg1Cr2R31Ro+0i4Gv7n2Ar8QY7YQZq1nfcMpW2N
	 hXctadhrHsLvI5rYQ7qekHpE4V/TrtCsEhPXJbEniLz+QvI+OYHssweWRJ6vnjkUa7
	 euuR2CfgVCD4g==
Subject: Re: [PATCH net-next 14/14] netfilter: cttimeout: annotate data-races
 around the default timeouts
From: netdev-bot+sashiko@kernel.org
To: jiayuan.chen@linux.dev
Cc: netdev@vger.kernel.org, dsahern@kernel.org, idosch@nvidia.com,
 davem@davemloft.net, edumazet@kernel.org, kuba@kernel.org, pabeni@redhat.com,
 horms@kernel.org, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
 razor@blackwall.org, paul@paul-moore.com, matttbe@kernel.org,
 martineau@kernel.org, geliang@kernel.org, ja@ssi.bg, achender@kernel.org,
 marcelo.leitner@gmail.com, lucien.xin@gmail.com, alibuda@linux.alibaba.com,
 dust.li@linux.alibaba.com, sidraya@linux.ibm.com, mjambigi@linux.ibm.com,
 tonylu@linux.alibaba.com, guwen@linux.alibaba.com,
 linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, bridge@lists.linux.dev,
 linux-security-module@vger.kernel.org, mptcp@lists.linux.dev,
 lvs-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
 rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org,
 linux-s390@vger.kernel.org
Date: Tue, 10 Nov 2026 05:53:27 +0000
Message-ID: <179429000729.994134.16108041301574145842@kernel.org>
In-Reply-To: <20261109025425.328445-15-jiayuan.chen@linux.dev>
References: <20261109025425.328445-15-jiayuan.chen@linux.dev>
X-sashiko-severity: Medium
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 1 potential
issue(s) to consider.

Critical: 0 · High: 0 · Medium: 1 · Low: 0

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [Medium] A concurrent sysctl write to a default conntrack timeout can
  still be silently undone.

--

netfilter: cttimeout: annotate data-races around the default timeouts

This commit changes the l4proto nlattr_to_obj() and obj_to_nlattr()
timeout callbacks to use WRITE_ONCE() and READ_ONCE() instead of plain
accesses. It targets races between cttimeout_default_set() and
cttimeout_default_get(), the conntrack packet path, and the
nf_conntrack_*_timeout* sysctl handlers, which all touch the same
per-netns default timeout arrays.

> diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
> index 99eedaa2b1183..777b21da3bcff 100644
> --- a/net/netfilter/nf_conntrack_proto_udp.c
> +++ b/net/netfilter/nf_conntrack_proto_udp.c
> @@ -155,16 +155,16 @@ static int udp_timeout_nlattr_to_obj(struct nlattr *tb[],
>  		timeouts = un->timeouts;
>  
>  	/* set default timeouts for UDP. */
> -	timeouts[UDP_CT_UNREPLIED] = un->timeouts[UDP_CT_UNREPLIED];
> -	timeouts[UDP_CT_REPLIED] = un->timeouts[UDP_CT_REPLIED];
> +	WRITE_ONCE(timeouts[UDP_CT_UNREPLIED], READ_ONCE(un->timeouts[UDP_CT_UNREPLIED]));
> +	WRITE_ONCE(timeouts[UDP_CT_REPLIED], READ_ONCE(un->timeouts[UDP_CT_REPLIED]));

[Severity: Medium]

Can a concurrent sysctl write still be lost here?

cttimeout_default_set() passes a NULL destination:

net/netfilter/nfnetlink_cttimeout.c:cttimeout_default_set() {
    ...
	ret = ctnl_timeout_parse_policy(NULL, l4proto, info->net,
					cda[CTA_TIMEOUT_DATA]);
    ...
}

So udp_timeout_nlattr_to_obj() sets timeouts to un->timeouts, and the
default copy turns into a self-copy of the live per-netns array:

	WRITE_ONCE(un->timeouts[UDP_CT_REPLIED],
		   READ_ONCE(un->timeouts[UDP_CT_REPLIED]));

That is still a separate load and store. The sysctl handler writes the
same field through proc_dointvec_jiffies() and does not take the nfnl
mutex. Take a request that carries only CTA_TIMEOUT_UDP_UNREPLIED, sent
while nf_conntrack_udp_timeout_stream is being written:

CPU0 (IPCTNL_MSG_TIMEOUT_DEFAULT_SET)
  old = READ_ONCE(un->timeouts[UDP_CT_REPLIED])

CPU1 (sysctl write)
  WRITE_ONCE(un->timeouts[UDP_CT_REPLIED], new)

CPU0
  WRITE_ONCE(un->timeouts[UDP_CT_REPLIED], old)

The sysctl value gets reverted, even though the netlink request never
named that attribute.

The second KCSAN splat in the commit message (proc_int_u2k_conv_uop vs
udp_timeout_nlattr_to_obj) comes from this access pair. Once both sides
are marked, KCSAN stops reporting it, but the update can still be lost.

The same self-copy happens in these places:

  tcp_timeout_nlattr_to_obj(), where timeouts = tn->timeouts and the
  loop covers all TCP_CONNTRACK_TIMEOUT_MAX entries
  sctp_timeout_nlattr_to_obj(), where timeouts = sn->timeouts
  gre_timeout_nlattr_to_obj(), where timeouts = gre_get_timeouts(net)
  the else branch of generic_timeout_nlattr_to_obj(), when timeout is
  &gn->timeout
  the else branch of icmpv6_timeout_nlattr_to_obj(), when timeout
  falls back to icmpv6_get_timeouts(net)

When the destination already points at the per-netns array, could the
default copy be skipped, so that fields missing from the request are
never stored?

>  
>  	if (tb[CTA_TIMEOUT_UDP_UNREPLIED]) {
> -		timeouts[UDP_CT_UNREPLIED] =
> -			ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDP_UNREPLIED])) * HZ;
> +		WRITE_ONCE(timeouts[UDP_CT_UNREPLIED],
> +			   ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDP_UNREPLIED])) * HZ);
>  	}

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261109025425.328445-1-jiayuan.chen%40linux.dev
