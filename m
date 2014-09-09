From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 18/20] ipvs: use correct address family in WLC logs
Date: Tue, 9 Sep 2014 16:40:37 -0700
Message-ID: <1410306039-2977-19-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=iNtjgo5kwJA1j6vr+OuwzBwifEmTkU69BtDbAmkAFpI=;
 b=JjEqvx04QJRKWaczdrw2TOtAG8y0PSW78hxi80mBcwNcZqXcGfhzoTGuaKL+P4kFmVU1
 NSgCaHDtqa2ACHjx3bmHPXEEj4XqHnVpeLrhs/8+lRmzOsMaHn+xrZ8I9knWibHiFHXQ
 o9N1/BWec0e26BC5lB6fT053KAn9PT28D9A= 
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
 net/netfilter/ipvs/ip_vs_wlc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index b5b4650..6b366fd 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -80,7 +80,8 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 
 	IP_VS_DBG_BUF(6, "WLC: server %s:%u "
 		      "activeconns %d refcnt %d weight %d overhead %d\n",
-		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      IP_VS_DBG_ADDR(least->af, &least->addr),
+		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
 		      atomic_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
-- 
1.8.1

