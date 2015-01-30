From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next,v2] ipvs: orphan skb on LOCAL_IN path
Date: Fri, 30 Jan 2015 10:18:05 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501301006320.4504@ja.home.ssi.bg>
References: <1422566751-92285-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1422566751-92285-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Thu, 29 Jan 2015, Alex Gartrell wrote:

> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -502,6 +505,9 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
>  	else
>  		ip_vs_update_conntrack(skb, cp, 1);
>  	if (!local) {
> +		/* orphan on LOCAL_IN */
> +		if (skb->dev)
> +			skb_orphan(skb);

	If early demux finds one socket in PRE_ROUTING and
later we DNAT the packet to different local real server we should
drop the socket. That is why in previous email I thought 
ip_vs_nat_send_or_cont should call skb_orphan() even for
local=true.

	Not sure, may be it is possible to get indication
from dnat_handler if packet was changed, so that we can
provide hint to ip_vs_nat_send_or_cont whether to call
skb_orphan only when MASQ mode actually changed daddr/dport,
i.e. when attached socket is not correct anymore.

>  		skb_forward_csum(skb);
>  		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
>  			dst_output);

Regards

--
Julian Anastasov <ja@ssi.bg>
