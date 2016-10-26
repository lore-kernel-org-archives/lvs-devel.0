From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH V2] ipvs does not decrement IP ttl
Date: Wed, 26 Oct 2016 10:31:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1610261016520.1867@ja.home.ssi.bg>
References: <1477431669-2782-1-git-send-email-dwip@linux.vnet.ibm.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1477431669-2782-1-git-send-email-dwip@linux.vnet.ibm.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dwip Banerjee <dwip@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 25 Oct 2016, Dwip Banerjee wrote:

> We decrement the IP ttl in all the modes in order to prevent infinite
> route loops. The changes were done based on Julian Anastasov's
> suggestions in a prior thread.
> 
> The ttl based check/discard and the actual decrement are done in
> __ip_vs_get_out_rt() and in __ip_vs_get_out_rt_v6(), for the IPv6
> case. decrement_ttl() implements the actual functionality for the
> two cases.
> 
> 
> Signed-off-by: Dwip Banerjee <dwip@linux.vnet.ibm.com>

	Very good, only some coding style problems below.

> ---
>  net/netfilter/ipvs/ip_vs_xmit.c |   53 +++++++++++++++++++++++++++++++++++++++
>  1 files changed, 53 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 01d3d89..724fd29 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -254,6 +254,53 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  	return true;
>  }
>  
> +static inline bool decrement_ttl(struct netns_ipvs *ipvs,
> +				 int skb_af,
> +				 struct sk_buff *skb)
> +{
> +	struct net *net = ipvs->net;

	Add empty line here.

> +#ifdef CONFIG_IP_VS_IPV6
> +	if (skb_af == AF_INET6) {
> +		struct dst_entry *dst = skb_dst(skb);
> +
> +		/* check and decrement ttl */
> +		if (ipv6_hdr(skb)->hop_limit <= 1) {
> +			/* Force OUTPUT device used as source address */
> +			skb->dev = dst->dev;
> +			icmpv6_send(skb, ICMPV6_TIME_EXCEED,
> +					 ICMPV6_EXC_HOPLIMIT, 0);

	ICMPV6_EXC_HOPLIMIT should be aligned to 'skb',
it is reported by scripts/checkpatch.pl --strict /tmp/file.patch

Regards

--
Julian Anastasov <ja@ssi.bg>
