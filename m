From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 ] IPVS: Conditionally include sysctl code
Date: Sun,  6 Mar 2011 08:45:42 +0900
Message-ID: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>

In the case where CONFIG_SYSCTL is undefined related
control code in IPVS is unnecessary. This patch series
attempts to make the inclusion of all such code
conditional on CONFIG_SYSCTL.

The first 4 patches in this series is Julian's series
"[PATCH 0/4] ipvs: changes for stats" which are required
for many of the subsequent changes.

The changes are available in the git repository at:
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git config-sysctl2

At this point I would like to merge both Julian's patches
and my changes.

If this series is successful I will examine what if any similar
changes are appropriate for the case where CONFIG_PROC_FS is undefined.

Julian Anastasov (4):
      ipvs: move struct netns_ipvs
      ipvs: reorganize tot_stats
      ipvs: zero percpu stats
      ipvs: remove unused seqcount stats

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

 include/net/ip_vs.h              |  189 ++++++++++++++++++++++++++++++++++---
 include/net/net_namespace.h      |    2 +-
 include/net/netns/ip_vs.h        |  143 ----------------------------
 net/netfilter/ipvs/ip_vs_conn.c  |   13 ++-
 net/netfilter/ipvs/ip_vs_core.c  |  104 +++++++++++++--------
 net/netfilter/ipvs/ip_vs_ctl.c   |  158 ++++++++++++++++++++-----------
 net/netfilter/ipvs/ip_vs_est.c   |    3 +-
 net/netfilter/ipvs/ip_vs_lblc.c  |   31 +++++--
 net/netfilter/ipvs/ip_vs_lblcr.c |   35 +++++--
 net/netfilter/ipvs/ip_vs_sync.c  |    8 +-
 10 files changed, 404 insertions(+), 282 deletions(-)
 delete mode 100644 include/net/netns/ip_vs.h
