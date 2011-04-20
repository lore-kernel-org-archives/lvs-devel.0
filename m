From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/3] IPVS: Change of register_pernet_subsys to register_pernet_device
Date: Wed, 20 Apr 2011 02:46:17 -0700
Message-ID: <m1sjtdtfva.fsf@fess.ebiederm.org>
References: <1303226705-29178-1-git-send-email-hans@schillstrom.com>
	<1303226705-29178-2-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1303226705-29178-2-git-send-email-hans@schillstrom.com> (Hans
	Schillstrom's message of "Tue, 19 Apr 2011 17:25:04 +0200")
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

Hans Schillstrom <hans@schillstrom.com> writes:

> This is part 1 of a makeover of the init and cleanup
> functions in ip_vs using name space.

That this fixes problems for you is great.  Why does this
fix the problems.  Does ip_vs really act more as a
network device passing packets than as a protocol implementation
or a library?

register_pernet_subsys already gives you the guarantee that
cleanup is in the reverse order of initialization.

I expect you are on the right track but it isn't clear to me from
reading the patch and it's description why this code should work.

Eric


> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
> ---
>  net/netfilter/ipvs/ip_vs_app.c   |    4 ++--
>  net/netfilter/ipvs/ip_vs_conn.c  |    4 ++--
>  net/netfilter/ipvs/ip_vs_core.c  |    6 +++---
>  net/netfilter/ipvs/ip_vs_ctl.c   |    6 +++---
>  net/netfilter/ipvs/ip_vs_est.c   |    4 ++--
>  net/netfilter/ipvs/ip_vs_ftp.c   |    4 ++--
>  net/netfilter/ipvs/ip_vs_lblc.c  |    6 +++---
>  net/netfilter/ipvs/ip_vs_lblcr.c |    6 +++---
>  net/netfilter/ipvs/ip_vs_proto.c |    4 ++--
>  net/netfilter/ipvs/ip_vs_sync.c  |    4 ++--
>  10 files changed, 24 insertions(+), 24 deletions(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
> index 2dc6de1..7e8e769 100644
> --- a/net/netfilter/ipvs/ip_vs_app.c
> +++ b/net/netfilter/ipvs/ip_vs_app.c
> @@ -599,12 +599,12 @@ int __init ip_vs_app_init(void)
>  {
>  	int rv;
>  
> -	rv = register_pernet_subsys(&ip_vs_app_ops);
> +	rv = register_pernet_device(&ip_vs_app_ops);
>  	return rv;
>  }
>  
>  
>  void ip_vs_app_cleanup(void)
>  {
> -	unregister_pernet_subsys(&ip_vs_app_ops);
> +	unregister_pernet_device(&ip_vs_app_ops);
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index c97bd45..36cd5ea 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1309,7 +1309,7 @@ int __init ip_vs_conn_init(void)
>  		rwlock_init(&__ip_vs_conntbl_lock_array[idx].l);
>  	}
>  
> -	retc = register_pernet_subsys(&ipvs_conn_ops);
> +	retc = register_pernet_device(&ipvs_conn_ops);
>  
>  	/* calculate the random value for connection hash */
>  	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
> @@ -1319,7 +1319,7 @@ int __init ip_vs_conn_init(void)
>  
>  void ip_vs_conn_cleanup(void)
>  {
> -	unregister_pernet_subsys(&ipvs_conn_ops);
> +	unregister_pernet_device(&ipvs_conn_ops);
>  	/* Release the empty cache */
>  	kmem_cache_destroy(ip_vs_conn_cachep);
>  	vfree(ip_vs_conn_tab);
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 07accf6..a7bb81d 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1913,7 +1913,7 @@ static int __init ip_vs_init(void)
>  {
>  	int ret;
>  
> -	ret = register_pernet_subsys(&ipvs_core_ops);	/* Alloc ip_vs struct */
> +	ret = register_pernet_device(&ipvs_core_ops);	/* Alloc ip_vs struct */
>  	if (ret < 0)
>  		return ret;
>  
> @@ -1964,7 +1964,7 @@ cleanup_sync:
>  	ip_vs_control_cleanup();
>    cleanup_estimator:
>  	ip_vs_estimator_cleanup();
> -	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
> +	unregister_pernet_device(&ipvs_core_ops);	/* free ip_vs struct */
>  	return ret;
>  }
>  
> @@ -1977,7 +1977,7 @@ static void __exit ip_vs_cleanup(void)
>  	ip_vs_protocol_cleanup();
>  	ip_vs_control_cleanup();
>  	ip_vs_estimator_cleanup();
> -	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
> +	unregister_pernet_device(&ipvs_core_ops);	/* free ip_vs struct */
>  	pr_info("ipvs unloaded.\n");
>  }
>  
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index ae47090..08715d8 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3657,7 +3657,7 @@ int __init ip_vs_control_init(void)
>  		INIT_LIST_HEAD(&ip_vs_svc_fwm_table[idx]);
>  	}
>  
> -	ret = register_pernet_subsys(&ipvs_control_ops);
> +	ret = register_pernet_device(&ipvs_control_ops);
>  	if (ret) {
>  		pr_err("cannot register namespace.\n");
>  		goto err;
> @@ -3682,7 +3682,7 @@ int __init ip_vs_control_init(void)
>  	return 0;
>  
>  err_net:
> -	unregister_pernet_subsys(&ipvs_control_ops);
> +	unregister_pernet_device(&ipvs_control_ops);
>  err:
>  	return ret;
>  }
> @@ -3691,7 +3691,7 @@ err:
>  void ip_vs_control_cleanup(void)
>  {
>  	EnterFunction(2);
> -	unregister_pernet_subsys(&ipvs_control_ops);
> +	unregister_pernet_device(&ipvs_control_ops);
>  	ip_vs_genl_unregister();
>  	nf_unregister_sockopt(&ip_vs_sockopts);
>  	LeaveFunction(2);
> diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
> index 8c8766c..759163e 100644
> --- a/net/netfilter/ipvs/ip_vs_est.c
> +++ b/net/netfilter/ipvs/ip_vs_est.c
> @@ -216,11 +216,11 @@ int __init ip_vs_estimator_init(void)
>  {
>  	int rv;
>  
> -	rv = register_pernet_subsys(&ip_vs_app_ops);
> +	rv = register_pernet_device(&ip_vs_app_ops);
>  	return rv;
>  }
>  
>  void ip_vs_estimator_cleanup(void)
>  {
> -	unregister_pernet_subsys(&ip_vs_app_ops);
> +	unregister_pernet_device(&ip_vs_app_ops);
>  }
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 6b5dd6d..dfa04d3 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -451,7 +451,7 @@ int __init ip_vs_ftp_init(void)
>  {
>  	int rv;
>  
> -	rv = register_pernet_subsys(&ip_vs_ftp_ops);
> +	rv = register_pernet_device(&ip_vs_ftp_ops);
>  	return rv;
>  }
>  
> @@ -460,7 +460,7 @@ int __init ip_vs_ftp_init(void)
>   */
>  static void __exit ip_vs_ftp_exit(void)
>  {
> -	unregister_pernet_subsys(&ip_vs_ftp_ops);
> +	unregister_pernet_device(&ip_vs_ftp_ops);
>  }
>  
>  
> diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> index 87e40ea..96765d0 100644
> --- a/net/netfilter/ipvs/ip_vs_lblc.c
> +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> @@ -603,20 +603,20 @@ static int __init ip_vs_lblc_init(void)
>  {
>  	int ret;
>  
> -	ret = register_pernet_subsys(&ip_vs_lblc_ops);
> +	ret = register_pernet_device(&ip_vs_lblc_ops);
>  	if (ret)
>  		return ret;
>  
>  	ret = register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
>  	if (ret)
> -		unregister_pernet_subsys(&ip_vs_lblc_ops);
> +		unregister_pernet_device(&ip_vs_lblc_ops);
>  	return ret;
>  }
>  
>  static void __exit ip_vs_lblc_cleanup(void)
>  {
>  	unregister_ip_vs_scheduler(&ip_vs_lblc_scheduler);
> -	unregister_pernet_subsys(&ip_vs_lblc_ops);
> +	unregister_pernet_device(&ip_vs_lblc_ops);
>  }
>  
>  
> diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> index 90f618a..5de425f 100644
> --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> @@ -799,20 +799,20 @@ static int __init ip_vs_lblcr_init(void)
>  {
>  	int ret;
>  
> -	ret = register_pernet_subsys(&ip_vs_lblcr_ops);
> +	ret = register_pernet_device(&ip_vs_lblcr_ops);
>  	if (ret)
>  		return ret;
>  
>  	ret = register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
>  	if (ret)
> -		unregister_pernet_subsys(&ip_vs_lblcr_ops);
> +		unregister_pernet_device(&ip_vs_lblcr_ops);
>  	return ret;
>  }
>  
>  static void __exit ip_vs_lblcr_cleanup(void)
>  {
>  	unregister_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
> -	unregister_pernet_subsys(&ip_vs_lblcr_ops);
> +	unregister_pernet_device(&ip_vs_lblcr_ops);
>  }
>  
>  
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index 17484a4..f7021fc 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -382,7 +382,7 @@ int __init ip_vs_protocol_init(void)
>  	REGISTER_PROTOCOL(&ip_vs_protocol_esp);
>  #endif
>  	pr_info("Registered protocols (%s)\n", &protocols[2]);
> -	return register_pernet_subsys(&ipvs_proto_ops);
> +	return register_pernet_device(&ipvs_proto_ops);
>  
>  	return 0;
>  }
> @@ -393,7 +393,7 @@ void ip_vs_protocol_cleanup(void)
>  	struct ip_vs_protocol *pp;
>  	int i;
>  
> -	unregister_pernet_subsys(&ipvs_proto_ops);
> +	unregister_pernet_device(&ipvs_proto_ops);
>  	/* unregister all the ipvs protocols */
>  	for (i = 0; i < IP_VS_PROTO_TAB_SIZE; i++) {
>  		while ((pp = ip_vs_proto_table[i]) != NULL)
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 3f87555..1aeca1d 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1692,10 +1692,10 @@ static struct pernet_operations ipvs_sync_ops = {
>  
>  int __init ip_vs_sync_init(void)
>  {
> -	return register_pernet_subsys(&ipvs_sync_ops);
> +	return register_pernet_device(&ipvs_sync_ops);
>  }
>  
>  void ip_vs_sync_cleanup(void)
>  {
> -	unregister_pernet_subsys(&ipvs_sync_ops);
> +	unregister_pernet_device(&ipvs_sync_ops);
>  }
