From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next v2] IPVS for v3.11
Date: Sun, 26 May 2013 08:41:16 +0900
Message-ID: <1369525277-2687-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

The following changes since commit a38e5e230e3f4e7bc9195d3e7a81567c888257ca:

  ipvs: use cond_resched_rcu() helper when walking connections (2013-05-23 14:23:18 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.11

for you to fetch changes up to 079956742452494326081349a66942654498cafa:

  ipvs: change type of netns_ipvs->sysctl_sync_qlen_max (2013-05-26 08:17:33 +0900)

----------------------------------------------------------------
IPVS enhancement for v3.11

Tidy up type of sysctl_sync_qlen_max member of struct netns_ipvs

----------------------------------------------------------------
Zhang Yanfei (1):
      ipvs: change type of netns_ipvs->sysctl_sync_qlen_max

 include/net/ip_vs.h            |    8 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)
