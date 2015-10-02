From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] Third Round of IPVS Updates for v4.4
Date: Fri,  2 Oct 2015 10:04:48 +0900
Message-ID: <1443747889-7725-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this build fix from Eric Biederman which resolves
a build problem introduced in is excellent work to cleanup IPVS which
you recently pulled: its queued up for v4.4 so no need to worry
about earlier kernel versions.

I have another minor cleanup, to fix a build warning, pending.
However, I wanted to send this one to you now as its hit nf-next,
net-next and in turn next, and a slow trickle of bug reports are appearing.


The following changes since commit 4bf1b54f9df7ced4869f7dfd0bdf5eb22aa98447:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next (2015-09-29 21:46:21 -0700)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs3-for-v4.4

for you to fetch changes up to b59f2e31b8abda3d63c53ea7672a219639ded61b:

  ipvs: Don't protect ip_vs_addr_is_unicast with CONFIG_SYSCTL (2015-10-01 15:05:15 +0900)

----------------------------------------------------------------
Eric W. Biederman (1):
      ipvs: Don't protect ip_vs_addr_is_unicast with CONFIG_SYSCTL

 net/netfilter/ipvs/ip_vs_core.c | 2 --
 1 file changed, 2 deletions(-)
