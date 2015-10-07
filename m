From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next 0/2] Fourth Round of IPVS Updates for v4.4
Date: Wed,  7 Oct 2015 14:23:21 +0900
Message-ID: <1444195403-4288-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider these build warning cleanups from David Ahern and myself.
They resolve some minor side effects of Eric Biederman' heroic work to
cleanup IPVS which you recently pulled: its queued up for v4.4 so no need
to worry about earlier kernel versions.

The following changes since commit a29a9a585b2840a205f085a34dfd65c75e86f7c3:

  netfilter: nfnetlink_log: allow to attach conntrack (2015-10-05 17:32:14 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs4-for-v4.4

for you to fetch changes up to 92240e8dc0d1a94ea3dde7cb19aace113dcc6cb9:

  ipvs: Remove possibly unused variables from ip_vs_conn_net_{init,cleanup} (2015-10-07 10:12:00 +0900)

----------------------------------------------------------------
David Ahern (1):
      ipvs: Remove possibly unused variable from ip_vs_out

Simon Horman (1):
      ipvs: Remove possibly unused variables from ip_vs_conn_net_{init,cleanup}

 net/netfilter/ipvs/ip_vs_conn.c | 13 +++++--------
 net/netfilter/ipvs/ip_vs_core.c |  3 +--
 2 files changed, 6 insertions(+), 10 deletions(-)
