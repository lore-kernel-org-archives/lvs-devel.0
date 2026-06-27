Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA9193644AF;
	Sat, 27 Jun 2026 20:53:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782593601; cv=none; b=If03q3f6GiDx3puLuv+58w+butEenQNCGLSxZgGBJzYFb8NVsvlN7FEmdxj2zdbYviEgQDQIixC7/o8Y4ajIoKYqM+SjJhow2lHWhgcYilOQ1XfGtiALJqciLzlnI/rQH3KD5+rnNaXBXCB0orpXLkki6bdCodHVPrI4TnYpPeU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782593601; c=relaxed/simple;
	bh=s2HhVTtt5r7eizOr19mBsAwr15RJ20ZsuXhGVfxCtX0=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=FEjCPVPYK92frb5fBwY2k/iDsCTLbfcpJFwKpYb/eUUFPrvpXprrDKR/ENokuju5bBmvP5D2TJcN13jeMN5cV1Ipk+ioNI9qSkeURE1ePZUdrWcS3NfeTUp/rB4CINuBcvvE0yfnCO0oorRbC0UaaEYnuLvtiKFzq5Kv+ILhMNg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=PRhywiTz; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="PRhywiTz"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 79CEC22402;
	Sat, 27 Jun 2026 23:47:00 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=VG44JPkImmxR9qXkRVBscbfn15Qm0MVXAI13gl6Lq1g=; b=PRhywiTzNh43
	9OB6DkZElBU3Xa6OXnQY5VKGzMRWOeoOtbNH1v5heQduBIxcsuyetrjsaSOgS2Ad
	406gbI6JyBbshtZdtbXpc3P+zaAICOg0yDtG3gOeGJ4lgwAUyufknMezrmAckY6T
	5NWeBq8Fh/sH+AYXtab4ifBxliJtIqexy6c8jcpV14Bv06YpA2a477j1u5QcVhhM
	1A+hCtF1MPkDUFkambEs3DIfmxUZiAgTX69h60JUdGgDAeBm9YHRPAffOwNN9/qL
	qPsisjpXIK9AE2K86CiSAo0FmLO1bKP6fHJXXL71qmlHZrkleV980ppjvAP+111S
	UV44JcJliPSJnur0rOiKPBNsAJlHP+C+6uW4aUVHcGMV59h0E6xWWXVZBb7QLBoZ
	yIcPfvjRzyJKmkrNN1LxcZSciNBZjP8cBWoruDOgS7tVM/orNTtI7D7wV6GzLqMs
	PLbs77a6om6jhnCbDF4pDMgj84YryZWeE+KdMykngSiHNMZftOwivk7FNZ/3xP14
	CtnAYPjINsvlN/kGYtnV2AEq0gb5hRgAQ/DFEdCZLOXPSlwfm8hjavJmXogRnlLU
	B65B44tt5yqDOUrDmjzZCJ0W9+2p6uAjKptTq0AP3708BWXIUrQ+o668N376MWW7
	pNR/XOT16KrbNhqq2frpKg+pdEudcyA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 27 Jun 2026 23:47:00 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 05D8B607D0;
	Sat, 27 Jun 2026 23:46:57 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 65RKkdcs013412;
	Sat, 27 Jun 2026 23:46:42 +0300
Date: Sat, 27 Jun 2026 23:46:39 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Ren Wei <n05ec@lzu.edu.cn>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        kaber@trash.net, nick@loadbalancer.org, yuantan098@gmail.com,
        yifanwucs@gmail.com, tomapufckgml@gmail.com, bird@lzu.edu.cn,
        roxy520tt@gmail.com
Subject: Re: [PATCH 1/1] ipvs: preserve conn hash flags when late-binding
 dest
In-Reply-To: <1b914f41d725bc064c9ba9830dc8169329737270.1782540466.git.roxy520tt@gmail.com>
Message-ID: <a37698c7-46de-1f04-5306-b6a6af7ee6c7@ssi.bg>
References: <cover.1782540466.git.roxy520tt@gmail.com> <1b914f41d725bc064c9ba9830dc8169329737270.1782540466.git.roxy520tt@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sun, 28 Jun 2026, Ren Wei wrote:

> From: Zhiling Zou <roxy520tt@gmail.com>
> 
> Synced connections can be created before their destination exists. When
> the destination is later added, ip_vs_try_bind_dest() binds it to the
> existing connection through ip_vs_bind_dest().
> 
> ip_vs_bind_dest() copies destination connection flags into cp->flags.
> For an already hashed connection, changing flags that define conn_tab
> membership breaks the hash table invariants. In particular, adding
> IP_VS_CONN_F_ONE_PACKET after the connection has been hashed can make
> expiry skip unlinking it from conn_tab. Changing the forwarding method
> can also make unlink use a different single or double hash-node layout
> than the one used at insertion time.
> 
> Preserve the flags that define conn_tab hashing when binding a
> destination to an already hashed connection.
> 
> Fixes: 26ec037f9841 ("IPVS: one-packet scheduling")

	The problem with the fix is that we should do it
in the hard way: the backup server should be able to define
its own forwarding methods. Otherwise, we can break existing
setups. For example, master can have localnode for some
dests, this can not be preserved in the backup for the
synced conns.

> Cc: stable@vger.kernel.org
> Reported-by: Yuan Tan <yuantan098@gmail.com>
> Reported-by: Yifan Wu <yifanwucs@gmail.com>
> Reported-by: Juefei Pu <tomapufckgml@gmail.com>
> Reported-by: Xin Liu <bird@lzu.edu.cn>
> Assisted-by: Codex:gpt-5.4
> Signed-off-by: Zhiling Zou <roxy520tt@gmail.com>
> Signed-off-by: Ren Wei <n05ec@lzu.edu.cn>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index cb36641f8d1c..016273906aac 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -998,7 +998,11 @@ static inline int ip_vs_dest_totalconns(struct ip_vs_dest *dest)
>  static inline void
>  ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
>  {
> +	const unsigned int hash_flags = IP_VS_CONN_F_FWD_MASK |
> +					IP_VS_CONN_F_NOOUTPUT |
> +					IP_VS_CONN_F_ONE_PACKET;
>  	unsigned int conn_flags;
> +	__u32 old_flags;
>  	__u32 flags;
>  
>  	/* if dest is NULL, then return directly */
> @@ -1011,7 +1015,8 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
>  	conn_flags = atomic_read(&dest->conn_flags);
>  	if (cp->protocol != IPPROTO_UDP)
>  		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
> -	flags = cp->flags;
> +	old_flags = cp->flags;
> +	flags = old_flags;
>  	/* Bind with the destination and its corresponding transmitter */
>  	if (flags & IP_VS_CONN_F_SYNC) {

	We can here unconditionally drop the IP_VS_CONN_F_ONE_PACKET flag:

		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;

	Because IP_VS_CONN_F_ONE_PACKET conns are not synced.

	And here when (flags & IP_VS_CONN_F_HASHED) and the fwd
	method changes between MASQ and non-MASQ for 
	!IP_VS_CONN_F_TEMPLATE we should call some new func
	that properly hashes/unhashes just the hn1 node.
	I can provide such function with proper locking.

>  		/* if the connection is not template and is created
> @@ -1023,6 +1028,13 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
>  		flags &= ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPUT);
>  	}
>  	flags |= conn_flags;
> +
> +	/* Preserve conn_tab hashing invariants after late binding. */
> +	if (old_flags & IP_VS_CONN_F_HASHED) {
> +		flags &= ~hash_flags;
> +		flags |= old_flags & hash_flags;
> +	}
> +
>  	cp->flags = flags;
>  	cp->dest = dest;

Regards

--
Julian Anastasov <ja@ssi.bg>

