From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/4] ipvs: take care of return value from protocol
 init_netns
Date: Wed, 25 Apr 2012 11:35:28 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204251126420.1895@ja.ssi.bg>
References: <1335339821-29684-1-git-send-email-hans.schillstrom@ericsson.com> <1335339821-29684-3-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335339821-29684-3-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com


	Hello,

On Wed, 25 Apr 2012, Hans Schillstrom wrote:

> ip_vs_create_timeout_table() can return NULL
> All functions protocol init_netns is affected of this patch.
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---

> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index 6a8d176..0b74795 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -79,7 +79,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
>  	atomic_set(&pd->appcnt, 0);	/* Init app counter */
>  
>  	if (pp->init_netns != NULL)
> -		pp->init_netns(net, pd);
> +		return pp->init_netns(net, pd);

	May be it is better to unlink and free the pd here
if init_netns fails. Currently, protocols attach only
allocated pointer (pd->timeout_table) and it is not a
big problem to call exit_netns on failure but lets do
it safely, every init handler should release its data on
failure and then we should not call exit_netns.

	Patch 1 looks ok and I'll ack it next time.

Regards

--
Julian Anastasov <ja@ssi.bg>
