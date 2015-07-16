From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf 5/6] ipvs: fix crash with sync protocol v0 and FTP
Date: Thu, 16 Jul 2015 11:14:12 +0900
Message-ID: <1437012853-7318-6-git-send-email-horms@verge.net.au>
References: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1437012853-7318-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Fix crash in 3.5+ if FTP is used after switching
sync_version to 0.

Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index b08ba9538d12..d99ad93eb855 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -612,7 +612,7 @@ static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp,
 			pkts = atomic_add_return(1, &cp->in_pkts);
 		else
 			pkts = sysctl_sync_threshold(ipvs);
-		ip_vs_sync_conn(net, cp->control, pkts);
+		ip_vs_sync_conn(net, cp, pkts);
 	}
 }
 
-- 
2.1.4
