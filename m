From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/1] export sysctl symbols needed by ip_vs_sync
Date: Mon, 30 Apr 2012 10:47:45 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204301034450.1649@ja.ssi.bg>
References: <1335766430-30528-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335766430-30528-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Horms <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com


	Hello,

On Mon, 30 Apr 2012, Hans Schillstrom wrote:

> To build ip_vs as a module sysctl_rmem_max and sysctl_wmem_max
> needs to be exported.
> The dependency was added by "ipvs: wakeup master thread" patch
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  net/core/sock.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 679c5bb..be8fe5d 100644
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
> 1.7.2.3

	I see why I missed this error. There is some
inefficiency in the build process. Once, I tested the
netns init problems with CONFIG_IP_VS=y, later switched back
to CONFIG_IP_VS=m without 'make clean' but the ip_vs.ko
is not considered, I still get ip_vs as builtin, not as
module:

# cat net/netfilter/ipvs/modules.builtin
kernel/net/netfilter/ipvs/ip_vs.ko

	Is only 'make clean' a solution for such
y->m change?

Regards

--
Julian Anastasov <ja@ssi.bg>
