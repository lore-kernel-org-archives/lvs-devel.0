From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS
Date: Wed, 11 Jul 2012 09:19:20 +0900
Message-ID: <1341965963-7275-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>


Hi Pablo,

this pull request consists of three bug fixes for IPVS.
Please consider for inclusion in 3.5 and stable.

The bug fix from Julian, "ipvs: fix oops in ip_vs_dst_event on rmmod"
fixes a regression introduced in 3.4 and thus I believe it is
only relevant to 3.5 and 3.4-stable.

The other two fixes appear to have been present since at least 2.6.37
(there were a lot of changes to IPVS around that time).

----------------------------------------------------------------

The following changes since commit 6bd0405bb4196b44f1acb7a58f11382cdaf6f7f0:

  netfilter: nf_ct_ecache: fix crash with multiple containers, one shutting down (2012-07-09 10:53:19 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master

for you to fetch changes up to 51878010232aaac12822e219b94e89de54faa1ef:

  ipvs: fix oops in ip_vs_dst_event on rmmod (2012-07-11 09:00:47 +0900)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: fix oops in ip_vs_dst_event on rmmod

Lin Ming (1):
      ipvs: fix oops on NAT reply in br_nf context

Xiaotian Feng (1):
      ipvs: add missing lock in ip_vs_ftp_init_conn()

 include/net/ip_vs.h            | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 5 +++--
 net/netfilter/ipvs/ip_vs_ftp.c | 2 ++
 3 files changed, 6 insertions(+), 3 deletions(-)

