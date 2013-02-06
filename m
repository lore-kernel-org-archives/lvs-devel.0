From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS fixes #2
Date: Wed,  6 Feb 2013 10:24:37 +0900
Message-ID: <1360113878-31051-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Daniel Borkmann <dborkman@redhat.com>

Hi Pablo,

Another fix. This one seems suitable for stable all the way back to
2.6.34. I suspect this change may not apply cleanly all the way back there.
Please let me know if I should prepare some backports.

----------------------------------------------------------------
The following changes since commit b425df4cdd953a400d814b4474c9d3ec04481858:

  ipvs: freeing uninitialized pointer on error (2013-01-28 10:14:37 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v3.8

for you to fetch changes up to 4b47bc9a9e69141ed3a854c57601f548e82c78ba:

  ipvs: sctp: fix checksumming on snat and dnat handlers (2013-02-06 09:56:50 +0900)

----------------------------------------------------------------
Second fix for IPVS targeted at 3.8

SCTP checksumming correction by Daniel Borkmann

This appears to have been present since SCTP support was added to IPVS
and is thus present since 2.6.34.

----------------------------------------------------------------
Daniel Borkmann (1):
      ipvs: sctp: fix checksumming on snat and dnat handlers

 net/netfilter/ipvs/ip_vs_proto_sctp.c |   35 ++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 18 deletions(-)
