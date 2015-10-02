From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] ipvs: Don't protect ip_vs_addr_is_unicast with CONFIG_SYSCTL
Date: Fri,  2 Oct 2015 10:04:49 +0900
Message-ID: <1443747889-7725-2-git-send-email-horms@verge.net.au>
References: <1443747889-7725-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443747889-7725-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

I arranged the code so that the compiler can remove the unecessary bits
in ip_vs_leave when CONFIG_SYSCTL is unset, and removed an explicit
CONFIG_SYSCTL.

Unfortunately when rebasing my work on top of that of Alex Gartrell I
missed the fact that the newly added function ip_vs_addr_is_unicast was
surrounded by CONFIG_SYSCTL.

So remove the now unnecessary CONFIG_SYSCTL guards around
ip_vs_addr_is_unicast.  It is causing build failures today when
CONFIG_SYSCTL is not selected and any self respecting compiler will
notice that sysctl_cache_bypass is always false without CONFIG_SYSCTL
and not include the logic from the function ip_vs_addr_is_unicast in
the compiled code.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 37dd77a3d0fb..d08df435c2aa 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -547,7 +547,6 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	return cp;
 }
 
-#ifdef CONFIG_SYSCTL
 static inline int ip_vs_addr_is_unicast(struct net *net, int af,
 					union nf_inet_addr *addr)
 {
@@ -557,7 +556,6 @@ static inline int ip_vs_addr_is_unicast(struct net *net, int af,
 #endif
 	return (inet_addr_type(net, addr->ip) == RTN_UNICAST);
 }
-#endif
 
 /*
  *  Pass or drop the packet.
-- 
2.1.4
