From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v2 PATCH 00/22] IPVS, Network Name Space aware
Date: Wed, 15 Dec 2010 01:43:13 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1012150136410.2010@ja.ssi.bg>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: horms@verge.net.au, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com


 	Hello,

On Mon, 13 Dec 2010, Hans Schillstrom wrote:

> This patch series adds network name space support to the LVS.
>
> REVISION
>
> This is version 2
>
> OVERVIEW
>
> The patch doesn't remove or add any functionality except for netns.
> For users that don't use network name space (netns) this patch is
> completely transparent.
>
> Now it's possible to run LVS in a Linux container (see lxc-tools)
> i.e.  a light weight visualization. For example it's possible to run
> one or several lvs on a real server in their own network name spaces.
>> From the LVS point of view it looks like it runs on it's own machine.
>
> IMPLEMENTATION
> Basic requirements for netns awareness
> - Global variables has to be moved to dyn. allocated memory.
> - No or very little performance loss
>
> Large hash tables connection hash and service hashes still resides in
> global memory with net ptr added in hash key.
> Most global variables now resides in a struct ipvs { } in netns/ip_vs.h.
> The size of per name space is 2004 bytes (for x86_64) and a little bit less
> for 32 bit archs.
>
> Statistics counters is now lock-free i.e. incremented per CPU,
> The estimator does a sum when using it.
>
> Procfs ip_vs_stats is also changed to reflect the "per cpu"
> ex.
> # cat /proc/net/ip_vs_stats
>       Total Incoming Outgoing         Incoming         Outgoing
> CPU    Conns  Packets  Packets            Bytes            Bytes
>  0        0        3        1               9D               34
>  1        0        1        2               49               70
>  2        0        1        2               34               76
>  3        1        2        2               70               74
>  ~        1        7        7              18A              18E
>
>     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
>           0        0        0                0                0
>
> Algorithm files are untouched except for lblc and lblcr.

 	Great! I have some small comments after first look:

v2 PATCH 01/22 - basic init
 	- first change in ip_vs_conn.c adds existing code:
 	/* Compute size and mask */

v2 PATCH 02/22 - services part 1
 	- net = skb_net(skb) in ip_vs_out must be after
 	check for skb_dst. The skb_dst checks are in ip_vs_in and
 	ip_vs_out, so skb_net() can be used only after these checks.

 	- __ip_vs_service_find and __ip_vs_svc_fwm_find are fast path,
 	may be net_eq(svc->net, net) check can be last, I assume
 	the different netns will use different VIPs and VPORTs?

 	- ip_vs_svc_table and ip_vs_svc_fwm_table are not per-ns,
 	so we can not use per-ns mutex in patch 17

v2 PATCH 03/22 - lblcr

v2 PATCH 04/22 - lblc

v2 PATCH 05/22 - prepare protocol

v2 PATCH 06/22 - tcp

v2 PATCH 07/22 - udp

v2 PATCH 08/22 - sctp

v2 PATCH 09/22 - AH, ESP

v2 PATCH 10/22 - use ip_vs_proto_data as param
 	- update_defense_level: are per-ns memory stats/limits possible?

 	- The pp -> pd conversion should start from functions like
 	ip_vs_out() that use pp = ip_vs_proto_get(iph.protocol),
 	now they should use
 	ip_vs_proto_data_get(net, iph.protocol). If
 	pp is needed, it is available from pd->pp. Many functions
 	that provide pp as argument should now provide pd.
 	Then 2nd lookups for proto like in ip_vs_set_state should
 	disappear.

 	- copy-and-paste bug in ip_vs_ctl.c:ip_vs_set_timeout():
 		pd = ip_vs_proto_data_get(net, IPPROTO_TCP)
 		should be IPPROTO_UDP

 	- may be ip_vs_protocol_timeout_change should propagate
 	event to all pd, not all pp?

v2 PATCH 11/22 - appcnt

v2 PATCH 12/22 - apps

v2 PATCH 13/22 - ip_vs_est
 	- estimation_timer: what protection is needed for for_each_net?
 	It is rtnl for user context and RCU for softirq?
 	May be est_timer must be per NS? Now may be rcu_read_lock is
 	needed before for_each_net_rcu ? for_each_net can be called
 	only under rtnl_lock?

v2 PATCH 14/22 - ip_vs_sync

v2 PATCH 15/22 - ip_vs_stats
 	- This was one of the hurdles for IPVS RCU conversion, the others
 	being dest->svc->stats and scheduler state. But can this
 	change break some scripts that parse /proc/net/ip_vs_stats ?

v2 PATCH 16/22 - connection hash

v2 PATCH 17/22 - ip_vs_ctl local vars
 	- I hope it is not fatal if __ip_vs_mutex remains global
 	because svc lists are global in patch 2

v2 PATCH 18/22 - defense work

v2 PATCH 19/22 - trash

v2 PATCH 20/22 - global svc counters

v2 PATCH 21/22 - init_net removal

v2 PATCH 22/22 - enable netns

Regards

--
Julian Anastasov <ja@ssi.bg>
