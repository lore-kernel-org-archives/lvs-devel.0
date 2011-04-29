From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Fri, 29 Apr 2011 10:29:30 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1104291024360.1605@ja.ssi.bg>
References: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com


	Hello,

On Fri, 29 Apr 2011, Hans Schillstrom wrote:

> This patch series handles exit from a network name space.
> 
> REVISION
> 
> This is version 3

	Great! Only one missing lock:

Patch 3:
	Missing write_[un]lock_bh(&__ip_vs_svc_lock) in ip_vs_flush,
	now we use ip_vs_unlink_service_nolock.

As you are going to create new version you can look also at these:

Patch 5:
	Can you rename 'goto exit;' to 'goto cleanup;' or
	'goto out;'

Patch 6:
	Add at least one comma after 'enabled' here:
	netns(%d) enabled first service added

> OVERVIEW
> Basically there was three faults in the netns implementation.
> - Kernel threads hold devices and preventing an exit.
> - dst cache holds references to devices.
> - Services was not always released.
> 
> Patch 1 & 3 contains the functionality
>       4 renames funcctions
>       5 removes empty functions
>       6 Debuging.
> 
> IMPLEMENTATION
> - Avoid to increment the usage counter for kernel threads.
>   this is done in the first patch.
> - Patch 3 tries to restore the cleanup order.
>   Add NETDEV_UNREGISTER notification for dst_reset
> 
> Revision 3 
> Residies in patch 3
>         Throttle renamed to enable.
>         Comments from Julian implemented
>         Check enable in ip_vs_in, ip_vs_out and ip_vs_forward_icmp*
>         Remove in ip_vs_in_icmp*.
>         ip_vs_svc_reset() moved into ip_vs_dst_event().
>         ip_vs_service_cleanup() uses ip_vs_flush and mutex lock.
>         ip_vs_unlink_service_nolock() added.

Regards

--
Julian Anastasov <ja@ssi.bg>
