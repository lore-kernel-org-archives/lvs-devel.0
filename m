From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v3 20/20] ipvs: Allow heterogeneous pools now that we support them
Date: Wed, 27 Aug 2014 22:43:54 -0700
Message-ID: <1409204634-1123-21-git-send-email-agartrell@fb.com>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=2VJ1ORAqFmZTWoz6lkP3bU81Syjz4bND0Ywo1IzFmBQ=;
 b=qW8Xo6nzJyx7Wf1hm496002G7d16s9ELoGggmDOk48R20wYfuZ75tOS4I8B1DKc9EukU
 A7QGBm1MoRPoHWJN3CE35smbSY0OEw8gKyJvQYciH29Fni8aVadpDv/NcCv80FhTYoWL
 /egX28iOMxNIoi6Pu61J7hPDTRQ254fWoOY= 
In-Reply-To: <1409204634-1123-1-git-send-email-agartrell@fb.com>
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
index c374ebb..bec0d74 100644
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
@@ -3489,6 +3485,26 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
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

