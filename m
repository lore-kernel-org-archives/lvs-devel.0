From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 64/84] ipvs: Pass ipvs not net into ip_vs_conn_net_flush
Date: Mon, 21 Sep 2015 13:02:41 -0500
Message-ID: <1442858581-15869-64-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
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
2.2.1

