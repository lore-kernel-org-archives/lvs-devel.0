From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v2 PATCH 00/22] IPVS, Network Name Space aware
Date: Wed, 15 Dec 2010 23:11:19 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1012152305360.1827@ja.ssi.bg>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>  <alpine.LFD.2.00.1012150136410.2010@ja.ssi.bg> <1292409147.4983.298.camel@seasc0214>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1292409147.4983.298.camel@seasc0214>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>


 	Hello,

On Wed, 15 Dec 2010, Hans Schillstrom wrote:

>> v2 PATCH 13/22 - ip_vs_est
>>  	- estimation_timer: what protection is needed for for_each_net?
>>  	It is rtnl for user context and RCU for softirq?
>>  	May be est_timer must be per NS? Now may be rcu_read_lock is
>>  	needed before for_each_net_rcu ? for_each_net can be called
>>  	only under rtnl_lock?
>>
> [snip]
>
> In case of a common timer for all ns:
>
> 	rcu_read_lock();
> 	for_each_net_rcu(net) {
> 		...
>
> 	}
> 	rcu_read_unlock();
>
> I guess it's better with a timer per netns ?

 	Yes, I too have little preference for the per-ns timer.

> (then for_each_net() is not needed, and the locking can remain the same
> as before the netns change.)

Regards

--
Julian Anastasov <ja@ssi.bg>
