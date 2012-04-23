From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL net] IPVS (v2)
Date: Mon, 23 Apr 2012 22:12:10 +0900
Message-ID: <1335186732-16002-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Sasha Levin <levinsasha928@gmail.com>

sorry for the miss-fire a little earlier. Please consider the following two
changes for 3.4. The patch from Julian reolves a crash on module unload.
And the patch from Sasha resolves a crash on initialisation.

The following changes since commit 6ba900676bec8baaf61aa2f85b7345c0e65774d9:

  netfilter: nf_conntrack: fix incorrect logic in nf_conntrack_init_net (2012-04-10 13:00:38 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master

for you to fetch changes up to 0cc4789846744470e50707cbc7f0fbb543e6f2a3:

  ipvs: fix crash in ip_vs_control_net_cleanup on unload (2012-04-23 21:45:50 +0900)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: fix crash in ip_vs_control_net_cleanup on unload

Sasha Levin (1):
      netfilter: ipvs: Verify that IP_VS protocol has been registered

 net/netfilter/ipvs/ip_vs_ctl.c   |    4 ++--
 net/netfilter/ipvs/ip_vs_proto.c |   27 ++++++++++++++++++---------
 2 files changed, 20 insertions(+), 11 deletions(-)
