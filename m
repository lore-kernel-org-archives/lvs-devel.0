From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-2.6] IPVS
Date: Thu, 31 Mar 2011 10:32:14 +0900
Message-ID: <1301535135-4288-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick
to get the following fix from Hans.

I have based this patch on net-2.6/master as nf-2.6/master seems a little
out of date (i.e. pre 2.6.39-rc1). Please let me know if you would
prefer me to use a different base. Alternatively, feel free to apply
the single patch by hand.

Hans Schillstrom (1):
      IPVS Bug, Null ptr in ip_vs_ctl.c ip_vs_genl_dump_daemons().

 include/net/ip_vs.h            |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
