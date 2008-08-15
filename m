From: Simon Horman <horms@verge.net.au>
Subject: [GIT] Please pull updates for IPVS
Date: Fri, 15 Aug 2008 10:12:52 +1000
Message-ID: <20080815001250.GC15825@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Sven Wegener <sven.wegener@stealer.net>, Julius Volz <juliusv@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Dave,

I have pulled together the handful of unmerged but agreed to
IPVS patches that are floating around.

Julius, Sven and I would particularly like Julius' two changes to go
in. They add a new interface which is currently unused and thus the
likelihood of breakage seems low.

The other changes are clean ups.



The following changes since commit 0eb8b1fe9238ca4c1797e4c105d5790abda1726f:
  Michael Chan (1):
        bnx2: Update version to 1.8.0.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git master

Julius Volz (2):
      IPVS: Add genetlink interface definitions to ip_vs.h
      IPVS: Add genetlink interface implementation

Simon Horman (1):
      ipvs: rename __ip_vs_wlc_schedule in lblc and lblcr schedulers

Sven Wegener (2):
      ipvs: Only call init_service, update_service and done_service for schedulers if defined
      ipvs: Create init functions for estimator code

 include/linux/ip_vs.h       |  160 ++++++++
 include/net/ip_vs.h         |    2 +
 net/ipv4/ipvs/ip_vs_core.c  |    8 +-
 net/ipv4/ipvs/ip_vs_ctl.c   |  896 ++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/ipvs/ip_vs_est.c   |   18 +-
 net/ipv4/ipvs/ip_vs_lblc.c  |   13 +-
 net/ipv4/ipvs/ip_vs_lblcr.c |   13 +-
 net/ipv4/ipvs/ip_vs_lc.c    |   21 -
 net/ipv4/ipvs/ip_vs_nq.c    |   24 --
 net/ipv4/ipvs/ip_vs_rr.c    |    7 -
 net/ipv4/ipvs/ip_vs_sed.c   |   24 --
 net/ipv4/ipvs/ip_vs_wlc.c   |   24 --
 12 files changed, 1072 insertions(+), 138 deletions(-)
