From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 0/6] Convert some GFP_ATOMIC allocations
Date: Fri, 13 Apr 2012 16:49:36 +0300
Message-ID: <1334324982-3143-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	Convert mostly schedulers and one place for timeout table.
Only one place is left: register_ip_vs_proto_netns. I hope
someone will fix it together with other changes.

Julian Anastasov (6):
  ipvs: timeout tables do not need GFP_ATOMIC allocation
  ipvs: SH scheduler does not need GFP_ATOMIC allocation
  ipvs: DH scheduler does not need GFP_ATOMIC allocation
  ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init
  ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init
  ipvs: WRR scheduler does not need GFP_ATOMIC allocation

 net/netfilter/ipvs/ip_vs_dh.c    |    2 +-
 net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 net/netfilter/ipvs/ip_vs_proto.c |    2 +-
 net/netfilter/ipvs/ip_vs_sh.c    |    2 +-
 net/netfilter/ipvs/ip_vs_wrr.c   |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

-- 
1.7.3.4

