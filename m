From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Implement full-functionality option for ECN encapsulation
 in tunnel
Date: Wed, 15 Feb 2017 22:39:16 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1702152235410.1942@ja.home.ssi.bg>
References: <1487165636-10157-1-git-send-email-vfedorenko@yandex-team.ru>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1487165636-10157-1-git-send-email-vfedorenko@yandex-team.ru>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vadim Fedorenko <vfedorenko@yandex-team.ru>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

On Wed, 15 Feb 2017, Vadim Fedorenko wrote:

> IPVS tunnel mode works as simple tunnel (see RFC 3168) copying ECN field
> to outer header. That's result in packet drops on egress tunnels in case
> the egress tunnel operates as ECN-capable with Full-functionality option
> (like ip_tunnel and ip6_tunnel kernel modules), according to RFC 3168
> section 9.1.1 recommendation.
> 
> This patch implements ECN full-functionality option into ipvs xmit code.
> 
> Cc: netdev@vger.kernel.org
> Cc: lvs-devel@vger.kernel.org
> Signed-off-by: Vadim Fedorenko <vfedorenko@yandex-team.ru>
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 01d3d89..b3286f3 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -879,6 +879,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
>  {
>  	struct sk_buff *new_skb = NULL;
>  	struct iphdr *old_iph = NULL;
> +	__u8 old_dsfield;
>  #ifdef CONFIG_IP_VS_IPV6
>  	struct ipv6hdr *old_ipv6h = NULL;
>  #endif
> @@ -903,7 +904,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
>  			*payload_len =
>  				ntohs(old_ipv6h->payload_len) +
>  				sizeof(*old_ipv6h);
> -		*dsfield = ipv6_get_dsfield(old_ipv6h);
> +		old_dsfield = ipv6_get_dsfield(old_ipv6h);
>  		*ttl = old_ipv6h->hop_limit;
>  		if (df)
>  			*df = 0;
> @@ -918,12 +919,15 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
>  
>  		/* fix old IP header checksum */
>  		ip_send_check(old_iph);
> -		*dsfield = ipv4_get_dsfield(old_iph);
> +		old_dsfield = ipv4_get_dsfield(old_iph);
>  		*ttl = old_iph->ttl;
>  		if (payload_len)
>  			*payload_len = ntohs(old_iph->tot_len);
>  	}
>  
> +	/* Implement full-functionality option for ECN encapsulation */
> +	*dsfield = INET_ECN_encapsulate(old_dsfield, old_dsfield);
> +
>  	return skb;
>  error:
>  	kfree_skb(skb);
> -- 
> 1.9.1

Regards

--
Julian Anastasov <ja@ssi.bg>
