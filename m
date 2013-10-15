From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL] IPVS updates for v3.13
Date: Tue, 15 Oct 2013 11:01:44 +0900
Message-ID: <1381802507-7934-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider the following fixes for IPVS for v3.13.

This pull request is based on nf-next.


The following changes since commit 58308451e91974267e1f4a618346055342019e02:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next (2013-10-10 15:29:44 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.13

for you to fetch changes up to 1255ce5f10dbb4646c8d43b8d59faab48ae4a6b2:

  ipvs: improved SH fallback strategy (2013-10-15 10:54:50 +0900)

----------------------------------------------------------------
IPVS updates for v3.13

* Improvements to SH fallback strategy
* Avoid rcu_barrier during netns cleanup
* Fix the IPVS_CMD_ATTR_MAX definition

----------------------------------------------------------------
Alexander Frolkin (1):
      ipvs: improved SH fallback strategy

Julian Anastasov (2):
      ipvs: fix the IPVS_CMD_ATTR_MAX definition
      ipvs: avoid rcu_barrier during netns cleanup

 include/net/ip_vs.h              |  6 ++++++
 include/uapi/linux/ip_vs.h       |  2 +-
 net/netfilter/ipvs/ip_vs_ctl.c   |  6 +-----
 net/netfilter/ipvs/ip_vs_lblc.c  |  2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |  2 +-
 net/netfilter/ipvs/ip_vs_sh.c    | 39 +++++++++++++++++++++++++++++----------
 6 files changed, 39 insertions(+), 18 deletions(-)
