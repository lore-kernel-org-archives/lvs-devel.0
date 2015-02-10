From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS Enhancements for v3.20
Date: Tue, 10 Feb 2015 15:32:08 +0900
Message-ID: <1423549929-25064-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this enhancement for v3.20.

It adds support for 64-bit rates in IPVS statistics.


The following changes since commit 4c1017aa80c95a74703139bb95c4ce0d130efe4d:

  netfilter: nft_lookup: add missing attribute validation for NFTA_LOOKUP_SET_ID (2015-01-30 19:08:20 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.20

for you to fetch changes up to cd67cd5eb25ae9a7bafbfd3d52d4c05e1d80af3b:

  ipvs: use 64-bit rates in stats (2015-02-09 16:59:03 +0900)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: use 64-bit rates in stats

 include/net/ip_vs.h             |  50 ++++++++----
 include/uapi/linux/ip_vs.h      |   7 +-
 net/netfilter/ipvs/ip_vs_core.c |  36 +++++----
 net/netfilter/ipvs/ip_vs_ctl.c  | 174 ++++++++++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_est.c  | 102 ++++++++++++-----------
 5 files changed, 226 insertions(+), 143 deletions(-)
