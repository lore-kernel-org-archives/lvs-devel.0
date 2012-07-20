From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 0/2] Changes for PMTU Discovery
Date: Fri, 20 Jul 2012 11:59:51 +0300
Message-ID: <1342774793-29234-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	This patchset implements PMTU Discovery for TUN
packets and option to disable it.

Julian Anastasov (2):
  ipvs: implement passive PMTUD for IPIP packets
  ipvs: add pmtu_disc option to disable IP DF for TUN packets

 include/net/ip_vs.h             |   11 +++++
 net/netfilter/ipvs/ip_vs_core.c |   76 ++++++++++++++++++++++++++++++++++-
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++
 net/netfilter/ipvs/ip_vs_xmit.c |   83 ++++++++++++++++++++++++++------------
 4 files changed, 149 insertions(+), 29 deletions(-)

-- 
1.7.3.4

