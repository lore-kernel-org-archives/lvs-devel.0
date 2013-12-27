From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf 0/2] IPVS Fixes for v3.13
Date: Fri, 27 Dec 2013 12:37:35 +0900
Message-ID: <1388115457-9873-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider the following fixes for IPVS for v3.13.
Or alternatively for v3.14.

This pull-request consists of two patches from Jesper Dangaard Brouer to
resolve sequence number problems introduced by 41d73ec053d2 (netfilter:
nf_conntrack: make sequence number adjustments usuable without NAT) in
v3.11-rc7.

I believe they are -stable candidates back to v3.11.


The following changes since commit 443d20fd188208aa4df2118ad49f9168e411016d:

  netfilter: nf_ct_timestamp: Fix BUG_ON after netns deletion (2013-12-20 14:58:29 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.13

for you to fetch changes up to b25adce1606427fd88da08f5203714cada7f6a98:

  ipvs: correct usage/allocation of seqadj ext in ipvs (2013-12-27 12:30:02 +0900)

----------------------------------------------------------------
IPVS Fixes for v3.13

Two patches from Jesper Dangaard Brouer to resolve sequence number problems
introduced by 41d73ec053d2 (netfilter: nf_conntrack: make sequence number
adjustments usuable without NAT) in v3.11-rc7.

----------------------------------------------------------------
Jesper Dangaard Brouer (2):
      netfilter: WARN about wrong usage of sequence number adjustments
      ipvs: correct usage/allocation of seqadj ext in ipvs

 net/netfilter/ipvs/ip_vs_nfct.c     | 6 ++++++
 net/netfilter/nf_conntrack_seqadj.c | 5 +++++
 2 files changed, 11 insertions(+)
