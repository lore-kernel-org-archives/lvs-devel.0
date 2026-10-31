Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793477601;
	b=0Q/pmJ55Var4F/8VcpCnhzUF/7OqQLLjOdPXmZpRlYwDRcQ4teeqTyyu9IcR7OtJXEw0
	 h8DkiIip2iOLKJU09ue91laeYkiTcg+vDcnPSIdR0wp7GFnbU/C5n2M2vT+zKU3e0lFbr
	 CRibwecVCXEdYXJWRGvqPgZMNJoB3JeGgQkHvidD2z5C5tyWhoRZxeFw0O1iEMYqmnIzA
	 to9zbL457og8zRLIfoEvdWpOylz1+m+P+0ys3B8q09UEjjsPGHhv9fBfhxtbrIRQw4joJ
	 G1ZcR3xVajEyxUTTtyoycmdf2/Gi0cZWA1MUb2uTWcxF8tVW8yCiuMdm9ZnhWDxLPEA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793477601;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=cPFfTN6/hzKEJ9Jp6JStK5DFXphnyN3uZMogfrm57M0=;
	b=S6U9M148Ktoac3Cs28eI8qNgUOP0V2uP3nxyKqyOtPaBn533I6cgKwlVQc0JgiO8d8A1
	 x2sJpWWBxxEXXXSOd6FcMB+eG4skaIG9ZgeUrvEMzTRuCNr4mC6rGj6aR35xHlR3qkCxK
	 ZDjg4fMi6x+l4CW41ak8YHofgS3CD6MNZJgJndv4xcpkGTmQHSrauH6BZqd1Kyu+P6gYc
	 M8WQX2g9HUta5nkdck2X4ZekcI0dpYDto8apGru1JNh9JsIffUxIBVW1ERvnQPeTpJmxU
	 FMRH829xoDytoza17Qgv6qKGEemWVXwGu91tBO7/7EP40jIVDHDxa8SJu1klopR1Gig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=MSldMUD4;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09F16606A31A;
	Sat, 31 Oct 2026 20:13:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 09F16606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=MSldMUD4
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 229ED21F72;
	Sat, 31 Oct 2026 22:13:09 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=cPFfTN6/hzKEJ9Jp6JStK5DFXphnyN3uZMogfrm57M0=; b=MSldMUD40SxN
	Oc/nqD0+2eFqMgpsSOMyF8QenoUqgGCIbswEi9MVdXrvg8nq+VPXqChk4Gf3pNTD
	4JIF2LAN///G8fogaO5MxHGmj2Fz4aCPSPHGVDNKb49BDcRCdAgaJD3S0IjOwKYK
	W3XsMNljqBKfVIolK1qyJtZisSzIqG1cLPbV2I/g725GHhrGbO0spFpDP4RI3i2n
	yRO1fjCrUAzFPfNHVB0ApECEYup2TUiWyjnHH3agPKLgXpd7QnqAo+iaqgFA6Yhc
	f7+KOpgb0iTJXqN5H7AKTCYwkA/HIEA2pCMGE43x24e793FjQoDv3h/ZMjT44n28
	KZZTjnQmI/ISeqoQtMPsolABooAosI+KHNxZ0uQiZ6Na3vi81teJBQ+fvVd/nIKu
	SlumkEMdW3PCtaZd34gyYmqE5PTcyB5AAbjmpmMORdH2R0zkEf0Fbup5i3M/0aKT
	UtZqtsEQPNrsJxM9xFKBfqtT3CU+Vy0QwhEa5cbDhgrOpakg4Kq1Epophb6gQlwz
	W/Bt3UTm/cynm/btp3iadhN/TrjO3B/vPdP+O0QJiKYmfssjwSzt5+m+T6aJYuey
	6vHRNohdF4+BVfLgogL+svUDyOno6GRaAhGm3VyoYmt8pNg7WAD9f9HSwqOfjMEB
	q2BswHCKydG1hUzx2mHBj9gA+932hbk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 31 Oct 2026 22:13:08 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 866C2601BB;
	Sat, 31 Oct 2026 22:13:08 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 69VKD0jG037434;
	Sat, 31 Oct 2026 22:13:01 +0200
Date: Sat, 31 Oct 2026 22:13:00 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Yingjie Wang <x-professor@outlook.com>
cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "horms@verge.net.au" <horms@verge.net.au>,
        "pablo@netfilter.org" <pablo@netfilter.org>,
        "fw@strlen.de" <fw@strlen.de>, "phil@nwl.cc" <phil@nwl.cc>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@kernel.org" <edumazet@kernel.org>,
        "kuba@kernel.org" <kuba@kernel.org>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "coreteam@netfilter.org" <coreteam@netfilter.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH nf] ipvs: avoid wrapping persistent service timeouts
In-Reply-To: <4f420fda8690ac470be44b3da284b65501c77bb5.1793430892.git.x-professor@outlook.com>
Message-ID: <5fa37fba-530c-2c5b-038e-9cb95e34023d@ssi.bg>
References: <4f420fda8690ac470be44b3da284b65501c77bb5.1793430892.git.x-professor@outlook.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sat, 31 Oct 2026, Yingjie Wang wrote:

> ip_vs_add_service() and ip_vs_edit_service() convert the persistent
> timeout from seconds to jiffies with u->timeout * HZ. Both operands are
> unsigned int and the value comes unchecked from the socket API or from
> IPVS_SVC_ATTR_TIMEOUT, so timeouts above UINT_MAX / HZ wrap.
> 
> With HZ=1000, 4294968 seconds becomes 704 jiffies and is reported back
> as 0 seconds. Persistence templates copy svc->timeout, so their timer is
> armed for 0.7 seconds and a client can be moved to another real server
> long before the configured timeout.
> 
> A related boundary exists on 32-bit kernels. Some products that fit in
> unsigned int exceed the maximum safe jiffy delay. For example, 4294967
> seconds becomes 4294967000 jiffies with HZ=1000. Adding that delay to
> jiffies wraps, and the timer code can treat the result as already expired.
> 
> Limit the seconds value using both the storage width and
> MAX_JIFFY_OFFSET before multiplying by HZ. Saturate out-of-range values
> instead of rejecting requests that previously succeeded. Also print the
> stored unsigned timeout with %u in /proc/net/ip_vs, since a valid stored
> value can exceed INT_MAX.
> 
> The overflow was reproduced in an x86-64 QEMU guest (HZ=1000) through
> the IPVS socket API. A persistent one-packet UDP service with two real
> servers was set to 4294968 seconds, and a client in another network
> namespace sent two datagrams 1.5 seconds apart. On the base kernel the
> template expired between the datagrams, as it did for a 1-second
> control, and the second datagram went to the other real server. With
> this change the template remained present and both datagrams went to the
> same server. The 300-second control was unchanged.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: Yingjie Wang <x-professor@outlook.com>
> ---
> 
> Notes:
>     ip_vs_set_timeout() rejects global TCP/UDP timeouts above INT_MAX / HZ
>     with -EINVAL. This path saturates instead because the persistent timeout
>     is a __u32 whose full range has always been accepted. Saturation avoids
>     adding a new error result while keeping the stored delay within both the
>     storage width and the safe jiffy range.
> 
>  net/netfilter/ipvs/ip_vs_ctl.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index ce9fe20d6106a..0d4a113eb5a7f 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1749,6 +1749,15 @@ static void ip_vs_dest_trash_expire(struct timer_list *t)
>  	spin_unlock(&ipvs->dest_trash_lock);
>  }
>  
> +/* Convert seconds without overflowing or exceeding a safe jiffy delay. */
> +static unsigned int ip_vs_svc_timeout(unsigned int timeout)
> +{
> +	unsigned long max_secs;
> +
> +	max_secs = min_t(unsigned long, UINT_MAX, MAX_JIFFY_OFFSET) / HZ;
> +	return min_t(unsigned long, timeout, max_secs) * HZ;
> +}
> +

	Better to add something like this in include/net/ip_vs.h,
it will be used in multiple files:

/* All timeouts up to 31 days */
#define IP_VS_TIMEOUT_MAX_SECS	(86400 * 31)

static inline unsigned long ip_vs_timeout_ticks(unsigned int secs)
{
	secs = min_t(unsigned int, secs, IP_VS_TIMEOUT_MAX_SECS);
#if BITS_PER_LONG <= 32
	secs = min_t(unsigned int, secs, MAX_JIFFY_OFFSET / HZ);
#endif
	return (unsigned long) secs * HZ;
}

	The IP_VS_TIMEOUT_MAX_SECS value comes from the ipvsadm
MAX_TIMEOUT. It is used both for service persistence and the
protocol timeouts. We have to add checks in ip_vs_add_service and
ip_vs_edit_service for IP_VS_TIMEOUT_MAX_SECS and to return -EINVAL.
As the timeout field in struct ip_vs_service is unsigned int, it
should be changed to unsigned long, it is in ticks. The checks in 
ip_vs_set_timeout() should be for IP_VS_TIMEOUT_MAX_SECS, not for
INT_MAX / HZ.

	Then when we convert the secs to ticks we should use
ticks = ip_vs_timeout_ticks(secs). This includes svc->timeout and
the assignments in ip_vs_set_timeout().

	Also, ip_vs_proc_conn() in ip_vs_sync.c should use
cp->timeout = ip_vs_timeout_ticks(timeout) too, instead of
MAX_SCHEDULE_TIMEOUT / HZ * HZ. This place is the reason we
to add the first line in ip_vs_timeout_ticks(), the other
places will have early check for IP_VS_TIMEOUT_MAX_SECS.

	The idea is to reject timeouts above 31 days but
to silently clamp the value to MAX_JIFFY_OFFSET / HZ due to
32-bit platform limits.

>  /*
>   *	Add a service into the service hash table
>   */
> @@ -1864,7 +1873,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  	svc->port = u->port;
>  	svc->fwmark = u->fwmark;
>  	svc->flags = u->flags & ~IP_VS_SVC_F_HASHED;
> -	svc->timeout = u->timeout * HZ;
> +	svc->timeout = ip_vs_svc_timeout(u->timeout);
>  	svc->netmask = u->netmask;
>  	svc->ipvs = ipvs;
>  
> @@ -2031,7 +2040,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
>  	 * Set the flags and timeout value
>  	 */
>  	svc->flags = u->flags | IP_VS_SVC_F_HASHED;
> -	svc->timeout = u->timeout * HZ;
> +	svc->timeout = ip_vs_svc_timeout(u->timeout);
>  	svc->netmask = u->netmask;
>  
>  	old_pe = rcu_dereference_protected(svc->pe, 1);
> @@ -3064,9 +3073,9 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
>  		}
>  
>  		if (svc->flags & IP_VS_SVC_F_PERSISTENT)
> -			seq_printf(seq, "persistent %d %08X\n",
> -				svc->timeout,
> -				ntohl(svc->netmask));
> +			seq_printf(seq, "persistent %u %08X\n",
> +				   svc->timeout,
> +				   ntohl(svc->netmask));
>  		else
>  			seq_putc(seq, '\n');
>  
> 
> base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

