From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] Second Round of IPVS Updates for v4.3
Date: Fri, 21 Aug 2015 09:23:38 -0700
Message-ID: <1440174222-12695-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these IPVS Updates for v4.3.

I realise these are a little late in the cycle, so if you would prefer
me to repost them for v4.4 then just let me know.

The updates include:
* A new scheduler from Raducu Deaconu
* Enhanced configurability of the sync daemon from Julian Anastasov

The following changes since commit 81bf1c64e7fe08f956c74fe2b0f1fa6eb163bd91:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2015-08-21 06:09:05 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v4.3

for you to fetch changes up to d33288172e72c4729e8b9f2243fb40601afabc8f:

  ipvs: add more mcast parameters for the sync daemon (2015-08-21 09:10:11 -0700)

----------------------------------------------------------------
Julian Anastasov (3):
      ipvs: call rtnl_lock early
      ipvs: add sync_maxlen parameter for the sync daemon
      ipvs: add more mcast parameters for the sync daemon

Raducu Deaconu (1):
      ipvs: Add ovf scheduler

 include/net/ip_vs.h             |  23 ++--
 include/uapi/linux/ip_vs.h      |   5 +
 net/netfilter/ipvs/Kconfig      |  11 ++
 net/netfilter/ipvs/Makefile     |   1 +
 net/netfilter/ipvs/ip_vs_ctl.c  | 143 ++++++++++++++++-----
 net/netfilter/ipvs/ip_vs_ovf.c  |  86 +++++++++++++
 net/netfilter/ipvs/ip_vs_sync.c | 269 ++++++++++++++++++++++++++--------------
 7 files changed, 402 insertions(+), 136 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_ovf.c
