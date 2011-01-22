From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS updates for v2.6.38-rc1
Date: Sat, 22 Jan 2011 14:10:33 +1100
Message-ID: <1295665835-8708-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Changli Gao <xiaosuo@gmail.com>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Hi Patrick, please consider pulling
  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick

This includes bugfixes by Changli Gao and Hans Schillstrom.

Changli Gao (1):
      netfilter: ipvs: fix compiler warnings

Simon Horman (1):
      IPVS: Change sock_create_kernel() to __sock_create()

 net/netfilter/ipvs/ip_vs_ctl.c   |    4 ++++
 net/netfilter/ipvs/ip_vs_proto.c |    4 ++++
 net/netfilter/ipvs/ip_vs_sync.c  |    4 ++--
 3 files changed, 10 insertions(+), 2 deletions(-)

