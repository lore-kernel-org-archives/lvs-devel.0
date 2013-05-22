From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] ipvs: Fix reuse connection if real server is dead
Date: Wed, 22 May 2013 22:11:35 +0400
Message-ID: <519D0A57.7010204@cogentembedded.com>
References: <1369202209-18570-1-git-send-email-horms@verge.net.au> <1369202209-18570-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1369202209-18570-3-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

Hello.

On 22-05-2013 9:56, Simon Horman wrote:

> From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

> Expire cached connection for new TCP/SCTP connection if real server is down

> Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
> Acked-by Hans Schillstrom <hans@schillstrom.com>

    Missing :.

> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>   net/netfilter/ipvs/ip_vs_core.c | 36 ++++++++++++++++++++++++++++++++++++
>   1 file changed, 36 insertions(+)

> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 085b588..7967d12 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1001,6 +1001,33 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
>   	return th->rst;
>   }
>
> +static inline bool is_new_conn(const struct sk_buff *skb,
> +			       struct ip_vs_iphdr *iph)
> +{
> +	switch (iph->protocol) {
> +	case IPPROTO_TCP: {
> +		struct tcphdr _tcph, *th;
> +
> +		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
> +		if (th == NULL)
> +			return false;
> +		return th->syn;
> +	}
> +	case IPPROTO_SCTP: {
> +		sctp_chunkhdr_t *sch, schunk;
> +
> +		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
> +				sizeof(schunk), &schunk);

    This line should be aligned under the next character after (.

> +		if (sch == NULL)
> +			return false;
> +		return (sch->type == SCTP_CID_INIT);

    () not needed.

> +	}
> +	default:
> +		return false;
> +	}
> +}
> +
> +

    Too many empty lines?

WBR, Sergei

