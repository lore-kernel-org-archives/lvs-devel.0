From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 00/19] IPVS optimizations, part 2
Date: Fri, 22 Mar 2013 11:46:35 +0200
Message-ID: <1363945614-11752-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	This is the second patchset with IPVS optimizations.
Now we convert the schedulers, dests and services to RCU.

	All patches are for net-next based on the first
patchset v3. The idea is after discussion and review Simon to
apply the patchset after a week or so to ipvs-next tree.

	The changes in this patchset eliminate global locks
from packet processing by using RCU. There are more details
in the patches.

	After this patchset the situation is as follows:

- dests:
	- lookups under RCU lock allow ip_vs_dest_hold, used
	for binding dest to conn or to select dest by scheduler
	- dests are freed by dest_trash code long after grace period

- services:
	- no global read_lock
	- lookups under RCU lock allow scheduler to select
	dests under RCU lock
	- grace period implemented with IP_VS_WAIT_WHILE is
	gone allowing scheduler's dest selection and scheduler
	reconfiguration to run in parallel

- schedulers:
	- schedule method runs under RCU lock, needs _rcu
	if using svc->destinations, needs _bh suffix to locks
	because it can be called in LOCAL_OUT hook
	- when dest is added, the add_dest method is called
	instead of update_service
	- when dest is deleted, the del_dest method is called
	instead of update_service
	- when dest is updated, the upd_dest method is called
	instead of update_service
	- scheduler can hold dests in its state long after they are
	unlinked from svc, even without providing del_dest handler.
	But such dests must not be returned by the
	schedule method (needs IP_VS_DEST_F_AVAILABLE check)
	- sched_data must be freed after grace period and
	module exit should be delayed with synchronize_rcu
	to wait all RCU read-side critical sections to
	complete

- BH:
	- we do not disable BHs in LOCAL_OUT and sync code anymore
	- _bh suffixes are added to all places that need them,
	except timer handlers

Julian Anastasov (19):
  ipvs: change ip_vs_sched_lock to mutex
  ipvs: preparations for using rcu in schedulers
  ipvs: add ip_vs_dest_hold and ip_vs_dest_put
  ipvs: convert dh scheduler to rcu
  ipvs: convert lblc scheduler to rcu
  ipvs: convert lblcr scheduler to rcu
  ipvs: convert lc scheduler to rcu
  ipvs: convert nq scheduler to rcu
  ipvs: convert rr scheduler to rcu
  ipvs: convert sed scheduler to rcu
  ipvs: convert sh scheduler to rcu
  ipvs: convert wlc scheduler to rcu
  ipvs: convert wrr scheduler to rcu
  ipvs: reorganize dest trash
  ipvs: do not expect result from done_service
  ipvs: convert sched_lock to spin lock
  ipvs: convert dests to rcu
  ipvs: convert services to rcu
  ipvs: do not disable bh for long time

 include/net/ip_vs.h                   |   59 +++--
 net/netfilter/ipvs/ip_vs_app.c        |    4 +-
 net/netfilter/ipvs/ip_vs_conn.c       |   47 ++--
 net/netfilter/ipvs/ip_vs_core.c       |   57 ++---
 net/netfilter/ipvs/ip_vs_ctl.c        |  510 ++++++++++++++++-----------------
 net/netfilter/ipvs/ip_vs_dh.c         |   86 +++---
 net/netfilter/ipvs/ip_vs_ftp.c        |    2 +
 net/netfilter/ipvs/ip_vs_lblc.c       |  115 ++++----
 net/netfilter/ipvs/ip_vs_lblcr.c      |  190 +++++++------
 net/netfilter/ipvs/ip_vs_lc.c         |    3 +-
 net/netfilter/ipvs/ip_vs_nq.c         |    3 +-
 net/netfilter/ipvs/ip_vs_pe.c         |   12 -
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   18 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   22 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |   14 +-
 net/netfilter/ipvs/ip_vs_rr.c         |   64 +++--
 net/netfilter/ipvs/ip_vs_sched.c      |   63 ++---
 net/netfilter/ipvs/ip_vs_sed.c        |    5 +-
 net/netfilter/ipvs/ip_vs_sh.c         |   86 +++---
 net/netfilter/ipvs/ip_vs_sync.c       |   35 +--
 net/netfilter/ipvs/ip_vs_wlc.c        |    5 +-
 net/netfilter/ipvs/ip_vs_wrr.c        |  176 +++++++-----
 net/netfilter/ipvs/ip_vs_xmit.c       |   16 +-
 23 files changed, 819 insertions(+), 773 deletions(-)

-- 
1.7.3.4

