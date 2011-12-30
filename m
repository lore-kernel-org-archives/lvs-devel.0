From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL net-next] IPVS
Date: Fri, 30 Dec 2011 14:19:01 +0900
Message-ID: <1325222342-20240-1-git-send-email-horms@verge.net.au>
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
  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next master

To get the following fix from Julian

Julian Anastasov (1):
      ipvs: try also real server with port 0 in backup server

 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  |   10 ++++++++--
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 4 files changed, 11 insertions(+), 5 deletions(-)
