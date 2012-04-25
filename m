From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/1] ipvs: kernel oops - do_ip_vs_get_ctl
Date: Wed, 25 Apr 2012 11:56:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204251151280.1895@ja.ssi.bg>
References: <1335339884-29825-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335339884-29825-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com


	Hello,

On Wed, 25 Apr 2012, Hans Schillstrom wrote:

> Change order of init so netns init is ready
> when register ioctl and netlink.
> 
> Reported-by: "Ryan O'Hara" <rohara@redhat.com>
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/net/ip_vs.h             |    2 +
>  net/netfilter/ipvs/ip_vs_core.c |    9 ++++++
>  net/netfilter/ipvs/ip_vs_ctl.c  |   52 ++++++++++++++++++++++----------------
>  3 files changed, 41 insertions(+), 22 deletions(-)
> 

> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 7131417..efaf484 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3750,21 +3750,10 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
>  	free_percpu(ipvs->tot_stats.cpustats);
>  }
>  
> -int __init ip_vs_control_init(void)
> +int ip_vs_register_nl_ioctl(void)

	Can we add __init here. Everything else looks good.

Regards

--
Julian Anastasov <ja@ssi.bg>
