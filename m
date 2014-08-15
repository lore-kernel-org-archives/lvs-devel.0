From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 04/18] ipvs: prevent mixing heterogeneous pools and synchronization
Date: Thu, 14 Aug 2014 20:23:27 -0700
Message-ID: <1408073021-24007-5-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=BtAGa5nTOrvLnJc2B1/faaIKMmFhya67kaCUS/pfXLU=;
 b=J9IogFKvm3iUXRUXBpWw8AUrym41lnzF1w41PCtfQZcILnFhj52WsFVL8lPvkVIaSDne
 /1FxbW8SxsfnEzdDgOzc/9l0oXWhZOJqQCKJJu1qCplKlKDERLQcAIBXBIMaeu1P17CU
 ZSqS47YU0uwFQYvbpfWN1QwiiWPYSRK/eKA= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

The synchronization protocol is not compatible with heterogeneous pools, so
we need to verify that we're not turning both on at the same time.

This also introduces a switch statement that we'll use to turn on
forwarding types on a case by case basis.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2356f1d..6d07a51 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -858,10 +858,6 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 
 	EnterFunction(2);
 
-	/* Temporary for consistency */
-	if (udest->af != svc->af)
-		return -EINVAL;
-
 #ifdef CONFIG_IP_VS_IPV6
 	if (udest->af == AF_INET6) {
 		atype = ipv6_addr_type(&udest->addr.in6);
@@ -3355,6 +3351,12 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
 		return -EINVAL;
 
+	/* The synchronization protocol is incompatible with mixed family
+	 * services
+	 */
+	if (net_ipvs(net)->mixed_address_family_dests > 0)
+		return -EINVAL;
+
 	return start_sync_thread(net,
 				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
 				 nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
@@ -3487,6 +3489,26 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		 */
 		if (udest.af == 0)
 			udest.af = svc->af;
+
+		if (udest.af != svc->af) {
+			/* The synchronization protocol is incompatible
+			 * with mixed family services
+			 */
+			if (net_ipvs(net)->sync_state) {
+				ret = -EINVAL;
+				goto out;
+			}
+
+			/* Which connection types do we support? */
+			switch (udest.conn_flags) {
+			case IP_VS_CONN_F_TUNNEL:
+				/* We are able to forward this */
+				break;
+			default:
+				ret = -EINVAL;
+				goto out;
+			}
+		}
 	}
 
 	switch (cmd) {
-- 
1.8.1

