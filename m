From: Simon Horman <horms@verge.net.au>
Subject: Re: linux-next: Tree for Oct 1 (ipvs)
Date: Fri, 2 Oct 2015 09:45:49 +0900
Message-ID: <20151002004549.GA22640@verge.net.au>
References: <20151001165001.02d3ada5@canb.auug.org.au>
 <560D6CB6.5070904@infradead.org>
Mime-Version: 1.0
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <560D6CB6.5070904@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org

Hi Randy,

On Thu, Oct 01, 2015 at 10:26:14AM -0700, Randy Dunlap wrote:
> On 09/30/15 23:50, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20150930:
> > 
> 
> on x86_64:
> 
> ../net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_leave':
> ../net/netfilter/ipvs/ip_vs_core.c:584:6: error: implicit declaration of function 'ip_vs_addr_is_unicast' [-Werror=implicit-function-declaration]
>       ip_vs_addr_is_unicast(net, svc->af, &iph->daddr)) {
>       ^
> ../net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_out':
> ../net/netfilter/ipvs/ip_vs_core.c:1177:14: warning: unused variable 'net' [-Wunused-variable]
>   struct net *net = ipvs->net;

Thanks for reporting this problem.

I have the following patch queued up in the ipvs-next tree
and plan to send a pull request for it later today.

From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH] ipvs: Don't protect ip_vs_addr_is_unicast with CONFIG_SYSCTL

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
