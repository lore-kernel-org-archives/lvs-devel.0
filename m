From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH nf-next] ipvs: fix uninitialized variable warning
Date: Mon, 30 Mar 2020 11:20:15 +0800
Message-ID: <1585538415-27583-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

If outer_proto is not set, GCC warning as following:

In file included from net/netfilter/ipvs/ip_vs_core.c:52:
net/netfilter/ipvs/ip_vs_core.c: In function 'ip_vs_in_icmp':
include/net/ip_vs.h:233:4: warning: 'outer_proto' may be used uninitialized in this function [-Wmaybe-uninitialized]
 233 |    printk(KERN_DEBUG pr_fmt(msg), ##__VA_ARGS__); \
     |    ^~~~~~
net/netfilter/ipvs/ip_vs_core.c:1666:8: note: 'outer_proto' was declared here
1666 |  char *outer_proto;
     |        ^~~~~~~~~~~

Fixes: 73348fed35d0 ("ipvs: optimize tunnel dumps for icmp errors")
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d2ac530..aa6a603 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1663,7 +1663,7 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	unsigned int offset, offset2, ihl, verdict;
 	bool tunnel, new_cp = false;
 	union nf_inet_addr *raddr;
-	char *outer_proto;
+	char *outer_proto = "IPIP";
 
 	*related = 1;
 
@@ -1723,7 +1723,6 @@ static int ipvs_gre_decap(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		if (cih == NULL)
 			return NF_ACCEPT; /* The packet looks wrong, ignore */
 		tunnel = true;
-		outer_proto = "IPIP";
 	} else if ((cih->protocol == IPPROTO_UDP ||	/* Can be UDP encap */
 		    cih->protocol == IPPROTO_GRE) &&	/* Can be GRE encap */
 		   /* Error for our tunnel must arrive at LOCAL_IN */
-- 
1.8.3.1



