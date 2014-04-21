From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS Updates for v3.16
Date: Mon, 21 Apr 2014 09:16:46 +0900
Message-ID: <1398039407-12060-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>


Hi Pablo,

please consider the following updates for IPVS for v3.16.

It consists of a format string fix from Masanari Iida.


The following changes since commit 6125c94e6972fca79214809a43eb60e27feff3ee:

  netfilter: nft_ct: split nft_ct_init() into two functions for get/set (2014-03-30 13:31:44 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.16

for you to fetch changes up to 9c55bfa9373b4b44c32f0e844923a0e6c607056d:

  netfilter: Fix format string mismatch in ip_vs_proto_name() (2014-04-03 10:35:35 +0900)

----------------------------------------------------------------
IPVS Updates for v3.16

* Format string fix from  Masanari Iida

----------------------------------------------------------------
Masanari Iida (1):
      netfilter: Fix format string mismatch in ip_vs_proto_name()

 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
