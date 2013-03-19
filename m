From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS changes for v3.10
Date: Tue, 19 Mar 2013 21:43:46 +0900
Message-ID: <1363697028-15314-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

The following changes since commit 1cdb09056b27b2a06b06dc7187d2c33d57082d20:

  netfilter: nfnetlink_queue: use xor hash function to distribute instances (2013-03-15 12:38:40 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.10

for you to fetch changes up to b962abdc6531c8de837504ebc98139587162f223:

  ipvs: fix some sparse warnings (2013-03-19 21:18:38 +0900)

----------------------------------------------------------------
IPVS changes for v3.10 from Julian Anastasov

----------------------------------------------------------------
Julian Anastasov (2):
      ipvs: fix hashing in ip_vs_svc_hashkey
      ipvs: fix some sparse warnings

 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |    8 +-------
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 +++++---
 net/netfilter/ipvs/ip_vs_est.c  |    2 +-
 4 files changed, 8 insertions(+), 12 deletions(-)
