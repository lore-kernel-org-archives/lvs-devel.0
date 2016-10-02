From: HePeng <xnhp0320@icloud.com>
Subject: ip_vs_conn_expire_now may cause timer callback runs on two CPUs for a same session
Date: Sun, 2 Oct 2016 23:59:49 +0800
Message-ID: <2C44267D-1193-4F59-9A49-356F38E90064@icloud.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Hi, 

I am a newbie to IPVS.
I read the code of ipvs in 3.10 kernel, and think the 
the implementation of *ip_vs_expire_now* may cause 
timer callback runs on two CPUs for a same session.



CPU 0                         CPU 1                   CPU2



                      a timer is detached 
                      from lists, and the 
                      callback fn is going 
                      to be called.

                                               a packet belongs 
                                               to the same session
                                               is processed by this CPU 
                                               and the timer is re-activated on
                                               this CPU. Then, the ref of *cp* is released.

ip_vs_conn_expire_now
is called on this 
session, which finds 
a pending timer, and 
then *mod_timer_pending*
will change the timer
to expire immediately.
read_unlock allows 
preemption again.

the timer expires and 
callback runs.         call back fn runs
                       

Am I right? This seems break the rule that *ip_vs_conn_expire* should only 
runs on one CPU at time per conn.
see http://oss.sgi.com/archives/netdev/2003-11/msg00763.html



