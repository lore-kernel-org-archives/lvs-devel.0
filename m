From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 2/2] IPVS: use pr_err and friends instead of
	IP_VS_ERR and friends
Date: Mon, 3 Aug 2009 10:36:59 +1000
Message-ID: <20090803003658.GQ6177@verge.net.au>
References: <20090802210530.14843.62378.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090802210530.14843.62378.stgit@jazzy.zrh.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hannes Eder <heder@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>, Jan Engelhardt <jengelh@medozas.de>, David Miller <davem@davemloft.net>

On Sun, Aug 02, 2009 at 11:05:41PM +0200, Hannes Eder wrote:
> Since pr_err and friends are used instead of printk there is no point
> in keeping IP_VS_ERR and friends.  Furthermore make use of '__func__'
> instead of hard coded function names.
> 
> Signed-off-by: Hannes Eder <heder@google.com>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
> 
> changes for v4: rebase to next-20090731
> 
> changes for v3:
> 
> On Tue, Jul 28, 2009 at 22:56, Joe Perches<joe@perches.com> wrote:
> > On Tue, 2009-07-28 at 22:35 +0200, Hannes Eder wrote:
> >> Since pr_err and friends is used instead of printk there is not point
> >> in keeping IP_VS_ERR and friends.
> >> +                     pr_err("Schedule: port zero only supported "
> >> +                            "in persistent services, "
> >> +                            "check your ipvs configuration\n");
> >
> > You might consider ignoring the checkpatch 80 char limit here
> > and consolidate the message into a single string.
> >
> > It helps when grepping.
> 
> I did not change this, because obeying the 80 characters limit is IMHO
> a good idea.
> 
> >> @@ -377,8 +377,8 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
> >>  static int ip_vs_svc_unhash(struct ip_vs_service *svc)
> >>  {
> >>       if (!(svc->flags & IP_VS_SVC_F_HASHED)) {
> >> -             IP_VS_ERR("ip_vs_svc_unhash(): request for unhash flagged, "
> >> -                       "called from %p\n", __builtin_return_address(0));
> >> +             pr_err("ip_vs_svc_unhash(): request for unhash flagged, "
> >> +                    "called from %p\n", __builtin_return_address(0));
> >
> > Maybe use something like:
> >        "%s(): <foo> called from %pf",
> >         __func__, __builtin_return_address(0)
> 
> Done.  Although I am using %pF instead of %pf.  First %pf ist not yet
> in 2.6.30.y and might never be and second the offset might actually be
> interesting, as at least one of these functions has multiple call
> sites within one function, did not check the others.
> 
> Cheers,
> Hannes
> 
>  include/net/ip_vs.h                  |    7 +---
>  net/netfilter/ipvs/ip_vs_app.c       |   16 ++++-----
>  net/netfilter/ipvs/ip_vs_conn.c      |   14 ++++----
>  net/netfilter/ipvs/ip_vs_core.c      |   24 +++++++------
>  net/netfilter/ipvs/ip_vs_ctl.c       |   62 ++++++++++++++++------------------
>  net/netfilter/ipvs/ip_vs_dh.c        |    4 +-
>  net/netfilter/ipvs/ip_vs_ftp.c       |    4 +-
>  net/netfilter/ipvs/ip_vs_lblc.c      |    6 ++-
>  net/netfilter/ipvs/ip_vs_lblcr.c     |   14 ++++----
>  net/netfilter/ipvs/ip_vs_lc.c        |    2 +
>  net/netfilter/ipvs/ip_vs_nq.c        |    2 +
>  net/netfilter/ipvs/ip_vs_proto.c     |    2 +
>  net/netfilter/ipvs/ip_vs_proto_tcp.c |    2 +
>  net/netfilter/ipvs/ip_vs_proto_udp.c |    2 +
>  net/netfilter/ipvs/ip_vs_rr.c        |    2 +
>  net/netfilter/ipvs/ip_vs_sched.c     |   38 ++++++++++-----------
>  net/netfilter/ipvs/ip_vs_sed.c       |    2 +
>  net/netfilter/ipvs/ip_vs_sh.c        |    2 +
>  net/netfilter/ipvs/ip_vs_sync.c      |   50 ++++++++++++++-------------
>  net/netfilter/ipvs/ip_vs_wrr.c       |    4 +-
>  net/netfilter/ipvs/ip_vs_xmit.c      |   40 +++++++++++-----------
>  21 files changed, 147 insertions(+), 152 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9108203..1c8ee1b 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -150,13 +150,10 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
>  #endif
>  
>  #define IP_VS_BUG() BUG()
> -#define IP_VS_ERR(msg...) pr_err(msg)
> -#define IP_VS_INFO(msg...) pr_info(msg)
> -#define IP_VS_WARNING(msg...) pr_warning(msg)
> -#define IP_VS_ERR_RL(msg...)						\
> +#define IP_VS_ERR_RL(msg, ...)						\
>  	do {								\
>  		if (net_ratelimit())					\
> -			pr_err(msg);					\
> +			pr_err(msg, ##__VA_ARGS__);			\
>  	} while (0)
>  
>  #ifdef CONFIG_IP_VS_DEBUG
> diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
> index c1781f8..3c7e427 100644
> --- a/net/netfilter/ipvs/ip_vs_app.c
> +++ b/net/netfilter/ipvs/ip_vs_app.c
> @@ -265,12 +265,12 @@ static inline void vs_fix_seq(const struct ip_vs_seq *vseq, struct tcphdr *th)
>  	if (vseq->delta || vseq->previous_delta) {
>  		if(after(seq, vseq->init_seq)) {
>  			th->seq = htonl(seq + vseq->delta);
> -			IP_VS_DBG(9, "vs_fix_seq(): added delta (%d) to seq\n",
> -				  vseq->delta);
> +			IP_VS_DBG(9, "%s(): added delta (%d) to seq\n",
> +				  __func__, vseq->delta);
>  		} else {
>  			th->seq = htonl(seq + vseq->previous_delta);
> -			IP_VS_DBG(9, "vs_fix_seq(): added previous_delta "
> -				  "(%d) to seq\n", vseq->previous_delta);
> +			IP_VS_DBG(9, "%s(): added previous_delta (%d) to seq\n",
> +				  __func__, vseq->previous_delta);
>  		}
>  	}
>  }
> @@ -294,14 +294,14 @@ vs_fix_ack_seq(const struct ip_vs_seq *vseq, struct tcphdr *th)
>  		   to receive next, so compare it with init_seq+delta */
>  		if(after(ack_seq, vseq->init_seq+vseq->delta)) {
>  			th->ack_seq = htonl(ack_seq - vseq->delta);
> -			IP_VS_DBG(9, "vs_fix_ack_seq(): subtracted delta "
> -				  "(%d) from ack_seq\n", vseq->delta);
> +			IP_VS_DBG(9, "%s(): subtracted delta "
> +				  "(%d) from ack_seq\n", __func__, vseq->delta);
>  
>  		} else {
>  			th->ack_seq = htonl(ack_seq - vseq->previous_delta);
> -			IP_VS_DBG(9, "vs_fix_ack_seq(): subtracted "
> +			IP_VS_DBG(9, "%s(): subtracted "
>  				  "previous_delta (%d) from ack_seq\n",
> -				  vseq->previous_delta);
> +				  __func__, vseq->previous_delta);
>  		}
>  	}
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 4173d7b..27c30cf 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -153,8 +153,8 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
>  		atomic_inc(&cp->refcnt);
>  		ret = 1;
>  	} else {
> -		IP_VS_ERR("ip_vs_conn_hash(): request for already hashed, "
> -			  "called from %p\n", __builtin_return_address(0));
> +		pr_err("%s(): request for already hashed, called from %pF\n",
> +		       __func__, __builtin_return_address(0));
>  		ret = 0;
>  	}
>  
> @@ -692,7 +692,7 @@ ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
>  
>  	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
>  	if (cp == NULL) {
> -		IP_VS_ERR_RL("ip_vs_conn_new: no memory available.\n");
> +		IP_VS_ERR_RL("%s(): no memory\n", __func__);
>  		return NULL;
>  	}
>  
> @@ -1076,10 +1076,10 @@ int __init ip_vs_conn_init(void)
>  		return -ENOMEM;
>  	}
>  
> -	IP_VS_INFO("Connection hash table configured "
> -		   "(size=%d, memory=%ldKbytes)\n",
> -		   IP_VS_CONN_TAB_SIZE,
> -		   (long)(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head))/1024);
> +	pr_info("Connection hash table configured "
> +		"(size=%d, memory=%ldKbytes)\n",
> +		IP_VS_CONN_TAB_SIZE,
> +		(long)(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head))/1024);
>  	IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
>  		  sizeof(struct ip_vs_conn));
>  
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 6811dca..b227750 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -391,9 +391,9 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	 */
>  	if (!svc->fwmark && pptr[1] != svc->port) {
>  		if (!svc->port)
> -			IP_VS_ERR("Schedule: port zero only supported "
> -				  "in persistent services, "
> -				  "check your ipvs configuration\n");
> +			pr_err("Schedule: port zero only supported "
> +			       "in persistent services, "
> +			       "check your ipvs configuration\n");
>  		return NULL;
>  	}
>  
> @@ -465,7 +465,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
>  		ip_vs_service_put(svc);
>  
>  		/* create a new connection entry */
> -		IP_VS_DBG(6, "ip_vs_leave: create a cache_bypass entry\n");
> +		IP_VS_DBG(6, "%s(): create a cache_bypass entry\n", __func__);
>  		cp = ip_vs_conn_new(svc->af, iph.protocol,
>  				    &iph.saddr, pptr[0],
>  				    &iph.daddr, pptr[1],
> @@ -667,8 +667,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
>  	unsigned int verdict = NF_DROP;
>  
>  	if (IP_VS_FWD_METHOD(cp) != 0) {
> -		IP_VS_ERR("shouldn't reach here, because the box is on the "
> -			  "half connection in the tun/dr module.\n");
> +		pr_err("shouldn't reach here, because the box is on the "
> +		       "half connection in the tun/dr module.\n");
>  	}
>  
>  	/* Ensure the checksum is correct */
> @@ -1490,7 +1490,7 @@ static int __init ip_vs_init(void)
>  
>  	ret = ip_vs_control_init();
>  	if (ret < 0) {
> -		IP_VS_ERR("can't setup control.\n");
> +		pr_err("can't setup control.\n");
>  		goto cleanup_estimator;
>  	}
>  
> @@ -1498,23 +1498,23 @@ static int __init ip_vs_init(void)
>  
>  	ret = ip_vs_app_init();
>  	if (ret < 0) {
> -		IP_VS_ERR("can't setup application helper.\n");
> +		pr_err("can't setup application helper.\n");
>  		goto cleanup_protocol;
>  	}
>  
>  	ret = ip_vs_conn_init();
>  	if (ret < 0) {
> -		IP_VS_ERR("can't setup connection table.\n");
> +		pr_err("can't setup connection table.\n");
>  		goto cleanup_app;
>  	}
>  
>  	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
>  	if (ret < 0) {
> -		IP_VS_ERR("can't register hooks.\n");
> +		pr_err("can't register hooks.\n");
>  		goto cleanup_conn;
>  	}
>  
> -	IP_VS_INFO("ipvs loaded.\n");
> +	pr_info("ipvs loaded.\n");
>  	return ret;
>  
>    cleanup_conn:
> @@ -1537,7 +1537,7 @@ static void __exit ip_vs_cleanup(void)
>  	ip_vs_protocol_cleanup();
>  	ip_vs_control_cleanup();
>  	ip_vs_estimator_cleanup();
> -	IP_VS_INFO("ipvs unloaded.\n");
> +	pr_info("ipvs unloaded.\n");
>  }
>  
>  module_init(ip_vs_init);
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index e6133ea..fba2892 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -343,8 +343,8 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
>  	unsigned hash;
>  
>  	if (svc->flags & IP_VS_SVC_F_HASHED) {
> -		IP_VS_ERR("ip_vs_svc_hash(): request for already hashed, "
> -			  "called from %p\n", __builtin_return_address(0));
> +		pr_err("%s(): request for already hashed, called from %pF\n",
> +		       __func__, __builtin_return_address(0));
>  		return 0;
>  	}
>  
> @@ -377,8 +377,8 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
>  static int ip_vs_svc_unhash(struct ip_vs_service *svc)
>  {
>  	if (!(svc->flags & IP_VS_SVC_F_HASHED)) {
> -		IP_VS_ERR("ip_vs_svc_unhash(): request for unhash flagged, "
> -			  "called from %p\n", __builtin_return_address(0));
> +		pr_err("%s(): request for unhash flagged, called from %pF\n",
> +		       __func__, __builtin_return_address(0));
>  		return 0;
>  	}
>  
> @@ -844,7 +844,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
>  
>  	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_ATOMIC);
>  	if (dest == NULL) {
> -		IP_VS_ERR("ip_vs_new_dest: kmalloc failed.\n");
> +		pr_err("%s(): no memory.\n", __func__);
>  		return -ENOMEM;
>  	}
>  
> @@ -888,13 +888,13 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  	EnterFunction(2);
>  
>  	if (udest->weight < 0) {
> -		IP_VS_ERR("ip_vs_add_dest(): server weight less than zero\n");
> +		pr_err("%s(): server weight less than zero\n", __func__);
>  		return -ERANGE;
>  	}
>  
>  	if (udest->l_threshold > udest->u_threshold) {
> -		IP_VS_ERR("ip_vs_add_dest(): lower threshold is higher than "
> -			  "upper threshold\n");
> +		pr_err("%s(): lower threshold is higher than upper threshold\n",
> +			__func__);
>  		return -ERANGE;
>  	}
>  
> @@ -906,7 +906,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  	dest = ip_vs_lookup_dest(svc, &daddr, dport);
>  
>  	if (dest != NULL) {
> -		IP_VS_DBG(1, "ip_vs_add_dest(): dest already exists\n");
> +		IP_VS_DBG(1, "%s(): dest already exists\n", __func__);
>  		return -EEXIST;
>  	}
>  
> @@ -1000,13 +1000,13 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  	EnterFunction(2);
>  
>  	if (udest->weight < 0) {
> -		IP_VS_ERR("ip_vs_edit_dest(): server weight less than zero\n");
> +		pr_err("%s(): server weight less than zero\n", __func__);
>  		return -ERANGE;
>  	}
>  
>  	if (udest->l_threshold > udest->u_threshold) {
> -		IP_VS_ERR("ip_vs_edit_dest(): lower threshold is higher than "
> -			  "upper threshold\n");
> +		pr_err("%s(): lower threshold is higher than upper threshold\n",
> +			__func__);
>  		return -ERANGE;
>  	}
>  
> @@ -1018,7 +1018,7 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  	dest = ip_vs_lookup_dest(svc, &daddr, dport);
>  
>  	if (dest == NULL) {
> -		IP_VS_DBG(1, "ip_vs_edit_dest(): dest doesn't exist\n");
> +		IP_VS_DBG(1, "%s(): dest doesn't exist\n", __func__);
>  		return -ENOENT;
>  	}
>  
> @@ -1118,7 +1118,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  	dest = ip_vs_lookup_dest(svc, &udest->addr, dport);
>  
>  	if (dest == NULL) {
> -		IP_VS_DBG(1, "ip_vs_del_dest(): destination not found!\n");
> +		IP_VS_DBG(1, "%s(): destination not found!\n", __func__);
>  		return -ENOENT;
>  	}
>  
> @@ -1164,8 +1164,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
>  	/* Lookup the scheduler by 'u->sched_name' */
>  	sched = ip_vs_scheduler_get(u->sched_name);
>  	if (sched == NULL) {
> -		IP_VS_INFO("Scheduler module ip_vs_%s not found\n",
> -			   u->sched_name);
> +		pr_info("Scheduler module ip_vs_%s not found\n", u->sched_name);
>  		ret = -ENOENT;
>  		goto out_mod_dec;
>  	}
> @@ -1179,7 +1178,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
>  
>  	svc = kzalloc(sizeof(struct ip_vs_service), GFP_ATOMIC);
>  	if (svc == NULL) {
> -		IP_VS_DBG(1, "ip_vs_add_service: kmalloc failed.\n");
> +		IP_VS_DBG(1, "%s(): no memory\n", __func__);
>  		ret = -ENOMEM;
>  		goto out_err;
>  	}
> @@ -1262,8 +1261,7 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
>  	 */
>  	sched = ip_vs_scheduler_get(u->sched_name);
>  	if (sched == NULL) {
> -		IP_VS_INFO("Scheduler module ip_vs_%s not found\n",
> -			   u->sched_name);
> +		pr_info("Scheduler module ip_vs_%s not found\n", u->sched_name);
>  		return -ENOENT;
>  	}
>  	old_sched = sched;
> @@ -2080,8 +2078,8 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
>  		return -EPERM;
>  
>  	if (len != set_arglen[SET_CMDID(cmd)]) {
> -		IP_VS_ERR("set_ctl: len %u != %u\n",
> -			  len, set_arglen[SET_CMDID(cmd)]);
> +		pr_err("set_ctl: len %u != %u\n",
> +		       len, set_arglen[SET_CMDID(cmd)]);
>  		return -EINVAL;
>  	}
>  
> @@ -2132,9 +2130,9 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
>  
>  	/* Check for valid protocol: TCP or UDP, even for fwmark!=0 */
>  	if (usvc.protocol != IPPROTO_TCP && usvc.protocol != IPPROTO_UDP) {
> -		IP_VS_ERR("set_ctl: invalid protocol: %d %pI4:%d %s\n",
> -			  usvc.protocol, &usvc.addr.ip,
> -			  ntohs(usvc.port), usvc.sched_name);
> +		pr_err("set_ctl: invalid protocol: %d %pI4:%d %s\n",
> +		       usvc.protocol, &usvc.addr.ip,
> +		       ntohs(usvc.port), usvc.sched_name);
>  		ret = -EFAULT;
>  		goto out_unlock;
>  	}
> @@ -2359,8 +2357,8 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  		return -EPERM;
>  
>  	if (*len < get_arglen[GET_CMDID(cmd)]) {
> -		IP_VS_ERR("get_ctl: len %u < %u\n",
> -			  *len, get_arglen[GET_CMDID(cmd)]);
> +		pr_err("get_ctl: len %u < %u\n",
> +		       *len, get_arglen[GET_CMDID(cmd)]);
>  		return -EINVAL;
>  	}
>  
> @@ -2405,7 +2403,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  		size = sizeof(*get) +
>  			sizeof(struct ip_vs_service_entry) * get->num_services;
>  		if (*len != size) {
> -			IP_VS_ERR("length: %u != %u\n", *len, size);
> +			pr_err("length: %u != %u\n", *len, size);
>  			ret = -EINVAL;
>  			goto out;
>  		}
> @@ -2445,7 +2443,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  		size = sizeof(*get) +
>  			sizeof(struct ip_vs_dest_entry) * get->num_dests;
>  		if (*len != size) {
> -			IP_VS_ERR("length: %u != %u\n", *len, size);
> +			pr_err("length: %u != %u\n", *len, size);
>  			ret = -EINVAL;
>  			goto out;
>  		}
> @@ -3173,7 +3171,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
>  	else if (cmd == IPVS_CMD_GET_CONFIG)
>  		reply_cmd = IPVS_CMD_SET_CONFIG;
>  	else {
> -		IP_VS_ERR("unknown Generic Netlink command\n");
> +		pr_err("unknown Generic Netlink command\n");
>  		return -EINVAL;
>  	}
>  
> @@ -3238,7 +3236,7 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
>  	goto out;
>  
>  nla_put_failure:
> -	IP_VS_ERR("not enough space in Netlink message\n");
> +	pr_err("not enough space in Netlink message\n");
>  	ret = -EMSGSIZE;
>  
>  out_err:
> @@ -3369,13 +3367,13 @@ int __init ip_vs_control_init(void)
>  
>  	ret = nf_register_sockopt(&ip_vs_sockopts);
>  	if (ret) {
> -		IP_VS_ERR("cannot register sockopt.\n");
> +		pr_err("cannot register sockopt.\n");
>  		return ret;
>  	}
>  
>  	ret = ip_vs_genl_register();
>  	if (ret) {
> -		IP_VS_ERR("cannot register Generic Netlink interface.\n");
> +		pr_err("cannot register Generic Netlink interface.\n");
>  		nf_unregister_sockopt(&ip_vs_sockopts);
>  		return ret;
>  	}
> diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
> index d0c0594..fe3e188 100644
> --- a/net/netfilter/ipvs/ip_vs_dh.c
> +++ b/net/netfilter/ipvs/ip_vs_dh.c
> @@ -150,7 +150,7 @@ static int ip_vs_dh_init_svc(struct ip_vs_service *svc)
>  	tbl = kmalloc(sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE,
>  		      GFP_ATOMIC);
>  	if (tbl == NULL) {
> -		IP_VS_ERR("ip_vs_dh_init_svc(): no memory\n");
> +		pr_err("%s(): no memory\n", __func__);
>  		return -ENOMEM;
>  	}
>  	svc->sched_data = tbl;
> @@ -217,7 +217,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  
>  	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
>  
> -	IP_VS_DBG(6, "ip_vs_dh_schedule(): Scheduling...\n");
> +	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
>  
>  	tbl = (struct ip_vs_dh_bucket *)svc->sched_data;
>  	dest = ip_vs_dh_get(svc->af, tbl, &iph.daddr);
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 9c16a3f..33e2c79 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -385,8 +385,8 @@ static int __init ip_vs_ftp_init(void)
>  		ret = register_ip_vs_app_inc(app, app->protocol, ports[i]);
>  		if (ret)
>  			break;
> -		IP_VS_INFO("%s: loaded support on port[%d] = %d\n",
> -			   app->name, i, ports[i]);
> +		pr_info("%s: loaded support on port[%d] = %d\n",
> +			app->name, i, ports[i]);
>  	}
>  
>  	if (ret)
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index 98fb185..c1757f3 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -202,7 +202,7 @@ ip_vs_lblc_new(struct ip_vs_lblc_table *tbl, const union nf_inet_addr *daddr,
>  	if (!en) {
>  		en = kmalloc(sizeof(*en), GFP_ATOMIC);
>  		if (!en) {
> -			IP_VS_ERR("ip_vs_lblc_new(): no memory\n");
> +			pr_err("%s(): no memory\n", __func__);
>  			return NULL;
>  		}
>  
> @@ -335,7 +335,7 @@ static int ip_vs_lblc_init_svc(struct ip_vs_service *svc)
>  	 */
>  	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
>  	if (tbl == NULL) {
> -		IP_VS_ERR("ip_vs_lblc_init_svc(): no memory\n");
> +		pr_err("%s(): no memory\n", __func__);
>  		return -ENOMEM;
>  	}
>  	svc->sched_data = tbl;
> @@ -480,7 +480,7 @@ ip_vs_lblc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  
>  	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
>  
> -	IP_VS_DBG(6, "ip_vs_lblc_schedule(): Scheduling...\n");
> +	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
>  
>  	/* First look in our cache */
>  	read_lock(&svc->sched_lock);
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index 5f5e5f4..715b57f 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -111,7 +111,7 @@ ip_vs_dest_set_insert(struct ip_vs_dest_set *set, struct ip_vs_dest *dest)
>  
>  	e = kmalloc(sizeof(*e), GFP_ATOMIC);
>  	if (e == NULL) {
> -		IP_VS_ERR("ip_vs_dest_set_insert(): no memory\n");
> +		pr_err("%s(): no memory\n", __func__);
>  		return NULL;
>  	}
>  
> @@ -205,8 +205,9 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
>  		}
>  	}
>  
> -	IP_VS_DBG_BUF(6, "ip_vs_dest_set_min: server %s:%d "
> +	IP_VS_DBG_BUF(6, "%s(): server %s:%d "
>  		      "activeconns %d refcnt %d weight %d overhead %d\n",
> +		      __func__,
>  		      IP_VS_DBG_ADDR(least->af, &least->addr),
>  		      ntohs(least->port),
>  		      atomic_read(&least->activeconns),
> @@ -252,8 +253,9 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
>  		}
>  	}
>  
> -	IP_VS_DBG_BUF(6, "ip_vs_dest_set_max: server %s:%d "
> +	IP_VS_DBG_BUF(6, "%s(): server %s:%d "
>  		      "activeconns %d refcnt %d weight %d overhead %d\n",
> +		      __func__,
>  		      IP_VS_DBG_ADDR(most->af, &most->addr), ntohs(most->port),
>  		      atomic_read(&most->activeconns),
>  		      atomic_read(&most->refcnt),
> @@ -377,7 +379,7 @@ ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
>  	if (!en) {
>  		en = kmalloc(sizeof(*en), GFP_ATOMIC);
>  		if (!en) {
> -			IP_VS_ERR("ip_vs_lblcr_new(): no memory\n");
> +			pr_err("%s(): no memory\n", __func__);
>  			return NULL;
>  		}
>  
> @@ -511,7 +513,7 @@ static int ip_vs_lblcr_init_svc(struct ip_vs_service *svc)
>  	 */
>  	tbl = kmalloc(sizeof(*tbl), GFP_ATOMIC);
>  	if (tbl == NULL) {
> -		IP_VS_ERR("ip_vs_lblcr_init_svc(): no memory\n");
> +		pr_err("%s(): no memory\n", __func__);
>  		return -ENOMEM;
>  	}
>  	svc->sched_data = tbl;
> @@ -657,7 +659,7 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  
>  	ip_vs_fill_iphdr(svc->af, skb_network_header(skb), &iph);
>  
> -	IP_VS_DBG(6, "ip_vs_lblcr_schedule(): Scheduling...\n");
> +	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
>  
>  	/* First look in our cache */
>  	read_lock(&svc->sched_lock);
> diff --git a/net/netfilter/ipvs/ip_vs_lc.c b/net/netfilter/ipvs/ip_vs_lc.c
> index 4ecd5e1..4f69db1 100644
> --- a/net/netfilter/ipvs/ip_vs_lc.c
> +++ b/net/netfilter/ipvs/ip_vs_lc.c
> @@ -47,7 +47,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	struct ip_vs_dest *dest, *least = NULL;
>  	unsigned int loh = 0, doh;
>  
> -	IP_VS_DBG(6, "ip_vs_lc_schedule(): Scheduling...\n");
> +	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
>  
>  	/*
>  	 * Simply select the server with the least number of
> diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
> index 2224478..c413e18 100644
> --- a/net/netfilter/ipvs/ip_vs_nq.c
> +++ b/net/netfilter/ipvs/ip_vs_nq.c
> @@ -60,7 +60,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	struct ip_vs_dest *dest, *least = NULL;
>  	unsigned int loh = 0, doh;
>  
> -	IP_VS_DBG(6, "ip_vs_nq_schedule(): Scheduling...\n");
> +	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
>  
>  	/*
>  	 * We calculate the load of each dest server as follows:
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index a95bc40..85c8892 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -262,7 +262,7 @@ int __init ip_vs_protocol_init(void)
>  #ifdef CONFIG_IP_VS_PROTO_ESP
>  	REGISTER_PROTOCOL(&ip_vs_protocol_esp);
>  #endif
> -	IP_VS_INFO("Registered protocols (%s)\n", &protocols[2]);
> +	pr_info("Registered protocols (%s)\n", &protocols[2]);
>  
>  	return 0;
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index c36c80d..2278e14 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -664,7 +664,7 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
>  				break;
>  			spin_unlock(&tcp_app_lock);
>  
> -			IP_VS_DBG_BUF(9, "%s: Binding conn %s:%u->"
> +			IP_VS_DBG_BUF(9, "%s(): Binding conn %s:%u->"
>  				      "%s:%u to app %s on port %u\n",
>  				      __func__,
>  				      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
> diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
> index 96ebe40..33a05d3 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_udp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
> @@ -445,7 +445,7 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
>  				break;
>  			spin_unlock(&udp_app_lock);
>  
> -			IP_VS_DBG_BUF(9, "%s: Binding conn %s:%u->"
> +			IP_VS_DBG_BUF(9, "%s(): Binding conn %s:%u->"
>  				      "%s:%u to app %s on port %u\n",
>  				      __func__,
>  				      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
> diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
> index b01007e..e210f37 100644
> --- a/net/netfilter/ipvs/ip_vs_rr.c
> +++ b/net/netfilter/ipvs/ip_vs_rr.c
> @@ -51,7 +51,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	struct list_head *p, *q;
>  	struct ip_vs_dest *dest;
>  
> -	IP_VS_DBG(6, "ip_vs_rr_schedule(): Scheduling...\n");
> +	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
>  
>  	write_lock(&svc->sched_lock);
>  	p = (struct list_head *)svc->sched_data;
> diff --git a/net/netfilter/ipvs/ip_vs_sched.c b/net/netfilter/ipvs/ip_vs_sched.c
> index 87bc5ea..bbc1ac7 100644
> --- a/net/netfilter/ipvs/ip_vs_sched.c
> +++ b/net/netfilter/ipvs/ip_vs_sched.c
> @@ -47,11 +47,11 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
>  	int ret;
>  
>  	if (svc == NULL) {
> -		IP_VS_ERR("ip_vs_bind_scheduler(): svc arg NULL\n");
> +		pr_err("%s(): svc arg NULL\n", __func__);
>  		return -EINVAL;
>  	}
>  	if (scheduler == NULL) {
> -		IP_VS_ERR("ip_vs_bind_scheduler(): scheduler arg NULL\n");
> +		pr_err("%s(): scheduler arg NULL\n", __func__);
>  		return -EINVAL;
>  	}
>  
> @@ -60,7 +60,7 @@ int ip_vs_bind_scheduler(struct ip_vs_service *svc,
>  	if (scheduler->init_service) {
>  		ret = scheduler->init_service(svc);
>  		if (ret) {
> -			IP_VS_ERR("ip_vs_bind_scheduler(): init error\n");
> +			pr_err("%s(): init error\n", __func__);
>  			return ret;
>  		}
>  	}
> @@ -77,19 +77,19 @@ int ip_vs_unbind_scheduler(struct ip_vs_service *svc)
>  	struct ip_vs_scheduler *sched;
>  
>  	if (svc == NULL) {
> -		IP_VS_ERR("ip_vs_unbind_scheduler(): svc arg NULL\n");
> +		pr_err("%s(): svc arg NULL\n", __func__);
>  		return -EINVAL;
>  	}
>  
>  	sched = svc->scheduler;
>  	if (sched == NULL) {
> -		IP_VS_ERR("ip_vs_unbind_scheduler(): svc isn't bound\n");
> +		pr_err("%s(): svc isn't bound\n", __func__);
>  		return -EINVAL;
>  	}
>  
>  	if (sched->done_service) {
>  		if (sched->done_service(svc) != 0) {
> -			IP_VS_ERR("ip_vs_unbind_scheduler(): done error\n");
> +			pr_err("%s(): done error\n", __func__);
>  			return -EINVAL;
>  		}
>  	}
> @@ -106,8 +106,7 @@ static struct ip_vs_scheduler *ip_vs_sched_getbyname(const char *sched_name)
>  {
>  	struct ip_vs_scheduler *sched;
>  
> -	IP_VS_DBG(2, "ip_vs_sched_getbyname(): sched_name \"%s\"\n",
> -		  sched_name);
> +	IP_VS_DBG(2, "%s(): sched_name \"%s\"\n", __func__, sched_name);
>  
>  	read_lock_bh(&__ip_vs_sched_lock);
>  
> @@ -173,12 +172,12 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
>  	struct ip_vs_scheduler *sched;
>  
>  	if (!scheduler) {
> -		IP_VS_ERR("register_ip_vs_scheduler(): NULL arg\n");
> +		pr_err("%s(): NULL arg\n", __func__);
>  		return -EINVAL;
>  	}
>  
>  	if (!scheduler->name) {
> -		IP_VS_ERR("register_ip_vs_scheduler(): NULL scheduler_name\n");
> +		pr_err("%s(): NULL scheduler_name\n", __func__);
>  		return -EINVAL;
>  	}
>  
> @@ -190,8 +189,8 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
>  	if (!list_empty(&scheduler->n_list)) {
>  		write_unlock_bh(&__ip_vs_sched_lock);
>  		ip_vs_use_count_dec();
> -		IP_VS_ERR("register_ip_vs_scheduler(): [%s] scheduler "
> -			  "already linked\n", scheduler->name);
> +		pr_err("%s(): [%s] scheduler already linked\n",
> +		       __func__, scheduler->name);
>  		return -EINVAL;
>  	}
>  
> @@ -203,9 +202,8 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
>  		if (strcmp(scheduler->name, sched->name) == 0) {
>  			write_unlock_bh(&__ip_vs_sched_lock);
>  			ip_vs_use_count_dec();
> -			IP_VS_ERR("register_ip_vs_scheduler(): [%s] scheduler "
> -					"already existed in the system\n",
> -					scheduler->name);
> +			pr_err("%s(): [%s] scheduler already existed "
> +			       "in the system\n", __func__, scheduler->name);
>  			return -EINVAL;
>  		}
>  	}
> @@ -215,7 +213,7 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
>  	list_add(&scheduler->n_list, &ip_vs_schedulers);
>  	write_unlock_bh(&__ip_vs_sched_lock);
>  
> -	IP_VS_INFO("[%s] scheduler registered.\n", scheduler->name);
> +	pr_info("[%s] scheduler registered.\n", scheduler->name);
>  
>  	return 0;
>  }
> @@ -227,15 +225,15 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
>  int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
>  {
>  	if (!scheduler) {
> -		IP_VS_ERR( "unregister_ip_vs_scheduler(): NULL arg\n");
> +		pr_err("%s(): NULL arg\n", __func__);
>  		return -EINVAL;
>  	}
>  
>  	write_lock_bh(&__ip_vs_sched_lock);
>  	if (list_empty(&scheduler->n_list)) {
>  		write_unlock_bh(&__ip_vs_sched_lock);
> -		IP_VS_ERR("unregister_ip_vs_scheduler(): [%s] scheduler "
> -			  "is not in the list. failed\n", scheduler->name);
> +		pr_err("%s(): [%s] scheduler is not in the list. failed\n",
> +		       __func__, scheduler->name);
>  		return -EINVAL;
>  	}
>  
> @@ -248,7 +246,7 @@ int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
>  	/* decrease the module use count */
>  	ip_vs_use_count_dec();
>  
> -	IP_VS_INFO("[%s] scheduler unregistered.\n", scheduler->name);
> +	pr_info("[%s] scheduler unregistered.\n", scheduler->name);
>  
>  	return 0;
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
> index 4f745dd..1ab75a9 100644
> --- a/net/netfilter/ipvs/ip_vs_sed.c
> +++ b/net/netfilter/ipvs/ip_vs_sed.c
> @@ -64,7 +64,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	struct ip_vs_dest *dest, *least;
>  	unsigned int loh, doh;
>  
> -	IP_VS_DBG(6, "ip_vs_sed_schedule(): Scheduling...\n");
> +	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
>  
>  	/*
>  	 * We calculate the load of each dest server as follows:
> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index fb4d2d2..8e6cfd3 100644
> --- a/net/netfilter/ipvs/ip_vs_sh.c
> +++ b/net/netfilter/ipvs/ip_vs_sh.c
> @@ -147,7 +147,7 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
>  	tbl = kmalloc(sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE,
>  		      GFP_ATOMIC);
>  	if (tbl == NULL) {
> -		IP_VS_ERR("ip_vs_sh_init_svc(): no memory\n");
> +		pr_err("%s(): no memory\n", __func__);
>  		return -ENOMEM;
>  	}
>  	svc->sched_data = tbl;
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index cc04c99..e177f0d 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -246,7 +246,7 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
>  	if (!curr_sb) {
>  		if (!(curr_sb=ip_vs_sync_buff_create())) {
>  			spin_unlock(&curr_sb_lock);
> -			IP_VS_ERR("ip_vs_sync_buff_create failed.\n");
> +			pr_err("ip_vs_sync_buff_create failed.\n");
>  			return;
>  		}
>  	}
> @@ -412,7 +412,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
>  			if (dest)
>  				atomic_dec(&dest->refcnt);
>  			if (!cp) {
> -				IP_VS_ERR("ip_vs_conn_new failed\n");
> +				pr_err("ip_vs_conn_new failed\n");
>  				return;
>  			}
>  		} else if (!cp->dest) {
> @@ -580,8 +580,8 @@ static int bind_mcastif_addr(struct socket *sock, char *ifname)
>  
>  	addr = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
>  	if (!addr)
> -		IP_VS_ERR("You probably need to specify IP address on "
> -			  "multicast interface.\n");
> +		pr_err("You probably need to specify IP address on "
> +		       "multicast interface.\n");
>  
>  	IP_VS_DBG(7, "binding socket with (%s) %pI4\n",
>  		  ifname, &addr);
> @@ -605,13 +605,13 @@ static struct socket * make_send_sock(void)
>  	/* First create a socket */
>  	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
>  	if (result < 0) {
> -		IP_VS_ERR("Error during creation of socket; terminating\n");
> +		pr_err("Error during creation of socket; terminating\n");
>  		return ERR_PTR(result);
>  	}
>  
>  	result = set_mcast_if(sock->sk, ip_vs_master_mcast_ifn);
>  	if (result < 0) {
> -		IP_VS_ERR("Error setting outbound mcast interface\n");
> +		pr_err("Error setting outbound mcast interface\n");
>  		goto error;
>  	}
>  
> @@ -620,14 +620,14 @@ static struct socket * make_send_sock(void)
>  
>  	result = bind_mcastif_addr(sock, ip_vs_master_mcast_ifn);
>  	if (result < 0) {
> -		IP_VS_ERR("Error binding address of the mcast interface\n");
> +		pr_err("Error binding address of the mcast interface\n");
>  		goto error;
>  	}
>  
>  	result = sock->ops->connect(sock, (struct sockaddr *) &mcast_addr,
>  			sizeof(struct sockaddr), 0);
>  	if (result < 0) {
> -		IP_VS_ERR("Error connecting to the multicast addr\n");
> +		pr_err("Error connecting to the multicast addr\n");
>  		goto error;
>  	}
>  
> @@ -650,7 +650,7 @@ static struct socket * make_receive_sock(void)
>  	/* First create a socket */
>  	result = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
>  	if (result < 0) {
> -		IP_VS_ERR("Error during creation of socket; terminating\n");
> +		pr_err("Error during creation of socket; terminating\n");
>  		return ERR_PTR(result);
>  	}
>  
> @@ -660,7 +660,7 @@ static struct socket * make_receive_sock(void)
>  	result = sock->ops->bind(sock, (struct sockaddr *) &mcast_addr,
>  			sizeof(struct sockaddr));
>  	if (result < 0) {
> -		IP_VS_ERR("Error binding to the multicast addr\n");
> +		pr_err("Error binding to the multicast addr\n");
>  		goto error;
>  	}
>  
> @@ -669,7 +669,7 @@ static struct socket * make_receive_sock(void)
>  			(struct in_addr *) &mcast_addr.sin_addr,
>  			ip_vs_backup_mcast_ifn);
>  	if (result < 0) {
> -		IP_VS_ERR("Error joining to the multicast group\n");
> +		pr_err("Error joining to the multicast group\n");
>  		goto error;
>  	}
>  
> @@ -709,7 +709,7 @@ ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
>  	msg->size = htons(msg->size);
>  
>  	if (ip_vs_send_async(sock, (char *)msg, msize) != msize)
> -		IP_VS_ERR("ip_vs_send_async error\n");
> +		pr_err("ip_vs_send_async error\n");
>  }
>  
>  static int
> @@ -740,9 +740,9 @@ static int sync_thread_master(void *data)
>  	struct ip_vs_sync_thread_data *tinfo = data;
>  	struct ip_vs_sync_buff *sb;
>  
> -	IP_VS_INFO("sync thread started: state = MASTER, mcast_ifn = %s, "
> -		   "syncid = %d\n",
> -		   ip_vs_master_mcast_ifn, ip_vs_master_syncid);
> +	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
> +		"syncid = %d\n",
> +		ip_vs_master_mcast_ifn, ip_vs_master_syncid);
>  
>  	while (!kthread_should_stop()) {
>  		while ((sb = sb_dequeue())) {
> @@ -783,9 +783,9 @@ static int sync_thread_backup(void *data)
>  	struct ip_vs_sync_thread_data *tinfo = data;
>  	int len;
>  
> -	IP_VS_INFO("sync thread started: state = BACKUP, mcast_ifn = %s, "
> -		   "syncid = %d\n",
> -		   ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
> +	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
> +		"syncid = %d\n",
> +		ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
>  
>  	while (!kthread_should_stop()) {
>  		wait_event_interruptible(*tinfo->sock->sk->sk_sleep,
> @@ -797,7 +797,7 @@ static int sync_thread_backup(void *data)
>  			len = ip_vs_receive(tinfo->sock, tinfo->buf,
>  					sync_recv_mesg_maxlen);
>  			if (len <= 0) {
> -				IP_VS_ERR("receiving message error\n");
> +				pr_err("receiving message error\n");
>  				break;
>  			}
>  
> @@ -827,7 +827,7 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
>  	int (*threadfn)(void *data);
>  	int result = -ENOMEM;
>  
> -	IP_VS_DBG(7, "%s: pid %d\n", __func__, task_pid_nr(current));
> +	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
>  	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
>  		  sizeof(struct ip_vs_sync_conn));
>  
> @@ -904,14 +904,14 @@ out:
>  
>  int stop_sync_thread(int state)
>  {
> -	IP_VS_DBG(7, "%s: pid %d\n", __func__, task_pid_nr(current));
> +	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
>  
>  	if (state == IP_VS_STATE_MASTER) {
>  		if (!sync_master_thread)
>  			return -ESRCH;
>  
> -		IP_VS_INFO("stopping master sync thread %d ...\n",
> -			   task_pid_nr(sync_master_thread));
> +		pr_info("stopping master sync thread %d ...\n",
> +			task_pid_nr(sync_master_thread));
>  
>  		/*
>  		 * The lock synchronizes with sb_queue_tail(), so that we don't
> @@ -928,8 +928,8 @@ int stop_sync_thread(int state)
>  		if (!sync_backup_thread)
>  			return -ESRCH;
>  
> -		IP_VS_INFO("stopping backup sync thread %d ...\n",
> -			   task_pid_nr(sync_backup_thread));
> +		pr_info("stopping backup sync thread %d ...\n",
> +			task_pid_nr(sync_backup_thread));
>  
>  		ip_vs_sync_state &= ~IP_VS_STATE_BACKUP;
>  		kthread_stop(sync_backup_thread);
> diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
> index c39ebb6..70ff82c 100644
> --- a/net/netfilter/ipvs/ip_vs_wrr.c
> +++ b/net/netfilter/ipvs/ip_vs_wrr.c
> @@ -97,7 +97,7 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
>  	 */
>  	mark = kmalloc(sizeof(struct ip_vs_wrr_mark), GFP_ATOMIC);
>  	if (mark == NULL) {
> -		IP_VS_ERR("ip_vs_wrr_init_svc(): no memory\n");
> +		pr_err("%s(): no memory\n", __func__);
>  		return -ENOMEM;
>  	}
>  	mark->cl = &svc->destinations;
> @@ -144,7 +144,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
>  	struct ip_vs_wrr_mark *mark = svc->sched_data;
>  	struct list_head *p;
>  
> -	IP_VS_DBG(6, "ip_vs_wrr_schedule(): Scheduling...\n");
> +	IP_VS_DBG(6, "%s(): Scheduling...\n", __func__);
>  
>  	/*
>  	 * This loop will always terminate, because mark->cw in (0, max_weight]
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 061e76d..30b3189 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -238,8 +238,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	EnterFunction(10);
>  
>  	if (ip_route_output_key(&init_net, &rt, &fl)) {
> -		IP_VS_DBG_RL("ip_vs_bypass_xmit(): ip_route_output error, dest: %pI4\n",
> -			     &iph->daddr);
> +		IP_VS_DBG_RL("%s(): ip_route_output error, dest: %pI4\n",
> +			     __func__, &iph->daddr);
>  		goto tx_error_icmp;
>  	}
>  
> @@ -248,7 +248,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
>  		ip_rt_put(rt);
>  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
> -		IP_VS_DBG_RL("ip_vs_bypass_xmit(): frag needed\n");
> +		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error;
>  	}
>  
> @@ -302,8 +302,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  
>  	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
>  	if (!rt) {
> -		IP_VS_DBG_RL("ip_vs_bypass_xmit_v6(): ip6_route_output error, dest: %pI6\n",
> -			     &iph->daddr);
> +		IP_VS_DBG_RL("%s(): ip6_route_output error, dest: %pI6\n",
> +			     __func__, &iph->daddr);
>  		goto tx_error_icmp;
>  	}
>  
> @@ -312,7 +312,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if (skb->len > mtu) {
>  		dst_release(&rt->u.dst);
>  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
> -		IP_VS_DBG_RL("ip_vs_bypass_xmit_v6(): frag needed\n");
> +		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error;
>  	}
>  
> @@ -539,9 +539,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	EnterFunction(10);
>  
>  	if (skb->protocol != htons(ETH_P_IP)) {
> -		IP_VS_DBG_RL("ip_vs_tunnel_xmit(): protocol error, "
> +		IP_VS_DBG_RL("%s(): protocol error, "
>  			     "ETH_P_IP: %d, skb protocol: %d\n",
> -			     htons(ETH_P_IP), skb->protocol);
> +			     __func__, htons(ETH_P_IP), skb->protocol);
>  		goto tx_error;
>  	}
>  
> @@ -553,7 +553,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
>  	if (mtu < 68) {
>  		ip_rt_put(rt);
> -		IP_VS_DBG_RL("ip_vs_tunnel_xmit(): mtu less than 68\n");
> +		IP_VS_DBG_RL("%s(): mtu less than 68\n", __func__);
>  		goto tx_error;
>  	}
>  	if (skb_dst(skb))
> @@ -565,7 +565,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	    && mtu < ntohs(old_iph->tot_len)) {
>  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
>  		ip_rt_put(rt);
> -		IP_VS_DBG_RL("ip_vs_tunnel_xmit(): frag needed\n");
> +		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error;
>  	}
>  
> @@ -581,7 +581,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  		if (!new_skb) {
>  			ip_rt_put(rt);
>  			kfree_skb(skb);
> -			IP_VS_ERR_RL("ip_vs_tunnel_xmit(): no memory\n");
> +			IP_VS_ERR_RL("%s(): no memory\n", __func__);
>  			return NF_STOLEN;
>  		}
>  		kfree_skb(skb);
> @@ -649,9 +649,9 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	EnterFunction(10);
>  
>  	if (skb->protocol != htons(ETH_P_IPV6)) {
> -		IP_VS_DBG_RL("ip_vs_tunnel_xmit_v6(): protocol error, "
> +		IP_VS_DBG_RL("%s(): protocol error, "
>  			     "ETH_P_IPV6: %d, skb protocol: %d\n",
> -			     htons(ETH_P_IPV6), skb->protocol);
> +			     __func__, htons(ETH_P_IPV6), skb->protocol);
>  		goto tx_error;
>  	}
>  
> @@ -665,7 +665,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	/* TODO IPv6: do we need this check in IPv6? */
>  	if (mtu < 1280) {
>  		dst_release(&rt->u.dst);
> -		IP_VS_DBG_RL("ip_vs_tunnel_xmit_v6(): mtu less than 1280\n");
> +		IP_VS_DBG_RL("%s(): mtu less than 1280\n", __func__);
>  		goto tx_error;
>  	}
>  	if (skb_dst(skb))
> @@ -674,7 +674,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
>  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
>  		dst_release(&rt->u.dst);
> -		IP_VS_DBG_RL("ip_vs_tunnel_xmit_v6(): frag needed\n");
> +		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error;
>  	}
>  
> @@ -690,7 +690,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  		if (!new_skb) {
>  			dst_release(&rt->u.dst);
>  			kfree_skb(skb);
> -			IP_VS_ERR_RL("ip_vs_tunnel_xmit_v6(): no memory\n");
> +			IP_VS_ERR_RL("%s(): no memory\n", __func__);
>  			return NF_STOLEN;
>  		}
>  		kfree_skb(skb);
> @@ -763,7 +763,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
>  		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
>  		ip_rt_put(rt);
> -		IP_VS_DBG_RL("ip_vs_dr_xmit(): frag needed\n");
> +		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error;
>  	}
>  
> @@ -816,7 +816,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if (skb->len > mtu) {
>  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
>  		dst_release(&rt->u.dst);
> -		IP_VS_DBG_RL("ip_vs_dr_xmit_v6(): frag needed\n");
> +		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error;
>  	}
>  
> @@ -891,7 +891,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF))) {
>  		ip_rt_put(rt);
>  		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
> -		IP_VS_DBG_RL("ip_vs_in_icmp(): frag needed\n");
> +		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error;
>  	}
>  
> @@ -966,7 +966,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>  	if (skb->len > mtu) {
>  		dst_release(&rt->u.dst);
>  		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
> -		IP_VS_DBG_RL("ip_vs_in_icmp(): frag needed\n");
> +		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
>  		goto tx_error;
>  	}
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
