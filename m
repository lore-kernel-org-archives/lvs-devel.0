From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 18/18] export sysctl symbols needed by ip_vs_sync
Date: Sun, 6 May 2012 22:54:12 +0200
Message-ID: <20120506205412.GA22406@1984>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
 <1335939762-1912-19-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335939762-1912-19-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hi David,

The IPVS people needs this patch for net-next to allow to tune the
socket buffer for ipvs_sync (the state synchronization that they do
from kernel-space). This exports sysctl_wmem_max and sysctl_rmem_max
living in net/core/sock.c. So far, they've been using global socket
tuning to make them bigger (this avoids overruning the socket under
high peak of state-change synchronization).

I think this is out of my scope (since it's out of the netfilter
tree).

Would you acknowledge it, please?

On Wed, May 02, 2012 at 03:22:42PM +0900, Simon Horman wrote:
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> To build ip_vs as a module sysctl_rmem_max and sysctl_wmem_max
> needs to be exported.
> The dependency was added by "ipvs: wakeup master thread" patch
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/core/sock.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index c7e60ea..ac3131a 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -258,7 +258,9 @@ static struct lock_class_key af_callback_keys[AF_MAX];
>  
>  /* Run time adjustable parameters. */
>  __u32 sysctl_wmem_max __read_mostly = SK_WMEM_MAX;
> +EXPORT_SYMBOL(sysctl_wmem_max);
>  __u32 sysctl_rmem_max __read_mostly = SK_RMEM_MAX;
> +EXPORT_SYMBOL(sysctl_rmem_max);
>  __u32 sysctl_wmem_default __read_mostly = SK_WMEM_MAX;
>  __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
>  
> -- 
> 1.7.10
> 
