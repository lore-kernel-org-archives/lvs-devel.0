From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS Updates for v3.18
Date: Wed, 27 Aug 2014 15:20:42 +0900
Message-ID: <1409120443-978-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this IPVS update for v3.17.

The update reduces stack memory for sockopt data.


The following changes since commit f111f780ae1abf4cdc464f24293be90c010a04f6:

  netfilter: nfnetlink_acct: add filter support to nfacct counter list/reset (2014-08-26 21:36:19 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.18

for you to fetch changes up to af912017e809155ddded01ddc1dc48883f5186e5:

  ipvs: reduce stack usage for sockopt data (2014-08-27 14:32:34 +0900)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: reduce stack usage for sockopt data

 net/netfilter/ipvs/ip_vs_ctl.c | 102 +++++++++++++++++++++++------------------
 1 file changed, 57 insertions(+), 45 deletions(-)

