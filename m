From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS
Date: Fri, 25 Feb 2011 11:43:29 +0900
Message-ID: <1298601812-8168-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Changli Gao <xiaosuo@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
go get the following changes by Changli.

      ipvs: use hlist instead of list
      ipvs: use enum to instead of magic numbers
      ipvs: unify the formula to estimate the overhead of processing connections

 include/net/ip_vs.h              |   16 +++++++++++-
 net/netfilter/ipvs/ip_vs_conn.c  |   52 +++++++++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_lblc.c  |   13 ++-------
 net/netfilter/ipvs/ip_vs_lblcr.c |   25 +++++-------------
 net/netfilter/ipvs/ip_vs_lc.c    |   18 +------------
 net/netfilter/ipvs/ip_vs_wlc.c   |   20 +-------------
 net/netfilter/ipvs/ip_vs_xmit.c  |   41 +++++++++++++++++++----------
 7 files changed, 84 insertions(+), 101 deletions(-)

