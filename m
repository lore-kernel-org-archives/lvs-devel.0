From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipvs: allow rescheduling of new connections when port
 reuse is detected
Date: Mon, 23 Feb 2015 22:07:21 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502232201270.2963@ja.home.ssi.bg>
References: <fd8eceefb063494081853644d1495c8e453f9638.1424705679.git.mleitner@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <fd8eceefb063494081853644d1495c8e453f9638.1424705679.git.mleitner@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Mon, 23 Feb 2015, Marcelo Ricardo Leitner wrote:

> Currently, when TCP/SCTP port reusing happens, IPVS will find the old
> entry and use it for the new one, behaving like a forced persistence.
> But if you consider a cluster with a heavy load of small connections,
> such reuse will happen often and may lead to a not optimal load
> balancing and might prevent a new node from getting a fair load.
> 
> This patch introduces a new sysctl, conn_reuse_mode, that allows
> controlling how to proceed when port reuse is detected. The default
> value will allow rescheduling of new connections only if the old entry
> was in TIME_WAIT state for TCP or CLOSED for SCTP.
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

	Thanks, looks good. Simon, please apply to ipvs-next.

Signed-off-by: Julian Anastasov <ja@ssi.bg>

> ---
> 
> Notes:
>     v1->v2:
>       updated to add kfree(param->pe_data) in ip_vs_proc_conn() chunk
> 
>  Documentation/networking/ipvs-sysctl.txt | 21 ++++++++++++++++++++
>  include/net/ip_vs.h                      | 11 +++++++++++
>  net/netfilter/ipvs/ip_vs_core.c          | 33 ++++++++++++++++++++++++++++----
>  net/netfilter/ipvs/ip_vs_ctl.c           |  8 ++++++++
>  net/netfilter/ipvs/ip_vs_sync.c          | 21 ++++++++++++++++++--
>  5 files changed, 88 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
> index 7a3c047295914cbc8c4273506a9b6d35246a1750..3ba709531adba970595251fa73d6d471ed14c5c1 100644
> --- a/Documentation/networking/ipvs-sysctl.txt
> +++ b/Documentation/networking/ipvs-sysctl.txt
> @@ -22,6 +22,27 @@ backup_only - BOOLEAN
>  	If set, disable the director function while the server is
>  	in backup mode to avoid packet loops for DR/TUN methods.
>  
> +conn_reuse_mode - INTEGER
> +	1 - default
> +
> +	Controls how ipvs will deal with connections that are detected
> +	port reuse. It is a bitmap, with the values being:
> +
> +	0: disable any special handling on port reuse. The new
> +	connection will be delivered to the same real server that was
> +	servicing the previous connection. This will effectively
> +	disable expire_nodest_conn.
> +
> +	bit 1: enable rescheduling of new connections when it is safe.
> +	That is, whenever expire_nodest_conn and for TCP sockets, when
> +	the connection is in TIME_WAIT state (which is only possible if
> +	you use NAT mode).
> +
> +	bit 2: it is bit 1 plus, for TCP connections, when connections
> +	are in FIN_WAIT state, as this is the last state seen by load
> +	balancer in Direct Routing mode. This bit helps on adding new
> +	real servers to a very busy cluster.
> +
>  conntrack - BOOLEAN
>  	0 - disabled (default)
>  	not 0 - enabled
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 615b20b585452111a25085890d8fa875657dbe76..6c7ee0ae7ef1694671e4b6af0906b2fa077f5c7c 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -924,6 +924,7 @@ struct netns_ipvs {
>  	int			sysctl_nat_icmp_send;
>  	int			sysctl_pmtu_disc;
>  	int			sysctl_backup_only;
> +	int			sysctl_conn_reuse_mode;
>  
>  	/* ip_vs_lblc */
>  	int			sysctl_lblc_expiration;
> @@ -1042,6 +1043,11 @@ static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
>  	       ipvs->sysctl_backup_only;
>  }
>  
> +static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
> +{
> +	return ipvs->sysctl_conn_reuse_mode;
> +}
> +
>  #else
>  
>  static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
> @@ -1109,6 +1115,11 @@ static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
>  	return 0;
>  }
>  
> +static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
> +{
> +	return 1;
> +}
> +
>  #endif
>  
>  /* IPVS core functions
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index b87ca32efa0b4e6edc7f251c2c32c4ba3b55659c..3ec9b1a54024fa421f330cf1d0eeb67da9683127 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1046,6 +1046,26 @@ static inline bool is_new_conn(const struct sk_buff *skb,
>  	}
>  }
>  
> +static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
> +					int conn_reuse_mode)
> +{
> +	/* Controlled (FTP DATA or persistence)? */
> +	if (cp->control)
> +		return false;
> +
> +	switch (cp->protocol) {
> +	case IPPROTO_TCP:
> +		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
> +			((conn_reuse_mode & 2) &&
> +			 (cp->state == IP_VS_TCP_S_FIN_WAIT) &&
> +			 (cp->flags & IP_VS_CONN_F_NOOUTPUT));
> +	case IPPROTO_SCTP:
> +		return cp->state == IP_VS_SCTP_S_CLOSED;
> +	default:
> +		return false;
> +	}
> +}
> +
>  /* Handle response packets: rewrite addresses and send away...
>   */
>  static unsigned int
> @@ -1585,6 +1605,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	struct ip_vs_conn *cp;
>  	int ret, pkts;
>  	struct netns_ipvs *ipvs;
> +	int conn_reuse_mode;
>  
>  	/* Already marked as IPVS request or reply? */
>  	if (skb->ipvs_property)
> @@ -1653,10 +1674,14 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	 */
>  	cp = pp->conn_in_get(af, skb, &iph, 0);
>  
> -	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
> -	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
> -	    is_new_conn(skb, &iph)) {
> -		ip_vs_conn_expire_now(cp);
> +	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
> +	if (conn_reuse_mode && !iph.fragoffs &&
> +	    is_new_conn(skb, &iph) && cp &&
> +	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
> +	      unlikely(!atomic_read(&cp->dest->weight))) ||
> +	     unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
> +		if (!atomic_read(&cp->n_control))
> +			ip_vs_conn_expire_now(cp);
>  		__ip_vs_conn_put(cp);
>  		cp = NULL;
>  	}
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index e55759056361c47ed1fcfa5c656541ba39bfd260..ec7f6f1e07cee1d15a6f839defc86aec8abd821e 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1808,6 +1808,12 @@ static struct ctl_table vs_vars[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec,
>  	},
> +	{
> +		.procname	= "conn_reuse_mode",
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
>  #ifdef CONFIG_IP_VS_DEBUG
>  	{
>  		.procname	= "debug_level",
> @@ -3732,6 +3738,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
>  	ipvs->sysctl_pmtu_disc = 1;
>  	tbl[idx++].data = &ipvs->sysctl_pmtu_disc;
>  	tbl[idx++].data = &ipvs->sysctl_backup_only;
> +	ipvs->sysctl_conn_reuse_mode = 1;
> +	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
>  
>  
>  	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index c47ffd7a0a709cb73834c84652f251960f25db79..f96229cdb6e184543b6b958575c08c5a3c1b4b72 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -845,10 +845,27 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
>  	struct ip_vs_conn *cp;
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> -	if (!(flags & IP_VS_CONN_F_TEMPLATE))
> +	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
>  		cp = ip_vs_conn_in_get(param);
> -	else
> +		if (cp && ((cp->dport != dport) ||
> +			   !ip_vs_addr_equal(cp->daf, &cp->daddr, daddr))) {
> +			if (!(flags & IP_VS_CONN_F_INACTIVE)) {
> +				ip_vs_conn_expire_now(cp);
> +				__ip_vs_conn_put(cp);
> +				cp = NULL;
> +			} else {
> +				/* This is the expiration message for the
> +				 * connection that was already replaced, so we
> +				 * just ignore it.
> +				 */
> +				__ip_vs_conn_put(cp);
> +				kfree(param->pe_data);
> +				return;
> +			}
> +		}
> +	} else {
>  		cp = ip_vs_ct_in_get(param);
> +	}
>  
>  	if (cp) {
>  		/* Free pe_data */
> -- 
> 1.9.3

Regards

--
Julian Anastasov <ja@ssi.bg>
