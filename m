From: sven.wegener@stealer.net
Subject: [PATCH] ipvs: A couple of fixes and cleanups
Date: Sun, 10 Aug 2008 11:07:30 +0000
Message-ID: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Hi guys,

here come a couple of fixes and cleanups for IPVS. Worth mentioning are the two
possible deadlock fixes. One introduced by my last sync daemon work, which
hasn't hit any stable kernel yet. The other one is in the estimator code and
goes back to at leat since we started working with git for the kernel. The
latter I think qualifies for -stable.

I've pushed the changes (8123b42..2e45552) based on davem's net tree here

	git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem

Sven Wegener (9):
      ipvs: Fix possible deadlock in sync code
      ipvs: Fix possible deadlock in estimator code
      ipvs: Use ARRAY_SIZE()
      ipvs: Use list_empty() instead of open-coding the same functionality
      ipvs: Initialize schedulers' struct list_head at compile time
      ipvs: Annotate init functions with __init
      ipvs: Mark net_vs_ctl_path const
      ipvs: Embed estimator object into stats object
      ipvs: No need to zero out ip_vs_stats during initialization

 include/net/ip_vs.h         |   26 ++++++++--
 net/ipv4/ipvs/ip_vs_app.c   |    2 +-
 net/ipv4/ipvs/ip_vs_conn.c  |    2 +-
 net/ipv4/ipvs/ip_vs_ctl.c   |   12 ++--
 net/ipv4/ipvs/ip_vs_dh.c    |    2 +-
 net/ipv4/ipvs/ip_vs_est.c   |  116 ++++++++++++++----------------------------
 net/ipv4/ipvs/ip_vs_lblc.c  |    2 +-
 net/ipv4/ipvs/ip_vs_lblcr.c |    2 +-
 net/ipv4/ipvs/ip_vs_lc.c    |    2 +-
 net/ipv4/ipvs/ip_vs_nq.c    |    2 +-
 net/ipv4/ipvs/ip_vs_proto.c |    2 +-
 net/ipv4/ipvs/ip_vs_rr.c    |    2 +-
 net/ipv4/ipvs/ip_vs_sched.c |    4 +-
 net/ipv4/ipvs/ip_vs_sed.c   |    2 +-
 net/ipv4/ipvs/ip_vs_sh.c    |    2 +-
 net/ipv4/ipvs/ip_vs_sync.c  |    4 +-
 net/ipv4/ipvs/ip_vs_wlc.c   |    2 +-
 net/ipv4/ipvs/ip_vs_wrr.c   |    2 +-
 18 files changed, 84 insertions(+), 104 deletions(-)


