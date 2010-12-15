From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [*v2 PATCH 00/22] IPVS, Network Name Space aware
Date: Wed, 15 Dec 2010 11:32:27 +0100
Message-ID: <1292409147.4983.298.camel@seasc0214>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
	 <alpine.LFD.2.00.1012150136410.2010@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1012150136410.2010@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>

On Wed, 2010-12-15 at 00:43 +0100, Julian Anastasov wrote:
> 	Hello,
> 
> On Mon, 13 Dec 2010, Hans Schillstrom wrote:
[snip]
> v2 PATCH 13/22 - ip_vs_est
>  	- estimation_timer: what protection is needed for for_each_net?
>  	It is rtnl for user context and RCU for softirq?
>  	May be est_timer must be per NS? Now may be rcu_read_lock is
>  	needed before for_each_net_rcu ? for_each_net can be called
>  	only under rtnl_lock?
> 
[snip]

In case of a common timer for all ns:

	rcu_read_lock();
	for_each_net_rcu(net) {
		...

	}
	rcu_read_unlock();

I guess it's better with a timer per netns ?
(then for_each_net() is not needed, and the locking can remain the same
as before the netns change.)


Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>

