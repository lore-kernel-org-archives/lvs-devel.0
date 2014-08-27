From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS fixes for v3.17
Date: Wed, 27 Aug 2014 15:15:14 +0900
Message-ID: <1409120115-32053-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this IPVS fix for v3.17.

It allows CHECKSUM_PARTIAL to work in conjunction with
TCP/UDP csum offlad and the tunnel forwarding mechanism
provided by IPVS.

I suspect that this problem has existed for as long
has IPVS has been present in the kernel: some time before
git epoch of the git history in Linus's tree.

I would like this change considered for -stable.

It appears to apply and build cleanly against v3.16.1 and v3.14.17.

I can work on patches for older versions if you think it is appropriate.


The following changes since commit d1c85c2ebe7ffe1f1b27846bd1ba0944c513d822:

  netfilter: HAVE_JUMP_LABEL instead of CONFIG_JUMP_LABEL (2014-08-25 10:45:28 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.17

for you to fetch changes up to ea1d5d7755a3e556de78cc757d1895d5c7180548:

  ipvs: properly declare tunnel encapsulation (2014-08-27 14:31:56 +0900)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: properly declare tunnel encapsulation

 net/netfilter/ipvs/ip_vs_xmit.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

Julian Anastasov (1):
  ipvs: properly declare tunnel encapsulation

 net/netfilter/ipvs/ip_vs_xmit.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

-- 
2.0.1
