From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 1/1] IPVS netns shutdown/startup dead-lock
Date: Tue, 14 Jun 2011 00:25:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106132309440.1627@ja.ssi.bg>
References: <1307957530-12732-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1307957530-12732-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com


	Hello,

On Mon, 13 Jun 2011, Hans Schillstrom wrote:

> ip_vs_mutext is used by both netns shutdown code and startup
> and both implicit uses sk_lock-AF_INET mutex.
> 
> cleanup CPU-1         startup CPU-2
> ip_vs_dst_event()     ip_vs_genl_set_cmd()
>  sk_lock-AF_INET     __ip_vs_mutex
>                      sk_lock-AF_INET
> __ip_vs_mutex
> * DEAD LOCK *

	So, sk_lock-AF_INET is locked before calling
ip_vs_dst_event ? Do you have a backtrace for this case?
I assume your patch is tested to fix the problem ?

> This can be solved by have the ip_vs_mutex per netns
> or avid locking when starting/stoping sync-threads.
> i.e. just add a starting/stoping flag.

	sk_release_kernel is called in thread
context, so ip_vs_mutex is not involved there. We
have a problem only with start_sync_thread, right?

> ip_vs_mutex per name-space seems to be a more future proof solution.

	Global mutex protects some global lists such as
virtual services. If your patch works, better way to fix this problem
is to use some new mutex. May be we can move the IPVS_CMD_NEW_DAEMON,
IPVS_CMD_DEL_DAEMON and IP_VS_SO_GET_DAEMON code before the
__ip_vs_mutex locking. This mutex should be used for start_sync_thread,
stop_sync_thread, ip_vs_genl_dump_daemons and IP_VS_SO_GET_DAEMON.
For example, ip_vs_sync_mutex.

	Note that __ip_vs_sync_cleanup is missing a
__ip_vs_mutex lock. We have to use the new mutex there.

> Which one should be used ?

	For now __ip_vs_mutex should be global ...

Regards

--
Julian Anastasov <ja@ssi.bg>
