From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: handle connections started by real-servers
Date: Sat, 9 Apr 2016 13:13:02 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604091310420.2087@ja.home.ssi.bg>
References: <5703e735.EsjlanP0p7ANNSWm%marcoangaroni@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-747802322-1460196785=:2087"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <5703e735.EsjlanP0p7ANNSWm%marcoangaroni@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-747802322-1460196785=:2087
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Tue, 5 Apr 2016, Marco Angaroni wrote:

> When using LVS-NAT and SIP persistence-egine over UDP, the following
> limitations are present with current implementation:
> 
>   1) To actually have load-balancing based on Call-ID header, you need to
>      use one-packet-scheduling mode. But with one-packet-scheduling the
>      connection is deleted just after packet is forwarded, so SIP responses
>      coming from real-servers do not match any connection and SNAT is
>      not applied.
> 
>   2) If you do not use "-o" option, IPVS behaves as normal UDP load
>      balancer, so different SIP calls (each one identified by a different
>      Call-ID) coming from the same ip-address/port go to the same
>      real-server. So basically you don’t have load-balancing based on
>      Call-ID as intended.
> 
>   3) Call-ID is not learned when a new SIP call is started by a real-server
>      (inside-to-outside direction), but only in the outside-to-inside
>      direction. This would be a general problem for all SIP servers acting
>      as Back2BackUserAgent.
> 
> This patch aims to solve problems 1) and 3) while keeping OPS mode
> mandatory for SIP-UDP, so that 2) is not a problem anymore.
> 
> The basic mechanism implemented is to make packets, that do not match any
> existent connection but come from real-servers, create new connections
> instead of let them pass without any effect.
> When such packets pass through ip_vs_out(), if their source ip address and
> source port match a configured real-server, a new connection is
> automatically created in the same way as it would have happened if the
> packet had come from outside-to-inside direction. A new connection template
> is created too if the virtual-service is persistent and there is no
> matching connection template found. The new connection automatically
> created, if the service had "-o" option, is an OPS connection that lasts
> only the time to forward the packet, just like it happens on the
> ingress side.
> 
> The main part of this mechanism is implemented inside a persistent-engine
> specific callback (at the moment only SIP persistent engine exists) and
> is triggered only for UDP packets, since connection oriented protocols, by
> using different set of ports (typically ephemeral ports) to open new
> outgoing connections, should not need this feature.
> 
> The following requisites are needed for automatic connection creation; if
> any is missing the packet simply goes the same way as before.
> a) virtual-service is not fwmark based (this is because fwmark services
>    do not store address and port of the virtual-service, required to
>    build the connection data).
> b) virtual-service and real-servers must not have been configured with
>    omitted port (this is again to have all data to create the connection).
> 
> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>

	Nice addition, thanks! Simon, please apply.

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  include/net/ip_vs.h               |  17 +++++
>  net/netfilter/ipvs/ip_vs_core.c   | 154 ++++++++++++++++++++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_ctl.c    |  46 +++++++++++-
>  net/netfilter/ipvs/ip_vs_pe_sip.c |  15 ++++
>  4 files changed, 231 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 0816c87..7eff508 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -731,6 +731,12 @@ struct ip_vs_pe {
>  	u32 (*hashkey_raw)(const struct ip_vs_conn_param *p, u32 initval,
>  			   bool inverse);
>  	int (*show_pe_data)(const struct ip_vs_conn *cp, char *buf);
> +	/* create connections for real-server outgoing packets */
> +	struct ip_vs_conn* (*conn_out)(struct ip_vs_service *svc,
> +				       struct ip_vs_dest *dest,
> +				       struct sk_buff *skb,
> +				       const struct ip_vs_iphdr *iph,
> +				       __be16 dport, __be16 cport);
>  };
>  
>  /* The application module object (a.k.a. app incarnation) */
> @@ -874,6 +880,7 @@ struct netns_ipvs {
>  	/* Service counters */
>  	atomic_t		ftpsvc_counter;
>  	atomic_t		nullsvc_counter;
> +	atomic_t		conn_out_counter;
>  
>  #ifdef CONFIG_SYSCTL
>  	/* 1/rate drop and drop-entry variables */
> @@ -1147,6 +1154,12 @@ static inline int sysctl_cache_bypass(struct netns_ipvs *ipvs)
>   */
>  const char *ip_vs_proto_name(unsigned int proto);
>  void ip_vs_init_hash_table(struct list_head *table, int rows);
> +struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
> +				      struct ip_vs_dest *dest,
> +				      struct sk_buff *skb,
> +				      const struct ip_vs_iphdr *iph,
> +				      __be16 dport,
> +				      __be16 cport);
>  #define IP_VS_INIT_HASH_TABLE(t) ip_vs_init_hash_table((t), ARRAY_SIZE((t)))
>  
>  #define IP_VS_APP_TYPE_FTP	1
> @@ -1378,6 +1391,10 @@ ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol
>  bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
>  			    const union nf_inet_addr *daddr, __be16 dport);
>  
> +struct ip_vs_dest *
> +ip_vs_find_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
> +			const union nf_inet_addr *daddr, __be16 dport);
> +
>  int ip_vs_use_count_inc(void);
>  void ip_vs_use_count_dec(void);
>  int ip_vs_register_nl_ioctl(void);
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index f57b4dc..398ccb5 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -68,6 +68,7 @@ EXPORT_SYMBOL(ip_vs_conn_put);
>  #ifdef CONFIG_IP_VS_DEBUG
>  EXPORT_SYMBOL(ip_vs_get_debug_level);
>  #endif
> +EXPORT_SYMBOL(ip_vs_new_conn_out);
>  
>  static int ip_vs_net_id __read_mostly;
>  /* netns cnt used for uniqueness */
> @@ -1099,6 +1100,143 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
>  	}
>  }
>  
> +/* Generic function to create new connections for outgoing RS packets
> + *
> + * Pre-requisites for successful connection creation:
> + * 1) Virtual Service is NOT fwmark based:
> + *    In fwmark-VS actual vaddr and vport are unknown to IPVS
> + * 2) Real Server and Virtual Service were NOT configured without port:
> + *    This is to allow match of different VS to the same RS ip-addr
> + */
> +struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
> +				      struct ip_vs_dest *dest,
> +				      struct sk_buff *skb,
> +				      const struct ip_vs_iphdr *iph,
> +				      __be16 dport,
> +				      __be16 cport)
> +{
> +	struct ip_vs_conn_param param;
> +	struct ip_vs_conn *ct = NULL, *cp = NULL;
> +	const union nf_inet_addr *vaddr, *daddr, *caddr;
> +	union nf_inet_addr snet;
> +	__be16 vport;
> +	unsigned int flags;
> +
> +	EnterFunction(12);
> +	vaddr = &svc->addr;
> +	vport = svc->port;
> +	daddr = &iph->saddr;
> +	caddr = &iph->daddr;
> +
> +	/* check pre-requisites are satisfied */
> +	if (svc->fwmark)
> +		return NULL;
> +	if (!vport || !dport)
> +		return NULL;
> +
> +	/* for persistent service first create connection template */
> +	if (svc->flags & IP_VS_SVC_F_PERSISTENT) {
> +		/* apply netmask the same way ingress-side does */
> +#ifdef CONFIG_IP_VS_IPV6
> +		if (svc->af == AF_INET6)
> +			ipv6_addr_prefix(&snet.in6, &caddr->in6,
> +					 (__force __u32)svc->netmask);
> +		else
> +#endif
> +			snet.ip = caddr->ip & svc->netmask;
> +		/* fill params and create template if not existent */
> +		if (ip_vs_conn_fill_param_persist(svc, skb, iph->protocol,
> +						  &snet, 0, vaddr,
> +						  vport, &param) < 0)
> +			return NULL;
> +		ct = ip_vs_ct_in_get(&param);
> +		if (!ct) {
> +			ct = ip_vs_conn_new(&param, dest->af, daddr, dport,
> +					    IP_VS_CONN_F_TEMPLATE, dest, 0);
> +			if (!ct) {
> +				kfree(param.pe_data);
> +				return NULL;
> +			}
> +			ct->timeout = svc->timeout;
> +		} else {
> +			kfree(param.pe_data);
> +		}
> +	}
> +
> +	/* connection flags */
> +	flags = ((svc->flags & IP_VS_SVC_F_ONEPACKET) &&
> +		 iph->protocol == IPPROTO_UDP) ? IP_VS_CONN_F_ONE_PACKET : 0;
> +	/* create connection */
> +	ip_vs_conn_fill_param(svc->ipvs, svc->af, iph->protocol,
> +			      caddr, cport, vaddr, vport, &param);
> +	cp = ip_vs_conn_new(&param, dest->af, daddr, dport, flags, dest, 0);
> +	if (!cp) {
> +		if (ct)
> +			ip_vs_conn_put(ct);
> +		return NULL;
> +	}
> +	if (ct) {
> +		ip_vs_control_add(cp, ct);
> +		ip_vs_conn_put(ct);
> +	}
> +	ip_vs_conn_stats(cp, svc);
> +
> +	/* return connection (will be used to handle outgoing packet) */
> +	IP_VS_DBG_BUF(6, "New connection RS-initiated:%c c:%s:%u v:%s:%u "
> +		      "d:%s:%u conn->flags:%X conn->refcnt:%d\n",
> +		      ip_vs_fwd_tag(cp),
> +		      IP_VS_DBG_ADDR(cp->af, &cp->caddr), ntohs(cp->cport),
> +		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
> +		      IP_VS_DBG_ADDR(cp->af, &cp->daddr), ntohs(cp->dport),
> +		      cp->flags, atomic_read(&cp->refcnt));
> +	LeaveFunction(12);
> +	return cp;
> +}
> +
> +/* Handle outgoing packets which are considered requests initiated by
> + * real servers, so that subsequent responses from external client can be
> + * routed to the right real server.
> + * Used also for outgoing responses in OPS mode.
> + *
> + * Connection management is handled by persistent-engine specific callback.
> + */
> +static struct ip_vs_conn *__ip_vs_rs_conn_out(unsigned int hooknum,
> +					      struct netns_ipvs *ipvs,
> +					      int af, struct sk_buff *skb,
> +					      const struct ip_vs_iphdr *iph)
> +{
> +	struct ip_vs_dest *dest;
> +	struct ip_vs_conn *cp = NULL;
> +	__be16 _ports[2], *pptr;
> +
> +	if (hooknum == NF_INET_LOCAL_IN)
> +		return NULL;
> +
> +	pptr = frag_safe_skb_hp(skb, iph->len,
> +				sizeof(_ports), _ports, iph);
> +	if (!pptr)
> +		return NULL;
> +
> +	rcu_read_lock();
> +	dest = ip_vs_find_real_service(ipvs, af, iph->protocol,
> +				       &iph->saddr, pptr[0]);
> +	if (dest) {
> +		struct ip_vs_service *svc;
> +		struct ip_vs_pe *pe;
> +
> +		svc = rcu_dereference(dest->svc);
> +		if (svc) {
> +			pe = rcu_dereference(svc->pe);
> +			if (pe && pe->conn_out)
> +				cp = pe->conn_out(svc, dest, skb, iph,
> +						  pptr[0], pptr[1]);
> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	return cp;
> +}
> +
>  /* Handle response packets: rewrite addresses and send away...
>   */
>  static unsigned int
> @@ -1244,6 +1382,22 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>  
>  	if (likely(cp))
>  		return handle_response(af, skb, pd, cp, &iph, hooknum);
> +
> +	/* Check for real-server-started requests */
> +	if (atomic_read(&ipvs->conn_out_counter)) {
> +		/* Currently only for UDP:
> +		 * connection oriented protocols typically use
> +		 * ephemeral ports for outgoing connections, so
> +		 * related incoming responses would not match any VS
> +		 */
> +		if (pp->protocol == IPPROTO_UDP) {
> +			cp = __ip_vs_rs_conn_out(hooknum, ipvs, af, skb, &iph);
> +			if (likely(cp))
> +				return handle_response(af, skb, pd, cp, &iph,
> +						       hooknum);
> +		}
> +	}
> +
>  	if (sysctl_nat_icmp_send(ipvs) &&
>  	    (pp->protocol == IPPROTO_TCP ||
>  	     pp->protocol == IPPROTO_UDP ||
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index e7c1b05..fcb2681 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -567,6 +567,36 @@ bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
>  	return false;
>  }
>  
> +/* Find real service record by <proto,addr,port>.
> + * In case of multiple records with the same <proto,addr,port>, only
> + * the first found record is returned.
> + *
> + * To be called under RCU lock.
> + */
> +struct ip_vs_dest *ip_vs_find_real_service(struct netns_ipvs *ipvs, int af,
> +					   __u16 protocol,
> +					   const union nf_inet_addr *daddr,
> +					   __be16 dport)
> +{
> +	unsigned int hash;
> +	struct ip_vs_dest *dest;
> +
> +	/* Check for "full" addressed entries */
> +	hash = ip_vs_rs_hashkey(af, daddr, dport);
> +
> +	hlist_for_each_entry_rcu(dest, &ipvs->rs_table[hash], d_list) {
> +		if (dest->port == dport &&
> +		    dest->af == af &&
> +		    ip_vs_addr_equal(af, &dest->addr, daddr) &&
> +			(dest->protocol == protocol || dest->vfwmark)) {
> +			/* HIT */
> +			return dest;
> +		}
> +	}
> +
> +	return NULL;
> +}
> +
>  /* Lookup destination by {addr,port} in the given service
>   * Called under RCU lock.
>   */
> @@ -1253,6 +1283,8 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
>  		atomic_inc(&ipvs->ftpsvc_counter);
>  	else if (svc->port == 0)
>  		atomic_inc(&ipvs->nullsvc_counter);
> +	if (svc->pe && svc->pe->conn_out)
> +		atomic_inc(&ipvs->conn_out_counter);
>  
>  	ip_vs_start_estimator(ipvs, &svc->stats);
>  
> @@ -1293,6 +1325,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
>  	struct ip_vs_scheduler *sched = NULL, *old_sched;
>  	struct ip_vs_pe *pe = NULL, *old_pe = NULL;
>  	int ret = 0;
> +	bool new_pe_conn_out, old_pe_conn_out;
>  
>  	/*
>  	 * Lookup the scheduler, by 'u->sched_name'
> @@ -1355,8 +1388,16 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
>  	svc->netmask = u->netmask;
>  
>  	old_pe = rcu_dereference_protected(svc->pe, 1);
> -	if (pe != old_pe)
> +	if (pe != old_pe) {
>  		rcu_assign_pointer(svc->pe, pe);
> +		/* check for optional methods in new pe */
> +		new_pe_conn_out = (pe && pe->conn_out) ? true : false;
> +		old_pe_conn_out = (old_pe && old_pe->conn_out) ? true : false;
> +		if (new_pe_conn_out && !old_pe_conn_out)
> +			atomic_inc(&svc->ipvs->conn_out_counter);
> +		if (old_pe_conn_out && !new_pe_conn_out)
> +			atomic_dec(&svc->ipvs->conn_out_counter);
> +	}
>  
>  out:
>  	ip_vs_scheduler_put(old_sched);
> @@ -1391,6 +1432,8 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
>  
>  	/* Unbind persistence engine, keep svc->pe */
>  	old_pe = rcu_dereference_protected(svc->pe, 1);
> +	if (old_pe && old_pe->conn_out)
> +		atomic_dec(&ipvs->conn_out_counter);
>  	ip_vs_pe_put(old_pe);
>  
>  	/*
> @@ -3960,6 +4003,7 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
>  		    (unsigned long) ipvs);
>  	atomic_set(&ipvs->ftpsvc_counter, 0);
>  	atomic_set(&ipvs->nullsvc_counter, 0);
> +	atomic_set(&ipvs->conn_out_counter, 0);
>  
>  	/* procfs stats */
>  	ipvs->tot_stats.cpustats = alloc_percpu(struct ip_vs_cpu_stats);
> diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
> index b3e0e5b..dff3a3e 100644
> --- a/net/netfilter/ipvs/ip_vs_pe_sip.c
> +++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
> @@ -143,6 +143,20 @@ static int ip_vs_sip_show_pe_data(const struct ip_vs_conn *cp, char *buf)
>  	return cp->pe_data_len;
>  }
>  
> +static struct ip_vs_conn *
> +ip_vs_sip_conn_out(struct ip_vs_service *svc,
> +		   struct ip_vs_dest *dest,
> +		   struct sk_buff *skb,
> +		   const struct ip_vs_iphdr *iph,
> +		   __be16 dport,
> +		   __be16 cport)
> +{
> +	if (likely(iph->protocol == IPPROTO_UDP))
> +		return ip_vs_new_conn_out(svc, dest, skb, iph, dport, cport);
> +	/* currently no need to handle other than UDP */
> +	return NULL;
> +}
> +
>  static struct ip_vs_pe ip_vs_sip_pe =
>  {
>  	.name =			"sip",
> @@ -153,6 +167,7 @@ static struct ip_vs_pe ip_vs_sip_pe =
>  	.ct_match =		ip_vs_sip_ct_match,
>  	.hashkey_raw =		ip_vs_sip_hashkey_raw,
>  	.show_pe_data =		ip_vs_sip_show_pe_data,
> +	.conn_out =		ip_vs_sip_conn_out,
>  };
>  
>  static int __init ip_vs_sip_init(void)
> -- 
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-747802322-1460196785=:2087--
