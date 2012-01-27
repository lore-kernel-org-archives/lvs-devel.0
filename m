From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS
Date: Fri, 27 Jan 2012 10:45:26 +0900
Message-ID: <1327628727-22482-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master
to get the following fix from Julian.

The bug in question has been present since 2.6.37 and accordingly I would
like the fix considered for both 3.3 and stable. I have confirmed that it
applies and builds against your net tree, 3.2.2, 3.1.10, 3.0.18 and 2.6.39.4.

Julian Anastasov (1):
      ipvs: fix matching of fwmark templates during scheduling

 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
