From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS fixes for v3.10
Date: Wed, 17 Apr 2013 11:18:01 +0900
Message-ID: <1366165082-11156-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

The following changes since commit aaa795ad25e18488b026572c7ba2ca8f99ced0b7:

  netfilter: nat: propagate errors from xfrm_me_harder() (2013-04-08 12:34:01 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs3-for-v3.10

for you to fetch changes up to 4208bd136ff6d885982c9581e861577785bf3a98:

  ipvs: fix sparse warnings reported by kbuild test robot (2013-04-17 11:01:42 +0900)

----------------------------------------------------------------
Fix from Julian Anastasov for warnings flagged by sparse.
Some problems relate to changes introduced since v3.9. Others
have been around for longer.

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: fix sparse warnings reported by kbuild test robot

 include/net/ip_vs.h              |    8 +++---
 include/uapi/linux/ip_vs.h       |    4 +--
 net/netfilter/ipvs/ip_vs_conn.c  |   14 +++++-----
 net/netfilter/ipvs/ip_vs_core.c  |    3 ++-
 net/netfilter/ipvs/ip_vs_ctl.c   |   55 +++++++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c  |    4 +--
 8 files changed, 52 insertions(+), 40 deletions(-)
