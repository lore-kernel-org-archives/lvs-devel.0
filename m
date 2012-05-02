From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL net-next v2] IPVS
Date: Wed,  2 May 2012 15:22:24 +0900
Message-ID: <1335939762-1912-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hi Pablo,

please consider the following 18 changes for 3.5.

This replaces a 17 patch pull request that I sent earlier today by adding a
patch from Hans patch to the head of the request.  You should be able to
just pull again if you have already pulled the original series and not
applied anything else on top.

Please note that there will be a conflict with the following when merged
with net-next due to the following change which is already present in
David's tree. It should be a trivial merge but please let me know if you
want to handle this another way.

	4a17fd5 sock: Introduce named constants for sk_reuse

The following changes since commit c3dc836d807a9b9855eefe535fdcbcf7cbb7a574:

  netfilter: bridge: optionally set indev to vlan (2012-04-24 01:22:44 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

for you to fetch changes up to 3de4b8ca4ffa3dafaeef985fabe152a1717a8ea0:

  export sysctl symbols needed by ip_vs_sync (2012-05-02 14:48:55 +0900)

----------------------------------------------------------------
H Hartley Sweeten (2):
      IPVS: ip_vs_ftp.c: local functions should not be exposed globally
      IPVS: ip_vs_proto.c: local functions should not be exposed globally

Hans Schillstrom (1):
      export sysctl symbols needed by ip_vs_sync

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
 net/core/sock.c                  |    2 +
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
 14 files changed, 669 insertions(+), 274 deletions(-)
