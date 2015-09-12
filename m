From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs:Fix locking requirements in the function
 ip_vs_unlink_service
Date: Sat, 12 Sep 2015 21:28:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509122111110.1491@ja.home.ssi.bg>
References: <1442032025-18642-1-git-send-email-xerofoify@gmail.com> <alpine.LFD.2.11.1509120910090.1626@ja.home.ssi.bg> <55F43D34.3020805@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55F43D34.3020805@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: nick <xerofoify@gmail.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org


	Hello,

On Sat, 12 Sep 2015, nick wrote:

> > 	BH locking is not needed anymore. Also, sched_lock is
> > used by schedulers to protect only access to svc->sched_data
> > fields.
> > 
> > 	It seems the comment is outdated after
> > commit ceec4c381681 ("ipvs: convert services to rcu").
> > 
> Julian,
> You are correct after reading the commit id for rcu locking conversion that this comment
> is outdated. However the locking may still be required but in terms of rcu_read_lock/
> unlock around this function call as it's still a critical region.

	This function is called under __ip_vs_mutex, so
there is single writer that modifies the configuration.
As "readers" the schedulers access the configuration under
rcu_read_lock (eg. called in tcp_conn_schedule) but they
are free to use other locking too. ip_vs_wlc.c scheduler
is example where sched_lock is not used because only
svc->destinations is accessed which is protected with RCU
by definition. You can check __ip_vs_unlink_dest() how
dest is unlinked with list_del_rcu() before sched->del_dest
method is called.

Regards

--
Julian Anastasov <ja@ssi.bg>
