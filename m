From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS Bug, Null ptr in ip_vs_ctl.c
 ip_vs_genl_dump_daemons().
Date: Thu, 31 Mar 2011 10:24:37 +0900
Message-ID: <20110331012436.GA2822@verge.net.au>
References: <1301495797-7546-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1301495797-7546-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Wed, Mar 30, 2011 at 04:36:37PM +0200, Hans Schillstrom wrote:
> ipvsadm -ln --daemon will trigger a Null pointer exception because
> ip_vs_genl_dump_daemons() uses skb_net() instead of skb_sknet().
> 
> To prevent others from NULL ptr a check is made in ip_vs.h skb_net().
> 
> This patches is based on net-2.6

Thanks Hans,

I will prepare a pull request for Patrick this afternoon.

