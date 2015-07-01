From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: orphan_skb in tunnel transmit case
Date: Thu, 2 Jul 2015 01:16:10 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507020040560.1728@ja.home.ssi.bg>
References: <1435783822-2258560-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1435783822-2258560-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Wed, 1 Jul 2015, Alex Gartrell wrote:

> It's possible that the sk came from early_demux.  This will blow up every
> time in the TCP_TIME_WAIT case in ip_local_out.  No similar crashes exist
> for masquerade or gateway because they do not use ip_local_out{,6}.

	May be it is better to do it for all kind of
forwarding methods:

http://archive.linuxvirtualserver.org/html/lvs-devel/2015-01/msg00018.html
http://archive.linuxvirtualserver.org/html/lvs-devel/2015-01/msg00032.html

	By this way, skb->destructor can be safely changed
in output path (eg. in ip_fragment) while for input path
sock_edemux should be called where sk_state is properly
checked in sock_gen_put.

> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index bf66a86..1db0ca7 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -521,6 +521,13 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
>  	if (unlikely(cp->flags & IP_VS_CONN_F_NFCT))
>  		ret = ip_vs_confirm_conntrack(skb);
>  	if (ret == NF_ACCEPT) {
> +		/* In this case, skb is associated with an old, receiving
> +		 * socket, which may be in TIME-WAIT and invalid for the
> +		 * forward path, so we orphan it.
> +		 */
> +		if (skb->dev)
> +			skb_orphan(skb);
> +
>  		nf_reset(skb);
>  		skb_forward_csum(skb);
>  	}

Regards

--
Julian Anastasov <ja@ssi.bg>
