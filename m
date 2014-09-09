From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 14/20] ipvs: use correct address family in NQ logs
Date: Tue, 9 Sep 2014 16:40:33 -0700
Message-ID: <1410306039-2977-15-git-send-email-agartrell@fb.com>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EyPiliRxfFT0bWGVPTudFwz/EjIAW7hjvsalaQbWX2A=;
 b=I6TwhE3kh0e5CAI3LrbCGuifIVeDhTorbySMgfJu46Jv0GfdIjTz0C5qH+jX0W23oPIi
 EuBnNIPWt8+Ztkd3PhqUcVJgKZfcwtj9Vb2F+TeypGDBtKhJKcZbuwV1C9qQeaTMCU4d
 Ea+QytAgDksgdR0cOZDk9EJ5SFzUalE6Wls= 
In-Reply-To: <1410306039-2977-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
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
 net/netfilter/ipvs/ip_vs_nq.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index 961a6de..a8b6340 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -107,7 +107,8 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
   out:
 	IP_VS_DBG_BUF(6, "NQ: server %s:%u "
 		      "activeconns %d refcnt %d weight %d overhead %d\n",
-		      IP_VS_DBG_ADDR(svc->af, &least->addr), ntohs(least->port),
+		      IP_VS_DBG_ADDR(least->af, &least->addr),
+		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
 		      atomic_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
-- 
1.8.1
