Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2274B363089;
	Mon, 21 Sep 2026 05:50:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789969804; cv=none; b=nnm2FElz3HyuxCbeqvYJEH35EL1gOiu3y8NpkEaPERyRKz2JSeqYUdJtS7hEpwltymUj53cPNg2FptNJwPv+Mti73niCbvArP7CTSIIih4OS5GHlRH60zOKd4Kys1noVhFOksk/2bZaWoIv89ltbRoeAMSgAm6DBNQk9rcVEF6o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789969804; c=relaxed/simple;
	bh=HBZTeJ9Ujbp/FLhF1g9urNyi2WNQBTUb+lGGfqZpECI=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=nF33MgCbxo0rGHHDCP19Y6HxacCd9Qqb4hhdK8lxaS1sCCoSh3cKqaCUqwJ3iC5nOdUDq+eGiUfN4ZqZdeCVYlKQbeUHxxub+QFecAzW/1HQQ4XbrohhCskJ4t1qHNcCdsBRzwl7rfWpEAoj4W24QisActgZSc15yed2806qIN0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=X9Sv/O+4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="X9Sv/O+4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 52CFC1F000FF;
	Mon, 21 Sep 2026 05:50:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789969802;
	bh=y7MnwHTPjZSCJeljp9xv40vE+F8c/Ac5lfCsoQxx65w=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=X9Sv/O+4kjr2inNsZVPomsCINvEH8nfuixu/6BndH0eY8UwixNTK4/b3OLCxvL9Yc
	 zBKgFYYhv3mMDu+sHjGN+9jdunyypWAihEoz28jzcGmUDKZicycY6NnRogA2g3w5kP
	 64tsJbYJv1WDM5xSQ3fckEB9aiMqLqFSH4V8pOo6GQG1m4ZhwXNO+55Kfd9kCeQRsb
	 1vvXy/gRa8RoqIkG4bWivjv9R032SxlrgMAnSCejYmf7fjl7a7s4bp9Dvx+9gj8WIS
	 fH7blRV/XmGntiP+dQXUbjH9v8wIjLu3lbaG6Id7eFQPcGnDVH2HfF324M3/XY4ZJU
	 U9fpfRsub2YTA==
Subject: Re: [PATCH v4 nf-next 2/3] ipvs: tcp: enable per-connection
 secure_tcp in state machine
From: netdev-bot+sashiko@kernel.org
To: adrianox@gmail.com
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, fw@strlen.de,
 netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kuba@kernel.org
Date: Mon, 21 Sep 2026 05:50:01 +0000
Message-ID: <178996980187.2160803.6175658961734674008@kernel.org>
In-Reply-To: <20260920054708.988867-3-adrianox@gmail.com>
References: <20260920054708.988867-3-adrianox@gmail.com>
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

- [Low] Documentation/networking/ipvs-sysctl.rst:283-288 documents the
  hardened ("more complicated") TCP state transition table as reachable…

--

ipvs: tcp: enable per-connection secure_tcp in state machine

This changes set_tcp_state() so that a connection carrying
IP_VS_CONN_F_SECURE_TCP is driven by tcp_states_dos instead of
pd->tcp_state_table, leaving the netns-wide table as the fallback.  The
old FIXME comment in tcp_timeout_change() is replaced with a note
describing the sysctl as the netns-wide default.

> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index fec0e8b47b71..3b9a2c8e9a52 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -451,11 +451,10 @@ static void tcp_timeout_change(struct ip_vs_proto_data *pd, int flags)
>  	int on = (flags & 1);		/* secure_tcp */
>  
>  	/*
> -	** FIXME: change secure_tcp to independent sysctl var
> -	** or make it per-service or per-app because it is valid
> -	** for most if not for all of the applications. Something
> -	** like "capabilities" (flags) for each object.
> -	*/
> +	 * This remains the netns-wide default / global floor (e.g. when
> +	 * memory pressure kicks in). Per-service hardening is now carried
> +	 * by IP_VS_CONN_F_SECURE_TCP on each connection (set_tcp_state).
> +	 */
>  	pd->tcp_state_table = (on ? tcp_states_dos : tcp_states);
>  }

[Severity: Low]
Should Documentation/networking/ipvs-sysctl.rst be updated along with this
comment change?

The only in-tree description of the hardened table currently ties it
exclusively to the sysctl:

Documentation/networking/ipvs-sysctl.rst:

	secure_tcp - INTEGER
		- 0  - disabled (default)

		The secure_tcp defense is to use a more complicated TCP state
		transition table. ...

The new comment recharacterises that knob as a netns-wide default/floor,
but the .rst still reads as if 0 means no connection uses the hardened
table.

>  
> @@ -479,6 +478,7 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>  	int state_idx;
>  	int new_state = IP_VS_TCP_S_CLOSE;
>  	int state_off = tcp_state_off[direction];
> +	const struct tcp_states_t *table;

[ ... ]

> @@ -496,8 +496,10 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>  		goto tcp_state_out;
>  	}
>  
> -	new_state =
> -		pd->tcp_state_table[state_off+state_idx].next_state[cp->state];
> +	table = pd->tcp_state_table;
> +	if (cp->flags & IP_VS_CONN_F_SECURE_TCP)
> +		table = tcp_states_dos;
> +	new_state = table[state_off + state_idx].next_state[cp->state];

[Severity: Low]
With this override in set_tcp_state(), can an operator still conclude from
net.ipv4.vs.secure_tcp = 0 that no connection is using tcp_states_dos?

A service carrying the new IP_VS_SVC_F_SECURE_TCP bit
(include/uapi/linux/ip_vs.h, settable via IPVS_SVC_ATTR_FLAGS) propagates
IP_VS_CONN_F_SECURE_TCP to its connections, and then set_tcp_state() picks
tcp_states_dos regardless of the sysctl value, so for example SYN_RECV no
longer advances to ESTABLISHED on a bare SYN+ACK.

There is no entry under Documentation/ for IP_VS_SVC_F_SECURE_TCP or for
this new interaction with secure_tcp.  Could a documentation update be
added for the new user-settable flag?

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260920054708.988867-1-adrianox%40gmail.com
