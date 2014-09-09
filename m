From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 12/20] ipvs: use correct address family in DH logs
Date: Tue, 9 Sep 2014 16:40:31 -0700
Message-ID: <1410306039-2977-13-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=dNtG/58HrYFsN88Wt7pxQPgPQafTrUQOpL+7AY5432g=;
 b=jaoYjI0cFXghff9wzKTicYVaYIQo5SCNzHWSAuXYKBa7MgY+CB6xjRkR0b94SWE4dYGA
 9Xeg0mt7KL+X9kdmPv3sSbDGaE8KD1EZ84GuEZGlzgkskJQ9RMRPXSfvpvGtVhBmtudi
 AgJiYitYmTB023U22RPw1RWEyydF5upapG4= 
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, Alex Gartrell <agartrell@fb.com>

From: Julian Anastasov <ja@ssi.bg>

Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_dh.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index c3b8454..6be5c53 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -234,7 +234,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	IP_VS_DBG_BUF(6, "DH: destination IP address %s --> server %s:%d\n",
 		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
-		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 		      ntohs(dest->port));
 
 	return dest;
-- 
1.8.1

