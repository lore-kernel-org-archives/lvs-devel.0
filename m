From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 64/84] ipvs: Pass ipvs not net into ip_vs_conn_net_flush
Date: Thu, 24 Sep 2015 09:52:49 +0900
Message-ID: <1443055989-1306-65-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
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
 net/netfilter/ipvs/ip_vs_conn.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a99bbf6c8202..4bb1b7d1286d 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1309,11 +1309,10 @@ void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 /*
  *      Flush all the connection entries in the ip_vs_conn_tab
  */
-static void ip_vs_conn_flush(struct net *net)
+static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
 {
 	int idx;
 	struct ip_vs_conn *cp, *cp_c;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 flush_again:
 	rcu_read_lock();
@@ -1359,8 +1358,10 @@ int __net_init ip_vs_conn_net_init(struct net *net)
 
 void __net_exit ip_vs_conn_net_cleanup(struct net *net)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
+
 	/* flush all the connection entries first */
-	ip_vs_conn_flush(net);
+	ip_vs_conn_flush(ipvs);
 	remove_proc_entry("ip_vs_conn", net->proc_net);
 	remove_proc_entry("ip_vs_conn_sync", net->proc_net);
 }
-- 
2.1.4
