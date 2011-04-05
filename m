From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS
Date: Tue,  5 Apr 2011 12:22:11 +0900
Message-ID: <1301973732-8989-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next-2.6.git master
to get the following minor change from myself. This pull request is
based on nf-next-2.6.

Simon Horman (1):
      IPVS: combine consecutive #ifdef CONFIG_PROC_FS blocks

 net/netfilter/ipvs/ip_vs_ctl.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

