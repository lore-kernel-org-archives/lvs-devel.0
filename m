From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL net-next-2.6] IPVS
Date: Wed, 15 Jun 2011 08:43:16 +0900
Message-ID: <1308095001-21002-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>

Hi Patrick, Hi Pablo,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next-2.6.git
master

It includes four clean-ups by Hans
and an enhancement of the FTP helper by Julian.

I have based the pull request on next-2.6 as
nf-next-2.6 seems to be a little old. Please let me
know if a different base would suit you better.

Hans Schillstrom (4):
      IPVS remove unused var from migration to netns
      IPVS: rename of netns init and cleanup functions.
      IPVS: labels at pos 0
      IPVS: remove unused init and cleanup functions.

Julian Anastasov (1):
      ipvs: support more FTP PASV responses

 include/net/ip_vs.h              |   34 +++++++-----------
 net/netfilter/ipvs/ip_vs_app.c   |   14 +------
 net/netfilter/ipvs/ip_vs_conn.c  |    4 +-
 net/netfilter/ipvs/ip_vs_core.c  |   71 +++++++++++++------------------------
 net/netfilter/ipvs/ip_vs_ctl.c   |   28 +++++++-------
 net/netfilter/ipvs/ip_vs_est.c   |   13 +------
 net/netfilter/ipvs/ip_vs_ftp.c   |   52 ++++++++++++++++++++-------
 net/netfilter/ipvs/ip_vs_proto.c |    4 +-
 net/netfilter/ipvs/ip_vs_sync.c  |   13 +------
 9 files changed, 100 insertions(+), 133 deletions(-)

