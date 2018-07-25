From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3] ipvs: fix race between ip_vs_conn_new() and
 ip_vs_del_dest()
Date: Wed, 25 Jul 2018 22:12:48 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1807252208320.2437@ja.home.ssi.bg>
References: <1532503387-3800-1-git-send-email-tan.hu@zte.com.cn>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1532503387-3800-1-git-send-email-tan.hu@zte.com.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tan Hu <tan.hu@zte.com.cn>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn, jiang.biao2@zte.com.cn


	Hello,

On Wed, 25 Jul 2018, Tan Hu wrote:

> We came across infinite loop in ipvs when using ipvs in docker
> env.
> 
> When ipvs receives new packets and cannot find an ipvs connection,
> it will create a new connection, then if the dest is unavailable
> (i.e. IP_VS_DEST_F_AVAILABLE), the packet will be dropped sliently.
> 
> But if the dropped packet is the first packet of this connection,
> the connection control timer never has a chance to start and the
> ipvs connection cannot be released. This will lead to memory leak, or
> infinite loop in cleanup_net() when net namespace is released like
> this:
> 
>     ip_vs_conn_net_cleanup at ffffffffa0a9f31a [ip_vs]
>     __ip_vs_cleanup at ffffffffa0a9f60a [ip_vs]
>     ops_exit_list at ffffffff81567a49
>     cleanup_net at ffffffff81568b40
>     process_one_work at ffffffff810a851b
>     worker_thread at ffffffff810a9356
>     kthread at ffffffff810b0b6f
>     ret_from_fork at ffffffff81697a18
> 
> race condition:
>     CPU1                           CPU2
>     ip_vs_in()
>       ip_vs_conn_new()
>                                    ip_vs_del_dest()
>                                      __ip_vs_unlink_dest()
>                                        ~IP_VS_DEST_F_AVAILABLE
>       cp->dest && !IP_VS_DEST_F_AVAILABLE
>       __ip_vs_conn_put
>     ...
>     cleanup_net  ---> infinite looping
> 
> Fix this by checking whether the timer already started.
> 
> Signed-off-by: Tan Hu <tan.hu@zte.com.cn>
> Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>

	v3 looks good to me,

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon and Pablo, this can be applied to ipvs/nf tree...

> ---
> v2: fix use-after-free in CONN_ONE_PACKET case suggested by Julian Anastasov
> v3: remove trailing whitespace for patch checking 
> 
>  net/netfilter/ipvs/ip_vs_core.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 0679dd1..a17104f 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1972,13 +1972,20 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
>  	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
>  		/* the destination server is not available */
> 
> -		if (sysctl_expire_nodest_conn(ipvs)) {
> +		__u32 flags = cp->flags;
> +
> +		/* when timer already started, silently drop the packet.*/
> +		if (timer_pending(&cp->timer))
> +			__ip_vs_conn_put(cp);
> +		else
> +			ip_vs_conn_put(cp);
> +
> +		if (sysctl_expire_nodest_conn(ipvs) &&
> +		    !(flags & IP_VS_CONN_F_ONE_PACKET)) {
>  			/* try to expire the connection immediately */
>  			ip_vs_conn_expire_now(cp);
>  		}
> -		/* don't restart its timer, and silently
> -		   drop the packet. */
> -		__ip_vs_conn_put(cp);
> +
>  		return NF_DROP;
>  	}
> 
> --
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>
