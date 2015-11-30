From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: ipvs: avoid unused variable warning
Date: Mon, 30 Nov 2015 10:54:14 +0100
Message-ID: <9616810.SPqCgIbKt5@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

When CONFIG_PROC_FS is disabled, the local 'net' variable in
ip_vs_app_net_init becomes unused, as gcc warns:

net/netfilter/ipvs/ip_vs_app.c: In function 'ip_vs_app_net_init':
net/netfilter/ipvs/ip_vs_app.c:608:14: warning: unused variable 'net' [-Wunused-variable]

This removes the line by moving the pointer dereference into the
user of the variable.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 0328f7250693..e5422d3db501 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -614,8 +614,6 @@ int __net_init ip_vs_app_net_init(struct netns_ipvs *ipvs)
 
 void __net_exit ip_vs_app_net_cleanup(struct netns_ipvs *ipvs)
 {
-	struct net *net = ipvs->net;
