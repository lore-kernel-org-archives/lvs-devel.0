From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPVS Bug, Null ptr in ip_vs_ctl.c ip_vs_genl_dump_daemons().
Date: Mon, 04 Apr 2011 15:28:03 +0200
Message-ID: <4D99C763.6040503@trash.net>
References: <1301535135-4288-1-git-send-email-horms@verge.net.au> <1301535135-4288-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1301535135-4288-2-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>

On 31.03.2011 03:32, Simon Horman wrote:
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> ipvsadm -ln --daemon will trigger a Null pointer exception because
> ip_vs_genl_dump_daemons() uses skb_net() instead of skb_sknet().
> 
> To prevent others from NULL ptr a check is made in ip_vs.h skb_net().
> 

Applied, thanks.

