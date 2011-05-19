From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-2.6] IPVS
Date: Thu, 19 May 2011 21:32:56 +0900
Message-ID: <1305808377-12255-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Dave Jones <davej@redhat.com>, Pablo Neira Ayuso <pablo@netfilter.org>

Hi Pablo, Hi Patrick,

please consider pulling

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git master

to get the following fix for IPVS.

I have based my tree on net-2.6 as it contains all of the IPVS patches -
currently some are in Patrick's tree and one of them is in Pablo's tree but
all of them are in Dave's tree.

Please feel free to apply the patch manually if that suits you better.

Simon Horman (1):
      IPVS: Free resources on module removal

 net/netfilter/ipvs/ip_vs_ctl.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)
