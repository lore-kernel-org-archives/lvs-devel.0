From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next-2.6] IPVS
Date: Wed, 16 Feb 2011 15:04:50 +0900
Message-ID: <1297836293-5942-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Patrick Schaaf <netdev@bof.de>, Patrick McHardy <kaber@trash.net>

Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
go get:

	* Removal of unused ICMP code by Julian
	* More informative "no destination available" messages
	  by Patrick Schaaf
	* Fix to buffering of synchronisation messages
	  by Tinggong Wang and Julian

 include/net/ip_vs.h              |    2 ++
 net/netfilter/ipvs/ip_vs_core.c  |   28 +++-------------------------
 net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 net/netfilter/ipvs/ip_vs_lc.c    |    2 +-
 net/netfilter/ipvs/ip_vs_nq.c    |    2 +-
 net/netfilter/ipvs/ip_vs_rr.c    |    2 +-
 net/netfilter/ipvs/ip_vs_sched.c |   25 +++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_sed.c   |    2 +-
 net/netfilter/ipvs/ip_vs_sh.c    |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c  |    4 ++--
 net/netfilter/ipvs/ip_vs_wlc.c   |    2 +-
 net/netfilter/ipvs/ip_vs_wrr.c   |   14 ++++++++------
 13 files changed, 48 insertions(+), 41 deletions(-)

