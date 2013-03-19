From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS enhancements for v3.10
Date: Tue, 19 Mar 2013 10:41:11 +0900
Message-ID: <1363657273-5835-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
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

for you to fetch changes up to 95d7929db57c04833ace016fe6889d11f9c24dce:

  ipvs: remove extra rcu lock (2013-03-19 09:41:05 +0900)

----------------------------------------------------------------
IPVS enhancements for v3.10 from Julian Anastasov

----------------------------------------------------------------
Julian Anastasov (2):
      ipvs: add backup_only flag to avoid loops
      ipvs: remove extra rcu lock

 Documentation/networking/ipvs-sysctl.txt |    7 +++++++
 include/net/ip_vs.h                      |   12 ++++++++++++
 net/netfilter/ipvs/ip_vs_core.c          |   14 ++++++++------
 net/netfilter/ipvs/ip_vs_ctl.c           |    7 +++++++
 4 files changed, 34 insertions(+), 6 deletions(-)
