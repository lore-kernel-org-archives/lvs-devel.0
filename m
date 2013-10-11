From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 net-next] ipvs: avoid rcu_barrier during netns cleanup
Date: Fri, 11 Oct 2013 14:05:58 +0900
Message-ID: <20131011050558.GC4624@verge.net.au>
References: <1381299867-4929-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381299867-4929-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

Thanks Julian.

Pablo, could you merge net-next into nf-next so that
I can apply this patch on top of the later?

In particular I believe I need the following commit
to allow Julian's patch to apply cleanly (at all).

bcbde4c ("ipvs: make the service replacement more robust")

On Wed, Oct 09, 2013 at 09:24:27AM +0300, Julian Anastasov wrote:
> commit 578bc3ef1e473a ("ipvs: reorganize dest trash") added
> rcu_barrier() on cleanup to wait dest users and schedulers
> like LBLC and LBLCR to put their last dest reference.
> Using rcu_barrier with many namespaces is problematic.
> 
> Trying to fix it by freeing dest with kfree_rcu is not
> a solution, RCU callbacks can run in parallel and execution
> order is random.
> 
> Fix it by creating new function ip_vs_dest_put_and_free()
> which is heavier than ip_vs_dest_put(). We will use it just
> for schedulers like LBLC, LBLCR that can delay their dest
> release.
> 
> By default, dests reference is above 0 if they are present in
> service and it is 0 when deleted but still in trash list.
> Change the dest trash code to use ip_vs_dest_put_and_free(),
> so that refcnt -1 can be used for freeing. As result,
> such checks remain in slow path and the rcu_barrier() from
> netns cleanup can be removed.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> v2: no changes after v1
> 
>  include/net/ip_vs.h              |    6 ++++++
>  net/netfilter/ipvs/ip_vs_ctl.c   |    6 +-----
>  net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
>  net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
>  4 files changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 1c2e1b9..cd7275f 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1442,6 +1442,12 @@ static inline void ip_vs_dest_put(struct ip_vs_dest *dest)
>  	atomic_dec(&dest->refcnt);
>  }
>  
> +static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
> +{
> +	if (atomic_dec_return(&dest->refcnt) < 0)
> +		kfree(dest);
> +}
> +
>  /*
>   *      IPVS sync daemon data and function prototypes
>   *      (from ip_vs_sync.c)
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index a3df9bd..62786a4 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -704,7 +704,7 @@ static void ip_vs_dest_free(struct ip_vs_dest *dest)
>  	__ip_vs_dst_cache_reset(dest);
>  	__ip_vs_svc_put(svc, false);
>  	free_percpu(dest->stats.cpustats);
> -	kfree(dest);
> +	ip_vs_dest_put_and_free(dest);
>  }
>  
>  /*
> @@ -3820,10 +3820,6 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
>  {
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> -	/* Some dest can be in grace period even before cleanup, we have to
> -	 * defer ip_vs_trash_cleanup until ip_vs_dest_wait_readers is called.
> -	 */
> -	rcu_barrier();
>  	ip_vs_trash_cleanup(net);
>  	ip_vs_stop_estimator(net, &ipvs->tot_stats);
>  	ip_vs_control_net_cleanup_sysctl(net);
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index eff13c9..ca056a3 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -136,7 +136,7 @@ static void ip_vs_lblc_rcu_free(struct rcu_head *head)
>  						   struct ip_vs_lblc_entry,
>  						   rcu_head);
>  
> -	ip_vs_dest_put(en->dest);
> +	ip_vs_dest_put_and_free(en->dest);
>  	kfree(en);
>  }
>  
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index 0b85500..3f21a2f 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -130,7 +130,7 @@ static void ip_vs_lblcr_elem_rcu_free(struct rcu_head *head)
>  	struct ip_vs_dest_set_elem *e;
>  
>  	e = container_of(head, struct ip_vs_dest_set_elem, rcu_head);
> -	ip_vs_dest_put(e->dest);
> +	ip_vs_dest_put_and_free(e->dest);
>  	kfree(e);
>  }
>  
> -- 
> 1.7.3.4
> 
