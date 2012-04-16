From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] IPVS: make failure of netns init more stable
Date: Mon, 16 Apr 2012 17:25:23 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204161621080.1711@ja.ssi.bg>
References: <1334576378-2034-1-git-send-email-hans.schillstrom@ericsson.com> <1334576378-2034-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1334576378-2034-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com


	Hello,

On Mon, 16 Apr 2012, Hans Schillstrom wrote:

> Add a IP_VS_F_NET_INIT_OK flag
> that other modules can use for check of a successful init of ip_vs
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---

> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index b5a5c73..58722a2 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c

> @@ -1881,7 +1881,7 @@ static int __net_init __ip_vs_init(struct net *net)
>  		return -ENOMEM;
>  
>  	/* Hold the beast until a service is registerd */
> -	ipvs->enable = 0;
> +	ipvs->status = 0;
>  	ipvs->net = net;
>  	/* Counters used for creating unique names */
>  	ipvs->gen = atomic_read(&ipvs_netns_cnt);
> @@ -1906,6 +1906,7 @@ static int __net_init __ip_vs_init(struct net *net)
>  	if (ip_vs_sync_net_init(net) < 0)
>  		goto sync_fail;
>  
> +	IPVS_NETNS_OK(ipvs);
>  	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
>  			 sizeof(struct netns_ipvs), ipvs->gen);
>  	return 0;
> @@ -1924,6 +1925,7 @@ protocol_fail:
>  control_fail:
>  	ip_vs_estimator_net_cleanup(net);
>  estimator_fail:
> +	ipvs->status = 0;	/* Nothing is enabled */

	While 1st patch looks ok, keeping net->ipvs after
failure is not going to work. It seems you ignored the patch
I already posted. We duplicate the pointer in net->ipvs but
it should not be used after free.

	Note that net_generic() and net->ipvs can not be
used after ops_exit/ops_free and failed ops_init.

	But I see some inconsistency in net/core/net_namespace.c:
__register_pernet_operations when CONFIG_NET_NS is enabled
does not call ops_free after failed ops_init while when
CONFIG_NET_NS is not enabled ops_free is called. The
problem is that we leak the ops->size data allocated for the
failed net. I think, the fix should be ops_init to free the data.

	The 2nd problem is that after ops_free the
net_generic pointer remains assigned in ptr[id-1], even
after being freed. Not sure if recent changes to net_generic()
can deal with freed data. This BUG_ON(!ptr) can not catch
problems if one subsys uses net_generic() for another
subsys that can be unregistered.

	I'm going to test such fix for ops_init:

[PATCH] netns: do not leak net_generic data on failed init

	ops_init should free the net_generic data on
init failure and __register_pernet_operations should not
call ops_free when NET_NS is not enabled.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/core/net_namespace.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 0e950fd..31a5ae5 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -83,21 +83,29 @@ assign:
 
 static int ops_init(const struct pernet_operations *ops, struct net *net)
 {
-	int err;
+	int err = -ENOMEM;
+	void *data = NULL;
+
 	if (ops->id && ops->size) {
-		void *data = kzalloc(ops->size, GFP_KERNEL);
+		data = kzalloc(ops->size, GFP_KERNEL);
 		if (!data)
-			return -ENOMEM;
+			goto out;
 
 		err = net_assign_generic(net, *ops->id, data);
-		if (err) {
-			kfree(data);
-			return err;
-		}
+		if (err)
+			goto cleanup;
 	}
+	err = 0;
 	if (ops->init)
-		return ops->init(net);
-	return 0;
+		err = ops->init(net);
+	if (!err)
+		return 0;
+
+cleanup:
+	kfree(data);
+
+out:
+	return err;
 }
 
 static void ops_free(const struct pernet_operations *ops, struct net *net)
@@ -448,12 +456,7 @@ static void __unregister_pernet_operations(struct pernet_operations *ops)
 static int __register_pernet_operations(struct list_head *list,
 					struct pernet_operations *ops)
 {
-	int err = 0;
-	err = ops_init(ops, &init_net);
-	if (err)
-		ops_free(ops, &init_net);
-	return err;
-	
+	return ops_init(ops, &init_net);
 }
 
 static void __unregister_pernet_operations(struct pernet_operations *ops)
-- 
1.7.3.4

> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index debb8c7..6bc2420 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -439,6 +439,8 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
>  	struct ip_vs_app *app;
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> +	if (!IS_IPVS_NETNS_OK(ipvs))
> +		return -EUNATCH;

	I already provided patch for ip_vs_ftp.

>  	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
>  	if (!app)
>  		return -ENOMEM;
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index 27c24f1..f158f0c 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -551,6 +551,9 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
>  {
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> +	if (!IS_IPVS_NETNS_OK(ipvs))
> +		return -EUNATCH;
> +

	As for LBLC* they need just net->ipvs != NULL
check because net_generic can not be trusted for
other subsys.

>  	if (!net_eq(net, &init_net)) {
>  		ipvs->lblc_ctl_table = kmemdup(vs_vars_table,
>  						sizeof(vs_vars_table),
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index 7498756..aeecda4 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -745,6 +745,9 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
>  {
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> +	if (!IS_IPVS_NETNS_OK(ipvs))
> +		return -EUNATCH;
> +
>  	if (!net_eq(net, &init_net)) {
>  		ipvs->lblcr_ctl_table = kmemdup(vs_vars_table,
>  						sizeof(vs_vars_table),
> -- 
> 1.7.2.3

Regards

--
Julian Anastasov <ja@ssi.bg>
