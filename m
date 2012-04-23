From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL net] IPVS
Date: Mon, 23 Apr 2012 21:17:06 +0900
Message-ID: <1335183428-2585-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Sasha Levin <levinsasha928@gmail.com>

Hi Pablo,

please consider the following two changes for 3.4.  They are from Sasha
Levin and  resolve bugs on initialisation failure in IPVS.

The following changes since commit 6ba900676bec8baaf61aa2f85b7345c0e65774d9:

  netfilter: nf_conntrack: fix incorrect logic in nf_conntrack_init_net (2012-04-10 13:00:38 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git master

for you to fetch changes up to eb93daa9396acdcb9aea47ef125a60228f174deb:

  netfilter: ipvs: use GFP_KERNEL allocation where possible (2012-04-23 17:00:52 +0900)

----------------------------------------------------------------
Sasha Levin (2):
      netfilter: ipvs: Verify that IP_VS protocol has been registered
      netfilter: ipvs: use GFP_KERNEL allocation where possible

 net/netfilter/ipvs/ip_vs_proto.c |   29 +++++++++++++++++++----------
 1 file changed, 19 insertions(+), 10 deletions(-)
