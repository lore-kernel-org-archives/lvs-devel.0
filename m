From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL 0/2] IPVS enhancement for v3.12
Date: Wed,  7 Aug 2013 17:40:27 +0900
Message-ID: <1375864829-19840-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider the following IPVS enhancement for v3.12.

It looks like v3.12 is going to be pretty quiet for IPVS
as at this stage I'm not expecting anything more than a few more cleanup
patches. And I'm not even sure if they will come through.


The following changes since commit d8b3bfc253d8063fcce9c447ecc4cf3b1735b13a:

  netfilter: tproxy: fix build with IP6_NF_IPTABLES=n (2013-08-05 12:57:38 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.12

for you to fetch changes up to 54e35cc52346149a7bce8a2f622e215ed17bb56d:

  ipvs: ip_vs_sh: ip_vs_sh_get_port: check skb_header_pointer for NULL (2013-08-07 08:57:57 +0900)

----------------------------------------------------------------
IPVS enhancement for v3.12

* NULL pointer check in ip_vs_sh_get_port()
  - This sounds worse than it is, it seems to be only a theoretical problem

* Whitepsace cleanup

----------------------------------------------------------------
Daniel Borkmann (1):
      ipvs: ip_vs_sh: ip_vs_sh_get_port: check skb_header_pointer for NULL

Dragos Foianu (1):
      ipvs: fixed spacing at for statements

 net/netfilter/ipvs/ip_vs_lblcr.c | 8 ++++----
 net/netfilter/ipvs/ip_vs_sh.c    | 6 ++++++
 2 files changed, 10 insertions(+), 4 deletions(-)
