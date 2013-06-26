From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL 0/8] IPVS updates for v3.11 #2
Date: Wed, 26 Jun 2013 18:11:22 +0900
Message-ID: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider the following changes for IPVS for v3.11.

The following changes since commit 681f130f39e10087475383e6771b9366e26bab0c:

  netfilter: xt_socket: add XT_SOCKET_NOWILDCARD flag (2013-06-20 20:28:49 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.11

for you to fetch changes up to 8b4d14d8eb36874daf159d33dcccd4746a6f3189:

  netns: exclude ipvs from struct net when IPVS disabled (2013-06-26 18:01:46 +0900)

----------------------------------------------------------------
IPVS updates for v3.11

* Exclude IPVS from struct net when IPVS disabled
* Remove unnecessary head file
* Add sync_persist_mode flag to reduce sync traffic in the presence
  of persistence
* SH scheduler fallback and L4 hashing
* SCTP cleanup so that its implementation more closely resembles
  that of other protocols supported by IPVS
* Add sloppy TCP and SCTP modes to allow connections to
  fail from one IPVS director to another regardless of their state

----------------------------------------------------------------
Alexander Frolkin (2):
      ipvs: sloppy TCP and SCTP
      ipvs: SH fallback and L4 hashing

Julian Anastasov (4):
      ipvs: provide iph to schedulers
      ipvs: replace the SCTP state machine
      ipvs: drop SCTP connections depending on state
      ipvs: add sync_persist_mode flag

JunweiZhang (2):
      kernel: remove unnecessary head file
      netns: exclude ipvs from struct net when IPVS disabled

 Documentation/networking/ipvs-sysctl.txt |  13 +
 include/net/ip_vs.h                      |  84 +--
 include/net/net_namespace.h              |   2 +
 include/uapi/linux/ip_vs.h               |   6 +
 kernel/sysctl_binary.c                   |   1 -
 net/netfilter/ipvs/ip_vs_conn.c          |  12 +
 net/netfilter/ipvs/ip_vs_core.c          |   4 +-
 net/netfilter/ipvs/ip_vs_ctl.c           |  21 +
 net/netfilter/ipvs/ip_vs_dh.c            |  10 +-
 net/netfilter/ipvs/ip_vs_lblc.c          |  12 +-
 net/netfilter/ipvs/ip_vs_lblcr.c         |  12 +-
 net/netfilter/ipvs/ip_vs_lc.c            |   3 +-
 net/netfilter/ipvs/ip_vs_nq.c            |   3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c    | 860 ++++++-------------------------
 net/netfilter/ipvs/ip_vs_proto_tcp.c     |  14 +-
 net/netfilter/ipvs/ip_vs_rr.c            |   3 +-
 net/netfilter/ipvs/ip_vs_sed.c           |   3 +-
 net/netfilter/ipvs/ip_vs_sh.c            | 108 +++-
 net/netfilter/ipvs/ip_vs_sync.c          |  19 +-
 net/netfilter/ipvs/ip_vs_wlc.c           |   3 +-
 net/netfilter/ipvs/ip_vs_wrr.c           |   3 +-
 21 files changed, 399 insertions(+), 797 deletions(-)
