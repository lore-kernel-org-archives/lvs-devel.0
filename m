From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS build fixes and clean-ups
Date: Tue,  1 Feb 2011 11:14:11 +1100
Message-ID: <1296519255-10602-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>

Hi,

This short patch series addresses two linux-next build problems
raised by Randy Dunlap:

* net/netfilter/ipvs/ip_vs_core.c:1891: warning: format '%lu' expects type 'long unsigned int', but argument 2 has type 'unsigned int'
* ERROR: "unregister_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko]
  ERROR: "register_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!

The remainder of the changset is cleanups that I noticed along the way.

The changes are available at
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master

They are currently compile-tested only.

 include/net/ip_vs.h              |    2 --
 net/netfilter/ipvs/ip_vs_core.c  |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c   |   17 +++++++++--------
 net/netfilter/ipvs/ip_vs_lblc.c  |   20 ++++++++++----------
 net/netfilter/ipvs/ip_vs_lblcr.c |   20 ++++++++++----------
 5 files changed, 30 insertions(+), 31 deletions(-)
