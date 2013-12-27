From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS Updates for v3.14
Date: Fri, 27 Dec 2013 12:46:11 +0900
Message-ID: <1388115972-11861-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider the following IPVS updates for v3.14.

This pull-request consists of one change, the removal
of an unused variable by Geert Uytterhoeven.


The following changes since commit 6a649f339802f104549e1fb211e381036661e244:

  netfilter: add IPv4/6 IPComp extension match support (2013-12-24 12:37:58 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.14

for you to fetch changes up to 9dcbe1b87c4a8e3ed62e95369c18709541a3dc8f:

  ipvs: Remove unused variable ret from sync_thread_master() (2013-12-27 12:19:32 +0900)

----------------------------------------------------------------
IPVS Updates for v3.14

* Removal of unused variable by Geert Uytterhoeven

----------------------------------------------------------------
Geert Uytterhoeven (1):
      ipvs: Remove unused variable ret from sync_thread_master()

 net/netfilter/ipvs/ip_vs_sync.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)
