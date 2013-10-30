From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL] Second Round of IPVS updates for v3.13
Date: Wed, 30 Oct 2013 10:11:24 +0900
Message-ID: <1383095486-5215-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Daniel Borkmann <dborkman@redhat.com>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this second round of updates or IPVS for v3.13,
based on nf-next.

I realise this is rather late in the game as the v3.13 merge window
is just round the corner. So please let me know if you would
like me to handle things a different way.

There are two SCTP changes by Daniel Borkman.

* Correct verdict assignments in sctp_conn_schedule

  This is a bug fix for incorrect handling of the error case
  where skb_header_pointer() fails.

  It appears that this problem has been present since SCTP was added
  to IPVS in v2.6.34.

  I would like this change considered for -stable all the way back
  to v2.6.34. I have checked and it cherry-picks cleanly on top
  of v3.12-rc7 and v3.11. And seems to apply with some trivial merge conflicts
  on top of v3.4, v3.2 and v3.6.34. I am happy to supply versions of
  the patch that resolve those conflicts.

* Do not recalculate SCTP checksum if ports don't change

  This is an enhancement which should lead to increased performance
  in some cases.


The following changes since commit 6b8dbcf2c44fd7aa716560d04e9857c870bd510c:

  bridge: netfilter: orphan skb before invoking ip netfilter hooks (2013-10-27 21:44:33 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v3.13

for you to fetch changes up to 97203abe6bc41ee020f37c902bd1a761157f22c1:

  net: ipvs: sctp: do not recalc sctp csum when ports didn't change (2013-10-30 09:48:16 +0900)

----------------------------------------------------------------
Second Round of IPVS updates for v3.13

Some SCTP changes by Daniel Borkman.

* Correct verdict assignments in sctp_conn_schedule

  This is a bug fix for incorrect handling of the error case
  where skb_header_pointer() fails.

  It appears that this problem has been present since SCTP was added
  to IPVS in v2.6.34.

* Do not recalculate SCTP checksum if ports don't change

  This is an enhancement which should lead to increased performance
  in some cases.

----------------------------------------------------------------
Daniel Borkmann (2):
      net: ipvs: sctp: add missing verdict assignments in sctp_conn_schedule
      net: ipvs: sctp: do not recalc sctp csum when ports didn't change

 net/netfilter/ipvs/ip_vs_proto_sctp.c | 48 +++++++++++++++++++++++++++++------
 1 file changed, 40 insertions(+), 8 deletions(-)
