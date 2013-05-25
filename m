From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS fixes for v3.10
Date: Sun, 26 May 2013 08:16:38 +0900
Message-ID: <1369523799-27082-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

The following changes since commit 4f36ea6eed2081340c7a7aa98c73187ecfccebff:

  netfilter: ipt_ULOG: fix non-null terminated string in the nf_log path (2013-05-23 14:25:40 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.10

for you to fetch changes up to 1fb4f80a593231770eae3192e4a52fa7631bd897:

  ipvs: Fix reuse connection if real server is dead (2013-05-26 08:10:47 +0900)

----------------------------------------------------------------
IPVS fixes for v3.10

Correct connection reuse for TCP and SCTP

----------------------------------------------------------------
Grzegorz Lyczba (1):
      ipvs: Fix reuse connection if real server is dead

 net/netfilter/ipvs/ip_vs_core.c |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)
