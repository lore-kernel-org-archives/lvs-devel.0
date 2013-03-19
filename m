From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf v2] IPVS fixes for v3.9
Date: Tue, 19 Mar 2013 21:40:47 +0900
Message-ID: <1363696850-14766-1-git-send-email-horms@verge.net.au>
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

for you to fetch changes up to bf93ad72cd8cfabe66a7b3d66236a1266d357189:

  ipvs: remove extra rcu lock (2013-03-19 21:21:52 +0900)

----------------------------------------------------------------
IPVS fixes for v3.9 from Julian Anastasov

----------------------------------------------------------------
Julian Anastasov (3):
      ipvs: fix sctp chunk length order
      ipvs: add backup_only flag to avoid loops
      ipvs: remove extra rcu lock

 Documentation/networking/ipvs-sysctl.txt |    7 +++++++
 include/net/ip_vs.h                      |   12 ++++++++++++
 net/netfilter/ipvs/ip_vs_core.c          |   14 ++++++++------
 net/netfilter/ipvs/ip_vs_ctl.c           |    7 +++++++
 net/netfilter/ipvs/ip_vs_proto_sctp.c    |   16 +++++++++-------
 5 files changed, 43 insertions(+), 13 deletions(-)
