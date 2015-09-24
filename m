From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 43/84] ipvs: Pass ipvs not net to ip_vs_sync_net_init
Date: Thu, 24 Sep 2015 09:52:28 +0900
Message-ID: <1443055989-1306-44-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 net/netfilter/ipvs/ip_vs_sync.c | 4 +---
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b10b337ce974..47a4cddb7c33 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1328,7 +1328,7 @@ int ip_vs_control_net_init(struct net *net);
 int ip_vs_protocol_net_init(struct net *net);
 int ip_vs_app_net_init(struct net *net);
 int ip_vs_conn_net_init(struct net *net);
-int ip_vs_sync_net_init(struct net *net);
+int ip_vs_sync_net_init(struct netns_ipvs *ipvs);
 void ip_vs_conn_net_cleanup(struct net *net);
 void ip_vs_app_net_cleanup(struct net *net);
 void ip_vs_protocol_net_cleanup(struct net *net);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a8128b06f73b..5a5a6d63b3d9 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2087,7 +2087,7 @@ static int __net_init __ip_vs_init(struct net *net)
 	if (ip_vs_conn_net_init(net) < 0)
 		goto conn_fail;
 
-	if (ip_vs_sync_net_init(net) < 0)
+	if (ip_vs_sync_net_init(ipvs) < 0)
 		goto sync_fail;
 
 	printk(KERN_INFO "IPVS: Creating netns size=%zu id=%d\n",
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index e3f72cbc1204..11b4f17e2e1a 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -2007,10 +2007,8 @@ int stop_sync_thread(struct netns_ipvs *ipvs, int state)
 /*
  * Initialize data struct for each netns
  */
-int __net_init ip_vs_sync_net_init(struct net *net)
+int __net_init ip_vs_sync_net_init(struct netns_ipvs *ipvs)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
