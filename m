From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 0/2] IPVS Updates for v3.15
Date: Fri,  7 Mar 2014 12:46:12 +0900
Message-ID: <1394163974-25877-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider the following updates for IPVS for v3.15.

It consists of two cleanups.
* Whitespace cleanup from Tingwei Liu
* Section conflict cleanup from Andi Kleen

Please feel free to put Andi's patch into nf instead of nf-next if
you think that is appropriate.


The following changes since commit 0768b3b3d228c5acf2075f40f3d25cda30011d4f:

  netfilter: nf_tables: add optional user data area to rules (2014-02-27 16:56:00 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.15

for you to fetch changes up to 411fd527bc3f8357b499c760f7cd03633a0c7de2:

  ipvs: Reduce checkpatch noise in ip_vs_lblc.c (2014-03-07 12:36:21 +0900)

----------------------------------------------------------------
IPVS Updates for v3.15

* Cleanup from Tingwei Liu to correct whitespace
* Cleanup from Andi Kleen to avoid a LTO section conflict compile problem

----------------------------------------------------------------
Andi Kleen (1):
      sections, ipvs: Remove useless __read_mostly for ipvs genl_ops

Tingwei Liu (1):
      ipvs: Reduce checkpatch noise in ip_vs_lblc.c

 net/netfilter/ipvs/ip_vs_ctl.c  |  2 +-
 net/netfilter/ipvs/ip_vs_lblc.c | 13 ++++++-------
 2 files changed, 7 insertions(+), 8 deletions(-)
