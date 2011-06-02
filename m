From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL pablo/nf-2.6-updates] IPVS
Date: Thu,  2 Jun 2011 09:09:53 +0900
Message-ID: <1306973394-29504-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>

Hi Pablo, Hi Patrick,

Please consider pulling

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-2.6.git master

to get the following fix for IPVS from Julian. This is -sable material.

Julian Anastasov (1):
      ipvs: restore support for iptables SNAT

 net/netfilter/ipvs/ip_vs_core.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

My pull request is based on pablo/nf-2.6-updates revision
c74c0bfe0b61cf41a897c2444c038e0d3f600556:

  IPVS: bug in ip_vs_ftp, same list heaad used in all netns. (2011-05-27 13:37:46 +0200)
