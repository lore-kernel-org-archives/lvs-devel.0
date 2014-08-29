From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v4 20/20] ipvs: Allow heterogeneous pools now that we support them
Date: Fri, 29 Aug 2014 01:39:09 -0700
Message-ID: <1409301549-5284-21-git-send-email-agartrell@fb.com>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=J2exlNQ+VzY9I3CPkB5IreXXd1JF5QwbWMkj8GHdkYk=;
 b=rUvZFzN8kFEfbHjOw64H0xSBGduEFBEVy+txrOgQx/I65qgF7t8E2j93VrgHAFZjFyPs
 UAlTUcefsHYRArRz/r0Uf5/Wm6lsBt62FjmSqKgMx3tRdi6UJixjZvHd7Z3L4GOjOwvE
 fJT5iKNjtjq+q0Zcr9kp+1tRjjZyURCuC4M= 
In-Reply-To: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Remove the temporary consistency check and add a case statement to only
allow ipip mixed dests.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 175945f..325afe2 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -854,10 +854,6 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 
 	EnterFunction(2);
 
-	/* Temporary for consistency */
-	if (udest->af != svc->af)
-		return -EINVAL;
-
 #ifdef CONFIG_IP_VS_IPV6
 	if (udest->af == AF_INET6) {
 		atype = ipv6_addr_type(&udest->addr.in6);
@@ -3392,6 +3388,26 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
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

