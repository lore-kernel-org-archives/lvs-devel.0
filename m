From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL 0/5] IPVS fixes for v3.12
Date: Wed, 18 Sep 2013 14:45:37 -0500
Message-ID: <1379533542-9891-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider the following fixes for IPVS for v3.12.


The following changes since commit 61c5923a2f2d8ab98a1e3c76f17e0f4a871ec75b:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2013-09-17 20:22:53 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.12

for you to fetch changes up to d1ee4fea0b6946dd8bc61b46db35ea80af7af34b:

  ipvs: stats should not depend on CPU 0 (2013-09-18 14:40:20 -0500)

----------------------------------------------------------------
Fixes for IPVS for v3.12

* Fix overflow in LBLC and LBLCR schedulers.

  This resolves a regression introduced by commit b552f7e3a9524abcbcdf
  ("ipvs: unify the formula to estimate the overhead of processing
  connections").

  This problem was introduced in v2.6.38

* Correct stats calculation in the absence of CPU 0 in the possible mask

  This resolves a regression introduced by commit 17fc9963f837ef1
  ("IPVS: netns, ip_vs_stats and its procfs").

  This problem was introduced in v2.6.38

* Make the service replacement more robust

  This resolves a regression introduced by commit 578bc3ef1e473a
  ("ipvs: reorganize dest trash")

  This problem was introduced in 3.9

* Do not use dest after ip_vs_dest_put in LBLCR

  This resolves a regression introduced by commit c5549571f975ab
  ("ipvs: convert lblcr scheduler to rcu")

  This problem was introduced in 3.9

* Do not use dest after ip_vs_dest_put in LBLC

  This resolves a regression introduced by commit 2a4ffb70eef39
  ("ipvs: convert lblc scheduler to rcu")

  This problem was introduced in 3.9

----------------------------------------------------------------
Julian Anastasov (4):
      ipvs: make the service replacement more robust
      ipvs: do not use dest after ip_vs_dest_put in LBLC
      ipvs: do not use dest after ip_vs_dest_put in LBLCR
      ipvs: stats should not depend on CPU 0

Simon Kirby (1):
      ipvs: fix overflow on dest weight multiply

 include/net/ip_vs.h              |  9 ++---
 net/netfilter/ipvs/ip_vs_core.c  | 12 +++++-
 net/netfilter/ipvs/ip_vs_ctl.c   | 86 ++++++++++++++++------------------------
 net/netfilter/ipvs/ip_vs_est.c   |  4 +-
 net/netfilter/ipvs/ip_vs_lblc.c  | 72 +++++++++++++++------------------
 net/netfilter/ipvs/ip_vs_lblcr.c | 62 ++++++++++++-----------------
 net/netfilter/ipvs/ip_vs_nq.c    |  8 ++--
 net/netfilter/ipvs/ip_vs_sed.c   |  8 ++--
 net/netfilter/ipvs/ip_vs_wlc.c   |  6 +--
 9 files changed, 121 insertions(+), 146 deletions(-)
