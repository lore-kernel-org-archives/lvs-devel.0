From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL next-net] IPVS
Date: Wed,  2 May 2012 10:24:44 +0900
Message-ID: <1335921901-21284-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hi Pablo,

please consider the following 5 changes for 3.4, they are all bug fixes.
I would also like these changes considered for stable.

Please note that there will be a conflict with the following when merged with
net-next:

	4a17fd5 sock: Introduce named constants for sk_reuse


The following changes since commit c3dc836d807a9b9855eefe535fdcbcf7cbb7a574:

  netfilter: bridge: optionally set indev to vlan (2012-04-24 01:22:44 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

for you to fetch changes up to f0cb1dbac57864ed702da8ada6a00155fff0a13b:

  IPVS: ip_vs_proto.c: local functions should not be exposed globally (2012-05-02 10:12:37 +0900)

----------------------------------------------------------------
H Hartley Sweeten (2):
      IPVS: ip_vs_ftp.c: local functions should not be exposed globally
      IPVS: ip_vs_proto.c: local functions should not be exposed globally

Julian Anastasov (14):
      ipvs: timeout tables do not need GFP_ATOMIC allocation
      ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init
      ipvs: DH scheduler does not need GFP_ATOMIC allocation
      ipvs: WRR scheduler does not need GFP_ATOMIC allocation
      ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init
      ipvs: SH scheduler does not need GFP_ATOMIC allocation
      ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
      ipvs: remove check for IP_VS_CONN_F_SYNC from ip_vs_bind_dest
      ipvs: fix ip_vs_try_bind_dest to rebind app and transmitter
      ipvs: always update some of the flags bits in backup
      ipvs: wakeup master thread
      ipvs: reduce sync rate with time thresholds
      ipvs: add support for sync threads
      ipvs: optimize the use of flags in ip_vs_bind_dest

Sasha Levin (1):
      netfilter: ipvs: use GFP_KERNEL allocation where possible

 include/linux/ip_vs.h            |    5 +
 include/net/ip_vs.h              |   87 ++++-
 net/netfilter/ipvs/ip_vs_conn.c  |   69 ++--
 net/netfilter/ipvs/ip_vs_core.c  |   30 +-
 net/netfilter/ipvs/ip_vs_ctl.c   |   70 +++-
 net/netfilter/ipvs/ip_vs_dh.c    |    2 +-
 net/netfilter/ipvs/ip_vs_ftp.c   |    2 +-
 net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 net/netfilter/ipvs/ip_vs_proto.c |    6 +-
 net/netfilter/ipvs/ip_vs_sh.c    |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c  |  662 ++++++++++++++++++++++++++------------
 net/netfilter/ipvs/ip_vs_wrr.c   |    2 +-
 13 files changed, 667 insertions(+), 274 deletions(-)
