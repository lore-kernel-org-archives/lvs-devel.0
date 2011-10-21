From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS
Date: Fri, 21 Oct 2011 10:33:01 +0900
Message-ID: <1319160783-28422-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>

Hi Pablo,

please consider pulling the following to get compile fix
and cleanup patches from Krzysztof Wilczynski.

The following changes since commit 2ca5b853f1dd81c605ddc8a55e06bdad85636597:

  netfilter: export NAT definitions through linux/netfilter_ipv4/nf_nat.h (2011-10-11 03:32:34 +0200)

are available in the git repository at:
  git://github.com/horms/ipvs-next.git master

Krzysztof Wilczynski (2):
      ipvs: Remove unused variable "cs" from ip_vs_leave function.
      ipvs: Fix compilation error in ip_vs.h for ip_vs_confirm_conntrack function.

 include/net/ip_vs.h             |    2 +-
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)
