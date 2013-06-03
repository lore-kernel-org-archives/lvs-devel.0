From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch] ipvs: info leak in __ip_vs_get_dest_entries()
Date: Mon, 3 Jun 2013 23:00:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306032258190.1767@ja.ssi.bg>
References: <20130603090049.GA16171@debian>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130603090049.GA16171@debian>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org


	Hello,

On Mon, 3 Jun 2013, Dan Carpenter wrote:

> The entry struct has a 2 byte hole after ->port and another 4 byte
> hole after ->stats.outpkts.  You must have CAP_NET_ADMIN in your
> namespace to hit this information leak.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Julian Anastasov <ja@ssi.bg>

> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index df05c1c..e336535 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2542,6 +2542,7 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
>  		struct ip_vs_dest *dest;
>  		struct ip_vs_dest_entry entry;
>  
> +		memset(&entry, 0, sizeof(entry));
>  		list_for_each_entry(dest, &svc->destinations, n_list) {
>  			if (count >= get->num_dests)
>  				break;

Regards

--
Julian Anastasov <ja@ssi.bg>
