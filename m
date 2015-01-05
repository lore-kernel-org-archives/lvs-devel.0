From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC] ipvs: reschedule new connections if previous was on
 FIN_WAIT or TIME_WAIT
Date: Tue, 6 Jan 2015 00:26:14 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501052326290.11288@ja.home.ssi.bg>
References: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com> <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg> <54883DCA.7050906@redhat.com> <54887B3C.2000709@redhat.com> <alpine.LFD.2.11.1412102217500.4043@ja.home.ssi.bg>
 <548991AF.1050502@redhat.com> <alpine.LFD.2.11.1412112207350.2098@ja.home.ssi.bg> <548AD85D.1070109@redhat.com> <54A301AD.8060002@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <54A301AD.8060002@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: lvs-devel@vger.kernel.org, hannes@redhat.com, jbrouer@redhat.com


	Hello,

On Tue, 30 Dec 2014, Marcelo Ricardo Leitner wrote:

> What if we make the backup server purge the old entry, just like the active server does, and ignore old updates if needed? Please note the new hunk on ip_vs_sync.c. This is the patch I'm using so far, and I'm seeing good results with even with master/backup. Backup server successfully purges the old and creates a new entry when it detects such update:
> 
> [  344.971673] IPVS: Bind-dest TCP c:192.168.122.1:22222 v:192.168.122.200:80 d:192.168.122.67:80 fwd:R s:0 conn->flags:A3 conn->refcnt:1 dest->refcnt:2
> [  344.972071] IPVS: Unbind-dest TCP c:192.168.122.1:22222 v:192.168.122.200:80 d:192.168.122.95:80 fwd:R s:4 conn->flags:1A3 conn->refcnt:0 dest->refcnt:2

	Good idea

> -- 8< --
> 
>  /* IPVS core functions
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 990decba1fe418e36e59a1f081fcf0e47188da29..da2760496314d49a5b4f6f588de7cb565a28e223 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1036,6 +1036,20 @@ static inline bool is_new_conn(const struct sk_buff *skb,
>  	}
>  }
>  
> +static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
> +					int conn_reuse_mode)
> +{
> +	if ((cp->protocol != IPPROTO_TCP) && (cp->protocol != IPPROTO_SCTP))
> +		return false;

	If we want SCTP support may be we have to check
cp->state for IP_VS_SCTP_S_CLOSED, it is analog to
our IP_VS_TCP_S_TIME_WAIT state. But cp->state checks
should be per protocol, eg:

	/* Controlled (FTP DATA or persistence)? */
	if (cp->control)
		return false;
	switch (cp->protocol)
	{
	case IPPROTO_TCP:
		return ...
	case IPPROTO_SCTP:
		return cp->state == IP_VS_SCTP_S_CLOSED;
	default:
		return false;
	}

> +	/* Controlled (FTP DATA or persistence)? */
> +	if (cp->control)
> +		return false;
> +	return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
> +	       ((conn_reuse_mode & 2) &&
> +		(cp->state == IP_VS_TCP_S_FIN_WAIT) &&
> +		(cp->flags & IP_VS_CONN_F_NOOUTPUT));
> +}
> +
>  /* Handle response packets: rewrite addresses and send away...
>   */
>  static unsigned int
> @@ -1574,6 +1588,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	struct ip_vs_conn *cp;
>  	int ret, pkts;
>  	struct netns_ipvs *ipvs;
> +	int conn_reuse_mode;
>  
>  	/* Already marked as IPVS request or reply? */
>  	if (skb->ipvs_property)
> @@ -1642,9 +1657,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	 */
>  	cp = pp->conn_in_get(af, skb, &iph, 0);
>  
> -	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
> -	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
> -	    is_new_conn(skb, &iph)) {
> +	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
> +	if (conn_reuse_mode && !iph.fragoffs &&
> +	    is_new_conn(skb, &iph) && cp &&
> +	    !atomic_read(&cp->n_control) &&

	Above n_control check will prevent FTP:21 connections
to be replaced when expire_nodest_conn=1. May be the n_control
check should be moved below to avoid ip_vs_conn_expire_now?
Like this:

	if (!atomic_read(&cp->n_control))
		ip_vs_conn_expire_now(cp);
	__ip_vs_conn_put(cp);
	cp = NULL;

	I.e. old connection will not be tried for expiration
but we still create new connection. The old will not be visible
to packets.

> +	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
> +	      unlikely(!atomic_read(&cp->dest->weight))) ||
> +	     unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
>  		ip_vs_conn_expire_now(cp);
>  		__ip_vs_conn_put(cp);
>  		cp = NULL;

> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index c47ffd7a0a709cb73834c84652f251960f25db79..7ed4484c2c93e0aed89be55c773c94f3c80cc09e 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -850,6 +850,21 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
>  	else
>  		cp = ip_vs_ct_in_get(param);
>  
> +	if (cp && ((cp->dport != dport) ||
> +		   !ip_vs_addr_equal(cp->af, &cp->daddr, daddr))) {

	Better to use here the new cp->daf field
instead of cp->af.

> +		if (!(flags & IP_VS_CONN_F_INACTIVE)) {

	I guess, we here try to avoid old sync message to
expire new connection. The problem is that UDP conns and
templates are always IP_VS_CONN_F_INACTIVE, may be a TCP+SCTP
protocol check is needed.

> +			ip_vs_conn_expire_now(cp);
> +			__ip_vs_conn_put(cp);
> +			cp = NULL;
> +		} else {
> +			/* This is the expiration message for the
> +			 * connection that was already replaced, so we
> +			 * just ignore it.
> +			 */
> +			goto out;
> +		}
> +	}
> +
>  	if (cp) {
>  		/* Free pe_data */
>  		kfree(param->pe_data);
> @@ -925,6 +940,8 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
>  		else
>  			cp->timeout = (3*60*HZ);
>  	}
> +
> +out:
>  	ip_vs_conn_put(cp);
>  }
>  

Regards

--
Julian Anastasov <ja@ssi.bg>
