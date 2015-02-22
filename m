From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL] Second Round of IPVS Fixes for v3.20
Date: Sun, 22 Feb 2015 16:24:59 -0500
Message-ID: <1424640300-30364-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix for v3.20.

This patch resolves some memory leaks in connection
synchronisation code that date back to v2.6.39.


The following changes since commit 78296c97ca1fd3b104f12e1f1fbc06c46635990b:

  netfilter: xt_socket: fix a stack corruption bug (2015-02-16 17:00:48 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v3.20

for you to fetch changes up to 528c943f3bb919aef75ab2fff4f00176f09a4019:

  ipvs: add missing ip_vs_pe_put in sync code (2015-02-22 16:16:36 -0500)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: add missing ip_vs_pe_put in sync code

 net/netfilter/ipvs/ip_vs_sync.c | 3 +++
 1 file changed, 3 insertions(+)
