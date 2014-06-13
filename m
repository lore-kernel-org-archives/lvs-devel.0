From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS Fixes for v3.16
Date: Fri, 13 Jun 2014 16:37:08 +0900
Message-ID: <1402645029-21756-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

Please consider this IPVS fix for v3.16.

Fix for panic due use of tot_stats estimator outside of CONFIG_SYSCTL

It has been present since v3.6.39.

I would like this fix considered for -stable and I have checked that it
applies cleanly on top of v3.15, v3.14.7, v3.12.22, v3.10.43 and v3.2.60.


The following changes since commit f44a5f45f544561302e855e7bd104e5f506ec01b:

  ipvs: Fix panic due to non-linear skb (2014-05-26 10:22:46 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git ipvs-fixes-for-v3.16

for you to fetch changes up to 9802d21e7a0b0d2167ef745edc1f4ea7a0fc6ea3:

  ipvs: stop tot_stats estimator only under CONFIG_SYSCTL (2014-06-13 16:22:25 +0900)

----------------------------------------------------------------
IPVS Fixes for v3.16

Fix for panic due use of tot_stats estimator outside of CONFIG_SYSCTL

This resolves a bug introduced in v3.6.39 by 14e405461e664b
("IPVS: Add __ip_vs_control_{init,cleanup}_sysctl()").

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: stop tot_stats estimator only under CONFIG_SYSCTL

 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
