From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2 1/2] ipvs: reset ipvs pointer in netns
Date: Wed, 25 Apr 2012 00:29:58 +0300
Message-ID: <1335302999-10702-2-git-send-email-ja@ssi.bg>
References: <1335302999-10702-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1335302999-10702-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	Make sure net->ipvs is reset on netns cleanup or failed
initialization. It is needed for IPVS applications to know that
IPVS core is not loaded in netns.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

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
1.7.3.4

