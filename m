From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipvs: info leak in __ip_vs_get_dest_entries()
Date: Tue, 4 Jun 2013 10:03:27 +0900
Message-ID: <20130604010327.GA23054@verge.net.au>
References: <20130603090049.GA16171@debian>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130603090049.GA16171@debian>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

On Mon, Jun 03, 2013 at 12:00:49PM +0300, Dan Carpenter wrote:
> The entry struct has a 2 byte hole after ->port and another 4 byte
> hole after ->stats.outpkts.  You must have CAP_NET_ADMIN in your
> namespace to hit this information leak.

Hi Dan,

can I verify that it is actually possible to hit this and
thus the patch is a -stable candidate?

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
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
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
