From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Sun, 1 May 2011 20:48:58 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105012044161.1430@ja.ssi.bg>
References: <1304268618-18103-1-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1304268618-18103-1-git-send-email-hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com


	Hello,

On Sun, 1 May 2011, Hans Schillstrom wrote:

> This patch series handles exit from a network name space.
> 
> REVISION
> 
> This is version 4
> 
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
>   (eleased version could not handle unregistration of netdevices.)
> 
> Comments from Eric, Julian and Simon implmented.
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
>  
> Revision 4
> 	ip_vs_unlink_service_nolock() removed.
> 	ip_vs_flush() reverted.
> 	Return code check changed in stop thread.

	Not sure about patch 1 but patches 2-6 in v4 look
good to me. Thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

