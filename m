From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 53/84] ipvs: Pass ipvs not net into ip_vs_app_inc_new
Date: Thu, 24 Sep 2015 09:52:38 +0900
Message-ID: <1443055989-1306-54-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_app.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index f20f72c4ac80..951516b7783b 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -75,10 +75,9 @@ static void ip_vs_app_inc_rcu_free(struct rcu_head *head)
  *	Allocate/initialize app incarnation and register it in proto apps.
  */
 static int
-ip_vs_app_inc_new(struct net *net, struct ip_vs_app *app, __u16 proto,
+ip_vs_app_inc_new(struct netns_ipvs *ipvs, struct ip_vs_app *app, __u16 proto,
 		  __u16 port)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_protocol *pp;
 	struct ip_vs_app *inc;
 	int ret;
@@ -180,11 +179,12 @@ int
 register_ip_vs_app_inc(struct net *net, struct ip_vs_app *app, __u16 proto,
 		       __u16 port)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	int result;
 
 	mutex_lock(&__ip_vs_app_mutex);
 
-	result = ip_vs_app_inc_new(net, app, proto, port);
+	result = ip_vs_app_inc_new(ipvs, app, proto, port);
 
 	mutex_unlock(&__ip_vs_app_mutex);
 
-- 
2.1.4
