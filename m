From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS
Date: Wed, 11 Jul 2012 09:25:25 +0900
Message-ID: <1341966327-16606-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hi Pablo,

please consider the following enhancements to IPVS for inclusion in 3.6.

----------------------------------------------------------------
The following changes since commit 46ba5a25f521e3c50d7bb81b1abb977769047456:

  netfilter: nfnetlink_queue: do not allow to set unsupported flag bits (2012-07-04 19:51:50 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

for you to fetch changes up to 1fd130ebf10e1185022a9c0470f2298943bad1c4:

  ipvs: generalize app registration in netns (2012-07-10 17:58:10 +0900)

----------------------------------------------------------------
Julian Anastasov (2):
      ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
      ipvs: generalize app registration in netns

 include/net/ip_vs.h            |  5 ++--
 net/netfilter/ipvs/Kconfig     |  3 ++-
 net/netfilter/ipvs/ip_vs_app.c | 61 +++++++++++++++++++++++++++++++-----------
 net/netfilter/ipvs/ip_vs_ftp.c | 21 ++++-----------
 4 files changed, 54 insertions(+), 36 deletions(-)
