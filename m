From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH v3 0/4] ipvs: fix backup sync daemon with IPv6, and minor updates
Date: Wed, 15 Jun 2016 22:42:40 +0100
Message-ID: <1466026964-14114-1-git-send-email-quentin@armitage.org.uk>
References: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
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

v2 fixes a compile error in a debug message identified by kbuild test
robot. Now compiles with CONFIG_IP_VS_DEBUG enabled. Patch 2/5 is modified
to correct the problem, and patch 3/5 is modifed to apply with the
modified patch 2/5.

v3 incorporates changes suggested by Julian Anastasov.
Patch 1 now sets 'sock->sk->sk_bound_dev_if = ifindex' rather than setting
        sin6_scope_id. Also remove the locks since unnecessary.
Patch 3 shortens the logged message in order not to exceed 80-char limit.
Patch 4 Removed, the locks aren't necessary
Patch 5 No longer changes indentation of existing pr_info. Also removes <>
        around commit IDs in commit description.
Patches 1, 2, 3, 5 are updated to resolve coding style warnings, and all
	pass with 0 errors, warnings and checks.
Patch 5 now becomes patch 4.

The changes have all been tested and work as expected.

Quentin Armitage (4):
  ipvs: Enable setting IPv6 multicast address for ipvs
  ipvs: Stop calling __dev_get_by_name() repeatedly when starting sync
    daemon
  ipvs: Don't check result < 0 after setting result = 0
  ipvs: log additional sync daemon parameters

 net/netfilter/ipvs/ip_vs_sync.c |  105 +++++++++++++++++++--------------------
 1 files changed, 52 insertions(+), 53 deletions(-)

-- 
1.7.7.6

