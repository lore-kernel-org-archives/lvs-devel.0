From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL v2 00/15] Second Round of IPVS Updates for v3.18
Date: Thu, 18 Sep 2014 09:25:46 +0900
Message-ID: <1410999961-7975-1-git-send-email-horms@verge.net.au>
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

I hope that v2 of this pull request addresses the issues you raised
in v1. In particular "ipvs: use correct address family in scheduler logs"
patch consolidates what was previously 7 patches. And I have provided
a longer description: I hope the tone is closer to what you need.

This pull requests makes the following changes:

* Add simple weighted fail-over scheduler.
  - Unlike other IPVS schedulers this offers fail-over rather than load
    balancing. Connections are directed to the appropriate server based
    solely on highest weight value and server availability.
  - Thanks to Kenny Mathis

* Support IPv6 real servers in IPv4 virtual-services and vice versa
  - This feature is supported in conjunction with the tunnel (IPIP)
    forwarding mechanism. That is, IPv4 may be forwarded in IPv6 and
    vice versa.
  - The motivation for this is to allow more flexibility in the
    choice of IP version offered by both virtual-servers and
    real-servers as they no longer need to match: An IPv4 connection from an
    end-user may be forwarded to a real-server using IPv6 and vice versa.
  - Further work need to be done to support this feature in conjunction
    with connection synchronisation. For now such configurations are
    not allowed.
  - This change includes update to netlink protocol, adding a new
    destination address family attribute. And the necessary changes
    to plumb this information throughout IPVS.
  - Thanks to Alex Gartrell and Julian Anastasov

The following changes since commit 0bbe80e571c7b866afd92a98edd32a969467a7a9:

  netfilter: masquerading needs to be independent of x_tables in Kconfig (2014-09-12 09:40:18 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.18

for you to fetch changes up to bc18d37f676f76edbb5e0c37def78c704b5fbed0:

  ipvs: Allow heterogeneous pools now that we support them (2014-09-18 08:59:29 +0900)

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

Julian Anastasov (4):
      ipvs: address family of LBLC entry depends on svc family
      ipvs: address family of LBLCR entry depends on svc family
      ipvs: use correct address family in scheduler logs
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
 net/netfilter/ipvs/ip_vs_wrr.c        |   2 +-
 net/netfilter/ipvs/ip_vs_xmit.c       | 388 +++++++++++++++++++++-------------
 23 files changed, 544 insertions(+), 225 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_fo.c
