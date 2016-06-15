From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 0/5] ipvs: fix backup sync daemon with IPv6, and minor
 updates
Date: Wed, 15 Jun 2016 08:21:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1606150815500.2828@ja.home.ssi.bg>
References: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Armitage <quentin@armitage.org.uk>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org


	Hello,

On Tue, 14 Jun 2016, Quentin Armitage wrote:

> This series of patches arise from discovering that:
> ipvsadm --start-daemon backup --mcast-group IPv6_address ...
> would always fail.
> 
> The first patch resolves the problem. The second and third patches are
> optimizations that were noticed while investigating the original problem.
> The fourth patch adds a lock which appears to have been omitted, and the
> final patch adds the recently added sync daemon multicast parameters to
> the log messages that are written when the sync daemons start.
> 
> v2 fixes a compile error in a debug message identified by kbuild test robot.
> Now compiles with CONFIG_IP_VS_DEBUG enabled. Patch 2/5 is modified to correct
> the problem, and patch 3/5 is modifed to apply with the modified patch 2/5.
> 
> Quentin Armitage (5):
>   ipvs: Enable setting IPv6 multicast address for ipvs sync daemon
>     backup
>   ipvs: Stop calling __dev_get_by_name() repeatedly when starting sync
>     daemon
>   ipvs: Don't check result < 0 after setting result = 0
>   ipvs: Lock socket before setting SK_CAN_REUSE
>   ipvs: log additional sync daemon parameters
> 
>  net/netfilter/ipvs/ip_vs_sync.c |  104 +++++++++++++++++++-------------------
>  1 files changed, 52 insertions(+), 52 deletions(-)
> 
> -- 
> 1.7.7.6

	Thanks for catching this bug. Following are my
comments for the patches:

Patch 1:

	I missed the fact that link-local addresses (ffx2) require
binding to ifindex due to __ipv6_addr_needs_scope_id check,
I tested only with a ff05 address. BTW, ff01 is a node-local
address (loopback), you should not use it for IPVS.

	Instead of directly writing into sin6_scope_id we can use
'sock->sk->sk_bound_dev_if = ifindex;' before bind(), it will
work for v4 and v6. Let me know if such solution works.

	You have to send this patch as a bugfix, it should
apply to the net tree and later will go to stable trees (4.3+),
i.e. 4.4, 4.5, 4.6 and 4.7, I don't see stable 4.3 in
https://www.kernel.org/. You should mention in commit message
that this patch is a fix to specific commit (check
Documentation/SubmittingPatches):

Fixes: d33288172e72 ("ipvs: add more mcast parameters for the sync daemon")

	The other patches will go to the net-next tree in
separate patchset but I see little fuzz if patch 2 is applied
without patch 1, so may be this patchset should wait the first
patch to appear in net-next kernel.

Patch 2: looks OK

Patch 3: looks OK

	It was done this way to not exceed the 80-char limit.
May be you can reduce the message for the same reason.

Patch 4: looks OK

	Before bind() such operations should be safe without locks.

Patch 5:

	No need of <> for the commit IDs.

	The indentation of existing pr_info in both cases
should not be changed.

	Patches 1, 2, 3 have coding style warnings from checkpatch
that can be fixed, you can check them in this way:

scripts/checkpatch.pl --strict /tmp/file.patch

Regards

--
Julian Anastasov <ja@ssi.bg>
