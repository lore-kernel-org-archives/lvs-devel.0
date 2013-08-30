From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 0/5] IPVS fixes for v3.11
Date: Fri, 30 Aug 2013 18:14:23 +0900
Message-ID: <1377854068-22340-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

I'm not sure if it is too late in the cycle but
if not could you please consider these fixes for v3.11?

In my opinion these all seem to be -stable candidates.
I would appreciate your opinion on that.


The following changes since commit e75dc677ff8d06ffa61bef6fee436227ae5440c6:

  hso: Fix stack corruption on some architectures (2013-08-21 20:47:59 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.11

for you to fetch changes up to d5af9df3233d4cb2e7c9011af86ed53cdd12a136:

  ipvs: fix overflow on dest weight multiply (2013-08-30 17:52:03 +0900)

----------------------------------------------------------------
Fixes for IPVS for v3.11

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
      ipvs: do not use dest after ip_vs_dest_put in LBLC
      ipvs: do not use dest after ip_vs_dest_put in LBLCR
      ipvs: make the service replacement more robust
      ipvs: stats should not depend on CPU 0

Simon Kirby (1):
      ipvs: fix overflow on dest weight multiply

 include/net/ip_vs.h              |  8 ++--
 net/netfilter/ipvs/ip_vs_core.c  | 12 +++++-
 net/netfilter/ipvs/ip_vs_ctl.c   | 90 ++++++++++++++++------------------------
 net/netfilter/ipvs/ip_vs_est.c   |  4 +-
 net/netfilter/ipvs/ip_vs_lblc.c  | 72 +++++++++++++++-----------------
 net/netfilter/ipvs/ip_vs_lblcr.c | 62 ++++++++++++---------------
 net/netfilter/ipvs/ip_vs_nq.c    |  8 ++--
 net/netfilter/ipvs/ip_vs_sed.c   |  8 ++--
 net/netfilter/ipvs/ip_vs_wlc.c   |  6 +--
 9 files changed, 121 insertions(+), 149 deletions(-)



-- 
1.8.4

