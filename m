From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS for 3.8
Date: Tue, 23 Oct 2012 09:50:50 +0900
Message-ID: <1350953451-19441-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>

Hi Pablo,

please consider the following build fix from Jesper for 3.8.

----------------------------------------------------------------
The following changes since commit bcc58c4d9141160d6448e4589acbd46e5c647518:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next (2012-10-22 12:30:41 +0200)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

for you to fetch changes up to 54d83efa44aac87983f973abb42c508a25a2b554:

  ipvs: fix build errors related to config option combinations (2012-10-23 09:23:40 +0900)

----------------------------------------------------------------
Jesper Dangaard Brouer (1):
      ipvs: fix build errors related to config option combinations

 include/net/ip_vs.h |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
