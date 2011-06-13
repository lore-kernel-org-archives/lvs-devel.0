From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 1/1] IPVS netns shutdown/startup dead-lock
Date: Mon, 13 Jun 2011 20:11:29 +0900
Message-ID: <20110613111126.GA1502@verge.net.au>
References: <1307957530-12732-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1307957530-12732-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Mon, Jun 13, 2011 at 11:32:10AM +0200, Hans Schillstrom wrote:
> ip_vs_mutext is used by both netns shutdown code and startup
> and both implicit uses sk_lock-AF_INET mutex.
> 
> cleanup CPU-1         startup CPU-2
> ip_vs_dst_event()     ip_vs_genl_set_cmd()
>  sk_lock-AF_INET     __ip_vs_mutex
>                      sk_lock-AF_INET
> __ip_vs_mutex
> * DEAD LOCK *
> 
> This can be solved by have the ip_vs_mutex per netns
> or avid locking when starting/stoping sync-threads.
> i.e. just add a starting/stoping flag.
> 
> ip_vs_mutex per name-space seems to be a more future proof solution.
> 
> Which one should be used ?

I don't feel strongly either way.

> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/net/ip_vs.h             |    2 ++
>  net/netfilter/ipvs/ip_vs_ctl.c  |   15 ++++++++++-----
>  net/netfilter/ipvs/ip_vs_sync.c |   30 +++++++++++++++++++++++++-----
>  3 files changed, 37 insertions(+), 10 deletions(-)
> 

[snip]

> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 699c79a..21c541f 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c

[snip]

> @@ -3305,12 +3309,13 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
>  			ret = -EINVAL;
>  			goto out;
>  		}
> -
> +		/* Unlock since a global socket lock will be taken later */
> +		mutex_unlock(&__ip_vs_mutex);
>  		if (cmd == IPVS_CMD_NEW_DAEMON)
>  			ret = ip_vs_genl_new_daemon(net, daemon_attrs);
>  		else
>  			ret = ip_vs_genl_del_daemon(net, daemon_attrs);
> -		goto out;
> +		goto out_nounlock;

I'm not a huge fan of labels that only return.
So I think it would be slightly easier on the eyes
to just return here, not add out_nounlock,
and possibly rename out as out_unlock.

>  	} else if (cmd == IPVS_CMD_ZERO &&
>  		   !info->attrs[IPVS_CMD_ATTR_SERVICE]) {
>  		ret = ip_vs_zero_all(net);

[snip]
