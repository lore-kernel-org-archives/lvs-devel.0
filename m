From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 56/84] ipvs: Pass ipvs not net into ip_vs_app_inc_release
Date: Mon, 21 Sep 2015 13:02:33 -0500
Message-ID: <1442858581-15869-56-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_app.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index a0cc08337a2c..42220a0efda2 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -127,9 +127,8 @@ ip_vs_app_inc_new(struct netns_ipvs *ipvs, struct ip_vs_app *app, __u16 proto,
  *	Release app incarnation
  */
 static void
-ip_vs_app_inc_release(struct net *net, struct ip_vs_app *inc)
+ip_vs_app_inc_release(struct netns_ipvs *ipvs, struct ip_vs_app *inc)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_protocol *pp;
 
 	if (!(pp = ip_vs_proto_get(inc->protocol)))
@@ -230,7 +229,6 @@ out_unlock:
 void unregister_ip_vs_app(struct netns_ipvs *ipvs, struct ip_vs_app *app)
 {
 	struct ip_vs_app *a, *anxt, *inc, *nxt;
-	struct net *net = ipvs->net;
 
 	mutex_lock(&__ip_vs_app_mutex);
 
@@ -238,7 +236,7 @@ void unregister_ip_vs_app(struct netns_ipvs *ipvs, struct ip_vs_app *app)
 		if (app && strcmp(app->name, a->name))
 			continue;
 		list_for_each_entry_safe(inc, nxt, &a->incs_list, a_list) {
-			ip_vs_app_inc_release(net, inc);
+			ip_vs_app_inc_release(ipvs, inc);
 		}
 
 		list_del(&a->a_list);
-- 
2.2.1
