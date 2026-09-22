Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82EE2572673;
	Tue, 22 Sep 2026 17:12:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790097138; cv=none; b=HpCP+Tj1IwNYXgLiuW+4FJtxDwtZNKGE1/1053+6cPr13a4/cLYkl0T2/oRUZbfWwNby9MB0NFO8Ct0Y0Y23kK8g5ex5fiJT8pLfmoOnA1QODwdsgZgezhsk2M0SRJhyA/uuqf4mVHcvXFp6zoNALa4BkxSLAnRiR3apAPyqDhU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790097138; c=relaxed/simple;
	bh=zNQHcBd7xYGJRfYFZY4Bnu6Ky/BoGBYc61+QbkOviPY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=WuTSwmrRKMhavj7wGWZMXwFzTj46iszxdzapMlItvMnONmwhbpQ8RXAPIctrl8ibQnxJ2MzKy1LZ9FkJ2limAfF4S9eQMS4TzvEL+7A+Gk8JpRZV4pv1xHYebC67IVropnO2Smm9l/GFZ2PpaceLadI09+7VHNWIXA34jRQRw/s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=eKjz4rOr; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="eKjz4rOr"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8DA08213B2;
	Tue, 22 Sep 2026 20:12:09 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Js5PmAUcjbxW7gWn4Whs+OD6wHnqQpE49HM1IGljWhc=; b=eKjz4rOrPWyz
	D+g84LRf7FOEPohxy8J/rNiO6h1zQytm8c/48zfyZelj+Ny4NSONZwKL9AhKyDMv
	3MMZQJW+obmSzHy9YxNBLz3jxAxg7wfM9XKJadGx5FcviiBVGtij1B9si8uyFf+G
	znVJKoa0IVbCPWlFyVblD9AraJUtv4RiWCVmNihhanh9jU+QzHBxkRQ9Ib5ueq5W
	ryvJ2ldps+U/cPV9Tyy07GOOLFlsEPim98cHxKkqyzfT793NBuW67ad1N6B1gMep
	CnCmvFdT1h5EDA6rpk3pZuIzk5M/GDhQIl9hcJnfexgQPBT3lriIM3lqVQCrKgkj
	krSWPTRLepqLfZkEA3H85W1JI02CDyC8O5XP3Och+4k+9pam7x5XmwDOoYXDYACQ
	xaHOsONpw9kwtwWB9O/3kCQf+xB/t4mI2POWiHzYwjJrAo3uwOQYfLtz0LNcYbMD
	rw7TRIIKhKJylxB2q2BTXhoW6TtmjIegjJPLUJapsagk150iuEeark+Cn8seNe2k
	Pfl+NfFq7CI9+79t1nYrhFWsnv2rGraUdG4McR5OfEKLryIaE/gij3XCWfF5l55L
	DMJnwLFjGzHHGNO/EVTjWndsNJaT+nmgKBwEpy2x+IgG0Z2yflI4ZerlsqUkB02I
	Zv2UTIDVdJDt84ZEY+cO/+sRE0ZFziY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 22 Sep 2026 20:12:09 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8C7B1608CD;
	Tue, 22 Sep 2026 20:12:11 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68MHC9bH050657;
	Tue, 22 Sep 2026 20:12:09 +0300
Date: Tue, 22 Sep 2026 20:12:09 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Adriano Cordova <adrianox@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
        lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 nf-next 1/3] ipvs: add flags for per-service secure
 TCP state table
In-Reply-To: <20260921205706.1055288-2-adrianox@gmail.com>
Message-ID: <013264f0-57e4-c8e7-6e31-30d2e1b92893@ssi.bg>
References: <20260921205706.1055288-1-adrianox@gmail.com> <20260921205706.1055288-2-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 21 Sep 2026, Adriano Cordova wrote:

> Add IP_VS_SVC_F_SECURE_TCP to mark a virtual service for the
> DoS-hardened TCP connection state table, and
> IP_VS_CONN_F_SECURE_TCP to carry that capability on a connection
> so the TCP state machine can select the hardened table for it.
> 
> The service flag is 0x0100: bits 0x0008/0x0010/0x0020 are the
> scheduler bits, so leave 0x0040/0x0080 free for schedulers.
> 
> Set IP_VS_CONN_F_SECURE_TCP on every connection bound to a
> destination whose service carries IP_VS_SVC_F_SECURE_TCP.
> 
> Signed-off-by: Adriano Cordova <adrianox@gmail.com>
> ---
> Changes in v2:
> - Let IP_VS_SVC_F_SECURE_TCP be 0x0100, leaving 0x0040/0x0080 free for
>   scheduler flags.
> - Let IP_VS_CONN_F_SECURE_TCP be (1 << 17) and drop it from
>   IP_VS_CONN_F_BACKUP_MASK.
> - Set the flag in ip_vs_bind_dest() instead of at every ip_vs_conn_new()
>   call site.
> 
> Changes in v3:
> - Merge the uapi flag definition and the ip_vs_bind_dest() stamping into
>   a single patch.
> 
> (no changes since v3)
> 
>  include/uapi/linux/ip_vs.h      | 2 ++
>  net/netfilter/ipvs/ip_vs_conn.c | 4 ++++
>  net/netfilter/ipvs/ip_vs_core.c | 3 +++
>  3 files changed, 9 insertions(+)
> 
> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index 2c37c6ac7525..ade170109ff4 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -27,6 +27,7 @@
>  
>  #define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
>  #define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
> +#define IP_VS_SVC_F_SECURE_TCP	0x0100		/* use the hardened TCP table */
>  
>  /*
>   *      IPVS sync daemon states
> @@ -105,6 +106,7 @@
>  
>  /* Flags that are not sent to backup server start from bit 16 */
>  #define IP_VS_CONN_F_NFCT	(1 << 16)	/* use netfilter conntrack */
> +#define IP_VS_CONN_F_SECURE_TCP	(1 << 17)	/* use the hardened TCP table */
>  
>  /* Connection flags from destination that can be changed by user space */
>  #define IP_VS_CONN_F_DEST_MASK (IP_VS_CONN_F_FWD_MASK | \
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 6fa3e1dc534c..0b465298b64b 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1090,6 +1090,7 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
>  {
>  	unsigned int conn_flags;
>  	__u32 flags;
> +	struct ip_vs_service *svc;
>  
>  	/* if dest is NULL, then return directly */
>  	if (!dest)
> @@ -1102,6 +1103,9 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
>  	if (cp->protocol != IPPROTO_UDP)
>  		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
>  	flags = cp->flags;
> +	svc = rcu_dereference(dest->svc);
> +	if (svc && (svc->flags & IP_VS_SVC_F_SECURE_TCP))
> +		flags |= IP_VS_CONN_F_SECURE_TCP;

	Adriano, due to the long IPVS bugfix queue, sometimes
the -next work may conflict with other changes. This is the case
with the above hunk. Looks like we should wait the patch
"ipvs: do not create invisible templates" to be included
into the net tree, the net tree to be merged into the net-next
and nf-next tree and then you can post a version for nf-next
which will be on top of this patch. In the mean time I'll
review your changes soon, so that the patchset can be ready
for that moment.

>  	/* Bind with the destination and its corresponding transmitter */
>  	if (flags & IP_VS_CONN_F_SYNC) {
>  		/* Synced conns are hashed, so they can not get this flag */
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index ba0957798bad..aa8a3a964ffd 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -784,6 +784,9 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
>  				      IP_VS_CONN_F_ONE_PACKET : 0;
>  		union nf_inet_addr daddr = { .all = { 0, 0, 0, 0 } };
>  
> +		if (svc->flags & IP_VS_SVC_F_SECURE_TCP)
> +			flags |= IP_VS_CONN_F_SECURE_TCP;
> +
>  		/* create a new connection entry */
>  		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
>  		{
> -- 
> 2.51.0

Regards

--
Julian Anastasov <ja@ssi.bg>

