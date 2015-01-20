From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ipvs: orphan skb on LOCAL_IN path
Date: Tue, 20 Jan 2015 14:55:16 -0800
Message-ID: <1421794516-309785-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=N/ZthTKd0u3d+fs7owAUKrhyAj8EeRSyvrSfU50ZSmQ=;
 b=QSiv27Ca53XEBFmQB4aYwg0R12aLhfUAgVsz1AIRpYzm+Hroimez+ynYM1LtZUguantQ
 nBBtH8Wi2jZPDeNQRlgcD7qL1jddnXGPRi+d7TyamEfzGpZuZtUZh0vygEV27FfSRaUt
 pP1bRQrbMODXivf0QPjm6gRXXAdAL4xeaVE= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

skb->sk can be set in the early_demux path.  This can be problematic, as it
may be a time-wait socket, which will blow up in the ip6_output path when
we try to pull out the non-existent pinet6 pointer (the type-punning causes
that pointer to be garbage).

This patch orphans the skb if it's not a local socket, so we no longer have
to worry about running into the time-wait problem from early demux.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 990decb..57fc626 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1692,10 +1692,19 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 	ip_vs_in_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
-	if (cp->packet_xmit)
+	if (cp->packet_xmit) {
+		/* From now on, we only care about the skb->sk if it's
+		 * LOCAL_OUT (as we may need to update the MTU on a socket
+		 * we own for tunneling overhead.  We must orphan it, in
+		 * case a socket was in time-wait or something and this
+		 * value was assigned in the early_demux path.
+		 */
+		if (hooknum == NF_INET_LOCAL_IN)
+			skb_orphan(skb);
+
 		ret = cp->packet_xmit(skb, cp, pp, &iph);
 		/* do not touch skb anymore */
-	else {
+	} else {
 		IP_VS_DBG_RL("warning: packet_xmit is null");
 		ret = NF_ACCEPT;
 	}
-- 
Alex Gartrell <agartrell@fb.com>

