From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL] Third Round of IPVS Fixes for v3.16
Date: Tue, 22 Jul 2014 16:25:51 +0900
Message-ID: <1406013952-18522-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this third round of IPVS fixes for v3.16.

It includes one change from Alex Gartrell to:

* Maintain all DSCP and ECN bits for IPv6 tun forwarding
  This resolves an inconsistency between IPv4 and IPv6 behaviour.
  This behaviour was added when IPv6 support was added to IPVS
  in v2.6.27.

This pull request is for an unsigned, unannotated tag.
Please let me know if this doesn't work with your work flow.

The following changes since commit 2627b7e15c5064ddd5e578e4efd948d48d531a3f:

  ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack (2014-07-16 09:39:28 +0900)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes3-for-v3.16

for you to fetch changes up to 76f084bc10004b3050b2cff9cfac29148f1f6088:

  ipvs: Maintain all DSCP and ECN bits for ipv6 tun forwarding (2014-07-17 12:53:54 +0900)

----------------------------------------------------------------
Alex Gartrell (1):
      ipvs: Maintain all DSCP and ECN bits for ipv6 tun forwarding

 net/netfilter/ipvs/ip_vs_xmit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
