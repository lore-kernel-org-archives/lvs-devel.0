From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 0/5] IPVS changes
Date: Sat,  9 Mar 2013 23:25:03 +0200
Message-ID: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	This patchset adds new backup_only flag and fixes
some warnings found by sparse. I hope the SCTP part is
correct. In fact I see other problems with the SCTP state
machine that need to be resolved.

	The patchset does not overlap with the other
patchset for IPVS optimizations, so can be applied
independently.

Julian Anastasov (5):
  ipvs: add backup_only flag to avoid loops
  ipvs: remove extra rcu lock
  ipvs: fix sctp chunk length order
  ipvs: fix hashing in ip_vs_svc_hashkey
  ipvs: fix some sparse warnings

 Documentation/networking/ipvs-sysctl.txt |    7 +++++++
 include/net/ip_vs.h                      |   14 +++++++++++++-
 net/netfilter/ipvs/ip_vs_core.c          |   22 +++++++++-------------
 net/netfilter/ipvs/ip_vs_ctl.c           |   15 ++++++++++++---
 net/netfilter/ipvs/ip_vs_est.c           |    2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c    |   16 +++++++++-------
 6 files changed, 51 insertions(+), 25 deletions(-)

-- 
1.7.3.4

