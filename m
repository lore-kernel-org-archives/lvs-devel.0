From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 44/84] ipvs: Pass ipvs not net to ip_vs_sync_net_cleanup
Date: Sun, 20 Sep 2015 01:23:00 -0500
Message-ID: <1442730220-32458-44-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_core.c | 5 +++--
 net/netfilter/ipvs/ip_vs_sync.c | 3 +--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 47a4cddb7c33..f3ddf7696d68 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1334,7 +1334,7 @@ void ip_vs_app_net_cleanup(struct net *net);
 void ip_vs_protocol_net_cleanup(struct net *net);
 void ip_vs_control_net_cleanup(struct net *net);
 void ip_vs_estimator_net_cleanup(struct net *net);
-void ip_vs_sync_net_cleanup(struct net *net);
+void ip_vs_sync_net_cleanup(struct netns_ipvs *ipvs);
 void ip_vs_service_net_cleanup(struct netns_ipvs *ipvs);
 
 /* IPVS application functions
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5a5a6d63b3d9..cae395fc6523 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2128,10 +2128,11 @@ static void __net_exit __ip_vs_cleanup(struct net *net)
 
 static void __net_exit __ip_vs_dev_cleanup(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	EnterFunction(2);
-	net_ipvs(net)->enable = 0;	/* Disable packet reception */
+	ipvs->enable = 0;	/* Disable packet reception */
 	smp_wmb();
-	ip_vs_sync_net_cleanup(net);
+	ip_vs_sync_net_cleanup(ipvs);
 	LeaveFunction(2);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 11b4f17e2e1a..803001a45aa1 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -2015,10 +2015,9 @@ int __net_init ip_vs_sync_net_init(struct netns_ipvs *ipvs)
 	return 0;
 }
 
-void ip_vs_sync_net_cleanup(struct net *net)
+void ip_vs_sync_net_cleanup(struct netns_ipvs *ipvs)
 {
 	int retc;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	mutex_lock(&ipvs->sync_mutex);
 	retc = stop_sync_thread(ipvs, IP_VS_STATE_MASTER);
-- 
2.2.1

