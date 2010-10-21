From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] ipvs + nf_net
Date: Thu, 21 Oct 2010 16:24:46 +0200
Message-ID: <20101021142446.GA19085@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>

Hi Patrick,

please consider pulling the following. The changes
are the 12 IPVS patch series that Julian recently posted
as well as his ICMP translation patch.

The following changes since commit d86bef73b4a24e59e7c1f896a72bbf38430ac2c6:

  Fixed race condition at ip_vs.ko module init. (2010-10-19 17:13:16 +0200)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick

Julian Anastasov (13):
      ipvs: fix CHECKSUM_PARTIAL for TCP, UDP
      ipvs: optimize checksums for apps
      ipvs: switch to notrack mode
      ipvs: do not schedule conns from real servers
      ipvs: stop ICMP from FORWARD to local
      ipvs: fix CHECKSUM_PARTIAL for TUN method
      ipvs: create ip_vs_defrag_user
      ipvs: move ip_route_me_harder for ICMP
      ipvs: changes for local real server
      ipvs: changes for local client
      ipvs: inherit forwarding method in backup
      ipvs: provide address family for debugging
      nf_nat: restrict ICMP translation for embedded header

 include/net/ip_vs.h                     |   53 +++-
 net/ipv4/netfilter/nf_nat_core.c        |   29 +-
 net/netfilter/ipvs/ip_vs_conn.c         |    2 +
 net/netfilter/ipvs/ip_vs_core.c         |  586 ++++++++++++++++++++++---------
 net/netfilter/ipvs/ip_vs_ctl.c          |   18 +-
 net/netfilter/ipvs/ip_vs_ftp.c          |    7 +-
 net/netfilter/ipvs/ip_vs_proto.c        |    8 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   52 +---
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |    8 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   52 ++-
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   51 ++-
 net/netfilter/ipvs/ip_vs_xmit.c         |  503 +++++++++++++++++++++------
 12 files changed, 959 insertions(+), 410 deletions(-)
