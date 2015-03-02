From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS Enhancements for v4.1
Date: Mon,  2 Mar 2015 11:39:22 +0900
Message-ID: <1425263963-6660-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

please consider this enhancement from Marcelo Ricardo Leitner to IPVS for v4.1.
It allows rescheduling of new connections when port reuse is detected.

The following changes since commit 7f73b9f1ca7334eec0ff9a40e37ece92dd3e420f:

  netfilter: ipset: fix boolreturn.cocci warnings (2015-02-11 16:13:30 +0100)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.1

for you to fetch changes up to d752c364571743d696c2a54a449ce77550c35ac5:

  ipvs: allow rescheduling of new connections when port reuse is detected (2015-02-25 13:46:35 +0900)

----------------------------------------------------------------
Marcelo Ricardo Leitner (1):
      ipvs: allow rescheduling of new connections when port reuse is detected

 Documentation/networking/ipvs-sysctl.txt | 21 ++++++++++++++++++++
 include/net/ip_vs.h                      | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_core.c          | 33 ++++++++++++++++++++++++++++----
 net/netfilter/ipvs/ip_vs_ctl.c           |  8 ++++++++
 net/netfilter/ipvs/ip_vs_sync.c          | 21 ++++++++++++++++++--
 5 files changed, 88 insertions(+), 6 deletions(-)
