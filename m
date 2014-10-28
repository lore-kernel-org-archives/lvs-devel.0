From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS Fixes for v3.18
Date: Tue, 28 Oct 2014 10:05:33 +0900
Message-ID: <1414458334-22479-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix for v3.18.

It fixes a null-pointer dereference that may occur when logging
errors.

This problem was introduced by 4a4739d56b0 ("ipvs: Pull out
crosses_local_route_boundary logic") in v3.17-rc5. As such I would
also like it considered for 3.17-stable.


The following changes since commit 7965ee93719921ea5978f331da653dfa2d7b99f5:

  netfilter: nft_compat: fix wrong target lookup in nft_target_select_ops() (2014-10-27 22:17:46 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.18

for you to fetch changes up to 3d53666b40007b55204ee8890618da79a20c9940:

  ipvs: Avoid null-pointer deref in debug code (2014-10-28 09:48:31 +0900)

----------------------------------------------------------------
Alex Gartrell (1):
      ipvs: Avoid null-pointer deref in debug code

 net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
