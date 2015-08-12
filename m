From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 01/12] ipvs: pull out ip_vs_try_to_schedule function
Date: Wed, 12 Aug 2015 13:46:59 -0700
Message-ID: <1439412430-1702375-2-git-send-email-agartrell@fb.com>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=ESiRFWc0n56h6WaAdH5qVfQ/AmQ85B+bCp0xqvEQuMo=;
 b=K1Y6ZPliFkGJDhStmyGRpohp5fWmCPuq/w37ecp4I86VaE3nP7iEyIRv6MW7pfhkunQR
 xLHr5B64XwfPCW9HfGlJp83ZlivJelLl7o8zfvPIlkPQTz/F+WMD2U7wXZLSPMpYDIYa
 1x8nCcZZ1QYbkHaHHtyE9BxZJskJYDwV99Q= 
In-Reply-To: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, lvs-devel@vger.kernel.org
Cc: kernel-team@fb.com, alexgartrell@gmail.com, Alex Gartrell <agartrell@fb.com>

This is necessary as we'll be trying to schedule icmp later and we'll want
to share this code.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 57 ++++++++++++++++++++++++++---------------
 1 file changed, 37 insertions(+), 20 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 38fbc19..2d895ca 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1327,6 +1327,41 @@ ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 
 #endif
 
+static unsigned int
+ip_vs_try_to_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
+		      int *verdict, struct ip_vs_conn **cpp,
+		      struct ip_vs_iphdr *iph)
+{
+	struct ip_vs_protocol *pp = pd->pp;
+
+	if (!iph->fragoffs) {
+		/* No (second) fragments need to enter here, as nf_defrag_ipv6
+		 * replayed fragment zero will already have created the cp
+		 */
+
+		/* Schedule and create new connection entry into cpp */
+		if (!pp->conn_schedule(af, skb, pd, verdict, cpp, iph))
+			return 0;
+	}
+
+	if (unlikely(!*cpp)) {
+		/* sorry, all this trouble for a no-hit :) */
+		IP_VS_DBG_PKT(12, af, pp, skb, 0,
+			      "ip_vs_in: packet continues traversal as normal");
+		if (iph->fragoffs) {
+			/* Fragment that couldn't be mapped to a conn entry
+			 * is missing module nf_defrag_ipv6
+			 */
+			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
+			IP_VS_DBG_PKT(7, af, pp, skb, 0, "unhandled fragment");
+		}
+		*verdict = NF_ACCEPT;
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  *	Handle ICMP messages in the outside-to-inside direction (incoming).
  *	Find any that might be relevant, check against existing connections,
@@ -1700,31 +1735,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		cp = NULL;
 	}
 
-	if (unlikely(!cp) && !iph.fragoffs) {
-		/* No (second) fragments need to enter here, as nf_defrag_ipv6
-		 * replayed fragment zero will already have created the cp
-		 */
+	if (unlikely(!cp)) {
 		int v;
 
-		/* Schedule and create new connection entry into &cp */
-		if (!pp->conn_schedule(af, skb, pd, &v, &cp, &iph))
+		if (!ip_vs_try_to_schedule(af, skb, pd, &v, &cp, &iph))
 			return v;
 	}
 
-	if (unlikely(!cp)) {
-		/* sorry, all this trouble for a no-hit :) */
-		IP_VS_DBG_PKT(12, af, pp, skb, 0,
-			      "ip_vs_in: packet continues traversal as normal");
-		if (iph.fragoffs) {
-			/* Fragment that couldn't be mapped to a conn entry
-			 * is missing module nf_defrag_ipv6
-			 */
-			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
-			IP_VS_DBG_PKT(7, af, pp, skb, 0, "unhandled fragment");
-		}
-		return NF_ACCEPT;
-	}
