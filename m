From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL] IPVS fixes for v5.4
Date: Fri, 25 Oct 2019 13:12:03 +0200
Message-ID: <20191025111205.30555-1-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS fixes for v5.4.

* Eric Dumazet resolves a race condition in switching the defense level

* Davide Caratti resolves a race condition in module removal

This pull request is based on nf.


The following changes since commit 085461c8976e6cb4d5b608a7b7062f394c51a253:

  netfilter: nf_tables_offload: restore basechain deletion (2019-10-23 13:14:50 +0200)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v5.4

for you to fetch changes up to c24b75e0f9239e78105f81c5f03a751641eb07ef:

  ipvs: move old_secure_tcp into struct netns_ipvs (2019-10-24 11:56:02 +0200)

----------------------------------------------------------------
Davide Caratti (1):
      ipvs: don't ignore errors in case refcounting ip_vs module fails

Eric Dumazet (1):
      ipvs: move old_secure_tcp into struct netns_ipvs

 include/net/ip_vs.h              |  1 +
 net/netfilter/ipvs/ip_vs_app.c   | 12 ++++++++++--
 net/netfilter/ipvs/ip_vs_ctl.c   | 29 +++++++++++------------------
 net/netfilter/ipvs/ip_vs_pe.c    |  3 ++-
 net/netfilter/ipvs/ip_vs_sched.c |  3 ++-
 net/netfilter/ipvs/ip_vs_sync.c  | 13 ++++++++++---
 6 files changed, 36 insertions(+), 25 deletions(-)
