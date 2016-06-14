From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH 0/5] ipvs: fix backup sync daemon with IPv6, and minor updates
Date: Tue, 14 Jun 2016 02:43:28 +0100
Message-ID: <1465868613-26146-1-git-send-email-quentin@armitage.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Quentin Armitage <quentin@armitage.org.uk>

This series of patches arise from discovering that:
ipvsadm --start-daemon backup --mcast-group IPv6_address ...
would always fail.

The first patch resolves the problem. The second and third patches are
optimizations that were noticed while investigating the original problem.
The fourth patch adds a lock which appears to have been omitted, and the
final patch adds the recently added sync daemon multicast parameters to
the log messages that are written when the sync daemons start.

Quentin Armitage (5):
  ipvs: Enable setting IPv6 multicast address for ipvs sync daemon
    backup
  ipvs: Stop calling __dev_get_by_name() repeatedly when starting sync
    daemon
  ipvs: Don't check result < 0 after setting result = 0
  ipvs: Lock socket before setting SK_CAN_REUSE
  ipvs: log additional sync daemon parameters

 net/netfilter/ipvs/ip_vs_sync.c |  107 ++++++++++++++++++++-------------------
 1 files changed, 54 insertions(+), 53 deletions(-)

-- 
1.7.7.6

