From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 0/2] ipvs: new sync parameters
Date: Sun, 26 Jul 2015 15:03:26 +0300
Message-ID: <1437912208-29538-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

Add new parameters for the sync damon:
sync_maxlen, mcast_group, mcast_port, mcast_ttl.

Stop sending the sync packets with DF=1 to allow
fragmentation, eg. on possible MTU changes, reported
by Dan Carpenter.

This patchset is based on net-next but requires also the
"ipvs: call rtnl_lock early" change.

Julian Anastasov (2):
  ipvs: add sync_maxlen parameter for the sync daemon
  ipvs: add more mcast parameters for the sync daemon

 include/net/ip_vs.h             |  23 ++--
 include/uapi/linux/ip_vs.h      |   5 +
 net/netfilter/ipvs/ip_vs_ctl.c  | 101 ++++++++++++---
 net/netfilter/ipvs/ip_vs_sync.c | 267 ++++++++++++++++++++++++++--------------
 4 files changed, 275 insertions(+), 121 deletions(-)

-- 
1.9.3

