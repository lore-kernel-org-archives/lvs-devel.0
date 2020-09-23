From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: adjust the debug order of src and dst
Date: Wed, 23 Sep 2020 20:32:58 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2009232012470.4453@ja.home.ssi.bg>
References: <CAPaK2r921GtJVhwGKnZyCcQ1qkcWA=8TBWwNkW03R_=7TKzo6g@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAPaK2r921GtJVhwGKnZyCcQ1qkcWA=8TBWwNkW03R_=7TKzo6g@mail.gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yue longguang <yuelongguang@gmail.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, pablo@netfilter.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Wed, 23 Sep 2020, yue longguang wrote:

> From: ylg <bigclouds@163.com>
> 
> adjust the debug order of src and dst when tcp state changes
> 
> Signed-off-by: ylg <bigclouds@163.com>
> ---
>  net/netfilter/ipvs/ip_vs_proto_tcp.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index dc2e7da2742a..6567eb45a234 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -548,10 +548,10 @@ set_tcp_state(struct ip_vs_proto_data *pd,
> struct ip_vs_conn *cp,
>        th->fin ? 'F' : '.',
>        th->ack ? 'A' : '.',
>        th->rst ? 'R' : '.',
> -      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> -      ntohs(cp->dport),
>        IP_VS_DBG_ADDR(cp->af, &cp->caddr),
>        ntohs(cp->cport),
> +      IP_VS_DBG_ADDR(cp->daf, &cp->daddr),
> +      ntohs(cp->dport),
>        tcp_state_name(cp->state),
>        tcp_state_name(new_state),
>        refcount_read(&cp->refcnt));
> -- 

	The first patch applies but this one does not: wrapped lines,
different tabs. You can also consider using the
"c:%s:%d v:%s:%d d:%s:%d" format as in ip_vs_bind_dest(). As result,
we will avoid the confusion about "->" meaning.

Regards

--
Julian Anastasov <ja@ssi.bg>

