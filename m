From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs-next] ipvs: add sysctl to ignore tunneled packets
Date: Fri, 11 Sep 2015 22:24:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509112212460.1836@ja.home.ssi.bg>
References: <1441907665-1703876-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1441907665-1703876-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Thu, 10 Sep 2015, Alex Gartrell wrote:

> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 99be680..984cf49 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1760,8 +1760,16 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  
>  	/* Protocol supported? */
>  	pd = ip_vs_proto_data_get(net, iph.protocol);
> -	if (unlikely(!pd))
> +	if (unlikely(!pd)) {
> +		/* The only way we'll see this packet again is if it's
> +		 * encapsulated, so mark it with ipvs_property=1 so we
> +		 * skip it if we're ignoring tunneled packets
> +		 */
> +		if (sysctl_ignore_tunneled(net_ipvs(net)))

	We can use "ipvs" here. I remember people used
matching by src MAC to solve such problem for DR. For TUN
fwmark or match by input device can work too. In all cases,
a fwmark-based service is needed...

> +			skb->ipvs_property = 1;
> +
>  		return NF_ACCEPT;
> +	}

Regards

--
Julian Anastasov <ja@ssi.bg>
