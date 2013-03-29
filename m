From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS optimisations for v3.10
Date: Fri, 29 Mar 2013 13:11:17 +0900
Message-ID: <1364530311-11512-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

The following changes since commit e5c5d22e8dcf7c2d430336cbf8e180bd38e8daf1:

  net: add ETH_P_802_3_MIN (2013-03-28 01:20:42 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.10

for you to fetch changes up to e0566a7cef2f1afca4aa98244224fb9ca6ded08e:

  ipvs: do not disable bh for long time (2013-03-29 12:59:02 +0900)

----------------------------------------------------------------
IPVS optimisations for v3.10 by Julian Anastasov

----------------------------------------------------------------
Julian Anastasov (34):
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
      ipvs: change ip_vs_sched_lock to mutex
      ipvs: preparations for using rcu in schedulers
      ipvs: add ip_vs_dest_hold and ip_vs_dest_put
      ipvs: convert dh scheduler to rcu
      ipvs: convert lblc scheduler to rcu
      ipvs: convert lblcr scheduler to rcu
      ipvs: convert lc scheduler to rcu
      ipvs: convert nq scheduler to rcu
      ipvs: convert rr scheduler to rcu
      ipvs: convert sed scheduler to rcu
      ipvs: convert sh scheduler to rcu
      ipvs: convert wlc scheduler to rcu
      ipvs: convert wrr scheduler to rcu
      ipvs: reorganize dest trash
      ipvs: do not expect result from done_service
      ipvs: convert sched_lock to spin lock
      ipvs: convert dests to rcu
      ipvs: convert services to rcu
      ipvs: do not disable bh for long time

 include/linux/skbuff.h                |   35 +-
 include/net/ip_vs.h                   |  130 ++--
 net/core/dst.c                        |    9 +-
 net/netfilter/ipvs/ip_vs_app.c        |   31 +-
 net/netfilter/ipvs/ip_vs_conn.c       |  306 +++++-----
 net/netfilter/ipvs/ip_vs_core.c       |   73 +--
 net/netfilter/ipvs/ip_vs_ctl.c        |  641 ++++++++++----------
 net/netfilter/ipvs/ip_vs_dh.c         |   86 +--
 net/netfilter/ipvs/ip_vs_ftp.c        |    4 +
 net/netfilter/ipvs/ip_vs_lblc.c       |  115 ++--
 net/netfilter/ipvs/ip_vs_lblcr.c      |  190 +++---
 net/netfilter/ipvs/ip_vs_lc.c         |    3 +-
 net/netfilter/ipvs/ip_vs_nq.c         |    3 +-
 net/netfilter/ipvs/ip_vs_pe.c         |   55 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c     |    1 +
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   36 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   40 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   33 +-
 net/netfilter/ipvs/ip_vs_rr.c         |   64 +-
 net/netfilter/ipvs/ip_vs_sched.c      |   63 +-
 net/netfilter/ipvs/ip_vs_sed.c        |    5 +-
 net/netfilter/ipvs/ip_vs_sh.c         |   86 +--
 net/netfilter/ipvs/ip_vs_sync.c       |   35 +-
 net/netfilter/ipvs/ip_vs_wlc.c        |    5 +-
 net/netfilter/ipvs/ip_vs_wrr.c        |  176 +++---
 net/netfilter/ipvs/ip_vs_xmit.c       | 1050 ++++++++++++++-------------------
 26 files changed, 1611 insertions(+), 1664 deletions(-)
