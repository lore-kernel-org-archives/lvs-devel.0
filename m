From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 18/84] ipvs: Cache ipvs in ip_vs_genl_set_cmd
Date: Mon, 21 Sep 2015 13:01:55 -0500
Message-ID: <1442858581-15869-18-git-send-email-ebiederm@xmission.com>
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

Compute ipvs early in ip_vs_genl_set_cmd and use the cached value to
access ipvs->sync_state.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 20aeb993618f..7aae2dc0f766 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3516,8 +3516,10 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	int ret = 0, cmd;
 	int need_full_svc = 0, need_full_dest = 0;
 	struct net *net;
+	struct netns_ipvs *ipvs;
 
 	net = skb_sknet(skb);
+	ipvs = net_ipvs(net);
 	cmd = info->genlhdr->cmd;
 
 	mutex_lock(&__ip_vs_mutex);
@@ -3579,7 +3581,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 			/* The synchronization protocol is incompatible
 			 * with mixed family services
 			 */
-			if (net_ipvs(net)->sync_state) {
+			if (ipvs->sync_state) {
 				ret = -EINVAL;
 				goto out;
 			}
-- 
2.2.1
