From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS
Date: Tue, 15 Mar 2011 14:27:08 +0900
Message-ID: <1300166852-725-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>

Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick
to get the changes listed below.

This replaces the pull requests that I sent yesterday, sorry for messing
that up.

Also, sorry for letting the number of patches grow so much, Julian and I
were working on patches that conflicted with each other. But regardless, I
should have done something about getting a request to you earlier.

Jesper Juhl (1):
      IPVS: Fix variable assignment in ip_vs_notrack

Julian Anastasov (8):
      ipvs: avoid lookup for fwmark 0
      ipvs: remove _bh from percpu stats reading
      ipvs: move struct netns_ipvs
      ipvs: reorganize tot_stats
      ipvs: properly zero stats and rates
      ipvs: remove unused seqcount stats
      ipvs: optimize rates reading
      ipvs: rename estimator functions

Shan Wei (1):
      netfilter:ipvs: use kmemdup

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

 include/net/ip_vs.h               |  198 ++++++++++++++++++++++++++---
 include/net/net_namespace.h       |    2 +-
 include/net/netns/ip_vs.h         |  143 ---------------------
 net/netfilter/ipvs/ip_vs_conn.c   |   13 ++-
 net/netfilter/ipvs/ip_vs_core.c   |  104 +++++++++------
 net/netfilter/ipvs/ip_vs_ctl.c    |  256 ++++++++++++++++++++++---------------
 net/netfilter/ipvs/ip_vs_est.c    |   63 ++++-----
 net/netfilter/ipvs/ip_vs_lblc.c   |   31 ++++-
 net/netfilter/ipvs/ip_vs_lblcr.c  |   35 ++++--
 net/netfilter/ipvs/ip_vs_pe_sip.c |    9 +-
 net/netfilter/ipvs/ip_vs_sync.c   |   11 +-
 11 files changed, 492 insertions(+), 373 deletions(-)
 delete mode 100644 include/net/netns/ip_vs.h
