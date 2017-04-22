From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: explicitly forbid ipv6 service/dest creation if
 ipv6 mod is disabled
Date: Sat, 22 Apr 2017 14:16:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1704221355290.1974@ja.home.ssi.bg>
References: <2a5c88ca5670baade900e2b1f05a0dcc9927a29d.1492681122.git.pabeni@redhat.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <2a5c88ca5670baade900e2b1f05a0dcc9927a29d.1492681122.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paolo Abeni <pabeni@redhat.com>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org


	Hello,

On Thu, 20 Apr 2017, Paolo Abeni wrote:

> When creating a new ipvs service, ipv6 addresses are always accepted
> if CONFIG_IP_VS_IPV6 is enabled. On dest creation the address family
> is not explicitly checked.
> 
> This allows the user-space to configure ipvs services even if the
> system is booted with ipv6.disable=1. On specific configuration, ipvs
> can try to call ipv6 routing code at setup time, causing the kernel to
> oops due to fib6_rules_ops being NULL.
> 
> This change addresses the issue adding a check for the ipv6
> module being enabled while validating ipv6 service operations and
> adding the same validation for dest operations.
> 
> According to git history, this issue is apparently present since
> the introduction of ipv6 support, and the oops can be triggered
> since commit 09571c7ae30865ad ("IPVS: Add function to determine
> if IPv6 address is local")
> 
> Fixes: 09571c7ae30865ad ("IPVS: Add function to determine if IPv6 address is local")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

	Looks good to me but I see two places that can benefit
from such check:

- in ip_vs_genl_new_daemon() if we do not want to create IPv6 sockets
for the sync protocol in make_send_sock() and make_receive_sock().
Not sure if this can lead to crashes.

- in ip_vs_proc_sync_conn() if we do not want backup server to accept 
IPv6 conns because they may be created even when dests are missing.
We may use retc = 10 there. Not fatal but may eat memory for
conns that will not be used.

Regards
