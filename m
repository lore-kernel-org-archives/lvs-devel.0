From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Wed, 20 Oct 2010 17:21:45 +0200
Message-ID: <20101020152112.GA8502@verge.net.au>
References: <201010081317.04167.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010081317.04167.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

On Fri, Oct 08, 2010 at 01:17:02PM +0200, Hans Schillstrom wrote:
> This patch just contains ip_vs_ctl
> 
> Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index ca8ec8c..7e99cbc 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c

[ snip ]

> @@ -3377,62 +3383,131 @@ static void ip_vs_genl_unregister(void)
>  }
> 
>  /* End of Generic Netlink interface definitions */
> +/*
> + * per netns intit/exit func.
> + */
> +int /*__net_init*/ __ip_vs_control_init(struct net *net)

Can you describe why __net_init is commented out?

[ snip ]
