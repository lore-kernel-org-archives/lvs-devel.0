From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net-next 00/15] IPVS optimizations
Date: Thu, 21 Mar 2013 11:57:57 +0200
Message-ID: <1363859892-9058-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	This is a first patchset for IPVS optimizations.
Another patchset will address the locking in schedulers
and moving the global _bh disabling from LOCAL_OUT to all
locks.

	All patches are for net-next and Simon can
take them for ipvs-next.

	The changes in this patchset eliminate locks
and dst refcnt operations from packet processing by
using RCU. There are more details in the patches.

v3:
* in "ipvs: consolidate all dst checks on transmit in one place"
  preserve original skb dst even for local client, remove the
  rt_is_input_route and skb->dev check. Call update_pmtu only for
  local client by providing sk instead of skb.
* in "ipvs: optimize dst usage for real server" use
  rcu_dereference_protected for __ip_vs_dst_cache_reset instead of
  rcu_dereference_raw. Use the new skb_dst_set_noref_force func.
* in "ipvs: remove rs_lock by using RCU" prefer the port check in
  ip_vs_has_real_service
* "ipvs: convert locks used in persistence engines" needs only
  synchronize_rcu, not rcu_barrier, we do not use rcu callbacks

v2:
* use "net: add skb_dst_set_unref" instead of
  "net: add dst_get_noref and refdst_ptr helpers"
* add "ipvs: no need to reroute anymore on DNAT over loopback"
* add "ipvs: do not use skb_share_check"
* add "ipvs: consolidate all dst checks on transmit in one place", so
  that we can avoid the refdst games in next patch
* after "ipvs: consolidate all dst checks on transmit in one place"
  "ipvs: optimize dst usage for real server" is simpler and
  uses the new skb_dst_set_unref function
* extend "ipvs: reorder keys in connection structure" with
  changes in ip_vs_ct_in_get
* fix "ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new" to use new
  function ip_vs_addr_set, so that we reset all address fields
  that are used for hashing by hash_conntrack_raw

Julian Anastasov (15):
  net: add skb_dst_set_noref_force
  ipvs: avoid routing by TOS for real server
  ipvs: prefer NETDEV_DOWN event to free cached dsts
  ipvs: convert the IP_VS_XMIT macros to functions
  ipvs: rename functions related to dst_cache reset
  ipvs: no need to reroute anymore on DNAT over loopback
  ipvs: do not use skb_share_check
  ipvs: consolidate all dst checks on transmit in one place
  ipvs: optimize dst usage for real server
  ipvs: convert app locks
  ipvs: remove rs_lock by using RCU
  ipvs: convert locks used in persistence engines
  ipvs: convert connection locking
  ipvs: reorder keys in connection structure
  ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new

 include/linux/skbuff.h                |   35 ++-
 include/net/ip_vs.h                   |   71 ++-
 net/core/dst.c                        |    9 +-
 net/netfilter/ipvs/ip_vs_app.c        |   27 +-
 net/netfilter/ipvs/ip_vs_conn.c       |  271 +++++----
 net/netfilter/ipvs/ip_vs_core.c       |   16 +-
 net/netfilter/ipvs/ip_vs_ctl.c        |  143 +++---
 net/netfilter/ipvs/ip_vs_ftp.c        |    2 +
 net/netfilter/ipvs/ip_vs_pe.c         |   43 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c     |    1 +
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   18 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   18 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   19 +-
 net/netfilter/ipvs/ip_vs_xmit.c       | 1046 ++++++++++++++-------------------
 14 files changed, 810 insertions(+), 909 deletions(-)

-- 
1.7.3.4

