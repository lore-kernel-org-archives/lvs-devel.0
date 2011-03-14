From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 02/20] ipvs: reorganize tot_stats
Date: Mon, 14 Mar 2011 11:21:21 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103141104070.1736@ja.ssi.bg>
References: <1300074346-13799-1-git-send-email-horms@verge.net.au>  <1300074346-13799-3-git-send-email-horms@verge.net.au> <1300076903.2761.64.camel@edumazet-laptop>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1300076903.2761.64.camel@edumazet-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>


 	Hello,

On Mon, 14 Mar 2011, Eric Dumazet wrote:

>>  	Also, make sure ip_vs_stats_percpu_show reads properly
>> the u64 stats from user context.
>>
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
>> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> One comment : per cpu stats are really good to avoid cache misses, but I
> see tot_stats is included in struct netns_ipvs right after "conn_count",
> possibly sharing a hot cache line ?

 	conn_count and tcp_app_lock, udp_app_lock, sctp_app_lock
are used when packet creates new connection, probably on the
same time depending on the protocol in packet. May be conn_count
better to be before tcp_apps, far away from some sysctl vars
that are mostly read?

 	For tot_stats: cpustats ptr is always read,
other fields in tot_stats are updated from the 2-second
timer. May be it is better just to move tot_stats before
est_list, it is written at the same time?

Regards

--
Julian Anastasov <ja@ssi.bg>
