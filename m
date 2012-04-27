From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/5] ipvs: reset ipvs pointer in netns
Date: Fri, 27 Apr 2012 09:53:56 +0900
Message-ID: <1335488039-13471-3-git-send-email-horms@verge.net.au>
References: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335488039-13471-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Make sure net->ipvs is reset on netns cleanup or failed
initialization. It is needed for IPVS applications to know that
IPVS core is not loaded in netns.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 2555816..260b9ef 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1924,6 +1924,7 @@ protocol_fail:
 control_fail:
 	ip_vs_estimator_net_cleanup(net);
 estimator_fail:
+	net->ipvs = NULL;
 	return -ENOMEM;
 }
 
@@ -1936,6 +1937,7 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 	ip_vs_control_net_cleanup(net);
 	ip_vs_estimator_net_cleanup(net);
 	IP_VS_DBG(2, "ipvs netns %d released\n", net_ipvs(net)->gen);
+	net->ipvs = NULL;
 }
 
 static void __net_exit __ip_vs_dev_cleanup(struct net *net)
-- 
1.7.9.5

