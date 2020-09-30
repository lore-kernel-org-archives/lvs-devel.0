From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3] ipvs: Add traffic statistic up even it is VS/DR or
 VS/TUN mode
Date: Wed, 30 Sep 2020 21:19:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2009302019180.5709@ja.home.ssi.bg>
References: <20200929074110.33d7d740@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com> <20200930012611.54859-1-bigclouds@163.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20200930012611.54859-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "longguang.yue" <bigclouds@163.com>
Cc: kuba@kernel.org, yuelongguang@gmail.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>


	Hello,

On Wed, 30 Sep 2020, longguang.yue wrote:

> It's ipvs's duty to do traffic statistic if packets get hit,
> no matter what mode it is.
> 
> Signed-off-by: longguang.yue <bigclouds@163.com>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 14 ++++++++++++--
>  net/netfilter/ipvs/ip_vs_core.c |  5 ++++-
>  2 files changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index a90b8eac16ac..c4d164ce8ca7 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -401,6 +401,8 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
>  struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
>  {
>  	unsigned int hash;
> +	__be16 cport;
> +	const union nf_inet_addr *caddr;
>  	struct ip_vs_conn *cp, *ret=NULL;

	May be we can do it in few rounds, here is a list
of some initial notes...

	caddr/cport are misleading, can be saddr/sport (source)
or laddr/lport (local).

>  	/*
> @@ -411,10 +413,18 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
>  	rcu_read_lock();
>  
>  	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {

	Lets first check here for cp->cport before touching more
cache lines while traversing the list, it eliminates the cost of
next checks:

		if (p->vport != cp->cport)
			continue;

		then

		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
		...

> -		if (p->vport == cp->cport && p->cport == cp->dport &&
> +		cport = cp->dport;
> +		caddr = &cp->daddr;
> +
> +		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
> +			cport = cp->vport;
> +			caddr = &cp->vaddr;
> +		}

	Considering the issues solved by commit 3c5ab3f395d6,
such check more correctly matches the replies from DR/TUN
real server to local clients but also to remote clients
if director is used as router.

> +
> +		if (p->vport == cp->cport && p->cport == cport &&

		if (p->cport == sport &&
			...

>  		    cp->af == p->af &&
>  		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
> -		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
> +		    ip_vs_addr_equal(p->af, p->caddr, caddr) &&
>  		    p->protocol == cp->protocol &&
>  		    cp->ipvs == p->ipvs) {
>  			if (!__ip_vs_conn_get(cp))
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index e3668a6e54e4..7ba88dab297a 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1413,8 +1413,11 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>  			     ipvs, af, skb, &iph);
>  
>  	if (likely(cp)) {
> -		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
> +		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
> +			ip_vs_out_stats(cp, skb);
> +			skb->ipvs_property = 1;

	We will also need:

			if (!(cp->flags & IP_VS_CONN_F_NFCT))
				ip_vs_notrack(skb);

	Similar code is needed in handle_response_icmp(),
so that we account ICMP packets, where a jump to new label
before ip_vs_out_stats() can work.

	But such jump is preferred even for handle_response()
because the (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) check
should be moved from ip_vs_out() into handle_response().
For this to work the ip_vs_set_state() call in handle_response()
should be moved before the new label and ip_vs_out_stats() call.

>  			goto ignore_cp;
> +		}
>  		return handle_response(af, skb, pd, cp, &iph, hooknum);
>  	}

Regards

--
Julian Anastasov <ja@ssi.bg>

