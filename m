From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] Fixes for v3.15
Date: Mon, 26 May 2014 10:37:14 +0900
Message-ID: <1401068235-6730-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

I realise this is extremely late in the v3.15 cycle so please don't hesitate
to push it back to v3.16. I am more than happy to rebase/resubmit if that
is what you decided on.

This fix resolves a panic due to non-linear skb.

It has been present since v3.6-rc1.

I would like this fix considered for -stable and I have checked that it
applies cleanly on top of v3.10.40, v3.12.20 and v3.14.4.


The following changes since commit 3b084e99a3fabaeb0f9c65a0806cde30f0b2835e:

  netfilter: nf_tables: fix trace of matching non-terminal rule (2014-05-15 19:44:20 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.15

for you to fetch changes up to f44a5f45f544561302e855e7bd104e5f506ec01b:

  ipvs: Fix panic due to non-linear skb (2014-05-26 10:22:46 +0900)

----------------------------------------------------------------
IPVS Fixes for v3.15

Fix for panic due to non-linear skb by Peter Christensen.

This resolves a regression introduced in v3.6-rc1 by
f2edb9f7706dcb2c0d9a362b2ba849efe3a97f5e ("ipvs: implement
passive PMTUD for IPIP packets").

----------------------------------------------------------------
Peter Christensen (1):
      ipvs: Fix panic due to non-linear skb

 net/netfilter/ipvs/ip_vs_core.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)
