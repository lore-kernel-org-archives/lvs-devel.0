From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS
Date: Wed,  7 Dec 2011 17:07:02 +0900
Message-ID: <1323245223-13646-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Pablo,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
to obtain and enhancement to the SH scheduelr from Michael Maixim.

Michael Maxim (1):
      IPVS: Modify the SH scheduler to use weights

 net/netfilter/ipvs/Kconfig    |   15 +++++++++++++++
 net/netfilter/ipvs/ip_vs_sh.c |   20 ++++++++++++++++++--
 2 files changed, 33 insertions(+), 2 deletions(-)
