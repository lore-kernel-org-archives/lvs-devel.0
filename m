From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix possible use of uninitialized ipvs pointer
Date: Tue, 29 Sep 2015 22:04:03 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509292200300.1775@ja.home.ssi.bg>
References: <9bdf4c6e4d9aa5728488f0682008feaf35e3e092.1443545522.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <9bdf4c6e4d9aa5728488f0682008feaf35e3e092.1443545522.git.marcelo.leitner@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Cc: lvs-devel@vger.kernel.org, agartrell@fb.com


	Hello,

On Tue, 29 Sep 2015, Marcelo Ricardo Leitner wrote:

> 5e26b1b3abce[1] moved a derreference on ipvs on sysctl_sloppy_sctp(ipvs)
> to before its initialization.
> 
> Fix now is to just move ipvs initialization a bit upper.
> 
> Fixes: 5e26b1b3abce ("ipvs: support scheduling inverse and icmp SCTP packets")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

	This is already fixed in ipvs-next tree as part of the
Eric W. Biederman's work:

"ipvs: Hoist computation of ipvs earlier in sctp_conn_schedule"

> ---
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 2026fca7e1c36f12db1351e7c14e9eba8ad8b8e1..ac628a9afdb521c243d79b2f415ee98a3f41d0c3 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -20,6 +20,9 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  	sctp_sctphdr_t *sh, _sctph;
>  	__be16 _ports[2], *ports = NULL;
>  
> +	net = skb_net(skb);
> +	ipvs = net_ipvs(net);
> +
>  	if (likely(!ip_vs_iph_icmp(iph))) {
>  		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
>  		if (sh) {
> @@ -40,8 +43,6 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  		return 0;
>  	}
>  
> -	net = skb_net(skb);
> -	ipvs = net_ipvs(net);
>  	rcu_read_lock();
>  	if (likely(!ip_vs_iph_inverse(iph)))
>  		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,

Regards

--
Julian Anastasov <ja@ssi.bg>
