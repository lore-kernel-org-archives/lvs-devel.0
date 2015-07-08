From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipvs: fix crash with sync protocol v0 and FTP
Date: Wed,  8 Jul 2015 08:31:33 +0300
Message-ID: <1436333493-20436-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

Fix crash in 3.5+ if FTP is used after switching
sync_version to 0.

Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

 Compiles also on 3.10.81, 3.12.44, 3.14.45, 3.18.16, 4.0.6, 4.1

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 19b9cce..150047c 100644
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
1.9.3

