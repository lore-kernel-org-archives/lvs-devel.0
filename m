From: Simon Horman <horms@verge.net.au>
Subject: Re: [lvs-users] [PATCH net] ipvs: do not use random local source
 address for tunnels
Date: Mon, 29 Jun 2015 10:05:41 +0900
Message-ID: <20150629010540.GA13676@verge.net.au>
References: <1435405170-21023-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435405170-21023-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "LinuxVirtualServer.org users mailing list." <lvs-users@linuxvirtualserver.org>
Cc: lvs-devel@vger.kernel.org, Michael Vallaly <lvs@nolatency.com>

On Sat, Jun 27, 2015 at 02:39:30PM +0300, Julian Anastasov wrote:
> Michael Vallaly reports about wrong source address used
> in rare cases for tunneled traffic. Looks like
> __ip_vs_get_out_rt in 3.10+ is providing uninitialized
> dest_dst->dst_saddr.ip because ip_vs_dest_dst_alloc uses
> kmalloc. While we retry after seeing EINVAL from routing
> for data that does not look like valid local address, it
> still succeeded when this memory was previously used from
> other dests and with different local addresses. As result,
> we can use valid local address that is not suitable for
> our real server.
> 
> Fix it by providing 0.0.0.0 every time our cache is refreshed.
> By this way we will get preferred source address from routing.
> 
> Reported-by: Michael Vallaly <lvs@nolatency.com>
> Fixes: 026ace060dfe ("ipvs: optimize dst usage for real server")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have applied this to the ipvs tree.
