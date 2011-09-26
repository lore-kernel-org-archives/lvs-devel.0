From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL net-next] IPVS
Date: Mon, 26 Sep 2011 18:05:33 +0900
Message-ID: <1317027938-22053-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>

Hi,

with all the excitement of kernel.org being offline and a bunch of trees
likewise being offline I am a little unsure who should take this pull
request which is based on the current net-next tree. But I guess it should
be Patrick, Pablo or Dave.

The following changes since commit 7777de9af54a1402c79bf7663b38ff5ba308dd45:

  qlcnic: Change CDRP function (2011-09-23 14:23:59 -0400)

are available in the git repository at:
  git://github.com/horms/ipvs-next.git master

Krzysztof Wilczynski (1):
      ipvs: Expose ip_vs_ftp module parameters via sysfs.

Simon Horman (4):
      IPVS: Add documentation for new sysctl entries
      IPVS: Remove unused parameter from ip_vs_confirm_conntrack()
      IPVS: Remove unused return value of protocol state transitions
      IPVS: Removed unused variables

 Documentation/networking/ipvs-sysctl.txt |   52 +++++++++++++++++++++++++++++-
 include/net/ip_vs.h                      |   11 +++---
 net/netfilter/ipvs/ip_vs_core.c          |   13 +++----
 net/netfilter/ipvs/ip_vs_ctl.c           |    4 --
 net/netfilter/ipvs/ip_vs_ftp.c           |    5 ++-
 net/netfilter/ipvs/ip_vs_nfct.c          |    2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c    |   14 ++------
 net/netfilter/ipvs/ip_vs_proto_tcp.c     |    6 +--
 net/netfilter/ipvs/ip_vs_proto_udp.c     |    5 +--
 net/netfilter/ipvs/ip_vs_xmit.c          |    2 +-
 10 files changed, 75 insertions(+), 39 deletions(-)
