From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] IPVS Fixes for v3.14
Date: Tue,  4 Feb 2014 21:34:20 +0900
Message-ID: <1391517261-27222-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider the following fixes for IPVS for v3.14.

It consists of a fix for AF assingment by Michal Kubecek.

I believe this problem is present all the way back to v2.6.30, however, the
change only applies as far back as v3.10.  Please let me know if you would
like me to make some patches for older -stable versions.


The following changes since commit d922e1cb1ea17ac7f0a5c3c2be98d4bd80d055b8:

  net: Document promote_secondaries (2014-01-27 20:39:21 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes-for-v3.14

for you to fetch changes up to 2a971354e74f3837d14b9c8d7f7983b0c9c330e4:

  ipvs: fix AF assignment in ip_vs_conn_new() (2014-02-04 21:13:47 +0900)

----------------------------------------------------------------
IPVS Fixes for v3.14

Correction AF assignment by Michal Kubecek.
This resolves a problem whereby only the first 4 bytes of an IPv6
destination may be copied for a fwmark virtual service.

This problem appears to have been introduced by
be8be9eccbf2d908 "ipvs: Fix IPv4 FWMARK virtual services"
in 2.6.30.

----------------------------------------------------------------
Michal Kubecek (1):
      ipvs: fix AF assignment in ip_vs_conn_new()

 net/netfilter/ipvs/ip_vs_conn.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)
