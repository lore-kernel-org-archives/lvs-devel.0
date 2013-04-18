From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 6/6] ipvs: fix the remaining sparse warnings in
 ip_vs_ctl.c
Date: Thu, 18 Apr 2013 20:56:08 +0900
Message-ID: <20130418115608.GF11486@verge.net.au>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg>
 <1366231850-22188-7-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366231850-22188-7-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Wed, Apr 17, 2013 at 11:50:50PM +0300, Julian Anastasov wrote:
> - RCU annotations for ip_vs_info_seq_start and _stop
> - __percpu for cpustats
> - properly dereference svc->pe in ip_vs_genl_fill_service

Thanks, I have queued this up in ipvs-next.

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 68901e4..5b142fb 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1945,8 +1945,8 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
>  }
>  
>  static void *ip_vs_info_seq_start(struct seq_file *seq, loff_t *pos)
> +	__acquires(RCU)
>  {
> -
>  	rcu_read_lock();
>  	return *pos ? ip_vs_info_array(seq, *pos - 1) : SEQ_START_TOKEN;
>  }
> @@ -2001,6 +2001,7 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
>  }
>  
>  static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
> +	__releases(RCU)
>  {
>  	rcu_read_unlock();
>  }
> @@ -2145,7 +2146,7 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
>  {
>  	struct net *net = seq_file_single_net(seq);
>  	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
> -	struct ip_vs_cpu_stats *cpustats = tot_stats->cpustats;
> +	struct ip_vs_cpu_stats __percpu *cpustats = tot_stats->cpustats;
>  	struct ip_vs_stats_user rates;
>  	int i;
>  
> @@ -2882,6 +2883,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
>  				   struct ip_vs_service *svc)
>  {
>  	struct ip_vs_scheduler *sched;
> +	struct ip_vs_pe *pe;
>  	struct nlattr *nl_service;
>  	struct ip_vs_flags flags = { .flags = svc->flags,
>  				     .mask = ~0 };
> @@ -2903,9 +2905,9 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
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
>  	    nla_put_be32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask))
> -- 
> 1.7.3.4
> 
