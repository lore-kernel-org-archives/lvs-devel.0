From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 0/2] IPVS Updates for v3.17
Date: Wed, 16 Jul 2014 10:11:28 +0900
Message-ID: <1405473090-10432-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS Updates for v3.17.


The following changes since commit 24de3d377539e384621c5b8f8f8d8d01852dddc8:

  netfilter: use IS_ENABLED() macro (2014-06-30 11:38:03 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.17

for you to fetch changes up to 16ea4c6b9dde2ff44b2bd8bb459daa283cf3a46e:

  ipvs: Remove dead debug code (2014-07-16 10:07:11 +0900)

----------------------------------------------------------------
IPVS Updates for v3.17

Some clean-ups:
* Remove unnecessary NULL check before call to kfree
* Remove dead debug code

----------------------------------------------------------------
Fabian Frederick (1):
      ipvs: remove null test before kfree

Yannick Brosseau (1):
      ipvs: Remove dead debug code

 net/netfilter/ipvs/ip_vs_ctl.c  | 86 -----------------------------------------
 net/netfilter/ipvs/ip_vs_sync.c |  3 +-
 2 files changed, 1 insertion(+), 88 deletions(-)
