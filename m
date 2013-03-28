From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 00/15 v3] IPVS optimizations (repost)
Date: Thu, 28 Mar 2013 18:04:26 +0900
Message-ID: <20130328090425.GA31670@verge.net.au>
References: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364449184-26672-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Thu, Mar 28, 2013 at 02:39:29PM +0900, Simon Horman wrote:
> Hi Dave, Hi Pablo, Hi All,
> 
> This is a repost of an IPVS optimisations series by Julian Anastasov
> which has been acked by Hans Schillstrom.
> 
> I have tentatively applied them to the ipvs-next tree.
> However, the first patch of the series "net: add skb_dst_set_noref_force"
> touches core code and thus I believe it needs some review on netdev,
> this is the reason for me posting the series.
> 
> Assuming the patch is ok it would be easiest for me if
> it went through the ipvs-next tree. But if there is a preference
> for taking it through net-next, feel free.
> 
> What follows is Julian's cover-email for the series.
> And then git information. I am happy for Pablo to pull this
> if Dave is happy with that.

It seems that Dave has already acked the change.

http://marc.info/?l=linux-netdev&m=136294921002680&w=2

I'll tag ipvs-next and send a proper pull request.

> ======================================================================
> 
> Date: Thu, 21 Mar 2013 11:57:57 +0200
> From: Julian Anastasov <ja@ssi.bg>
> To: Simon Horman <horms@verge.net.au>
> Cc: lvs-devel@vger.kernel.org
> Subject: [PATCHv3 net-next 00/15] IPVS optimizations
> 
> 	This is a first patchset for IPVS optimizations.
> Another patchset will address the locking in schedulers
> and moving the global _bh disabling from LOCAL_OUT to all
> locks.
> 
> 	All patches are for net-next and Simon can
> take them for ipvs-next.
> 
> 	The changes in this patchset eliminate locks
> and dst refcnt operations from packet processing by
> using RCU. There are more details in the patches.
> 
> v3:
> * in "ipvs: consolidate all dst checks on transmit in one place"
>   preserve original skb dst even for local client, remove the
>   rt_is_input_route and skb->dev check. Call update_pmtu only for
>   local client by providing sk instead of skb.
> * in "ipvs: optimize dst usage for real server" use
>   rcu_dereference_protected for __ip_vs_dst_cache_reset instead of
>   rcu_dereference_raw. Use the new skb_dst_set_noref_force func.
> * in "ipvs: remove rs_lock by using RCU" prefer the port check in
>   ip_vs_has_real_service
> * "ipvs: convert locks used in persistence engines" needs only
>   synchronize_rcu, not rcu_barrier, we do not use rcu callbacks
> 
> v2:
> * use "net: add skb_dst_set_unref" instead of
>   "net: add dst_get_noref and refdst_ptr helpers"
> * add "ipvs: no need to reroute anymore on DNAT over loopback"
> * add "ipvs: do not use skb_share_check"
> * add "ipvs: consolidate all dst checks on transmit in one place", so
>   that we can avoid the refdst games in next patch
> * after "ipvs: consolidate all dst checks on transmit in one place"
>   "ipvs: optimize dst usage for real server" is simpler and
>   uses the new skb_dst_set_unref function
> * extend "ipvs: reorder keys in connection structure" with
>   changes in ip_vs_ct_in_get
> * fix "ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new" to use new
>   function ip_vs_addr_set, so that we reset all address fields
>   that are used for hashing by hash_conntrack_raw
> 
> ======================================================================
> 
> The following changes since commit dece40e848f6e022f960dc9de54be518928460c3:
> 
>   netfilter: nf_conntrack: speed up module removal path if netns in use (2013-03-19 17:08:31 +0100)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
> 
> for you to fetch changes up to e8a0eb703e38870118928384ffd5eeeb47e7e1ef:
> 
>   ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new (2013-03-28 14:16:38 +0900)
> 
> ----------------------------------------------------------------
> Julian Anastasov (15):
>       net: add skb_dst_set_noref_force
>       ipvs: avoid routing by TOS for real server
>       ipvs: prefer NETDEV_DOWN event to free cached dsts
>       ipvs: convert the IP_VS_XMIT macros to functions
>       ipvs: rename functions related to dst_cache reset
>       ipvs: no need to reroute anymore on DNAT over loopback
>       ipvs: do not use skb_share_check
>       ipvs: consolidate all dst checks on transmit in one place
>       ipvs: optimize dst usage for real server
>       ipvs: convert app locks
>       ipvs: remove rs_lock by using RCU
>       ipvs: convert locks used in persistence engines
>       ipvs: convert connection locking
>       ipvs: reorder keys in connection structure
>       ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new
> 
>  include/linux/skbuff.h                |   35 +-
>  include/net/ip_vs.h                   |   71 ++-
>  net/core/dst.c                        |    9 +-
>  net/netfilter/ipvs/ip_vs_app.c        |   27 +-
>  net/netfilter/ipvs/ip_vs_conn.c       |  271 +++++----
>  net/netfilter/ipvs/ip_vs_core.c       |   16 +-
>  net/netfilter/ipvs/ip_vs_ctl.c        |  143 +++--
>  net/netfilter/ipvs/ip_vs_ftp.c        |    2 +
>  net/netfilter/ipvs/ip_vs_pe.c         |   43 +-
>  net/netfilter/ipvs/ip_vs_pe_sip.c     |    1 +
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |   18 +-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  |   18 +-
>  net/netfilter/ipvs/ip_vs_proto_udp.c  |   19 +-
>  net/netfilter/ipvs/ip_vs_xmit.c       | 1046 ++++++++++++++-------------------
>  14 files changed, 810 insertions(+), 909 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
