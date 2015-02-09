From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf] ipvs: fix inability to remove a mixed-family RS
Date: Mon,  9 Feb 2015 14:25:08 +0900
Message-ID: <1423459508-15517-2-git-send-email-horms@verge.net.au>
References: <1423459508-15517-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1423459508-15517-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Alexey Andriyanov <alan@al-an.info>, Simon Horman <horms@verge.net.au>

From: Alexey Andriyanov <alan@al-an.info>

The current code prevents any operation with a mixed-family dest
unless IP_VS_CONN_F_TUNNEL flag is set. The problem is that it's impossible
for the client to follow this rule, because ip_vs_genl_parse_dest does
not even read the destination conn_flags when cmd = IPVS_CMD_DEL_DEST
(need_full_dest = 0).

Also, not every client can pass this flag when removing a dest. ipvsadm,
for example, does not support the "-i" command line option together with
the "-d" option.

This change disables any checks for mixed-family on IPVS_CMD_DEL_DEST command.

Signed-off-by: Alexey Andriyanov <alan@al-an.info>
Fixes: bc18d37f676f ("ipvs: Allow heterogeneous pools now that we support them")
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b8295a4..fdcda8b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3399,7 +3399,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		if (udest.af == 0)
 			udest.af = svc->af;
 
-		if (udest.af != svc->af) {
+		if (udest.af != svc->af && cmd != IPVS_CMD_DEL_DEST) {
 			/* The synchronization protocol is incompatible
 			 * with mixed family services
 			 */
-- 
2.1.4

