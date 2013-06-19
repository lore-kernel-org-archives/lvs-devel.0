From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS fix for v3.10
Date: Wed, 19 Jun 2013 10:56:01 +0900
Message-ID: <1371606963-30548-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

I realise this is rather late in the cycle, so please feel free
to push back on this. We can add it to v3.11 and then -stable.

This fix appears to resolve a long-standing problem that has
existed since SCTP support was added to IPVS in v2.6.32.
I believe it is relevant to -stable all the way back until then.

The following changes since commit b396966c4688522863572927cb30aa874b3ec504:

  netfilter: xt_TCPMSS: Fix missing fragmentation handling (2013-06-12 11:06:19 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.10

for you to fetch changes up to 06f3d7f973ec04290d86b7dd91b48d38d90433dc:

  ipvs: SCTP ports should be writable in ICMP packets (2013-06-19 09:53:52 +0900)

----------------------------------------------------------------
IPVS fix for v3.10

Correct long standing bug in treatment of SCTP
when it it is embeded in ICMP from a client.

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: SCTP ports should be writable in ICMP packets

 net/netfilter/ipvs/ip_vs_core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

-- 
1.8.2.1

