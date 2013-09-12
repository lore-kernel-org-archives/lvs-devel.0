From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 net 0/4] IPVS fixes for corner cases
Date: Thu, 12 Sep 2013 11:21:06 +0300
Message-ID: <1378974070-9372-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	The patchset contains fixes for races during
dest and service deletion caused from the recent RCU changes.

	The last change is required if CPU 0 can be missing
from the mask of possible CPUs. Otherwise, it can be
considered a non-fatal change.

v2:
* do not remove rcu_barrier() in "ipvs: make the service replacement
more robust", we should wait RCU callbacks in LBLC and LBLCR.
Non-fix change will remove it later.

Julian Anastasov (4):
  ipvs: make the service replacement more robust
  ipvs: do not use dest after ip_vs_dest_put in LBLC
  ipvs: do not use dest after ip_vs_dest_put in LBLCR
  ipvs: stats should not depend on CPU 0

 include/net/ip_vs.h              |    7 +--
 net/netfilter/ipvs/ip_vs_core.c  |   12 ++++-
 net/netfilter/ipvs/ip_vs_ctl.c   |   86 +++++++++++++++----------------------
 net/netfilter/ipvs/ip_vs_est.c   |    4 +-
 net/netfilter/ipvs/ip_vs_lblc.c  |   68 ++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_lblcr.c |   50 +++++++++-------------
 6 files changed, 101 insertions(+), 126 deletions(-)

-- 
1.7.3.4

