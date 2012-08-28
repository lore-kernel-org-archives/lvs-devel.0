From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 2/2] ipvs: Extend MTU check to account for IPv6 NAT
 defrag changes
Date: Tue, 28 Aug 2012 07:49:19 -0700
Message-ID: <1346165359.3571.9.camel@edumazet-glaptop>
References: <20120828142051.11475.63775.stgit@dragon>
	 <20120828142248.11475.15917.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=subject:from:to:cc:in-reply-to:references:content-type:date
         :message-id:mime-version:x-mailer:content-transfer-encoding;
        bh=M8dyNAQ+/JsKaJ8T1xSfi7shawgiM9ZIC9lUPGzSk8A=;
        b=kj+BfVbCnVgb5FwDKPEcuiQ67z55Ctvte5E77lLV+AZSm0H3KuVUT8j6OQ2fGIuyrl
         UiUgJe6Ov30UJxr/I3XSp0XV5301dYDMure2DLrtaTxdzFHYb7cD1kwTbIqK2hb/9Ka4
         mxtGF+AvU0l0hXaiwwFFg7Mqpgc/5JYQVA0worY5rGAswDstIxGQL89C2wv10/nYFv1W
         jJJKxHit5xtmD7oaaasbkDf1qu0XmGZ9bHiOzPzdr9Oe1HplkjfhapzDCT32Bo7weBwP
         sxK6XZgtBgjOUv7JSVorSfglgWrZ/hIPAe8gXl3bEwsMMY23uzB9tzKQ3wzs0LoXvtfb
         oyvA==
In-Reply-To: <20120828142248.11475.15917.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Tue, 2012-08-28 at 16:23 +0200, Jesper Dangaard Brouer wrote:
> This patch is necessary, to make IPVS work, after Patrick McHardys
> IPv6 NAT defragmentation changes.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> In V2: the tunnel mode is no longer a special case.
> 
>  net/netfilter/ipvs/ip_vs_xmit.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 67a3978..56f6d5d 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -88,7 +88,14 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
>  static inline bool
>  __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
>  {
> -	if (skb->len > mtu && !skb_is_gso(skb)) {
> +	if (IP6CB(skb)->frag_max_size) {
> +		/* frag_max_size tell us that, this packet have been
> +		 * defragmented by netfilter IPv6 conntrack module.
> +		 */
> +		if (IP6CB(skb)->frag_max_size > mtu)
> +			return true; /* largest fragment violate MTU */
> +	}
> +	else if (skb->len > mtu && !skb_is_gso(skb)) {
>  		return true; /* Packet size violate MTU size */
>  	}

Couldnt you use a single test ?

if (IP6CB(skb)->frag_max_size > mtu)
	return true;

if (skb->len > mtu && !skb_is_gso(skb))
	return true;



