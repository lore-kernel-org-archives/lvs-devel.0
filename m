From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipvs: fix ipv6 hook registration for local replies
Date: Fri, 22 Aug 2014 17:53:41 +0300
Message-ID: <1408719221-8042-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Chris J Arges <chris.j.arges@canonical.com>

commit fc604767613b6d2036cdc35b660bc39451040a47
("ipvs: changes for local real server") from 2.6.37
introduced DNAT support to local real server but the
IPv6 LOCAL_OUT handler ip_vs_local_reply6() is
registered incorrectly as IPv4 hook causing any outgoing
IPv4 traffic to be dropped depending on the IP header values.

Chris tracked down the problem to CONFIG_IP_VS_IPV6=y
Bug report: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1349768

Reported-by: Chris J Arges <chris.j.arges@canonical.com>
Tested-by: Chris J Arges <chris.j.arges@canonical.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e683675..5c34e8d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1906,7 +1906,7 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 	{
 		.hook		= ip_vs_local_reply6,
 		.owner		= THIS_MODULE,
-		.pf		= NFPROTO_IPV4,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_NAT_DST + 1,
 	},
-- 
1.9.0

