From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ip_vs_conn_expire_now may cause timer callback runs on two CPUs
 for a same session
Date: Sun, 2 Oct 2016 21:30:59 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1610022052320.1911@ja.home.ssi.bg>
References: <2C44267D-1193-4F59-9A49-356F38E90064@icloud.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <2C44267D-1193-4F59-9A49-356F38E90064@icloud.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: HePeng <xnhp0320@icloud.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sun, 2 Oct 2016, HePeng wrote:

> Hi, 
> 
> I am a newbie to IPVS.
> I read the code of ipvs in 3.10 kernel, and think the 
> the implementation of *ip_vs_expire_now* may cause 
> timer callback runs on two CPUs for a same session.

	IIRC, timers can not be scheduled on multiple
CPUs at the same time. They can be migrated to other
CPUs but only if callback is not running. __mod_timer()
checks if the callback is running (base->running_timer).
If so, it will schedule the timer on the same CPU where the
callback is currently running. So, the callback can be
called twice but not in parallel. Then, when ip_vs_conn_expire()
is called it will call del_timer() to catch such situations.
It is specified in the comments.

> CPU 0                         CPU 1                   CPU2
> 
> 
> 
>                       a timer is detached 
>                       from lists, and the 
>                       callback fn is going 
>                       to be called.
> 
>                                                a packet belongs 
>                                                to the same session
>                                                is processed by this CPU 
>                                                and the timer is re-activated on
>                                                this CPU. Then, the ref of *cp* is released.
> 
> ip_vs_conn_expire_now
> is called on this 
> session, which finds 
> a pending timer, and 
> then *mod_timer_pending*
> will change the timer
> to expire immediately.
> read_unlock allows 
> preemption again.
> 
> the timer expires and 
> callback runs.         call back fn runs
>                        
> 
> Am I right? This seems break the rule that *ip_vs_conn_expire* should only 
> runs on one CPU at time per conn.

	This is guaranteed by the timers. But it is our job
to not start/leave the timer while final callback frees the conn.

> see http://oss.sgi.com/archives/netdev/2003-11/msg00763.html

	Without checking the code from 2003, more likely
the fix above stops calling mod_timer after the final del_timer
to prevent starting new callback. And this goal is what is
later specified in the comments in 3.10 and latest kernels.

Regards

--
Julian Anastasov <ja@ssi.bg>
