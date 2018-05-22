From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: drop templates for never established TCP
 connections
Date: Tue, 22 May 2018 10:51:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1805220913400.2113@ja.home.ssi.bg>
References: <20180521172707.14106-1-mkoutny@suse.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="-1463811672-586259141-1526975510=:2113"
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180521172707.14106-1-mkoutny@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: =?UTF-8?Q?Michal_Koutn=C3=BD?= <mkoutny@suse.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, mkubecek@suse.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-586259141-1526975510=:2113
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Mon, 21 May 2018, Michal Koutný wrote:

> IPVS includes protection against filling the ip_vs_conn_tab by dropping 1/32 of
> feasible entries every second. The template entries (for persistent services)
> are never directly deleted by this mechanism but when a picked TCP connection
> entry is being dropped (1), the respective template entry is dropped too
> (realized by expiring 60 seconds after the connection entry being dropped).

	We try to drop the template in ip_vs_random_dropentry()
but I guess kernel/time/timer.c:enqueue_timer() puts both timers
in reverse order for expiration by using hlist_add_head().

> There is another mechanism that removes connection entries when they
> time out (2), in this case the associated template entry is not deleted.
> Under SYN flood template entries would accumulate (due to their entry
> longer timeout).

	There is also ip_vs_todrop() called in tcp_conn_schedule().
It just drops specific part from the SYNs on memory pressure.

> The accumulation takes place also with drop_entry being enabled. Roughly
> 15% ((31/32)^60) of SYN_RECV connections survive the dropping mechanism
> (1) and are removed by the timeout mechanism (2)(defaults to 60 seconds
> for SYN_RECV), thus template entries would still accumulate.
> 
> The patch ensures that when a connection entry times out, we also remove the
> template entry from the table. To prevent breaking persistent services (since
> the connection may time out in already established state) we add a new entry
> flag to protect templates what spawned at least one established TCP connection.
> 
> Cc: Michal Kubeček <mkubecek@suse.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>
> ---
>  include/uapi/linux/ip_vs.h           | 33 +++++++++++++++++----------------
>  net/netfilter/ipvs/ip_vs_conn.c      | 10 +++++++++-
>  net/netfilter/ipvs/ip_vs_core.c      | 15 ++++++++++++++-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c |  6 ++++++
>  4 files changed, 46 insertions(+), 18 deletions(-)
> 
> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index 1c916b2f89dc..ef3bbc001fcd 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -79,22 +79,23 @@
>   *      IPVS Connection Flags
>   *      Only flags 0..15 are sent to backup server
>   */
> -#define IP_VS_CONN_F_FWD_MASK	0x0007		/* mask for the fwd methods */
> -#define IP_VS_CONN_F_MASQ	0x0000		/* masquerading/NAT */
> -#define IP_VS_CONN_F_LOCALNODE	0x0001		/* local node */
> -#define IP_VS_CONN_F_TUNNEL	0x0002		/* tunneling */
> -#define IP_VS_CONN_F_DROUTE	0x0003		/* direct routing */
> -#define IP_VS_CONN_F_BYPASS	0x0004		/* cache bypass */
> -#define IP_VS_CONN_F_SYNC	0x0020		/* entry created by sync */
> -#define IP_VS_CONN_F_HASHED	0x0040		/* hashed entry */
> -#define IP_VS_CONN_F_NOOUTPUT	0x0080		/* no output packets */
> -#define IP_VS_CONN_F_INACTIVE	0x0100		/* not established */
> -#define IP_VS_CONN_F_OUT_SEQ	0x0200		/* must do output seq adjust */
> -#define IP_VS_CONN_F_IN_SEQ	0x0400		/* must do input seq adjust */
> -#define IP_VS_CONN_F_SEQ_MASK	0x0600		/* in/out sequence mask */
> -#define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
> -#define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
> -#define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
> +#define IP_VS_CONN_F_FWD_MASK		0x0007		/* mask for the fwd methods */
> +#define IP_VS_CONN_F_MASQ		0x0000		/* masquerading/NAT */
> +#define IP_VS_CONN_F_LOCALNODE		0x0001		/* local node */
> +#define IP_VS_CONN_F_TUNNEL		0x0002		/* tunneling */
> +#define IP_VS_CONN_F_DROUTE		0x0003		/* direct routing */
> +#define IP_VS_CONN_F_BYPASS		0x0004		/* cache bypass */
> +#define IP_VS_CONN_F_SYNC		0x0020		/* entry created by sync */
> +#define IP_VS_CONN_F_HASHED		0x0040		/* hashed entry */
> +#define IP_VS_CONN_F_NOOUTPUT		0x0080		/* no output packets */
> +#define IP_VS_CONN_F_INACTIVE		0x0100		/* not established */
> +#define IP_VS_CONN_F_OUT_SEQ		0x0200		/* must do output seq adjust */
> +#define IP_VS_CONN_F_IN_SEQ		0x0400		/* must do input seq adjust */
> +#define IP_VS_CONN_F_SEQ_MASK		0x0600		/* in/out sequence mask */
> +#define IP_VS_CONN_F_NO_CPORT		0x0800		/* no client port set yet */
> +#define IP_VS_CONN_F_TEMPLATE		0x1000		/* template, not connection */
> +#define IP_VS_CONN_F_ONE_PACKET		0x2000		/* forward only one packet */
> +#define IP_VS_CONN_F_TMPL_PERSISTED	0x4000		/* template, confirmed persistent */
>  
>  /* Initial bits allowed in backup server */
>  #define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 370abbf6f421..6afc606a388c 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -820,6 +820,7 @@ static void ip_vs_conn_rcu_free(struct rcu_head *head)
>  static void ip_vs_conn_expire(struct timer_list *t)
>  {
>  	struct ip_vs_conn *cp = from_timer(cp, t, timer);
> +	struct ip_vs_conn *cp_c;
>  	struct netns_ipvs *ipvs = cp->ipvs;
>  
>  	/*
> @@ -834,8 +835,15 @@ static void ip_vs_conn_expire(struct timer_list *t)
>  		del_timer(&cp->timer);
>  
>  		/* does anybody control me? */
> -		if (cp->control)
> +		cp_c = cp->control;
> +		if (cp_c) {
>  			ip_vs_control_del(cp);
> +			if (cp_c->flags & IP_VS_CONN_F_TEMPLATE &&
> +			    !(cp_c->flags & IP_VS_CONN_F_TMPL_PERSISTED)) {
> +				IP_VS_DBG(4, "del conn template\n");
> +				ip_vs_conn_expire_now(cp_c);

	So, we have current conn expired after 60 seconds
in IP_VS_TCP_S_SYN_RECV state and possibly other conns
in same state that are not expired yet.

	Another option is just to use something like:

	if (cp_c) {
		ip_vs_control_del(cp);
		/* Restart cp_c timer only for last conn */
		if (!atomic_read(&cp_c->n_control) &&
		    (cp_c->flags & IP_VS_CONN_F_TEMPLATE) &&
		    /* Some func to decide when to drop cp_c:
		     * - it can be for SYN state
		     * - it can be when cp was dropped on load
		     */
		    cp->state == IP_VS_TCP_S_SYN_RECV) {
			IP_VS_DBG(4, "del conn template\n");
			ip_vs_conn_expire_now(cp_c);
		}
	}

	It is not perfect, i.e. it does not know if there was
some conn that was established in the past:

- CONN1: SYN, SYN+ACK, ESTABLISH, FIN, FIN+ACK, expire
- CONN2: expire in SYN state, drop tpl before persistent timeout

	But it should work in the general case.
Anyways, give me some days to think more on this issue.

Regards
---1463811672-586259141-1526975510=:2113--
