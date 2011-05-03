From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-2.6] IPVS (Take II)
Date: Tue,  3 May 2011 16:05:14 +0900
Message-ID: <1304406316-15636-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git for-patrick
to get the following fix from Hans. They resolve some problems related
to his netns for IPVS work which was incorporated into 2.6.39-rc1.

The pull request is based on nf-2.6/master.

There are other less-pressing changes from Hans which
I plan to get you to pull into nf-next-2.6 once these
changes make it there (presumably via net-2.6 and then net-next-2.6).

Hans Schillstrom (2):
      IPVS: Change of socket usage to enable name space exit.
      IPVS: init and cleanup restructuring.

 include/net/ip_vs.h              |   17 +++++
 net/netfilter/ipvs/ip_vs_app.c   |   15 +----
 net/netfilter/ipvs/ip_vs_conn.c  |   12 +---
 net/netfilter/ipvs/ip_vs_core.c  |  102 ++++++++++++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_ctl.c   |  123 ++++++++++++++++++++++++++++++++------
 net/netfilter/ipvs/ip_vs_est.c   |   14 +----
 net/netfilter/ipvs/ip_vs_proto.c |   11 +---
 net/netfilter/ipvs/ip_vs_sync.c  |   65 +++++++++++---------
 8 files changed, 260 insertions(+), 99 deletions(-)
