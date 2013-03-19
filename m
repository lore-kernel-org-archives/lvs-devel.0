From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS fixes for v3.9
Date: Tue, 19 Mar 2013 10:39:55 +0900
Message-ID: <1363657198-5333-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

The following changes since commit a82783c91d5dce680dbd290ebf301a520b0e72a5:

  netfilter: ip6t_NPT: restrict to mangle table (2013-03-15 12:58:21 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.9

for you to fetch changes up to 1804ac13ac3d9d39b94f3074f303b286e90632ba:

  ipvs: fix some sparse warnings (2013-03-19 09:37:37 +0900)

----------------------------------------------------------------
IPVS fixes for v3.9 from Julian Anastasov

----------------------------------------------------------------
Julian Anastasov (3):
      ipvs: fix sctp chunk length order
      ipvs: fix hashing in ip_vs_svc_hashkey
      ipvs: fix some sparse warnings

 include/net/ip_vs.h                   |    2 +-
 net/netfilter/ipvs/ip_vs_core.c       |    8 +-------
 net/netfilter/ipvs/ip_vs_ctl.c        |    8 +++++---
 net/netfilter/ipvs/ip_vs_est.c        |    2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   16 +++++++++-------
 5 files changed, 17 insertions(+), 19 deletions(-)
