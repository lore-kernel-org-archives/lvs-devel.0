From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] ipvs: remove null test before kfree
Date: Wed, 16 Jul 2014 10:11:29 +0900
Message-ID: <1405473090-10432-2-git-send-email-horms@verge.net.au>
References: <1405473090-10432-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1405473090-10432-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Fabian Frederick <fabf@skynet.be>, Simon Horman <horms@verge.net.au>

From: Fabian Frederick <fabf@skynet.be>

Fix checkpatch warning:
WARNING: kfree(NULL) is safe this check is probably not required

Signed-off-by: Fabian Frederick <fabf@skynet.be>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index db80126..eadffb2 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -886,8 +886,7 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		cp = ip_vs_conn_new(param, daddr, dport, flags, dest, fwmark);
 		rcu_read_unlock();
 		if (!cp) {
-			if (param->pe_data)
-				kfree(param->pe_data);
+			kfree(param->pe_data);
 			IP_VS_DBG(2, "BACKUP, add new conn. failed\n");
 			return;
 		}
-- 
2.0.0
