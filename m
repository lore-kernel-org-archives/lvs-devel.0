From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: fix oops in ip_vs_dst_event on rmmod
Date: Tue, 10 Jul 2012 17:46:29 +0900
Message-ID: <20120710084629.GB27117@verge.net.au>
References: <1341682211-4751-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341682211-4751-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Sat, Jul 07, 2012 at 08:30:11PM +0300, Julian Anastasov wrote:
> 	After commit 39f618b4fd95ae243d940ec64c961009c74e3333 (3.4)
> "ipvs: reset ipvs pointer in netns" we can oops in
> ip_vs_dst_event on rmmod ip_vs because ip_vs_control_cleanup
> is called after the ipvs_core_ops subsys is unregistered and
> net->ipvs is NULL. Fix it by exiting early from ip_vs_dst_event
> if ipvs is NULL. It is safe because all services and dests
> for the net are already freed.

Hi Julian,

have you observed this oops or is it theoretical?
I ask because it effects if I should submit this change for
inclusion in 3.5 and 3.4-stable or just queue it up for 3.6.

Thanks.

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index dd811b8..b4a21d9 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1521,11 +1521,12 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
>  {
>  	struct net_device *dev = ptr;
>  	struct net *net = dev_net(dev);
> +	struct netns_ipvs *ipvs = net_ipvs(net);
>  	struct ip_vs_service *svc;
>  	struct ip_vs_dest *dest;
>  	unsigned int idx;
>  
> -	if (event != NETDEV_UNREGISTER)
> +	if (event != NETDEV_UNREGISTER || !ipvs)
>  		return NOTIFY_DONE;
>  	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
>  	EnterFunction(2);
> @@ -1551,7 +1552,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
>  		}
>  	}
>  
> -	list_for_each_entry(dest, &net_ipvs(net)->dest_trash, n_list) {
> +	list_for_each_entry(dest, &ipvs->dest_trash, n_list) {
>  		__ip_vs_dev_reset(dest, dev);
>  	}
>  	mutex_unlock(&__ip_vs_mutex);
> -- 
> 1.7.3.4
> 
