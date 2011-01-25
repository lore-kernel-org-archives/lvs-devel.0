From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS changes for 2.6.38-rc3
Date: Tue, 25 Jan 2011 23:17:04 +1000
Message-ID: <1295961426-7402-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Changli Gao <xiaosuo@gmail.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Hi Patrick,

please consider pulling
  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick

Which includes the following changes, both of which I believe 2.6.38 material.

Changli Gao (1):
      netfilter: ipvs: fix compiler warnings

Hans Schillstrom (1):
      IPVS netns BUG, register sysctl for root ns

 net/netfilter/ipvs/ip_vs_core.c |    4 +---
 net/netfilter/ipvs/ip_vs_ctl.c  |    2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

