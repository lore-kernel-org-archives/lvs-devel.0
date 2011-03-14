From: Simon Horman <horms@verge.net.au>
Subject: [patch v3 00/20] IPVS: Proposed Changes
Date: Mon, 14 Mar 2011 12:45:26 +0900
Message-ID: <1300074346-13799-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>

I am posting this series for review. In particular of patches 3 & 4 in the
series, whose previous versions received some feedback from Eric. And
patches 5 & 6 which are new.

The first 6 patches are fixes from Julian Anastasov.
They can be found in git at
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git ja2

The remaining patches are from myself to conditionally include sysctl
support. They have been posted several times and only haven't been merged
as there are some minor conflicts with Julian's changes.
They, along with Julian's changes, can be found in git at
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git config-sysctl2

Julian Anastasov (6):
      ipvs: move struct netns_ipvs
      ipvs: reorganize tot_stats
      ipvs: properly zero stats and rates
      ipvs: remove unused seqcount stats
      ipvs: optimize rates reading
      ipvs: rename estimator functions

Simon Horman (14):
      IPVS: Add ip_vs_route_me_harder()
      IPVS: Add sysctl_snat_reroute()
      IPVS: Add sysctl_nat_icmp_send()
      IPVS: Add {sysctl_sync_threshold,period}()
      IPVS: Add sysctl_sync_ver()
      IPVS: Add sysctl_expire_nodest_conn()
      IPVS: Add expire_quiescent_template()
      IPVS: Conditinally use sysctl_lblc{r}_expiration
      IPVS: ip_vs_todrop() becomes a noop when CONFIG_SYSCTL is undefined
      IPVS: Conditional ip_vs_conntrack_enabled()
      IPVS: Minimise ip_vs_leave when CONFIG_SYSCTL is undefined
      IPVS: Conditionally define and use ip_vs_lblc{r}_table
      IPVS: Add __ip_vs_control_{init,cleanup}_sysctl()
      IPVS: Conditionally include sysctl members of struct netns_ipvs

 include/net/ip_vs.h              |  196 +++++++++++++++++++++++++++---
 include/net/net_namespace.h      |    2 +-
 include/net/netns/ip_vs.h        |  143 ----------------------
 net/netfilter/ipvs/ip_vs_conn.c  |   13 ++-
 net/netfilter/ipvs/ip_vs_core.c  |  104 ++++++++++------
 net/netfilter/ipvs/ip_vs_ctl.c   |  248 ++++++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_est.c   |   55 ++++-----
 net/netfilter/ipvs/ip_vs_lblc.c  |   31 ++++--
 net/netfilter/ipvs/ip_vs_lblcr.c |   35 ++++--
 net/netfilter/ipvs/ip_vs_sync.c  |    8 +-
 10 files changed, 477 insertions(+), 358 deletions(-)
 delete mode 100644 include/net/netns/ip_vs.h
