From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL net] IPVS
Date: Tue, 11 Oct 2011 10:54:34 +0900
Message-ID: <1318298075-23501-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>

Hi Pablo, Hi Dave,

please consider the following change which is based on Dave's net tree.

The following changes since commit 3ee72ca99288f1de95ec9c570e43f531c8799f06:

  Merge git://github.com/davem330/net (2011-10-06 16:15:10 -0700)

are available in the git repository at:

  git@github.com:horms/ipvs.git master

Hans Schillstrom (1):
      IPVS netns shutdown/startup dead-lock

 include/net/ip_vs.h             |    1 +
 net/netfilter/ipvs/ip_vs_ctl.c  |  131 ++++++++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_sync.c |    6 ++
 3 files changed, 87 insertions(+), 51 deletions(-)
