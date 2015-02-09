From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS Fixes for v3.20
Date: Mon,  9 Feb 2015 14:25:07 +0900
Message-ID: <1423459508-15517-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this fix for v3.20

This patch prevents the kernel getting into a situation whereby a
real-server may not be removed from a heterogeneous IPVS virtual server.

This problem was introduced by  bc18d37f676f ("ipvs: Allow heterogeneous
pools now that we support them") in v3.18. This patch seems appropriate
for stable and I have checked that it applies cleanly to both v3.19 and
v3.18.6.


The following changes since commit 42b5212fee4f57907e9415b18fe19c13e65574bc:

  xen-netback: stop the guest rx thread after a fatal error (2015-02-02 19:39:04 -0800)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.20

for you to fetch changes up to dd3733b3e798daf778a1ec08557f388f00fdc2f6:

  ipvs: fix inability to remove a mixed-family RS (2015-02-09 14:13:30 +0900)

----------------------------------------------------------------
Alexey Andriyanov (1):
      ipvs: fix inability to remove a mixed-family RS

 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
