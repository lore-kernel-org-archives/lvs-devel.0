From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] ipvs: Keep track of backlog connections
Date: Wed, 1 Sep 2010 11:32:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009011113560.5403@u.domain.uli>
References: <alpine.LNX.2.00.1008311411190.5292@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1008311411190.5292@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Tue, 31 Aug 2010, Sven Wegener wrote:

> Hi all,
> 
> this patch has been sitting in my local repository for quite some time 
> now. The number of backlog connections helps diagnosing realserver related 
> overload and configuration problems. Is it worth merging? If yes, I'm 
> going to tidy it up and prepare the userspace portion for ipvsadm.
> 
> Sven
> 
> 
> From: Sven Wegener <sven.wegener@stealer.net>
> Subject: [PATCH] ipvs: Keep track of backlog connections
> 
> A backlog connection is a connection that is on its way from inactive to
> active. Speaking in TCP language, a connection from which we've seen the
> initial SYN packet, but the three-way handshake hasn't finished yet.
> These connections are expected to move to active soon. When a
> destination is overloaded or isn't able to successfully establish
> connections for various reasons, this count increases quickly and is an
> indication for a problem.

	Looks good but should not be applied now because
we should first put some changes for cp->flags, we are
reaching the limit of 16 bits for cp->flags. Your
intention is IP_VS_CONN_F_BACKLOG not to be sync-ed and
I agree. So, your patch will be applied after other
changes. I think, Simon will fix it later.

> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> ---
>  include/linux/ip_vs.h                |    3 +++
>  include/net/ip_vs.h                  |    1 +
>  net/netfilter/ipvs/ip_vs_conn.c      |    3 +++
>  net/netfilter/ipvs/ip_vs_ctl.c       |    3 +++
>  net/netfilter/ipvs/ip_vs_proto_tcp.c |   10 ++++++++++
>  net/netfilter/ipvs/ip_vs_sync.c      |    4 ++--
>  6 files changed, 22 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
> index 9708de2..4fe6565 100644
> --- a/include/linux/ip_vs.h
> +++ b/include/linux/ip_vs.h
> @@ -87,6 +87,7 @@
>  #define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
>  #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
>  #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
> +#define IP_VS_CONN_F_BACKLOG	0x4000		/* backlog connection */
>  
>  #define IP_VS_SCHEDNAME_MAXLEN	16
>  #define IP_VS_IFNAME_MAXLEN	16
> @@ -350,6 +351,8 @@ enum {
>  	IPVS_DEST_ATTR_PERSIST_CONNS,	/* persistent connections */
>  
>  	IPVS_DEST_ATTR_STATS,		/* nested attribute for dest stats */
> +
> +	IPVS_DEST_ATTR_BACKLOG_CONNS,	/* backlog connections */
>  	__IPVS_DEST_ATTR_MAX,
>  };
>  
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index a4747a0..c39dee6 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -499,6 +499,7 @@ struct ip_vs_dest {
>  	/* connection counters and thresholds */
>  	atomic_t		activeconns;	/* active connections */
>  	atomic_t		inactconns;	/* inactive connections */
> +	atomic_t		backlogconns;	/* backlog connections */
>  	atomic_t		persistconns;	/* persistent connections */
>  	__u32			u_threshold;	/* upper threshold */
>  	__u32			l_threshold;	/* lower threshold */
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index b71c69a..486dd48 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -607,6 +607,9 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
>  		} else {
>  			atomic_dec(&dest->activeconns);
>  		}
> +
> +		if (cp->flags & IP_VS_CONN_F_BACKLOG)
> +			atomic_dec(&dest->backlogconns);
>  	} else {
>  		/* It is a persistent connection/template, so decrease
>  		   the peristent connection counter */
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 0f0c079..1933e60 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2579,6 +2579,7 @@ static const struct nla_policy ip_vs_dest_policy[IPVS_DEST_ATTR_MAX + 1] = {
>  	[IPVS_DEST_ATTR_INACT_CONNS]	= { .type = NLA_U32 },
>  	[IPVS_DEST_ATTR_PERSIST_CONNS]	= { .type = NLA_U32 },
>  	[IPVS_DEST_ATTR_STATS]		= { .type = NLA_NESTED },
> +	[IPVS_DEST_ATTR_BACKLOG_CONNS]	= { .type = NLA_U32 },
>  };
>  
>  static int ip_vs_genl_fill_stats(struct sk_buff *skb, int container_type,
> @@ -2826,6 +2827,8 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
>  		    atomic_read(&dest->activeconns));
>  	NLA_PUT_U32(skb, IPVS_DEST_ATTR_INACT_CONNS,
>  		    atomic_read(&dest->inactconns));
> +	NLA_PUT_U32(skb, IPVS_DEST_ATTR_BACKLOG_CONNS,
> +		    atomic_read(&dest->backlogconns));
>  	NLA_PUT_U32(skb, IPVS_DEST_ATTR_PERSIST_CONNS,
>  		    atomic_read(&dest->persistconns));
>  
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index 282d24d..c92cbab 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -510,6 +510,16 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
>  				atomic_dec(&dest->inactconns);
>  				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
>  			}
> +
> +			if (new_state == IP_VS_TCP_S_SYN_RECV &&
> +					!(cp->flags & IP_VS_CONN_F_BACKLOG)) {
> +				atomic_inc(&dest->backlogconns);
> +				cp->flags |= IP_VS_CONN_F_BACKLOG;
> +			} else if (new_state == IP_VS_TCP_S_ESTABLISHED &&
> +					cp->flags & IP_VS_CONN_F_BACKLOG) {
> +				atomic_dec(&dest->backlogconns);
> +				cp->flags &= ~IP_VS_CONN_F_BACKLOG;
> +			}
>  		}
>  	}
>  
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 7ba0693..ceb1cd9 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -264,7 +264,7 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
>  	s->caddr = cp->caddr.ip;
>  	s->vaddr = cp->vaddr.ip;
>  	s->daddr = cp->daddr.ip;
> -	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
> +	s->flags = htons(cp->flags & ~(IP_VS_CONN_F_HASHED | IP_VS_CONN_F_BACKLOG));
>  	s->state = htons(cp->state);
>  	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
>  		struct ip_vs_sync_conn_options *opt =
> @@ -334,7 +334,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
>  		}
>  		s = (struct ip_vs_sync_conn *) p;
>  		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
> -		flags &= ~IP_VS_CONN_F_HASHED;
> +		flags &= ~(IP_VS_CONN_F_HASHED | IP_VS_CONN_F_BACKLOG);
>  		if (flags & IP_VS_CONN_F_SEQ_MASK) {
>  			opt = (struct ip_vs_sync_conn_options *)&s[1];
>  			p += FULL_CONN_SIZE;

Regards

--
Julian Anastasov <ja@ssi.bg>
