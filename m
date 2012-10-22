From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [nf-next PATCH] ipvs: fix build error when CONFIG_IP_VS_IPV6
 is disabled
Date: Mon, 22 Oct 2012 18:30:34 +0200
Message-ID: <20121022163034.GA6698@1984>
References: <20121022121711.31397.6231.stgit@dragon>
 <Pine.LNX.4.64.1210221732480.3065@ask.diku.dk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1210221732480.3065@ask.diku.dk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <hawk@diku.dk>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>, fengguang.wu@intel.com, yuanhan.liu@linux.intel.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Mon, Oct 22, 2012 at 05:39:43PM +0200, Jesper Dangaard Brouer wrote:
> 
> Hi Pablo,
> 
> Argh - there is one more CONFIG option combi that can cause issues.
> 
>  *So hold off on this patch*
> 
> Which is related to including linux/netfilter_ipv6/ip6_tables.h
> under CONFIG_IPV6 when CONFIG_NETFILTER is disabled, as
> kernel/sysctl_binary.c include net/ip_vs.h.  I'll send a new patch
> soon!

Ok, wait for it.

Thanks for your quick response.
