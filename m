Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795150728;
	b=b/tykK9i+P2snzqVdtB8yKZha7Pooi3IitlGvQGB4ip3UPqQT+RDCb2LC8uK8D6A2Zjr
	 8GZzum8k9mf4wdSuvYnGg5nDy72TTZfjUELkeI0Ak+mbHsEUQSjGCuvrGdHopSksrKP6R
	 QC4zuWqn4u3zkYm2BlP5LH/2PTGO462iAaIXCF38wHBTOcA7Lvyu3WoYCg2HSGBJhWfUn
	 Lak+HjMBri4MraN5IrGlx9+HVtSUa8oYAZqyztoF6BC8X4qTXv4Vlp5MhVxaCZxoTMsZm
	 gtVzohrWiBIwtdwiGEo2/8KKeb5oRL4Dw1o/KraxRw3yXgDV04kjjgNy0MLHVklQ+TQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795150728;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=aPqSmjxMQ+I7RBkvZTBS+fVtcupINHXalkw/kOXPt5Q=;
	b=n0n2bt0lTyhqlIue1GUXt273dIgCFb0MyN0QH/nwGn2XEYJtBu6aSoMSm1iOECR/NWYD
	 sZSUyHBierdYClvOYQ0DMzYtFP85Gb6eYKzBXqkWmi4Hq1AyzAL5Cg2Bu5IsX7ObaJlTI
	 EfA6yVSPBzJWPqV1lr/kuTDdlWrW4JeOWKTKVLWi+mcgdaV8gZN+vDg0bIla4Nx5I4PJU
	 mdJt4Jk8wyv1jNI3m1AU1sULw4O8Wl0b2um27QDa8h0yGAtw7lmNuwsWbjji53RZ1Kpv8
	 MdnlZNEPmVtlZyBgRDnPmXCKCZ6GNSwQiykaZ9ad2VBi8QztiYPKe5UFcPxvBjOX9jA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=6h2NWFMr;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 903B6606A33C;
	Fri, 20 Nov 2026 04:58:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 903B6606A33C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=6h2NWFMr
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 4D90621FD3;
	Fri, 20 Nov 2026 06:58:45 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=aPqSmjxMQ+I7RBkvZTBS+fVtcupINHXalkw/kOXPt5Q=; b=6h2NWFMrDuIC
	41dqED0VgMjOiiUIhXtM7/AeObFHl7OYoASDJPWGCMnfMUkizVfUW9DWBXXGJPEl
	+YERT6Myk/5ifhkDtjIjWyW/p277qBsQ+z5vhzHeqVYmOc8vRhllmKC003qcX3iC
	OKUtmAYZnESzGImPReXLwEk3xjoxgKf8tB/BUT4l4sj/VdXGEoXrwqVoO9bhUiCq
	eTYfZ51LBqHOoBu2IzbyC9lSn1qqvgjANO/zHpqpPV35vQEEsgOzIDkK38lTKXxR
	0sNEecGCzpioO4sx6arTgb5e6UmMbN5YpB05e3VrvRVIcy7lGeOsw3mR9hhQq915
	BDa7dVQ+sZmi0hw317dX07u9zmpFNnij197ckAzGJXBnswflCzYFrgIYr18i35NM
	bTEjYZrflPO6GxXvbAQyizHNRLNMZ7gk5fyNakzQlZksKrkWJeKbG4W2yA0zXCAs
	36gisgvGvtmDkej4TqWsN5DZWNGXyD7INo9CZBOIAeVoGKHJ0Pd86iv6OrWYPSMQ
	E7J3cZ9iKnLZELg2YXfSjjhJy/CFroktzv8zyqL4W6D1uxhsItdnQH0LOR/CN3en
	6iYrq5iVhihl6Y0PuLI6Woa9lsLXv4OmruqjyQuPMhRLD19Tbqq+xxaHF8BhS87R
	8v8DHNERSn7+FdSV5Rj6BtzM6Aw/zCw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 20 Nov 2026 06:58:45 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id ABA50604A8;
	Fri, 20 Nov 2026 06:58:44 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AK4wh0Z006393;
	Fri, 20 Nov 2026 06:58:43 +0200
Date: Fri, 20 Nov 2026 06:58:43 +0200 (EET)
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
Subject: Re: [PATCH nf v3] ipvs: avoid wrapping persistent service timeouts
In-Reply-To: <039a17bffd0d0e765d1c3e07a33083da90ffa0e3.1795058541.git.x-professor@outlook.com>
Message-ID: <f0b3611d-d042-09bb-f6f1-a750a2d8f25f@ssi.bg>
References: <039a17bffd0d0e765d1c3e07a33083da90ffa0e3.1795058541.git.x-professor@outlook.com>
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

On Thu, 19 Nov 2026, Yingjie Wang wrote:

> ip_vs_add_service() and ip_vs_edit_service() convert an unchecked u32
> timeout from seconds to jiffies with u->timeout * HZ. Both operands are
> unsigned int, so values above UINT_MAX / HZ wrap.
> 
> With HZ=1000, 4294968 seconds becomes 704 jiffies and is reported back
> as 0 seconds. Persistence templates copy svc->timeout, so their timer is
> armed for 0.7 seconds and a client can be moved to another real server
> long before the configured timeout.
> 
> ipvsadm limits service persistence and protocol timeouts to 31 days.
> Enforce the same limit in the kernel and reject larger values with
> -EINVAL. Convert accepted values through a common helper that clamps
> them to MAX_JIFFY_OFFSET / HZ on 32-bit systems. Use the helper for
> timeouts received from the synchronization protocol as well, since those
> values do not pass through the service configuration checks.
> 
> Change the service timeout and protocol timeout tables to unsigned long
> because they store jiffies. With HZ=1000, 31 days is 2678400000 jiffies,
> which does not fit in the signed int used by the protocol tables. This
> also allows the global protocol timeout interface to represent the full
> 31-day range on 64-bit systems.
> 
> The overflow was reproduced in an x86-64 QEMU guest with HZ=1000. A
> persistent one-packet UDP service was set to 4294968 seconds, and two
> datagrams sent 1.5 seconds apart were directed to different real servers
> after the template expired.
> 
> On the x86-64 test kernel with HZ=1000, 2678401-second service timeouts
> were accepted and 4294968 seconds read back as 0, while a 2678400-second
> protocol timeout was rejected. With this change, 2678401 and 4294968
> seconds are rejected, a failed edit leaves the previous service timeout
> unchanged, and 2678400-second service and protocol timeouts read back
> unchanged.
> 
> On an i386 test kernel with HZ=1000, the accepted 2678400-second values
> were clamped to 1073741 seconds by the 32-bit jiffy limit and read back
> as such through both interfaces.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Link: https://lore.kernel.org/r/5fa37fba-530c-2c5b-038e-9cb95e34023d@ssi.bg
> Signed-off-by: Yingjie Wang <x-professor@outlook.com>

	The patch looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> 
> Notes:
>     Changes in v3:
>     - Remove the jiffies.h include, as requested by Julian Anastasov.
>     - Rebase after f3aff3d80b579 ("ipvs: update flags and seqs in backup
>       server under lock").
>     
>     v2: https://lore.kernel.org/r/969309eb180c2e577dd6bb54a7d28afcbb2efeb3.1793513714.git.x-professor@outlook.com
>     v1: https://lore.kernel.org/r/4f420fda8690ac470be44b3da284b65501c77bb5.1793430892.git.x-professor@outlook.com
>     
>     Based on nf/for-netdev-nf-26-11-16 at 5367e14e92bb.
>     
>     Retested service and protocol timeout boundaries on x86-64 and i386
>     with HZ=1000. On x86-64, also exercised incoming synchronization records
>     for new and existing connections/templates, values above 31 days, and
>     the zero-timeout template default, with KASAN and lockdep enabled.
>     Built the IPVS directory with W=1 under x86-64 allmodconfig and
>     allyesconfig. The kernel IPVS selftest was not run.
> 
>  include/net/ip_vs.h                   | 19 ++++++++++++---
>  net/netfilter/ipvs/ip_vs_app.c        |  3 +--
>  net/netfilter/ipvs/ip_vs_ctl.c        | 35 ++++++++++++++++-----------
>  net/netfilter/ipvs/ip_vs_proto.c      |  4 +--
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |  6 ++---
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  |  6 ++---
>  net/netfilter/ipvs/ip_vs_proto_udp.c  |  6 ++---
>  net/netfilter/ipvs/ip_vs_sync.c       |  6 ++---
>  8 files changed, 51 insertions(+), 34 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 8dc80d5d42dc..47a753d76fe5 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -55,6 +55,18 @@
>  #define IP_VS_CONN_MAX	(1 << 24)
>  #endif
>  
> +/* All timeouts up to 31 days */
> +#define IP_VS_TIMEOUT_MAX_SECS	(86400U * 31)
> +
> +static inline unsigned long ip_vs_timeout_ticks(unsigned int secs)
> +{
> +	secs = min_t(unsigned int, secs, IP_VS_TIMEOUT_MAX_SECS);
> +#if BITS_PER_LONG <= 32
> +	secs = min_t(unsigned int, secs, MAX_JIFFY_OFFSET / HZ);
> +#endif
> +	return (unsigned long)secs * HZ;
> +}
> +
>  /* svc_table limits */
>  #define IP_VS_SVC_TAB_MIN_BITS	4
>  #define IP_VS_SVC_TAB_MAX_BITS	20
> @@ -776,7 +788,7 @@ struct ip_vs_protocol {
>  struct ip_vs_proto_data {
>  	struct ip_vs_proto_data	*next;
>  	struct ip_vs_protocol	*pp;
> -	int			*timeout_table;	/* protocol timeout table */
> +	unsigned long		*timeout_table;	/* protocol timeout table */
>  	atomic_t		appcnt;		/* counter of proto app incs. */
>  	struct tcp_states_t	*tcp_state_table;
>  };
> @@ -938,7 +950,7 @@ struct ip_vs_service {
>  	atomic_t		refcnt;   /* reference counter */
>  	__be16			port;	  /* port number for the service */
>  	unsigned int		flags;	  /* service status flags */
> -	unsigned int		timeout;  /* persistent timeout in ticks */
> +	unsigned long		timeout;  /* persistent timeout in ticks */
>  	__be32			netmask;  /* grouping granularity, mask/plen */
>  	struct netns_ipvs	*ipvs;
>  
> @@ -1845,7 +1857,8 @@ struct ip_vs_pe *__ip_vs_pe_getbyname(const char *pe_name);
>  int ip_vs_protocol_init(void);
>  void ip_vs_protocol_cleanup(void);
>  void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
> -int *ip_vs_create_timeout_table(int *table, int size);
> +unsigned long *ip_vs_create_timeout_table(const unsigned long *table,
> +					  size_t size);
>  void ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
>  			       const struct sk_buff *skb, int offset,
>  			       const char *msg);
> diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
> index 2c1b47702da2..918d9936d814 100644
> --- a/net/netfilter/ipvs/ip_vs_app.c
> +++ b/net/netfilter/ipvs/ip_vs_app.c
> @@ -93,8 +93,7 @@ ip_vs_app_inc_new(struct netns_ipvs *ipvs, struct ip_vs_app *app, __u16 proto,
>  
>  	if (app->timeouts) {
>  		inc->timeout_table =
> -			ip_vs_create_timeout_table(app->timeouts,
> -						   app->timeouts_size);
> +			kmemdup(app->timeouts, app->timeouts_size, GFP_KERNEL);
>  		if (!inc->timeout_table) {
>  			ret = -ENOMEM;
>  			goto out;
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index be818bf7d380..9c53ce6103a5 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1832,6 +1832,9 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  	int ret = 0;
>  	bool grow;
>  
> +	if (u->timeout > IP_VS_TIMEOUT_MAX_SECS)
> +		return -EINVAL;
> +
>  	/* increase the module use count */
>  	if (!ip_vs_use_count_inc())
>  		return -ENOPROTOOPT;
> @@ -1930,7 +1933,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  	svc->port = u->port;
>  	svc->fwmark = u->fwmark;
>  	svc->flags = u->flags & ~IP_VS_SVC_F_HASHED;
> -	svc->timeout = u->timeout * HZ;
> +	svc->timeout = ip_vs_timeout_ticks(u->timeout);
>  	svc->netmask = u->netmask;
>  	svc->ipvs = ipvs;
>  
> @@ -2037,6 +2040,9 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
>  	struct netns_ipvs *ipvs = svc->ipvs;
>  	int af_id = ip_vs_af_index(svc->af);
>  
> +	if (u->timeout > IP_VS_TIMEOUT_MAX_SECS)
> +		return -EINVAL;
> +
>  	/*
>  	 * Lookup the scheduler, by 'u->sched_name'
>  	 */
> @@ -2097,7 +2103,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
>  	 * Set the flags and timeout value
>  	 */
>  	svc->flags = u->flags | IP_VS_SVC_F_HASHED;
> -	svc->timeout = u->timeout * HZ;
> +	svc->timeout = ip_vs_timeout_ticks(u->timeout);
>  	svc->netmask = u->netmask;
>  
>  	old_pe = rcu_dereference_protected(svc->pe, 1);
> @@ -3136,9 +3142,8 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
>  		}
>  
>  		if (svc->flags & IP_VS_SVC_F_PERSISTENT)
> -			seq_printf(seq, "persistent %d %08X\n",
> -				svc->timeout,
> -				ntohl(svc->netmask));
> +			seq_printf(seq, "persistent %lu %08X\n",
> +				   svc->timeout, ntohl(svc->netmask));
>  		else
>  			seq_putc(seq, '\n');
>  
> @@ -3437,36 +3442,38 @@ static int ip_vs_set_timeout(struct netns_ipvs *ipvs, struct ip_vs_timeout_user
>  		  u->udp_timeout);
>  
>  #ifdef CONFIG_IP_VS_PROTO_TCP
> -	if (u->tcp_timeout < 0 || u->tcp_timeout > (INT_MAX / HZ) ||
> -	    u->tcp_fin_timeout < 0 || u->tcp_fin_timeout > (INT_MAX / HZ)) {
> +	if (u->tcp_timeout < 0 ||
> +	    u->tcp_timeout > IP_VS_TIMEOUT_MAX_SECS ||
> +	    u->tcp_fin_timeout < 0 ||
> +	    u->tcp_fin_timeout > IP_VS_TIMEOUT_MAX_SECS) {
>  		return -EINVAL;
>  	}
>  #endif
>  
>  #ifdef CONFIG_IP_VS_PROTO_UDP
> -	if (u->udp_timeout < 0 || u->udp_timeout > (INT_MAX / HZ))
> +	if (u->udp_timeout < 0 || u->udp_timeout > IP_VS_TIMEOUT_MAX_SECS)
>  		return -EINVAL;
>  #endif
>  
>  #ifdef CONFIG_IP_VS_PROTO_TCP
>  	if (u->tcp_timeout) {
>  		pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
> -		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED]
> -			= u->tcp_timeout * HZ;
> +		pd->timeout_table[IP_VS_TCP_S_ESTABLISHED] =
> +			ip_vs_timeout_ticks(u->tcp_timeout);
>  	}
>  
>  	if (u->tcp_fin_timeout) {
>  		pd = ip_vs_proto_data_get(ipvs, IPPROTO_TCP);
> -		pd->timeout_table[IP_VS_TCP_S_FIN_WAIT]
> -			= u->tcp_fin_timeout * HZ;
> +		pd->timeout_table[IP_VS_TCP_S_FIN_WAIT] =
> +			ip_vs_timeout_ticks(u->tcp_fin_timeout);
>  	}
>  #endif
>  
>  #ifdef CONFIG_IP_VS_PROTO_UDP
>  	if (u->udp_timeout) {
>  		pd = ip_vs_proto_data_get(ipvs, IPPROTO_UDP);
> -		pd->timeout_table[IP_VS_UDP_S_NORMAL]
> -			= u->udp_timeout * HZ;
> +		pd->timeout_table[IP_VS_UDP_S_NORMAL] =
> +			ip_vs_timeout_ticks(u->udp_timeout);
>  	}
>  #endif
>  	return 0;
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index 0046aed1fb38..3796cd93c028 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -185,8 +185,8 @@ void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags)
>  }
>  
>  
> -int *
> -ip_vs_create_timeout_table(int *table, int size)
> +unsigned long *
> +ip_vs_create_timeout_table(const unsigned long *table, size_t size)
>  {
>  	return kmemdup(table, size, GFP_KERNEL);
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index cb34bcceb4f6..abb256b92e5d 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -334,7 +334,7 @@ static const __u8 sctp_states
>  #define IP_VS_SCTP_MAX_RTO	((60 + 1) * HZ)
>  
>  /* Timeout table[state] */
> -static const int sctp_timeouts[IP_VS_SCTP_S_LAST + 1] = {
> +static const unsigned long sctp_timeouts[IP_VS_SCTP_S_LAST + 1] = {
>  	[IP_VS_SCTP_S_NONE]			= 2 * HZ,
>  	[IP_VS_SCTP_S_INIT1]			= (0 + 3 + 1) * HZ,
>  	[IP_VS_SCTP_S_INIT]			= IP_VS_SCTP_MAX_RTO,
> @@ -559,8 +559,8 @@ static int sctp_app_conn_bind(struct ip_vs_conn *cp)
>  static int __ip_vs_sctp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
>  {
>  	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
> -	pd->timeout_table = ip_vs_create_timeout_table((int *)sctp_timeouts,
> -							sizeof(sctp_timeouts));
> +	pd->timeout_table =
> +		ip_vs_create_timeout_table(sctp_timeouts, sizeof(sctp_timeouts));
>  	if (!pd->timeout_table)
>  		return -ENOMEM;
>  	return 0;
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index 25d4576d0e12..2511c78a7780 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -333,7 +333,7 @@ static const int tcp_state_off[IP_VS_DIR_LAST] = {
>  /*
>   *	Timeout table[state]
>   */
> -static const int tcp_timeouts[IP_VS_TCP_S_LAST+1] = {
> +static const unsigned long tcp_timeouts[IP_VS_TCP_S_LAST + 1] = {
>  	[IP_VS_TCP_S_NONE]		=	2*HZ,
>  	[IP_VS_TCP_S_ESTABLISHED]	=	15*60*HZ,
>  	[IP_VS_TCP_S_SYN_SENT]		=	2*60*HZ,
> @@ -672,8 +672,8 @@ void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp)
>  static int __ip_vs_tcp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
>  {
>  	ip_vs_init_hash_table(ipvs->tcp_apps, TCP_APP_TAB_SIZE);
> -	pd->timeout_table = ip_vs_create_timeout_table((int *)tcp_timeouts,
> -							sizeof(tcp_timeouts));
> +	pd->timeout_table =
> +		ip_vs_create_timeout_table(tcp_timeouts, sizeof(tcp_timeouts));
>  	if (!pd->timeout_table)
>  		return -ENOMEM;
>  	pd->tcp_state_table = tcp_states;
> diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
> index ab3ab9524168..3d0d8dac1da2 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_udp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
> @@ -402,7 +402,7 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
>  }
>  
>  
> -static const int udp_timeouts[IP_VS_UDP_S_LAST+1] = {
> +static const unsigned long udp_timeouts[IP_VS_UDP_S_LAST + 1] = {
>  	[IP_VS_UDP_S_NORMAL]		=	5*60*HZ,
>  	[IP_VS_UDP_S_LAST]		=	2*HZ,
>  };
> @@ -438,8 +438,8 @@ udp_state_transition(struct ip_vs_conn *cp, int direction,
>  static int __udp_init(struct netns_ipvs *ipvs, struct ip_vs_proto_data *pd)
>  {
>  	ip_vs_init_hash_table(ipvs->udp_apps, UDP_APP_TAB_SIZE);
> -	pd->timeout_table = ip_vs_create_timeout_table((int *)udp_timeouts,
> -							sizeof(udp_timeouts));
> +	pd->timeout_table =
> +		ip_vs_create_timeout_table(udp_timeouts, sizeof(udp_timeouts));
>  	if (!pd->timeout_table)
>  		return -ENOMEM;
>  	return 0;
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 7e562e745ab5..cfac362a0e8a 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -864,7 +864,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
>  			    unsigned int flags, unsigned int state,
>  			    unsigned int protocol, unsigned int type,
>  			    const union nf_inet_addr *daddr, __be16 dport,
> -			    unsigned long timeout, __u32 fwmark,
> +			    unsigned int timeout, __u32 fwmark,
>  			    struct ip_vs_sync_conn_options *opt)
>  {
>  	struct ip_vs_conn *cp_new = NULL;
> @@ -975,9 +975,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
>  	 *  - No problem.
>  	 */
>  	if (timeout) {
> -		if (timeout > MAX_SCHEDULE_TIMEOUT / HZ)
> -			timeout = MAX_SCHEDULE_TIMEOUT / HZ;
> -		cp->timeout = timeout*HZ;
> +		cp->timeout = ip_vs_timeout_ticks(timeout);
>  	} else {
>  		struct ip_vs_proto_data *pd;
>  
> 
> base-commit: 5367e14e92bbb0779612d36cce7c6e95d3bc5e68
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

