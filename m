From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v4 15/20] ipvs: use correct address family in RR logs
Date: Fri, 29 Aug 2014 01:39:04 -0700
Message-ID: <1409301549-5284-16-git-send-email-agartrell@fb.com>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=zpuDdF4Z4ytE5cfuwiemnBueGlhm562BzI5D7sA+E0k=;
 b=JM2RXmqLtrpdglfm7Pa8d22qf0AjiUrg4qALo3mGK+4Z9ESBsUuhw8AexgiZZ/fq1lgJ
 FWyKiSsYL+qHivSH2f4seGIhMzpK877CaPRNUc3Ic+SOza1AzbuUzF23pKlUwPx7DgLb
 gvpEimFT+kzggdFQfUaKlanGypkXzCuK0VA= 
In-Reply-To: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

From: Julian Anastasov <ja@ssi.bg>

Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_rr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 176b87c..58bacfc 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -95,7 +95,7 @@ stop:
 	spin_unlock_bh(&svc->sched_lock);
 	IP_VS_DBG_BUF(6, "RR: server %s:%u "
 		      "activeconns %d refcnt %d weight %d\n",
-		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port),
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
 		      atomic_read(&dest->activeconns),
 		      atomic_read(&dest->refcnt), atomic_read(&dest->weight));
 
-- 
1.8.1

