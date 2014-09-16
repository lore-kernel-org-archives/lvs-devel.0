From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 00/21] Second Round of IPVS Updates for v3.18
Date: Tue, 16 Sep 2014 09:34:14 +0900
Message-ID: <1410827675-3637-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS updates for v3.18.

* Add simple weighted failover scheduler
  - Thanks to Kenny Mathis
* Support v6 real servers in v4 pools and vice versa
  - Thanks to Alex Gartrell and Julian Anastasov


The following changes since commit 0bbe80e571c7b866afd92a98edd32a969467a7a9:

  netfilter: masquerading needs to be independent of x_tables in Kconfig (2014-09-12 09:40:18 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.18

for you to fetch changes up to 87f2b83b77d6139a888af87352ff35894e5c5d69:

  ipvs: Allow heterogeneous pools now that we support them (2014-09-16 09:03:43 +0900)

----------------------------------------------------------------
Alex Gartrell (10):
      ipvs: Add destination address family to netlink interface
      ipvs: Supply destination addr family to ip_vs_{lookup_dest,find_dest}
      ipvs: Pass destination address family to ip_vs_trash_get_dest
      ipvs: Supply destination address family to ip_vs_conn_new
      ipvs: prevent mixing heterogeneous pools and synchronization
      ipvs: Pull out crosses_local_route_boundary logic
      ipvs: Pull out update_pmtu code
      ipvs: Add generic ensure_mtu_is_adequate to handle mixed pools
      ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding
      ipvs: Allow heterogeneous pools now that we support them

Julian Anastasov (10):
      ipvs: address family of LBLC entry depends on svc family
      ipvs: address family of LBLCR entry depends on svc family
      ipvs: use correct address family in DH logs
      ipvs: use correct address family in LC logs
      ipvs: use correct address family in NQ logs
      ipvs: use correct address family in RR logs
      ipvs: use correct address family in SED logs
      ipvs: use correct address family in SH logs
      ipvs: use correct address family in WLC logs
      ipvs: use the new dest addr family field

Kenny Mathis (1):
      ipvs: Add simple weighted failover scheduler

 include/net/ip_vs.h                   |  15 +-
 include/uapi/linux/ip_vs.h            |   3 +
 net/netfilter/ipvs/Kconfig            |  10 +
 net/netfilter/ipvs/Makefile           |   1 +
 net/netfilter/ipvs/ip_vs_conn.c       |  74 +++++--
 net/netfilter/ipvs/ip_vs_core.c       |  15 +-
 net/netfilter/ipvs/ip_vs_ctl.c        | 112 +++++++---
 net/netfilter/ipvs/ip_vs_dh.c         |   2 +-
 net/netfilter/ipvs/ip_vs_fo.c         |  79 +++++++
 net/netfilter/ipvs/ip_vs_ftp.c        |   6 +-
 net/netfilter/ipvs/ip_vs_lblc.c       |  12 +-
 net/netfilter/ipvs/ip_vs_lblcr.c      |  12 +-
 net/netfilter/ipvs/ip_vs_lc.c         |   2 +-
 net/netfilter/ipvs/ip_vs_nq.c         |   3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   2 +-
 net/netfilter/ipvs/ip_vs_rr.c         |   2 +-
 net/netfilter/ipvs/ip_vs_sed.c        |   3 +-
 net/netfilter/ipvs/ip_vs_sh.c         |   8 +-
 net/netfilter/ipvs/ip_vs_sync.c       |  13 +-
 net/netfilter/ipvs/ip_vs_wlc.c        |   3 +-
 net/netfilter/ipvs/ip_vs_xmit.c       | 388 +++++++++++++++++++++-------------
 22 files changed, 543 insertions(+), 224 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_fo.c
