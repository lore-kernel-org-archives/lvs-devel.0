From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS Fixes for v4.1
Date: Fri,  8 May 2015 18:10:26 +0900
Message-ID: <1431076227-13893-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix for v4.1.

It resolves a memory leak which appears to have been around since v3.18.

The following changes since commit 39376ccb1968ba9f83e2a880a8bf02ad5dea44e1:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2015-04-27 23:12:34 -0400)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v4.1

for you to fetch changes up to f30bf2a5cac6c60ab366c4bc6db913597bf4d6ab:

  ipvs: fix memory leak in ip_vs_ctl.c (2015-05-08 17:58:54 +0900)

----------------------------------------------------------------
Tommi Rantala (1):
      ipvs: fix memory leak in ip_vs_ctl.c

 net/netfilter/ipvs/ip_vs_ctl.c | 3 +++
 1 file changed, 3 insertions(+)
