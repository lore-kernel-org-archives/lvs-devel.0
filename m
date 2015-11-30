From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: ipvs: avoid unused variable warning
Date: Mon, 30 Nov 2015 22:48:34 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1511302242210.1918@ja.home.ssi.bg>
References: <9616810.SPqCgIbKt5@wuerfel>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <9616810.SPqCgIbKt5@wuerfel>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Mon, 30 Nov 2015, Arnd Bergmann wrote:

> When CONFIG_PROC_FS is disabled, the local 'net' variable in
> ip_vs_app_net_init becomes unused, as gcc warns:
> 
> net/netfilter/ipvs/ip_vs_app.c: In function 'ip_vs_app_net_init':
> net/netfilter/ipvs/ip_vs_app.c:608:14: warning: unused variable 'net' [-Wunused-variable]
> 
> This removes the line by moving the pointer dereference into the
> user of the variable.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Julian Anastasov <ja@ssi.bg>

> diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
> index 0328f7250693..e5422d3db501 100644
> --- a/net/netfilter/ipvs/ip_vs_app.c
> +++ b/net/netfilter/ipvs/ip_vs_app.c
> @@ -614,8 +614,6 @@ int __net_init ip_vs_app_net_init(struct netns_ipvs *ipvs)
>  
>  void __net_exit ip_vs_app_net_cleanup(struct netns_ipvs *ipvs)
>  {
> -	struct net *net = ipvs->net;
> -
>  	unregister_ip_vs_app(ipvs, NULL /* all */);
> -	remove_proc_entry("ip_vs_app", net->proc_net);
> +	remove_proc_entry("ip_vs_app", ipvs->net->proc_net);
>  }

Regards

--
Julian Anastasov <ja@ssi.bg>
