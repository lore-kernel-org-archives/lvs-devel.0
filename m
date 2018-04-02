From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next v1] ipvs: add consistent source hashing
 scheduling
Date: Mon, 2 Apr 2018 22:05:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1804022145370.1734@ja.home.ssi.bg>
References: <20180402172025.7380-1-vincent@bernat.im>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180402172025.7380-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vincent Bernat <vincent@bernat.im>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Inju Song <inju.song@navercorp.com>


	Hello,

On Mon, 2 Apr 2018, Vincent Bernat wrote:

> Based on Google's Maglev algorithm [1][2], this scheduler builds a
> lookup table in a way disruption is minimized when a change
> occurs. This helps in case of active/active setup without
> synchronization. Like for classic source hashing, this lookup table is
> used to assign connections to a real server.
> 
> Both source address and port are used to compute the hash (unlike sh
> where this is optional).
> 
> Weights are correctly handled. Unlike sh, servers with a weight of 0
> are considered as absent. Also, unlike sh, when a server becomes
> unavailable due to a threshold, no fallback is possible: doing so
> would seriously impair the the usefulness of using a consistent hash.
> 
> There is a small hack to detect when all real servers have a weight of
> 0. It relies on the fact it is not possible for the weight of a real
> server to change during the execution of the assignment. I believe
> this is the case as modifications through netlink are subject to a
> mutex, but the use of atomic_read() is unsettling.
> 
> The value of 65537 for the hash table size is currently not modifiable
> at compile-time. This is the value suggested in the Maglev
> paper. Another possible value is 257 (for small tests) and 655373 (for
> very large setups).
> 
> [1]: https://research.google.com/pubs/pub44824.html
> [2]: https://blog.acolyer.org/2016/03/21/maglev-a-fast-and-reliable-software-network-load-balancer/

	Sorry to say it but may be you missed the discussion
on lvs-devel about the new MH scheduler implemented by Inju Song:

https://www.spinics.net/lists/lvs-devel/msg04928.html
http://archive.linuxvirtualserver.org/html/lvs-devel/2018-03/msg00023.html

	In the last 6 months we fixed all issues and I acked
v4 just yesterday:

http://archive.linuxvirtualserver.org/html/lvs-devel/2018-04/msg00003.html

	This scheduler supports:

- tables with different size (prime): IP_VS_MH_TAB_INDEX
- gcd of weights: ip_vs_mh_gcd_weight
- shifted weights: ip_vs_mh_shift_weight
- weight can be changed any time

> Signed-off-by: Vincent Bernat <vincent@bernat.im>
> ---
>  include/net/ip_vs.h            |  27 ++++
>  net/netfilter/ipvs/Kconfig     |  13 ++
>  net/netfilter/ipvs/Makefile    |   1 +
>  net/netfilter/ipvs/ip_vs_csh.c | 339 +++++++++++++++++++++++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_sh.c  |  32 +---
>  5 files changed, 381 insertions(+), 31 deletions(-)
>  create mode 100644 net/netfilter/ipvs/ip_vs_csh.c

Regards
