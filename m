From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v5] ipvs: Add traffic statistic up even it is VS/DR or
 VS/TUN mode
Date: Sun, 4 Oct 2020 15:25:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2010041409460.5398@ja.home.ssi.bg>
References: <alpine.LFD.2.23.451.2010022149210.4429@ja.home.ssi.bg> <20201004041300.75850-1-bigclouds@163.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20201004041300.75850-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "longguang.yue" <bigclouds@163.com>
Cc: kuba@kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, yuelongguang@gmail.com


	Hello,

On Sun, 4 Oct 2020, longguang.yue wrote:

> It's ipvs's duty to do traffic statistic if packets get hit,
> no matter what mode it is.
> 
> ----------------------
> Changes in v1: support DR/TUN mode statistic
> Changes in v2: ip_vs_conn_out_get handles DR/TUN mode's conn
> Changes in v3: fix checkpatch
> Changes in v4, v5: restructure and optimise this feature

	Tested it, patch works. But we should add info about all
new changes that v5 brings.

	First, the changelog between versions is usually to inform 
maintainers what is changed. Its place is after the "---" line
when we do not want it to be part of the commit log. Such long "-"
lines are not needed. See "14) The canonical patch format" from
Documentation/process/submitting-patches.rst

	As for commit log, we can add such info before
your two lines, for example:

Just like for MASQ, inspect the reply packets coming from DR/TUN
real servers and alter the connection's state and timeout
according to the protocol.

	Then your 2 lines will specify that stats are accounted too.

	The Subject can be changed too, for example:

[PATCH v6 net-next] ipvs: inspect reply packets from DR/TUN real servers

> ----------------------
> 
> Signed-off-by: longguang.yue <bigclouds@163.com>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 18 +++++++++++++++---
>  net/netfilter/ipvs/ip_vs_core.c | 17 ++++++-----------
>  2 files changed, 21 insertions(+), 14 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index a90b8eac16ac..af08ca2d9174 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -401,6 +401,8 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
>  struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
>  {
>  	unsigned int hash;
> +	__be16 sport;
> +	const union nf_inet_addr *saddr;
>  	struct ip_vs_conn *cp, *ret=NULL;

	Developers prefer the reverse xmas tree order of variables
where they are listed from longest to shortest, so we can do it
at least for new changes:

	struct ip_vs_conn *cp, *ret=NULL;
+	const union nf_inet_addr *saddr;
+	__be16 sport;

>  	/*
> @@ -411,10 +413,20 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
>  	rcu_read_lock();
>  
>  	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
> -		if (p->vport == cp->cport && p->cport == cp->dport &&
> -		    cp->af == p->af &&
> +		if (p->vport != cp->cport)
> +			continue;
> +
> +		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ) {
> +			sport = cp->vport;
> +			saddr = &cp->vaddr;
> +		} else {
> +			sport = cp->dport;
> +			saddr = &cp->daddr;
> +		}
> +
> +		if (p->cport == sport && cp->af == p->af &&
>  		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
> -		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
> +		    ip_vs_addr_equal(p->af, p->caddr, saddr) &&
>  		    p->protocol == cp->protocol &&
>  		    cp->ipvs == p->ipvs) {
>  			if (!__ip_vs_conn_get(cp))
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index e3668a6e54e4..494ea1fcf4d8 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -875,7 +875,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
>  	unsigned int verdict = NF_DROP;
>  
>  	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
> -		goto ignore_cp;
> +		goto after_nat;
>  
>  	/* Ensure the checksum is correct */
>  	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
> @@ -900,7 +900,7 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
>  
>  	if (ip_vs_route_me_harder(cp->ipvs, af, skb, hooknum))
>  		goto out;
> -
> +after_nat:
>  	/* do the statistics and put it back */
>  	ip_vs_out_stats(cp, skb);
>  
> @@ -909,8 +909,6 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
>  		ip_vs_notrack(skb);
>  	else
>  		ip_vs_update_conntrack(skb, cp, 0);
> -
> -ignore_cp:
>  	verdict = NF_ACCEPT;
>  
>  out:
> @@ -1276,6 +1274,9 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  {
>  	struct ip_vs_protocol *pp = pd->pp;
>  
> +	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
> +		goto after_nat;
> +
>  	IP_VS_DBG_PKT(11, af, pp, skb, iph->off, "Outgoing packet");
>  
>  	if (skb_ensure_writable(skb, iph->len))
> @@ -1316,6 +1317,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  
>  	IP_VS_DBG_PKT(10, af, pp, skb, iph->off, "After SNAT");
>  
> +after_nat:
>  	ip_vs_out_stats(cp, skb);
>  	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pd);
>  	skb->ipvs_property = 1;
> @@ -1413,8 +1415,6 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>  			     ipvs, af, skb, &iph);
>  
>  	if (likely(cp)) {
> -		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
> -			goto ignore_cp;
>  		return handle_response(af, skb, pd, cp, &iph, hooknum);
>  	}
>  
> @@ -1475,14 +1475,9 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>  		}
>  	}
>  
> -out:
>  	IP_VS_DBG_PKT(12, af, pp, skb, iph.off,
>  		      "ip_vs_out: packet continues traversal as normal");
>  	return NF_ACCEPT;
> -
> -ignore_cp:
> -	__ip_vs_conn_put(cp);
> -	goto out;
>  }
>  
>  /*
> -- 
> 2.20.1 (Apple Git-117)

Regards

--
Julian Anastasov <ja@ssi.bg>

