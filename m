From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [Outreachy kernel] [PATCH] net: netfilter: remove unused
 variable
Date: Wed, 29 Mar 2017 16:16:35 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1703291616070.2989@hadrien>
References: <20170329133848.GA1336@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329133848.GA1336@arushi-HP-Pavilion-Notebook>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: outreachy-kernel@googlegroups.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org



On Wed, 29 Mar 2017, Arushi Singhal wrote:

> This patch uses the following coccinelle script to remove
> a variable that was simply used to store the return
> value of a function call before returning it:
>
> @@
> identifier len,f;
> @@
>
> -int len;
>  ... when != len
>      when strict
> -len =
> +return
>         f(...);
> -return len;
>
> Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_ftp.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index d30c327bb578..9e1e682610ef 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -482,11 +482,9 @@ static struct pernet_operations ip_vs_ftp_ops = {
>
>  static int __init ip_vs_ftp_init(void)
>  {
> -	int rv;
>
> -	rv = register_pernet_subsys(&ip_vs_ftp_ops);
>  	/* rcu_barrier() is called by netns on error */
> -	return rv;
> +	return register_pernet_subsys(&ip_vs_ftp_ops);

It looks like you end up with an unnecessary blank line at the beginning
of the function.

julia

>  }
>
>  /*
> --
> 2.11.0
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe@googlegroups.com.
> To post to this group, send email to outreachy-kernel@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/20170329133848.GA1336%40arushi-HP-Pavilion-Notebook.
> For more options, visit https://groups.google.com/d/optout.
>
