From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter/ipvs: clear ipvs_property flag when SKB net
 namespace changed
Date: Sat, 28 Oct 2017 13:33:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1710281301090.1835@ja.home.ssi.bg>
References: <1509008225-19614-1-git-send-email-hustcat@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1509008225-19614-1-git-send-email-hustcat@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ye Yin <hustcat@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, willemb@google.com, edumazet@google.com, johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com, f.fainelli@gmail.com, fw@strlen.de, soheil@google.com, dwindsor@gmail.com, elena.reshetova@intel.com, tom@quantonium.net, Jason@zx2c4.com, linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Wei Zhou <chouryzhou@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Thu, 26 Oct 2017, Ye Yin wrote:

> When run ipvs in two different network namespace at the same host, and one
> ipvs transport network traffic to the other network namespace ipvs.
> 'ipvs_property' flag will make the second ipvs take no effect. So we should
> clear 'ipvs_property' when SKB network namespace changed.
> 
> Signed-off-by: Ye Yin <hustcat@gmail.com>
> Signed-off-by: Wei Zhou <chouryzhou@gmail.com>

	Patch looks good to me. ipvs_property was added long ago
but skb_scrub_packet() is more recent (3.11), so:

Fixes: 621e84d6f373 ("dev: introduce skb_scrub_packet()")
Signed-off-by: Julian Anastasov <ja@ssi.bg>

	I guess, DaveM can apply it directly as a bugfix
to the net tree.

> ---
>  include/linux/skbuff.h | 7 +++++++
>  net/core/skbuff.c      | 1 +
>  2 files changed, 8 insertions(+)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 72299ef..d448a48 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3770,6 +3770,13 @@ static inline void nf_reset_trace(struct sk_buff *skb)
>  #endif
>  }
>  
> +static inline void ipvs_reset(struct sk_buff *skb)
> +{
> +#if IS_ENABLED(CONFIG_IP_VS)
> +	skb->ipvs_property = 0;
> +#endif
> +}
> +
>  /* Note: This doesn't put any conntrack and bridge info in dst. */
>  static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src,
>  			     bool copy)
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 2465607..e140ba4 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4864,6 +4864,7 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
>  	if (!xnet)
>  		return;
>  
> +	ipvs_reset(skb);
>  	skb_orphan(skb);
>  	skb->mark = 0;
>  }
> -- 
> 1.7.12.4

Regards

--
Julian Anastasov <ja@ssi.bg>
