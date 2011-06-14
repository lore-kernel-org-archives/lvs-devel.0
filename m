From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Re: [RFC PATCH 1/1] IPVS netns shutdown/startup dead-lock
Date: Tue, 14 Jun 2011 09:36:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106140855230.1575@ja.ssi.bg>
References: <oth2obo.8109e7bd386ff72c34c0bda4b6945edf@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <oth2obo.8109e7bd386ff72c34c0bda4b6945edf@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, horms@verge.net.au, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Tue, 14 Jun 2011, Hans Schillstrom wrote:

> >On Mon, 13 Jun 2011, Hans Schillstrom wrote:
> >
> >> ip_vs_mutext is used by both netns shutdown code and startup
> >> and both implicit uses sk_lock-AF_INET mutex.
> >> 
> >> cleanup CPU-1         startup CPU-2
> >> ip_vs_dst_event()     ip_vs_genl_set_cmd()
> >>  sk_lock-AF_INET     __ip_vs_mutex
> >>                      sk_lock-AF_INET
> >> __ip_vs_mutex
> >> * DEAD LOCK *
> >
> >	So, sk_lock-AF_INET is locked before calling
> >ip_vs_dst_event ? Do you have a backtrace for this case?
> 
> Yes plenty this one is with lockdep
> 
> Chain exists of:
>   rtnl_mutex --> __ip_vs_mutex --> sk_lock-AF_INET
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(sk_lock-AF_INET);
>                                lock(__ip_vs_mutex);
>                                lock(sk_lock-AF_INET);
>   lock(rtnl_mutex);
> 
>  *** DEADLOCK ***
> 
> 3 locks held by ipvsadm/993:
>  #0:  (genl_mutex){+.+.+.}, at: [<ffffffff812edc52>] genl_lock+0x17/0x19
>  #1:  (__ip_vs_mutex){+.+.+.}, at: [<ffffffff81307dcb>] ip_vs_genl_set_cmd+0xe1/0x3a3
>  #2:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8130ffc1>] start_sync_thread+0x3ec/0x5ff

	I see

> >> ip_vs_mutex per name-space seems to be a more future proof solution.
> >
> >	Global mutex protects some global lists such as
> >virtual services. If your patch works, better way to fix this problem
> >is to use some new mutex. May be we can move the IPVS_CMD_NEW_DAEMON,
> >IPVS_CMD_DEL_DAEMON and IP_VS_SO_GET_DAEMON code before the
> >__ip_vs_mutex locking. This mutex should be used for start_sync_thread,
> >stop_sync_thread, ip_vs_genl_dump_daemons and IP_VS_SO_GET_DAEMON.
> >For example, ip_vs_sync_mutex.
> 
> I think we should avoid global mutexes as a rule of tumb, 
> because it's realy hard to keep track of all possible cases 
> that can occur when multiple netns is alive and/or goes up and down.
> 
> There might be more suprises while a netns exits (in terms of locks)...
> my gut feeling is, avoid global locks as long as possible.

	There should not be a problem between two netns when
using global mutexes. And there are no many places in IPVS
where other modules are accessed.

> >	Note that __ip_vs_sync_cleanup is missing a
> >__ip_vs_mutex lock. We have to use the new mutex there.
> 
> OK
> 
> >
> >> Which one should be used ?
> >
> >	For now __ip_vs_mutex should be global ...
> 
> I do agree, but in the long term I vote for mutex per netns.

	It will not help because the problem does not happen
between two netspaces but between ipvs and other modules.
The same problem would happen even if __ip_vs_mutex was
pernet mutex. So, lets try with new mutex.

Regards

--
Julian Anastasov <ja@ssi.bg>
