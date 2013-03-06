From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 00/12] IPVS optimizations
Date: Wed,  6 Mar 2013 10:42:10 +0200
Message-ID: <1362559342-18784-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	This is a first patchset for IPVS optimizations.
Another patchset will address the locking in schedulers
and moving the global _bh disabling from LOCAL_OUT to all
locks. It is in TODO list.

	All patches are for net-next. The idea is
after discussion and review Simon to apply the patchset
to ipvs-next tree.

	The changes in this patchset eliminate locks
and dst refcnt operations from packet processing by
using RCU. There are more details in the patches.

Julian Anastasov (12):
  net: add dst_get_noref and refdst_ptr helpers
  ipvs: avoid routing by TOS for real server
  ipvs: prefer NETDEV_DOWN event to free cached dsts
  ipvs: convert the IP_VS_XMIT macros to functions
  ipvs: rename functions related to dst_cache reset
  ipvs: optimize dst usage for real server
  ipvs: convert app locks
  ipvs: remove rs_lock by using RCU
  ipvs: convert locks used in persistence engines
  ipvs: convert connection locking
  ipvs: reorder keys in connection structure
  ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new

 include/net/dst.h                     |   14 +-
 include/net/ip_vs.h                   |   56 +++--
 net/netfilter/ipvs/ip_vs_app.c        |   27 ++-
 net/netfilter/ipvs/ip_vs_conn.c       |  254 +++++++++-------
 net/netfilter/ipvs/ip_vs_core.c       |   16 +-
 net/netfilter/ipvs/ip_vs_ctl.c        |  128 ++++----
 net/netfilter/ipvs/ip_vs_ftp.c        |    2 +
 net/netfilter/ipvs/ip_vs_pe.c         |   43 +--
 net/netfilter/ipvs/ip_vs_pe_sip.c     |    1 +
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   18 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   18 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   19 +-
 net/netfilter/ipvs/ip_vs_xmit.c       |  532 ++++++++++++++++++++-------------
 13 files changed, 633 insertions(+), 495 deletions(-)

-- 
1.7.3.4
