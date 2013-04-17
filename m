From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: fix sparse warnings reported by kbuild
 test robot
Date: Wed, 17 Apr 2013 11:02:47 +0900
Message-ID: <20130417020247.GE16092@verge.net.au>
References: <1366140914-1781-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366140914-1781-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Tue, Apr 16, 2013 at 10:35:14PM +0300, Julian Anastasov wrote:
> 	Some are from recent commits. Add comments
> that we provide both netmask and prefix len in svc
> netmask.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	May be Pablo will prefer to take it directly to
> save time.

Thanks for the fixes.
I will send a pull request to Pablo shortly.

> 
>  include/net/ip_vs.h              |    8 +++---
>  include/uapi/linux/ip_vs.h       |    4 +-
>  net/netfilter/ipvs/ip_vs_conn.c  |   14 ++++-----
>  net/netfilter/ipvs/ip_vs_core.c  |    3 +-
>  net/netfilter/ipvs/ip_vs_ctl.c   |   55 +++++++++++++++++++++++--------------
>  net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
>  net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
>  net/netfilter/ipvs/ip_vs_sync.c  |    4 +-
>  8 files changed, 52 insertions(+), 40 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index f9f5b05..4c062cc 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -678,7 +678,7 @@ struct ip_vs_service_user_kern {
>  	u16			af;
>  	u16			protocol;
>  	union nf_inet_addr	addr;		/* virtual ip address */
> -	u16			port;
> +	__be16			port;
>  	u32			fwmark;		/* firwall mark of service */
>  
>  	/* virtual service options */
> @@ -686,14 +686,14 @@ struct ip_vs_service_user_kern {
>  	char			*pe_name;
>  	unsigned int		flags;		/* virtual service flags */
>  	unsigned int		timeout;	/* persistent timeout in sec */
> -	u32			netmask;	/* persistent netmask */
> +	__be32			netmask;	/* persistent netmask or plen */
>  };
>  
>  
>  struct ip_vs_dest_user_kern {
>  	/* destination server address */
>  	union nf_inet_addr	addr;
> -	u16			port;
> +	__be16			port;
>  
>  	/* real server options */
>  	unsigned int		conn_flags;	/* connection flags */
> @@ -721,7 +721,7 @@ struct ip_vs_service {
>  	__u32                   fwmark;   /* firewall mark of the service */
>  	unsigned int		flags;	  /* service status flags */
>  	unsigned int		timeout;  /* persistent timeout in ticks */
> -	__be32			netmask;  /* grouping granularity */
> +	__be32			netmask;  /* grouping granularity, mask/plen */
>  	struct net		*net;
>  
>  	struct list_head	destinations;  /* real server d-linked list */
> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index 8a2d438..a245377 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -280,8 +280,8 @@ struct ip_vs_daemon_user {
>  #define IPVS_GENL_VERSION	0x1
>  
>  struct ip_vs_flags {
> -	__be32 flags;
> -	__be32 mask;
> +	__u32 flags;
> +	__u32 mask;
>  };
>  
>  /* Generic Netlink command attributes */
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index de64758..a083bda 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -966,7 +966,6 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
>  	struct ip_vs_iter_state *iter = seq->private;
>  
>  	for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> -		rcu_read_lock();
>  		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
>  			/* __ip_vs_conn_get() is not needed by
>  			 * ip_vs_conn_seq_show and ip_vs_conn_sync_seq_show
> @@ -977,16 +976,19 @@ static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
>  			}
>  		}
>  		rcu_read_unlock();
> +		rcu_read_lock();
>  	}
>  
>  	return NULL;
>  }
>  
>  static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
> +	__acquires(RCU)
>  {
>  	struct ip_vs_iter_state *iter = seq->private;
>  
>  	iter->l = NULL;
> +	rcu_read_lock();
>  	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;
>  }
>  
> @@ -1006,28 +1008,24 @@ static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  	e = rcu_dereference(hlist_next_rcu(&cp->c_list));
>  	if (e)
>  		return hlist_entry(e, struct ip_vs_conn, c_list);
> -	rcu_read_unlock();
>  
>  	idx = l - ip_vs_conn_tab;
>  	while (++idx < ip_vs_conn_tab_size) {
> -		rcu_read_lock();
>  		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
>  			iter->l = &ip_vs_conn_tab[idx];
>  			return cp;
>  		}
>  		rcu_read_unlock();
> +		rcu_read_lock();
>  	}
>  	iter->l = NULL;
>  	return NULL;
>  }
>  
>  static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
> +	__releases(RCU)
>  {
> -	struct ip_vs_iter_state *iter = seq->private;
> -	struct hlist_head *l = iter->l;
> -
> -	if (l)
> -		rcu_read_unlock();
> +	rcu_read_unlock();
>  }
>  
>  static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index f26fe33..a0d7bd3 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -235,7 +235,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  	/* Mask saddr with the netmask to adjust template granularity */
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (svc->af == AF_INET6)
> -		ipv6_addr_prefix(&snet.in6, &iph->saddr.in6, svc->netmask);
> +		ipv6_addr_prefix(&snet.in6, &iph->saddr.in6,
> +				 (__force __u32) svc->netmask);
>  	else
>  #endif
>  		snet.ip = iph->saddr.ip & svc->netmask;
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 9e4074c..5b142fb 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1164,9 +1164,13 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
>  	}
>  
>  #ifdef CONFIG_IP_VS_IPV6
> -	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
> -		ret = -EINVAL;
> -		goto out_err;
> +	if (u->af == AF_INET6) {
> +		__u32 plen = (__force __u32) u->netmask;
> +
> +		if (plen < 1 || plen > 128) {
> +			ret = -EINVAL;
> +			goto out_err;
> +		}
>  	}
>  #endif
>  
> @@ -1277,9 +1281,13 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
>  	}
>  
>  #ifdef CONFIG_IP_VS_IPV6
> -	if (u->af == AF_INET6 && (u->netmask < 1 || u->netmask > 128)) {
> -		ret = -EINVAL;
> -		goto out;
> +	if (u->af == AF_INET6) {
> +		__u32 plen = (__force __u32) u->netmask;
> +
> +		if (plen < 1 || plen > 128) {
> +			ret = -EINVAL;
> +			goto out;
> +		}
>  	}
>  #endif
>  
> @@ -1460,8 +1468,11 @@ void ip_vs_service_net_cleanup(struct net *net)
>  static inline void
>  ip_vs_forget_dev(struct ip_vs_dest *dest, struct net_device *dev)
>  {
> +	struct ip_vs_dest_dst *dest_dst;
> +
>  	spin_lock_bh(&dest->dst_lock);
> -	if (dest->dest_dst && dest->dest_dst->dst_cache->dev == dev) {
> +	dest_dst = rcu_dereference_protected(dest->dest_dst, 1);
> +	if (dest_dst && dest_dst->dst_cache->dev == dev) {
>  		IP_VS_DBG_BUF(3, "Reset dev:%s dest %s:%u ,dest->refcnt=%d\n",
>  			      dev->name,
>  			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
> @@ -1934,8 +1945,8 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
>  }
>  
>  static void *ip_vs_info_seq_start(struct seq_file *seq, loff_t *pos)
> +	__acquires(RCU)
>  {
> -
>  	rcu_read_lock();
>  	return *pos ? ip_vs_info_array(seq, *pos - 1) : SEQ_START_TOKEN;
>  }
> @@ -1990,6 +2001,7 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  }
>  
>  static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
> +	__releases(RCU)
>  {
>  	rcu_read_unlock();
>  }
> @@ -2134,7 +2146,7 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
>  {
>  	struct net *net = seq_file_single_net(seq);
>  	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
> -	struct ip_vs_cpu_stats *cpustats = tot_stats->cpustats;
> +	struct ip_vs_cpu_stats __percpu *cpustats = tot_stats->cpustats;
>  	struct ip_vs_stats_user rates;
>  	int i;
>  
> @@ -2871,6 +2883,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
>  				   struct ip_vs_service *svc)
>  {
>  	struct ip_vs_scheduler *sched;
> +	struct ip_vs_pe *pe;
>  	struct nlattr *nl_service;
>  	struct ip_vs_flags flags = { .flags = svc->flags,
>  				     .mask = ~0 };
> @@ -2887,17 +2900,17 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
>  	} else {
>  		if (nla_put_u16(skb, IPVS_SVC_ATTR_PROTOCOL, svc->protocol) ||
>  		    nla_put(skb, IPVS_SVC_ATTR_ADDR, sizeof(svc->addr), &svc->addr) ||
> -		    nla_put_u16(skb, IPVS_SVC_ATTR_PORT, svc->port))
> +		    nla_put_be16(skb, IPVS_SVC_ATTR_PORT, svc->port))
>  			goto nla_put_failure;
>  	}
>  
>  	sched = rcu_dereference_protected(svc->scheduler, 1);
> +	pe = rcu_dereference_protected(svc->pe, 1);
>  	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, sched->name) ||
> -	    (svc->pe &&
> -	     nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, svc->pe->name)) ||
> +	    (pe && nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, pe->name)) ||
>  	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
>  	    nla_put_u32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ) ||
> -	    nla_put_u32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask))
> +	    nla_put_be32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask))
>  		goto nla_put_failure;
>  	if (ip_vs_genl_fill_stats(skb, IPVS_SVC_ATTR_STATS, &svc->stats))
>  		goto nla_put_failure;
> @@ -3010,7 +3023,7 @@ static int ip_vs_genl_parse_service(struct net *net,
>  	} else {
>  		usvc->protocol = nla_get_u16(nla_protocol);
>  		nla_memcpy(&usvc->addr, nla_addr, sizeof(usvc->addr));
> -		usvc->port = nla_get_u16(nla_port);
> +		usvc->port = nla_get_be16(nla_port);
>  		usvc->fwmark = 0;
>  	}
>  
> @@ -3050,7 +3063,7 @@ static int ip_vs_genl_parse_service(struct net *net,
>  		usvc->sched_name = nla_data(nla_sched);
>  		usvc->pe_name = nla_pe ? nla_data(nla_pe) : NULL;
>  		usvc->timeout = nla_get_u32(nla_timeout);
> -		usvc->netmask = nla_get_u32(nla_netmask);
> +		usvc->netmask = nla_get_be32(nla_netmask);
>  	}
>  
>  	return 0;
> @@ -3076,7 +3089,7 @@ static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest)
>  		return -EMSGSIZE;
>  
>  	if (nla_put(skb, IPVS_DEST_ATTR_ADDR, sizeof(dest->addr), &dest->addr) ||
> -	    nla_put_u16(skb, IPVS_DEST_ATTR_PORT, dest->port) ||
> +	    nla_put_be16(skb, IPVS_DEST_ATTR_PORT, dest->port) ||
>  	    nla_put_u32(skb, IPVS_DEST_ATTR_FWD_METHOD,
>  			(atomic_read(&dest->conn_flags) &
>  			 IP_VS_CONN_F_FWD_MASK)) ||
> @@ -3185,7 +3198,7 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
>  	memset(udest, 0, sizeof(*udest));
>  
>  	nla_memcpy(&udest->addr, nla_addr, sizeof(udest->addr));
> -	udest->port = nla_get_u16(nla_port);
> +	udest->port = nla_get_be16(nla_port);
>  
>  	/* If a full entry was requested, check for the additional fields */
>  	if (full_entry) {
> @@ -3210,8 +3223,8 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
>  	return 0;
>  }
>  
> -static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __be32 state,
> -				  const char *mcast_ifn, __be32 syncid)
> +static int ip_vs_genl_fill_daemon(struct sk_buff *skb, __u32 state,
> +				  const char *mcast_ifn, __u32 syncid)
>  {
>  	struct nlattr *nl_daemon;
>  
> @@ -3232,8 +3245,8 @@ nla_put_failure:
>  	return -EMSGSIZE;
>  }
>  
> -static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __be32 state,
> -				  const char *mcast_ifn, __be32 syncid,
> +static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __u32 state,
> +				  const char *mcast_ifn, __u32 syncid,
>  				  struct netlink_callback *cb)
>  {
>  	void *hdr;
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index b2cc252..5ea26bd 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -104,7 +104,7 @@ struct ip_vs_lblc_entry {
>   */
>  struct ip_vs_lblc_table {
>  	struct rcu_head		rcu_head;
> -	struct hlist_head __rcu bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
> +	struct hlist_head	bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
>  	struct timer_list       periodic_timer; /* collect stale entries */
>  	atomic_t                entries;        /* number of entries */
>  	int                     max_size;       /* maximum size of entries */
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index feb9656..50123c2 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -284,7 +284,7 @@ struct ip_vs_lblcr_entry {
>   */
>  struct ip_vs_lblcr_table {
>  	struct rcu_head		rcu_head;
> -	struct hlist_head __rcu bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
> +	struct hlist_head	bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
>  	atomic_t                entries;        /* number of entries */
>  	int                     max_size;       /* maximum size of entries */
>  	struct timer_list       periodic_timer; /* collect stale entries */
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 8e57077..ff7f2ad 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1176,7 +1176,7 @@ static void ip_vs_process_message(struct net *net, __u8 *buffer,
>  		return;
>  	}
>  	/* Convert size back to host byte order */
> -	m2->size = ntohs(m2->size);
> +	m2->size = ntohs((__force __be16) m2->size);
>  
>  	if (buflen != m2->size) {
>  		IP_VS_DBG(2, "BACKUP, bogus message size\n");
> @@ -1547,7 +1547,7 @@ ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
>  	msize = msg->size;
>  
>  	/* Put size in network byte order */
> -	msg->size = htons(msg->size);
> +	msg->size = (__force __u16) htons(msg->size);
>  
>  	ret = ip_vs_send_async(sock, (char *)msg, msize);
>  	if (ret >= 0 || ret == -EAGAIN)
> -- 
> 1.7.3.4
> 
