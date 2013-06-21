From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] kernel: remove unnecessary head file
Date: Fri, 21 Jun 2013 09:40:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306210937180.1707@ja.ssi.bg>
References: <1371781157-16743-1-git-send-email-junwei.zhang@6wind.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1371781157-16743-1-git-send-email-junwei.zhang@6wind.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: JunweiZhang <junwei.zhang@6wind.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>


	Hello,

On Fri, 21 Jun 2013, junwei.zhang@6wind.com wrote:

> From: JunweiZhang <junwei.zhang@6wind.com>
> 
> ip_vs.h is not necessary for sysctl_binary.c.
> 
> prepare for the next patch to avoid compile issue.
> 
> Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

	Both patches look good to me:

Reviewed-by: Julian Anastasov <ja@ssi.bg>

	Please use version descriptor in future, for example:

[PATCHv2 ...] ...

> ---
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

Regards

--
Julian Anastasov <ja@ssi.bg>
