From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 0/6] Fix sparse warnings for IPVS
Date: Wed, 17 Apr 2013 23:50:44 +0300
Message-ID: <1366231850-22188-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

	Fix sparse warnings found by kbuild test robot

Julian Anastasov (6):
  ipvs: properly dereference dest_dst in ip_vs_forget_dev
  ipvs: fix sparse warnings for ip_vs_conn listing
  ipvs: fix sparse warnings in lblc and lblcr
  ipvs: fix sparse warnings for sync msg size
  ipvs: fix sparse warnings for some parameters
  ipvs: fix the remaining sparse warnings in ip_vs_ctl.c

 include/net/ip_vs.h              |    8 +++---
 include/uapi/linux/ip_vs.h       |    4 +-
 net/netfilter/ipvs/ip_vs_conn.c  |   14 ++++-----
 net/netfilter/ipvs/ip_vs_core.c  |    3 +-
 net/netfilter/ipvs/ip_vs_ctl.c   |   55 +++++++++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c  |    4 +-
 8 files changed, 52 insertions(+), 40 deletions(-)

-- 
1.7.3.4

