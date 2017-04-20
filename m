From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH] ipvs: explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled
Date: Thu, 20 Apr 2017 11:44:16 +0200
Message-ID: <2a5c88ca5670baade900e2b1f05a0dcc9927a29d.1492681122.git.pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 mx1.redhat.com F1462C054921
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org

When creating a new ipvs service, ipv6 addresses are always accepted
if CONFIG_IP_VS_IPV6 is enabled. On dest creation the address family
is not explicitly checked.

This allows the user-space to configure ipvs services even if the
system is booted with ipv6.disable=1. On specific configuration, ipvs
can try to call ipv6 routing code at setup time, causing the kernel to
oops due to fib6_rules_ops being NULL.

This change addresses the issue adding a check for the ipv6
module being enabled while validating ipv6 service operations and
adding the same validation for dest operations.

According to git history, this issue is apparently present since
the introduction of ipv6 support, and the oops can be triggered
since commit 09571c7ae30865ad ("IPVS: Add function to determine
if IPv6 address is local")

Fixes: 09571c7ae30865ad ("IPVS: Add function to determine if IPv6 address is local")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5aeb0dd..4d753be 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3078,6 +3078,17 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
 	return skb->len;
 }
 
+static bool ip_vs_is_af_valid(int af)
+{
+	if (af == AF_INET)
+		return true;
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6 && ipv6_mod_enabled())
+		return true;
+#endif
+	return false;
+}
+
 static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
 				    struct ip_vs_service_user_kern *usvc,
 				    struct nlattr *nla, int full_entry,
@@ -3104,11 +3115,7 @@ static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
 	memset(usvc, 0, sizeof(*usvc));
 
 	usvc->af = nla_get_u16(nla_af);
-#ifdef CONFIG_IP_VS_IPV6
-	if (usvc->af != AF_INET && usvc->af != AF_INET6)
-#else
-	if (usvc->af != AF_INET)
-#endif
+	if (!ip_vs_is_af_valid(usvc->af))
 		return -EAFNOSUPPORT;
 
 	if (nla_fwmark) {
@@ -3610,6 +3617,11 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		if (udest.af == 0)
 			udest.af = svc->af;
 
+		if (!ip_vs_is_af_valid(udest.af)) {
+			ret = -EAFNOSUPPORT;
+			goto out;
+		}
+
 		if (udest.af != svc->af && cmd != IPVS_CMD_DEL_DEST) {
 			/* The synchronization protocol is incompatible
 			 * with mixed family services
-- 
2.9.3

