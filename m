From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvs: memset problem/bug in ip_vs_tunnel_xmit_v6() ?
Date: Tue, 4 Sep 2012 22:53:44 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209042244580.2017@ja.ssi.bg>
References: <1346752358.3069.594.camel@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1346752358.3069.594.camel@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: LVS devel <lvs-devel@vger.kernel.org>


	Hello,

On Tue, 4 Sep 2012, Jesper Dangaard Brouer wrote:

> Hi 
> 
> While looking at the IP6CB related code in IPVS, I stumbled upon this,
> memset in ip_vs_tunnel_xmit_v6() which look wrong in a IPv6 related
> function...

	I saw it too in the last days. But I was not
sure what needs to be reset for output IPv6 path, may be
only IP6CB(skb)->flags matters and we should preserve it.
Comparing it with other places, eg. ip6_tnl_xmit2, may be
we should just delete this memset? By this way we will
preserve the flags.

> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c
> b/net/netfilter/ipvs/ip_vs_xmit.c
> index 1060bd5..7efa90c 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -998,6 +998,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct
> ip_vs_conn *cp,
>  
>         skb_push(skb, sizeof(struct ipv6hdr));
>         skb_reset_network_header(skb);
> +       /* jbrouer: Hmmm, memset below looks wrong in a IPv6 context */
>         memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>  
>         /* drop old route */
> 
> 
> The change looks like a copy-paste introduced in commit:
> 
> commit b3cdd2a73867d309dca288b8e820c09e3b7f1da1
> Author: Julius Volz <juliusv@google.com>
> Date:   Tue Sep 2 15:55:45 2008 +0200
> 
>     IPVS: Add and bind IPv6 xmit functions
>     
>     Add xmit functions for IPv6. Also add the already needed __ip_vs_get_out_rt_v6()
>     to ip_vs_core.c. Bind the new xmit functions to v6 connections.
>     
>     Signed-off-by: Julius Volz <juliusv@google.com>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> 
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer

Regards

--
Julian Anastasov <ja@ssi.bg>
