From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: adjust the debug order of src and dst
Date: Thu, 24 Sep 2020 17:55:50 +0200
Message-ID: <20200924155550.GC13127@vergenet.net>
References: <20200923055000.82748-1-bigclouds@163.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200923055000.82748-1-bigclouds@163.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "longguang.yue" <bigclouds@163.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Wed, Sep 23, 2020 at 01:49:59PM +0800, longguang.yue wrote:
> From: ylg <bigclouds@163.com>
> 
> adjust the debug order of src and dst when tcp state changes
> 
> Signed-off-by: ylg <bigclouds@163.com>

Hi,

This sounds reasonable to me but please provide your real name
in the Signed-off-by name, which should be consistent with the From field
at the top of the commit message (or, if absent of the email).

Thanks!

> ---
>  net/netfilter/ipvs/ip_vs_proto_tcp.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index dc2e7da2742a..6567eb45a234 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -548,10 +548,10 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>  			      th->fin ? 'F' : '.',
>  			      th->ack ? 'A' : '.',
>  			      th->rst ? 'R' : '.',
> -			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> -			      ntohs(cp->dport),
>  			      IP_VS_DBG_ADDR(cp->af, &cp->caddr),
>  			      ntohs(cp->cport),
> +			      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> +			      ntohs(cp->dport),
>  			      tcp_state_name(cp->state),
>  			      tcp_state_name(new_state),
>  			      refcount_read(&cp->refcnt));
> -- 
> 2.20.1 (Apple Git-117)
> 
