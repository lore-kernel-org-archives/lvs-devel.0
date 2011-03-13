From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS
Date: Mon, 14 Mar 2011 07:44:17 +0900
Message-ID: <1300056261-14709-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
to get the following changes.

Jesper Juhl (1):
      Fix variable assignment in ip_vs_notrack

Julian Anastasov (2):
      ipvs: avoid lookup for fwmark 0
      ipvs: remove _bh from percpu stats reading

Shan Wei (1):
      netfilter:ipvs: use kmemdup

 include/net/ip_vs.h               |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c    |    8 +++++---
 net/netfilter/ipvs/ip_vs_est.c    |    8 ++++----
 net/netfilter/ipvs/ip_vs_pe_sip.c |    9 ++++-----
 net/netfilter/ipvs/ip_vs_sync.c   |    3 +--
 5 files changed, 15 insertions(+), 15 deletions(-)
