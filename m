From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v4] ipvs: adjust the debug info in function
 set_tcp_state
Date: Sun, 27 Sep 2020 16:32:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2009271625160.35554@ja.home.ssi.bg>
References: <20200927120756.75676-1-bigclouds@163.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20200927120756.75676-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "longguang.yue" <bigclouds@163.com>
Cc: yuelongguang@gmail.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>


	Hello,

On Sun, 27 Sep 2020, longguang.yue wrote:

>         outputting client,virtual,dst addresses info when tcp state changes,
>         which makes the connection debug more clear
> 
> Signed-off-by: longguang.yue <bigclouds@163.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, Pablo, may be commit description should not
be indented...

> ---
>  net/netfilter/ipvs/ip_vs_proto_tcp.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index dc2e7da2742a..7da51390cea6 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -539,8 +539,8 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>  	if (new_state != cp->state) {
>  		struct ip_vs_dest *dest = cp->dest;
>  
> -		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] %s:%d->"
> -			      "%s:%d state: %s->%s conn->refcnt:%d\n",
> +		IP_VS_DBG_BUF(8, "%s %s [%c%c%c%c] c:%s:%d v:%s:%d "
> +			      "d:%s:%d state: %s->%s conn->refcnt:%d\n",
>  			      pd->pp->name,
>  			      ((state_off == TCP_DIR_OUTPUT) ?
>  			       "output " : "input "),
> @@ -548,10 +548,12 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>  			      th->fin ? 'F' : '.',
>  			      th->ack ? 'A' : '.',
>  			      th->rst ? 'R' : '.',
> -			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> -			      ntohs(cp->dport),
>  			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
>  			      ntohs(cp->cport),
> +			      IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
> +			      ntohs(cp->vport),
> +			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> +			      ntohs(cp->dport),
>  			      tcp_state_name(cp->state),
>  			      tcp_state_name(new_state),
>  			      refcount_read(&cp->refcnt));
> -- 
> 2.20.1 (Apple Git-117)

Regards

--
Julian Anastasov <ja@ssi.bg>

