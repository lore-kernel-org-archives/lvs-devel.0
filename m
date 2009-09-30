From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] net/netfilter: Makefile and pr_<level>
Date: Wed, 30 Sep 2009 15:37:15 -0700
Message-ID: <cover.1254349374.git.joe@perches.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

Standardize mechanism to #define KMSG_COMPONENT by
moving it to Makefile and cleanup and standardize
printks.  Corrected a few error message typos along
the way.

Joe Perches (2):
  net/netfilter/ipvs: Move #define KMSG_COMPONENT to Makefile
  net/netfilter: use pr_<level> consistently

 net/netfilter/Makefile                  |    2 +
 net/netfilter/ipvs/Makefile             |    3 +
 net/netfilter/ipvs/ip_vs_app.c          |    3 -
 net/netfilter/ipvs/ip_vs_conn.c         |    3 -
 net/netfilter/ipvs/ip_vs_core.c         |    3 -
 net/netfilter/ipvs/ip_vs_ctl.c          |    3 -
 net/netfilter/ipvs/ip_vs_dh.c           |    3 -
 net/netfilter/ipvs/ip_vs_est.c          |    3 -
 net/netfilter/ipvs/ip_vs_ftp.c          |    3 -
 net/netfilter/ipvs/ip_vs_lblc.c         |    3 -
 net/netfilter/ipvs/ip_vs_lblcr.c        |    3 -
 net/netfilter/ipvs/ip_vs_lc.c           |    3 -
 net/netfilter/ipvs/ip_vs_nq.c           |    3 -
 net/netfilter/ipvs/ip_vs_proto.c        |    3 -
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    3 -
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |    3 -
 net/netfilter/ipvs/ip_vs_proto_udp.c    |    3 -
 net/netfilter/ipvs/ip_vs_rr.c           |    3 -
 net/netfilter/ipvs/ip_vs_sched.c        |    3 -
 net/netfilter/ipvs/ip_vs_sed.c          |    3 -
 net/netfilter/ipvs/ip_vs_sh.c           |    3 -
 net/netfilter/ipvs/ip_vs_sync.c         |    3 -
 net/netfilter/ipvs/ip_vs_wlc.c          |    3 -
 net/netfilter/ipvs/ip_vs_wrr.c          |    3 -
 net/netfilter/ipvs/ip_vs_xmit.c         |    3 -
 net/netfilter/nf_conntrack_acct.c       |   12 ++--
 net/netfilter/nf_conntrack_amanda.c     |    2 +-
 net/netfilter/nf_conntrack_core.c       |   35 ++++-----
 net/netfilter/nf_conntrack_ecache.c     |    5 +-
 net/netfilter/nf_conntrack_expect.c     |    3 +-
 net/netfilter/nf_conntrack_ftp.c        |   31 ++++-----
 net/netfilter/nf_conntrack_h323_main.c  |  114 +++++++++++++++---------------
 net/netfilter/nf_conntrack_irc.c        |   10 +--
 net/netfilter/nf_conntrack_netlink.c    |   12 ++--
 net/netfilter/nf_conntrack_proto_gre.c  |    4 +-
 net/netfilter/nf_conntrack_proto_sctp.c |    9 +--
 net/netfilter/nf_conntrack_proto_tcp.c  |    4 +-
 net/netfilter/nf_conntrack_sane.c       |   17 ++---
 net/netfilter/nf_conntrack_sip.c        |    5 +-
 net/netfilter/nf_conntrack_standalone.c |    2 +-
 net/netfilter/nf_conntrack_tftp.c       |    3 +-
 net/netfilter/nfnetlink.c               |    6 +-
 net/netfilter/nfnetlink_log.c           |   20 +++---
 net/netfilter/nfnetlink_queue.c         |   15 ++--
 net/netfilter/xt_CONNMARK.c             |    2 +-
 net/netfilter/xt_CONNSECMARK.c          |    8 +--
 net/netfilter/xt_DSCP.c                 |    2 +-
 net/netfilter/xt_HL.c                   |    6 +-
 net/netfilter/xt_LED.c                  |   10 +--
 net/netfilter/xt_NFQUEUE.c              |    4 +-
 net/netfilter/xt_SECMARK.c              |   14 ++--
 net/netfilter/xt_TCPMSS.c               |   18 +++---
 net/netfilter/xt_TPROXY.c               |    3 +-
 net/netfilter/xt_cluster.c              |    8 +--
 net/netfilter/xt_connbytes.c            |    2 +-
 net/netfilter/xt_connlimit.c            |    2 +-
 net/netfilter/xt_connmark.c             |    2 +-
 net/netfilter/xt_conntrack.c            |    2 +-
 net/netfilter/xt_dscp.c                 |    2 +-
 net/netfilter/xt_hashlimit.c            |   24 +++----
 net/netfilter/xt_helper.c               |    2 +-
 net/netfilter/xt_hl.c                   |    4 +-
 net/netfilter/xt_limit.c                |    4 +-
 net/netfilter/xt_osf.c                  |    4 +-
 net/netfilter/xt_physdev.c              |    2 +-
 net/netfilter/xt_policy.c               |   11 +--
 net/netfilter/xt_recent.c               |    9 +--
 net/netfilter/xt_state.c                |    2 +-
 net/netfilter/xt_statistic.c            |    2 +-
 net/netfilter/xt_time.c                 |   14 ++--
 70 files changed, 224 insertions(+), 322 deletions(-)

