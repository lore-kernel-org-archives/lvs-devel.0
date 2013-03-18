From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS
Date: Mon, 18 Mar 2013 22:15:38 +0900
Message-ID: <1363612543-9787-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

please consider the following IPVS enhancements from Julian for 3.10.

----------------------------------------------------------------
The following changes since commit 1cdb09056b27b2a06b06dc7187d2c33d57082d20:

  netfilter: nfnetlink_queue: use xor hash function to distribute instances (2013-03-15 12:38:40 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.10

for you to fetch changes up to e095c65caffc923a0d1fb27763c3f9ec1dcb57fc:

  ipvs: fix some sparse warnings (2013-03-18 19:25:14 +0900)

----------------------------------------------------------------
IPVS enhancements for v3.10 from Julian Anastasov

----------------------------------------------------------------
Julian Anastasov (5):
      ipvs: add backup_only flag to avoid loops
      ipvs: remove extra rcu lock
      ipvs: fix sctp chunk length order
      ipvs: fix hashing in ip_vs_svc_hashkey
      ipvs: fix some sparse warnings

 Documentation/networking/ipvs-sysctl.txt |    7 +++++++
 include/net/ip_vs.h                      |   14 +++++++++++++-
 net/netfilter/ipvs/ip_vs_core.c          |   22 +++++++++-------------
 net/netfilter/ipvs/ip_vs_ctl.c           |   15 ++++++++++++---
 net/netfilter/ipvs/ip_vs_est.c           |    2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c    |   16 +++++++++-------
 6 files changed, 51 insertions(+), 25 deletions(-)
