From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-2.6] IPVS
Date: Fri, 22 Jul 2011 09:18:39 +0900
Message-ID: <1311293920-1983-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, Dave Jones <davej@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Huajun Li <huajun.li.lee@gmail.com>

Hi Pablo, Hi Patrick,

please consider pulling

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git master

to get the following crash on module removal fix for IPVS.

Sorry for sending this so very, very late in the release cycle.
I had sent it earlier but it seems to have slipped through the cracks
somehow.

Simon Horman (1):
      IPVS: Free resources on module removal

 net/netfilter/ipvs/ip_vs_ctl.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

