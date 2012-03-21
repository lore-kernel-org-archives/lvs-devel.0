From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS
Date: Wed, 21 Mar 2012 17:56:15 +0900
Message-ID: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master
to get the following enhancements to IPVS connection synchronisation
from Julian and a minor clean-up from myself.

The following changes since commit ace30d73ef09fd5f95b24c5c1c5aa11963981494:

  netfilter: xt_LOG: add __printf() to sb_add() (2012-03-07 17:41:52 +0100)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

Julian Anastasov (8):
      ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
      ipvs: remove check for IP_VS_CONN_F_SYNC from ip_vs_bind_dest
      ipvs: fix ip_vs_try_bind_dest to rebind app and transmitter
      ipvs: always update some of the flags bits in backup
      ipvs: use adaptive pause in master thread
      ipvs: reduce sync rate with time thresholds
      ipvs: add support for sync threads
      ipvs: optimize the use of flags in ip_vs_bind_dest

Simon Horman (1):
      ipvs: Provide a generic ip_vs_bind_xmit()

 include/linux/ip_vs.h           |    5 +
 include/net/ip_vs.h             |   59 ++++-
 net/netfilter/ipvs/ip_vs_conn.c |   83 ++++--
 net/netfilter/ipvs/ip_vs_core.c |   30 +--
 net/netfilter/ipvs/ip_vs_ctl.c  |   54 ++++-
 net/netfilter/ipvs/ip_vs_sync.c |  585 +++++++++++++++++++++++++--------------
 6 files changed, 547 insertions(+), 269 deletions(-)
