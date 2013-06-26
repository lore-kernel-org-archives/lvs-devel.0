From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 net-next 1/2] kernel: remove unnecessary head file
Date: Wed, 26 Jun 2013 17:59:25 +0900
Message-ID: <20130626085925.GB24362@verge.net.au>
References: <20130624.002401.1459814761780281188.davem@davemloft.net>
 <1372236006-16683-1-git-send-email-junwei.zhang@6wind.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1372236006-16683-1-git-send-email-junwei.zhang@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: junwei.zhang@6wind.com
Cc: davem@davemloft.net, wensong@linux-vs.org, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, nicolas.dichtel@6wind.com

On Wed, Jun 26, 2013 at 04:40:05PM +0800, junwei.zhang@6wind.com wrote:
> From: JunweiZhang <junwei.zhang@6wind.com>
> 
> ip_vs.h is not necessary for sysctl_binary.c.
> 
> prepare for the next patch to avoid compile issue.
> 
> Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Reviewed-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied to ipvs-next.

> ---
> v2: rebase on net-next
>  kernel/sysctl_binary.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> index aea4a9e..b609213 100644
> --- a/kernel/sysctl_binary.c
> +++ b/kernel/sysctl_binary.c
> @@ -3,7 +3,6 @@
>  #include "../fs/xfs/xfs_sysctl.h"
>  #include <linux/sunrpc/debug.h>
>  #include <linux/string.h>
> -#include <net/ip_vs.h>
>  #include <linux/syscalls.h>
>  #include <linux/namei.h>
>  #include <linux/mount.h>
> -- 
> 1.8.1.2
> 
