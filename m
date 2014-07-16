From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf] Second Round of IPVS Fixes for v3.16
Date: Wed, 16 Jul 2014 09:56:07 +0900
Message-ID: <1405472168-25192-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Hi Pablo,

Please consider this IPVS fix for v3.16.

It resolves a problem that was introduced in v3.0.

I would like this fix considered for -stable and I have checked that it
applies cleanly on top of v3.15.5, v3.14.12, v3.12.24, v3.10.48,
v3.4.98 and v3.2.61.


The following changes since commit ce355e209feb030945dae4c358c02f29a84f3f8b:

  netfilter: nf_tables: 64bit stats need some extra synchronization (2014-07-14 12:00:17 +0200)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs.git tags/ipvs-fixes2-for-v3.16

for you to fetch changes up to 2627b7e15c5064ddd5e578e4efd948d48d531a3f:

  ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack (2014-07-16 09:39:28 +0900)

----------------------------------------------------------------
Fix for crash due to spurious call to ip_vs_conn_drop_conntrack()

This resolves a big introduced in v3.0 by
8f4e0a18682d91 ("IPVS netns exit causes crash in conntrack")

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack

 net/netfilter/ipvs/ip_vs_conn.c | 1 -
 1 file changed, 1 deletion(-)
