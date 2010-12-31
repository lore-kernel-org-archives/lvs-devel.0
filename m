From: Simon Horman <horms@verge.net.au>
Subject: Re: [*v3 PATCH 14/22] IPVS: netns awareness to ip_vs_sync
Date: Fri, 31 Dec 2010 09:44:33 +0900
Message-ID: <20101231004433.GA14681@verge.net.au>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
 <1293706266-27152-15-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1293706266-27152-15-git-send-email-hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hans@schillstrom.com
Cc: ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

On Thu, Dec 30, 2010 at 11:50:58AM +0100, hans@schillstrom.com wrote:
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> All global variables moved to struct ipvs,
> most external changes fixed (i.e. init_net removed)
> in sync_buf create  + 4 replaced by sizeof(struct..)

[ snip ]

> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 0454a11..5d6e250 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1477,6 +1477,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	struct ip_vs_proto_data *pd;
>  	struct ip_vs_conn *cp;
>  	int ret, restart, pkts;
> +	struct net *net;

The line above adds a duplicate declaration of net as
just before the diff-context starts there is

	struct net *net = NULL;
