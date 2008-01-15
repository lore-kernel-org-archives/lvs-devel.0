From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Runtime interception method switch
Date: Tue, 15 Jan 2008 17:20:00 +0900
Message-ID: <20080115081959.GA8826@verge.net.au>
References: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <07C2E63F-FDF8-45D5-A20C-0B294C119A5E@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>

On Sun, Jan 13, 2008 at 04:12:38PM +0100, Raphael Vallazza wrote:
> Hi,
>
> i've just finished the patch for changing the connection interception  
> method at runtime (in /proc/sys/net/ipv4/vs/input_hook), it works pretty 
> well :) I've tested it with all the seetings and it worked without any 
> problems.
>
> It has been made for net-2.6.25 branch. I've also made some minor  
> corrections to the "connection interception choice patch". These patches 
> have to be appliet together...
>
> Thanks,
> Raphael
>
> P.S. i hope my mailer doesn't mess up the patches this time :-/

Unfortunately it did :-(

That asside, the patches look basically good.
I rediffed them and they seem to work fine.
Let me know if you want my version of the patches,
though I have not fixed all the issues that I saw.

Comments in-line.

> -- 
> :: e n d i a n
> :: open source - open minds
>
>
> #### 0001-IPVS-Add-choice-for-connection-interception-method.patch ####
>
> [PATCH] [IPVS]: Add choice for connection interception method
>
> This patch adds an option to set the position at which IPVS intercepts
> incoming connections from Netfilter.
>
> The options are:
>
> 1. INPUT (default)
> Intercept incoming connections after they have traveled through
> the INPUT table, only connections that have the director as
> destination address will be processed.
>
> 2. FORWARD
> Intercept incoming connections after they have traveled through
> the INPUT or the FORWARD table. It has the same functionlity of
> the "INPUT method", but also processes connections that are
> routed through the director, supporting VIP-less setups.
>
> 3. PREROUTING
> Intercept incoming connections before DNAT and input filtering
> has been applied, this enables transparent proxying on realnodes
> and localnode.
>
> Signed-off-by: Raphael Vallazza <raphael@endian.com>
> ---
>  net/ipv4/ipvs/Kconfig      |   44 +++++++++++++++++++++++++++++++++++ 
> +++++++++
>  net/ipv4/ipvs/ip_vs_core.c |   30 +++++++++++++++++++++++++++++-
>  2 files changed, 73 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
> index 09d0c3f..319f3e8 100644
> --- a/net/ipv4/ipvs/Kconfig
> +++ b/net/ipv4/ipvs/Kconfig
> @@ -24,6 +24,50 @@ menuconfig IP_VS
>
>  if IP_VS
>
> +choice
> +	prompt "IPVS connection interception method"
> +	default IP_VS_INPUT_LOCAL_IN
> +	help
> +	  This option sets the position at which IPVS intercepts incoming
> +	  connections from Netfilter. If in doubt select 'LOCAL_IN'.
> +
> +config IP_VS_INPUT_LOCAL_IN
> +	bool "INPUT"
> +	---help---
> +	  Intercept incoming connections after they have traveled through
> +	  the INPUT table, only connections that have the director as
> +	  destination address will be processed.
> +
> +	  This method allows to apply packet filtering in the INPUT table
> +	  before the connection is intercepted by IPVS.
> +
> +config IP_VS_INPUT_FORWARD
> +	bool "FORWARD"
> +	---help---
> +	  Intercept incoming connections after they have traveled through
> +	  the INPUT or the FORWARD table. It has the same functionlity of
> +	  the "INPUT method", but also processes connections that are
> +	  routed through the director, supporting VIP-less setups.
> +
> +	  This method allows to apply packet filtering in the INPUT or
> +	  FORWARD table, before the connection is intercepted by IPVS.
> +
> +config IP_VS_INPUT_PRE_ROUTING
> +	bool "PREROUTING"
> +	---help---
> +	  Intercept incoming connections before DNAT and input filtering
> +	  has been applied, this allows transparent proxying on realnodes
> +	  and localnode. Incoming connections are intercepted right after
> +	  the mangle PREROUTING table and before the nat PREROUTING table,
> +	  supporting VIP-less setups.
> +
> +	  WARNING: This method doesn't apply any packet filtering before
> +	  packets are intercepted by IPVS. To filter the connections that
> +	  should be intercepted, you have to mark the traffic in the
> +	  mangle PREROUTING table.
> +
> +endchoice
> +
>  config	IP_VS_DEBUG
>  	bool "IP virtual server debugging"
>  	---help---
> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> index 963981a..0da4ef6 100644
> --- a/net/ipv4/ipvs/ip_vs_core.c
> +++ b/net/ipv4/ipvs/ip_vs_core.c
> @@ -1026,6 +1026,7 @@ ip_vs_forward_icmp(unsigned int hooknum, struct  
> sk_buff *skb,
>
>
>  static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
> +#if defined(CONFIG_IP_VS_INPUT_LOCAL_IN) || defined(CONFIG_IP_VS_INPUT_FORWARD)

Shouldn't this just be

#if defined(CONFIG_IP_VS_INPUT_LOCAL_IN)

>  	/* After packet filtering, forward packet through VS/DR, VS/TUN,
>  	 * or VS/NAT(change destination), so that filtering rules can be
>  	 * applied to IPVS. */
> @@ -1036,6 +1037,33 @@ static struct nf_hook_ops ip_vs_ops[]  
> __read_mostly = {
>  		.hooknum        = NF_INET_LOCAL_IN,
>  		.priority       = 100,
>  	},
> +#endif
> +#ifdef CONFIG_IP_VS_INPUT_FORWARD
> +	/* Intercept incoming connections after they have traveled through
> +	 * the INPUT or the FORWARD table. It has the same functionlity of
> +	 * the "INPUT method", but also processes connections that are
> +	 * routed through the director, supporting VIP-less setups. */
> +	{
> +		.hook		= ip_vs_in,
> +		.owner		= THIS_MODULE,
> +		.pf		= PF_INET,
> +		.hooknum        = NF_INET_FORWARD,
> +		.priority       = 98,
> +	},
> +#endif
> +#ifdef CONFIG_IP_VS_INPUT_PRE_ROUTING
> +	/* Intercept incoming connections before DNAT and input filtering
> +	 * has been applied, this enables ransparent proxying on realnodes
> +	 * and localnode. Hook right after MANGLE and before NAT_DST.
> +	 */
> +	{
> +		.hook           = ip_vs_in,
> +		.owner          = THIS_MODULE,
> +		.pf             = PF_INET,
> +		.hooknum        = NF_INET_PRE_ROUTING,
> +		.priority       = NF_IP_PRI_NAT_DST - 1,
> +	},
> +#endif
>  	/* After packet filtering, change source only for VS/NAT */
>  	{
>  		.hook		= ip_vs_out,
> @@ -1059,7 +1087,7 @@ static struct nf_hook_ops ip_vs_ops[]  
> __read_mostly = {
>  		.owner		= THIS_MODULE,
>  		.pf		= PF_INET,
>  		.hooknum        = NF_INET_POST_ROUTING,
> -		.priority       = NF_IP_PRI_NAT_SRC-1,
> +		.priority       = NF_IP_PRI_NAT_SRC - 1,
>  	},
>  };
>
> -- 
> 1.5.3.7
>
>
> #### 0002-IPVS-Runtime-interception-method-switch.patch ####
>
> [IPVS]: Runtime interception method switch
>
> This patch allows to switch interception method at runtime by changing
> the value of /proc/sys/net/ipv4/vs/input_hook with one of the following
> values:
> 0 = INPUT
> 1 = FORWARD
> 2 = PREROUTING

Could you ass documentation of this to
Documentation/networking/ipvs-sysctl.txt ?

>
> Signed-off-by: Raphael Vallazza <raphael@endian.com>
> ---
>  include/net/ip_vs.h        |   15 +++++
>  net/ipv4/ipvs/Kconfig      |   10 +++-
>  net/ipv4/ipvs/ip_vs_core.c |  141 +++++++++++++++++++++++++++++++++++ 
> ++-------
>  net/ipv4/ipvs/ip_vs_ctl.c  |   43 +++++++++++++
>  4 files changed, 186 insertions(+), 23 deletions(-)
>
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 56f3c94..6b71e31 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -681,6 +681,21 @@ extern void ip_vs_init_hash_table(struct list_head 
> *table, int rows);
>  #define IP_VS_APP_TYPE_FTP	1
>
>  /*
> + *	IPVS input hook functions
> + */
> +enum {
> +	IP_VS_INPUT_HOOK_FIRST = -1,
> +	IP_VS_INPUT_HOOK_LOCAL_IN,
> +	IP_VS_INPUT_HOOK_FORWARD,
> +	IP_VS_INPUT_HOOK_PRE_ROUTING,
> +	IP_VS_INPUT_HOOK_LAST,
> +};
> +
> +extern int ip_vs_get_input_hook(void);
> +extern int ip_vs_register_hooks(int input_hook);
> +extern int ip_vs_unregister_hooks(int input_hook);
> +
> +/*
>   *     ip_vs_conn handling functions
>   *     (from ip_vs_conn.c)
>   */
> diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
> index 319f3e8..19217d7 100644
> --- a/net/ipv4/ipvs/Kconfig
> +++ b/net/ipv4/ipvs/Kconfig
> @@ -28,8 +28,14 @@ choice
>  	prompt "IPVS connection interception method"
>  	default IP_VS_INPUT_LOCAL_IN
>  	help
> -	  This option sets the position at which IPVS intercepts incoming
> -	  connections from Netfilter. If in doubt select 'LOCAL_IN'.
> +	  This option selects the default position at which IPVS intercepts
> +	  incoming connections from Netfilter. If in doubt select 'INPUT'.
> +	
> +	  The interception method can be switched at runtime in
> +	  /proc/sys/net/ipv4/vs/input_hook with the following values:
> +	    0 = INPUT
> +	    1 = FORWARD
> +	    2 = PREROUTING	
>
>  config IP_VS_INPUT_LOCAL_IN
>  	bool "INPUT"
> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> index 0da4ef6..6acfbbd 100644
> --- a/net/ipv4/ipvs/ip_vs_core.c
> +++ b/net/ipv4/ipvs/ip_vs_core.c
> @@ -1024,12 +1024,111 @@ ip_vs_forward_icmp(unsigned int hooknum, struct 
> sk_buff *skb,
>  	return ip_vs_in_icmp(skb, &r, hooknum);
>  }
>
> +/*
> + * Register netfilter hook based on input_hook type
> + */
> +
> +int ip_vs_register_hooks(int input_hook)
> +{
> +	int ret;
> +	char *hookstr;
> +	struct nf_hook_ops *in_hooks;

	Just me, but in_hook seems like a better name than in_hooks.

> +	int count;
> +
> +	IP_VS_DBG(5, "Registering input hooks: %i\n", input_hook);
> +
> +	switch (input_hook) {
> +	case IP_VS_INPUT_HOOK_LOCAL_IN:
> +		hookstr = "INPUT";
> +		in_hooks = ip_vs_ops_local_in;
> +		count = ARRAY_SIZE(ip_vs_ops_local_in);
> +		break;
> +	case IP_VS_INPUT_HOOK_FORWARD:
> +		hookstr = "FORWARD";
> +		in_hooks = ip_vs_ops_forward;
> +		count = ARRAY_SIZE(ip_vs_ops_forward);
> +		break;
> +	case IP_VS_INPUT_HOOK_PRE_ROUTING:
> +		hookstr = "PREROUTING";
> +		in_hooks = ip_vs_ops_pre_routing;
> +		count = ARRAY_SIZE(ip_vs_ops_pre_routing);
> +		break;
> +	default:
> +		return -1;
> +	}

Could the calculation of count be moved out of the switch to here
as the following?

	count = ARRAY_SIZE(in_hooks);
> +
> +	ret = nf_register_hooks(in_hooks, count);
> +	if (ret < 0) {
> +		IP_VS_ERR("Can't register %s hooks.\n", hookstr);
> +		return -1;
> +	}
> +
> +	ret = nf_register_hooks(ip_vs_ops_generic,
> +				ARRAY_SIZE(ip_vs_ops_generic));
> +	if (ret < 0) {
> +		nf_unregister_hooks(in_hooks, count);
> +		IP_VS_ERR("Can't register generic hooks.\n");
> +		return -1;
> +	}
> +
> +	IP_VS_INFO("Registered interception method: %s\n", hookstr);
> +	return 0;
> +}
> +
> +/*
> + * Unregister netfilter hook based on input_hook type
> + */
>
> -static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
> -#if defined(CONFIG_IP_VS_INPUT_LOCAL_IN) ||  
> defined(CONFIG_IP_VS_INPUT_FORWARD)
> -	/* After packet filtering, forward packet through VS/DR, VS/TUN,
> -	 * or VS/NAT(change destination), so that filtering rules can be
> -	 * applied to IPVS. */
> +int ip_vs_unregister_hooks(int input_hook)
> +{
> +	struct nf_hook_ops *in_hooks;
> +	int count;
> +
> +	IP_VS_DBG(5, "Unregistering input hooks: %i\n", input_hook);
> +
> +	switch (input_hook) {
> +	case IP_VS_INPUT_HOOK_LOCAL_IN:
> +		in_hooks = ip_vs_ops_local_in;
> +		count = ARRAY_SIZE(ip_vs_ops_local_in);
> +		break;
> +	case IP_VS_INPUT_HOOK_FORWARD:
> +		in_hooks = ip_vs_ops_forward;
> +		count = ARRAY_SIZE(ip_vs_ops_forward);
> +		break;
> +	case IP_VS_INPUT_HOOK_PRE_ROUTING:
> +		in_hooks = ip_vs_ops_pre_routing;
> +		count = ARRAY_SIZE(ip_vs_ops_pre_routing);
> +		break;
> +	default:
> +		return -1;
> +	}

Again, could the calculation of count be moved out of the switch
statement? Perhaps it could just be put directly in the
call to nf_unregister_hooks() ?

	nf_unregister_hooks(in_hooks, ARRAY_SIZE(in_hooks));

> +
> +	nf_unregister_hooks(in_hooks, count);
> +	nf_unregister_hooks(ip_vs_ops_generic, ARRAY_SIZE(ip_vs_ops_generic));
> +
> +	IP_VS_DBG(5, "Unregistered input hooks.\n");
> +	return 0;
> +}

I found that I needed to move the definition of ip_ve_register_hooks()
and ip_vs_unregister_hooks() to below the definition of all
the struct nf_hook_ops, as they are used in these functions.

The hunks below seem a bit messed up
and ip_vs_ips_pre_forward ends up with a duplicate
of the NF_INET_LOCAL_IN fragment from ip_vs_ops_local_in.

> +
> +
> +/* After packet filtering, forward packet through VS/DR, VS/TUN,
> + * or VS/NAT(change destination), so that filtering rules can be
> + * applied to IPVS. */
> +static struct nf_hook_ops ip_vs_ops_local_in[] __read_mostly = {
> +	{
> +		.hook		= ip_vs_in,
> +		.owner		= THIS_MODULE,
> +		.pf		= PF_INET,
> +		.hooknum        = NF_INET_LOCAL_IN,
> +		.priority       = 100,
> +	},
> +};
> +
> +/* Intercept incoming connections after they have traveled through
> + * the INPUT or the FORWARD table. It has the same functionlity of
> + * the "INPUT method", but also processes connections that are
> + * routed through the director, supporting VIP-less setups. */
> +static struct nf_hook_ops ip_vs_ops_forward[] __read_mostly = {
>  	{
>  		.hook		= ip_vs_in,
>  		.owner		= THIS_MODULE,
> @@ -1037,12 +1136,6 @@ static struct nf_hook_ops ip_vs_ops[]  
> __read_mostly = {
>  		.hooknum        = NF_INET_LOCAL_IN,
>  		.priority       = 100,
>  	},
> -#endif
> -#ifdef CONFIG_IP_VS_INPUT_FORWARD
> -	/* Intercept incoming connections after they have traveled through
> -	 * the INPUT or the FORWARD table. It has the same functionlity of
> -	 * the "INPUT method", but also processes connections that are
> -	 * routed through the director, supporting VIP-less setups. */
>  	{
>  		.hook		= ip_vs_in,
>  		.owner		= THIS_MODULE,
> @@ -1050,12 +1143,13 @@ static struct nf_hook_ops ip_vs_ops[]  
> __read_mostly = {
>  		.hooknum        = NF_INET_FORWARD,
>  		.priority       = 98,
>  	},
> -#endif
> -#ifdef CONFIG_IP_VS_INPUT_PRE_ROUTING
> -	/* Intercept incoming connections before DNAT and input filtering
> -	 * has been applied, this enables ransparent proxying on realnodes
> -	 * and localnode. Hook right after MANGLE and before NAT_DST.
> -	 */
> +};
> +
> +/* Intercept incoming connections before DNAT and input filtering
> + * has been applied, this enables ransparent proxying on realnodes
> + * and localnode. Hook right after MANGLE and before NAT_DST.
> + */
> +static struct nf_hook_ops ip_vs_ops_pre_routing[] __read_mostly = {
>  	{
>  		.hook           = ip_vs_in,
>  		.owner          = THIS_MODULE,
> @@ -1063,7 +1157,13 @@ static struct nf_hook_ops ip_vs_ops[]  
> __read_mostly = {
>  		.hooknum        = NF_INET_PRE_ROUTING,
>  		.priority       = NF_IP_PRI_NAT_DST - 1,
>  	},
> -#endif
> +};
> +
> +/*
> + * Generic Netfilter hooks required for all the input methods
> + */
> +
> +static struct nf_hook_ops ip_vs_ops_generic[] __read_mostly = {
>  	/* After packet filtering, change source only for VS/NAT */
>  	{
>  		.hook		= ip_vs_out,
> @@ -1119,9 +1219,8 @@ static int __init ip_vs_init(void)
>  		goto cleanup_app;
>  	}
>
> -	ret = nf_register_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
> +	ret = ip_vs_register_hooks(ip_vs_get_input_hook());
>  	if (ret < 0) {
> -		IP_VS_ERR("can't register hooks.\n");
>  		goto cleanup_conn;
>  	}
>
> @@ -1141,7 +1240,7 @@ static int __init ip_vs_init(void)
>
>  static void __exit ip_vs_cleanup(void)
>  {
> -	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
> +	ip_vs_unregister_hooks(ip_vs_get_input_hook());
>  	ip_vs_conn_cleanup();
>  	ip_vs_app_cleanup();
>  	ip_vs_protocol_cleanup();
> diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> index 94c5767..1e05c54 100644
> --- a/net/ipv4/ipvs/ip_vs_ctl.c
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c
> @@ -82,6 +82,15 @@ int sysctl_ip_vs_expire_quiescent_template = 0;
>  int sysctl_ip_vs_sync_threshold[2] = { 3, 50 };
>  int sysctl_ip_vs_nat_icmp_send = 0;
>
> +#ifdef CONFIG_IP_VS_INPUT_LOCAL_IN
> +static int sysctl_ip_vs_input_hook = IP_VS_INPUT_HOOK_LOCAL_IN;
> +#endif
> +#ifdef CONFIG_IP_VS_INPUT_FORWARD
> +static int sysctl_ip_vs_input_hook = IP_VS_INPUT_HOOK_FORWARD;
> +#endif
> +#ifdef CONFIG_IP_VS_INPUT_PRE_ROUTING
> +static int sysctl_ip_vs_input_hook = IP_VS_INPUT_HOOK_PRE_ROUTING;
> +#endif
>
>  #ifdef CONFIG_IP_VS_DEBUG
>  static int sysctl_ip_vs_debug_level = 0;
> @@ -92,6 +101,11 @@ int ip_vs_get_debug_level(void)
>  }
>  #endif
>
> +int ip_vs_get_input_hook(void)
> +{
> +	return sysctl_ip_vs_input_hook;
> +}
> +
>  /*
>   *	update_defense_level is called from keventd and from sysctl,
>   *	so it needs to protect itself from softirqs
> @@ -1376,6 +1390,28 @@ static int ip_vs_zero_all(void)
>  	return 0;
>  }
>
> +static int
> +proc_do_input_hook(struct ctl_table *table, int write, struct file  
> *filp,
> +		   void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	char *valp = table->data;
> +	int oldval = *valp;
> +	int rc;
> +
> +	rc = proc_dointvec(table, write, filp, buffer, lenp, ppos);
> +	if (write && (*valp != oldval)) {
> +		if ((*valp <= IP_VS_INPUT_HOOK_FIRST) ||
> +		    (*valp >= IP_VS_INPUT_HOOK_LAST)) {
> +			IP_VS_ERR("Invalid input hook value: %i\n", *valp);
> +			*valp = oldval;
> +		} else {
> +			/* unregister old and register new input hooks */
> +			ip_vs_unregister_hooks(oldval);
> +			ip_vs_register_hooks(*valp);
> +		}
> +	}
> +	return rc;
> +}
>
>  static int
>  proc_do_defense_mode(ctl_table *table, int write, struct file * filp,
> @@ -1430,6 +1466,13 @@ static struct ctl_table vs_vars[] = {
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec,
>  	},
> +	{
> +		.procname	= "input_hook",
> +		.data		= &sysctl_ip_vs_input_hook,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_do_input_hook,
> +	},
>  #ifdef CONFIG_IP_VS_DEBUG
>  	{
>  		.procname	= "debug_level",
> -- 
> 1.5.3.7
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
