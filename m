From: "junwei.zhang" <junwei.zhang@6wind.com>
Subject: Re: [PATCH 1/2] kernel: remove unnecessary head file
Date: Fri, 21 Jun 2013 10:14:16 +0800
Message-ID: <51C3B6F8.8010704@6wind.com>
References: <1371780327-16054-1-git-send-email-junwei.zhang@6wind.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1371780327-16054-1-git-send-email-junwei.zhang@6wind.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: junwei.zhang@6wind.com
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On 06/21/2013 10:05 AM, junwei.zhang@6wind.com wrote:
> From: JunweiZhang <junwei.zhang@6wind.com>
>
> Signed-off-by: JunweiZhang <junwei.zhang@6wind.com>
> ---
>   kernel/sysctl_binary.c | 1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> index aea4a9e..b609213 100644
> --- a/kernel/sysctl_binary.c
> +++ b/kernel/sysctl_binary.c
> @@ -3,7 +3,6 @@
>   #include "../fs/xfs/xfs_sysctl.h"
>   #include <linux/sunrpc/debug.h>
>   #include <linux/string.h>
> -#include <net/ip_vs.h>
>   #include <linux/syscalls.h>
>   #include <linux/namei.h>
>   #include <linux/mount.h>
Please ignore this series  patch.
I missing some comment.
