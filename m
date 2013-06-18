From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 0/3] SCTP Changes for IPVS
Date: Tue, 18 Jun 2013 10:08:05 +0300
Message-ID: <1371539288-5036-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	This patchset contains changes for SCTP.
The first patch adds SCTP protocol when making
protocols writable for ICMP. It can be classified as
bugfix.

	The second patch is a rewrite of the SCTP state
table. It changes the state names and the number and order
of states which is a incompatibility problem for SYNC but
I guess it is not so critical.

	Last patch adds fine tuning for SCTP states
during dropentry processing.

Julian Anastasov (3):
  ipvs: SCTP ports should be writable in ICMP packets
  ipvs: replace the SCTP state machine
  ipvs: drop SCTP connections depending on state

 include/net/ip_vs.h                   |   21 +-
 net/netfilter/ipvs/ip_vs_conn.c       |   12 +
 net/netfilter/ipvs/ip_vs_core.c       |    3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  854 ++++++---------------------------
 net/netfilter/ipvs/ip_vs_sync.c       |    7 +-
 5 files changed, 182 insertions(+), 715 deletions(-)

-- 
1.7.3.4

