From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH ipvs 1/2] net: ipvs: sctp: add missing verdict
 assignments in sctp_conn_schedule
Date: Fri, 25 Oct 2013 08:59:52 -0400
Message-ID: <20131025125952.GA9281@hmsreliant.think-freely.org>
References: <cover.1382689350.git.dborkman@redhat.com>
 <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On Fri, Oct 25, 2013 at 11:05:04AM +0200, Daniel Borkmann wrote:
> If skb_header_pointer() fails, we need to assign a verdict, that is
> NF_DROP in this case, otherwise, we would leave the verdict from
> conn_schedule() uninitialized when returning.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 23e596e..9ca7aa0 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -20,13 +20,18 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  	sctp_sctphdr_t *sh, _sctph;
>  
>  	sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
> -	if (sh == NULL)
> +	if (sh == NULL) {
> +		*verdict = NF_DROP;
>  		return 0;
> +	}
>  
>  	sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
>  				 sizeof(_schunkh), &_schunkh);
> -	if (sch == NULL)
> +	if (sch == NULL) {
> +		*verdict = NF_DROP;
>  		return 0;
> +	}
> +
>  	net = skb_net(skb);
>  	ipvs = net_ipvs(net);
>  	rcu_read_lock();
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
