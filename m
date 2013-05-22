From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS for v3.11
Date: Wed, 22 May 2013 14:56:47 +0900
Message-ID: <1369202209-18570-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

The following changes since commit eee1d5a14780b9391ec51f3feaf4cffb521ddbb1:

  sctp: Correct type and usage of sctp_end_cksum() (2013-04-29 20:09:08 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.11

for you to fetch changes up to fc889767fc2e51e43787408e3ff9fb34e5312c74:

  ipvs: Fix reuse connection if real server is dead (2013-05-22 14:43:11 +0900)

----------------------------------------------------------------
Two enhancements to IPVS for v3.11

* Correct connection reuse for TCP and SCTP
* Tidy up type of sysctl_sync_qlen_max member of struct netns_ipvs

----------------------------------------------------------------
Grzegorz Lyczba (1):
      ipvs: Fix reuse connection if real server is dead

Zhang Yanfei (1):
      ipvs: change type of netns_ipvs->sysctl_sync_qlen_max

 include/net/ip_vs.h             |  8 ++++----
 net/netfilter/ipvs/ip_vs_core.c | 36 ++++++++++++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c  |  4 ++--
 3 files changed, 42 insertions(+), 6 deletions(-)
