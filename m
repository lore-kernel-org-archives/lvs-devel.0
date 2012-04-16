From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 2/2] IPVS: make failure of netns init more stable
Date: Mon, 16 Apr 2012 19:16:31 +0200
Message-ID: <201204161916.33621.hans.schillstrom@ericsson.com>
References: <1334576378-2034-1-git-send-email-hans.schillstrom@ericsson.com> <1334576378-2034-2-git-send-email-hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1204161621080.1711@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1204161621080.1711@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>

Hello
On Monday 16 April 2012 16:25:23 Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 16 Apr 2012, Hans Schillstrom wrote:
> 
> > Add a IP_VS_F_NET_INIT_OK flag
> > that other modules can use for check of a successful init of ip_vs
> > 
> > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> > ---
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index b5a5c73..58722a2 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> 
> > @@ -1881,7 +1881,7 @@ static int __net_init __ip_vs_init(struct net *net)
> >  		return -ENOMEM;
> >  
> >  	/* Hold the beast until a service is registerd */
> > -	ipvs->enable = 0;
> > +	ipvs->status = 0;
> >  	ipvs->net = net;
> >  	/* Counters used for creating unique names */
> >  	ipvs->gen = atomic_read(&ipvs_netns_cnt);
> > @@ -1906,6 +1906,7 @@ static int __net_init __ip_vs_init(struct net *net)
> >  	if (ip_vs_sync_net_init(net) < 0)
> >  		goto sync_fail;
> >  
> > +	IPVS_NETNS_OK(ipvs);
> >  	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
> >  			 sizeof(struct netns_ipvs), ipvs->gen);
> >  	return 0;
> > @@ -1924,6 +1925,7 @@ protocol_fail:
> >  control_fail:
> >  	ip_vs_estimator_net_cleanup(net);
> >  estimator_fail:
> > +	ipvs->status = 0;	/* Nothing is enabled */
> 
> 	While 1st patch looks ok, keeping net->ipvs after
> failure is not going to work. It seems you ignored the patch
> I already posted. We duplicate the pointer in net->ipvs but
> it should not be used after free.
> 
Sorry, I'll revert that.

> 	Note that net_generic() and net->ipvs can not be
> used after ops_exit/ops_free and failed ops_init.

True, when ip_vs(.ko) fails. I missed that.

> 
> 	But I see some inconsistency in net/core/net_namespace.c:
> __register_pernet_operations when CONFIG_NET_NS is enabled
> does not call ops_free after failed ops_init while when
> CONFIG_NET_NS is not enabled ops_free is called. The 
> problem is that we leak the ops->size data allocated for the
> failed net. I think, the fix should be ops_init to free the data.

Are you sure ?
In my code it does... 

static int __register_pernet_operations(struct list_head *list,
					struct pernet_operations *ops)
at line 417
..
		for_each_net(net) {
			error = ops_init(ops, net);
			if (error)
				goto out_undo;
...
line 426
out_undo:
	/* If I have an error cleanup all namespaces I initialized */
	list_del(&ops->list);
	ops_exit_list(ops, &net_exit_list);
	ops_free_list(ops, &net_exit_list);
	return error;
}


> 	The 2nd problem is that after ops_free the
> net_generic pointer remains assigned in ptr[id-1], even
> after being freed. Not sure if recent changes to net_generic()
> can deal with freed data. This BUG_ON(!ptr) can not catch
> problems if one subsys uses net_generic() for another
> subsys that can be unregistered.
> 
> 	I'm going to test such fix for ops_init:
> 
> [PATCH] netns: do not leak net_generic data on failed init
> 
> 	ops_init should free the net_generic data on
> init failure and __register_pernet_operations should not
> call ops_free when NET_NS is not enabled.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/core/net_namespace.c |   33 ++++++++++++++++++---------------
>  1 files changed, 18 insertions(+), 15 deletions(-)
> 
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 0e950fd..31a5ae5 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -83,21 +83,29 @@ assign:
>  
>  static int ops_init(const struct pernet_operations *ops, struct net *net)
>  {
> -	int err;
> +	int err = -ENOMEM;
> +	void *data = NULL;
> +
>  	if (ops->id && ops->size) {
> -		void *data = kzalloc(ops->size, GFP_KERNEL);
> +		data = kzalloc(ops->size, GFP_KERNEL);
>  		if (!data)
> -			return -ENOMEM;
> +			goto out;
>  
>  		err = net_assign_generic(net, *ops->id, data);
> -		if (err) {
> -			kfree(data);
> -			return err;
> -		}
> +		if (err)
> +			goto cleanup;
>  	}
> +	err = 0;
>  	if (ops->init)
> -		return ops->init(net);
> -	return 0;
> +		err = ops->init(net);
> +	if (!err)
> +		return 0;
> +
> +cleanup:
> +	kfree(data);
> +
> +out:
> +	return err;
>  }
>  
>  static void ops_free(const struct pernet_operations *ops, struct net *net)
> @@ -448,12 +456,7 @@ static void __unregister_pernet_operations(struct pernet_operations *ops)
>  static int __register_pernet_operations(struct list_head *list,
>  					struct pernet_operations *ops)
>  {
> -	int err = 0;
> -	err = ops_init(ops, &init_net);
> -	if (err)
> -		ops_free(ops, &init_net);
> -	return err;
> -	
> +	return ops_init(ops, &init_net);
>  }
>  
>  static void __unregister_pernet_operations(struct pernet_operations *ops)

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
