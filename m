From: Andrew Sy Kim <kim.andrewsy@gmail.com>
Subject: [PATCH] ipvs: add missing struct name in ip_vs_enqueue_expire_nodest_conns when CONFIG_SYSCTL is disabled
Date: Fri, 17 Jul 2020 12:24:50 -0400
Message-ID: <20200717162450.1049-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Bgxlqmi2+F2aXisPWdaUIbUjIKEMc7nJuMVPpqp6z0c=;
        b=Dq1U1O1K0vuSFxJkkHmHOInamh0NUsS/68BH4CFYc+ccBa0v72VmFVXY38wU9ne0kz
         84CBUPHd09Cs85F0RJjYUWlFwFsQ216g8lLkK6L4RM2MDt+k23DyEG9gJKgsfn5mASez
         Cvhdt7aeLZ52QAq5FJId/uj+8zFNtPmIA3i1LW7MYjoZu00u6aybD3w/rilJOZeVFiPl
         bAqyGRf5CNQPG4CnHq9bVzVOIL4inW7F/taOfwg2h0bqxa1cayk2o18+MTXwBUPewyHP
         gabcBuuYIuslbAaSt8+M07RNbCi4ORAbZ8GIKwrNcIiQbm1oDZqlkNbkHI9mk+FcCUgB
         dBCA==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Andrew Sy Kim <kim.andrewsy@gmail.com>

Adds missing "*ipvs" to ip_vs_enqueue_expire_nodest_conns when
CONFIG_SYSCTL is disabled

Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
---
 include/net/ip_vs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 91a9e1d590a6..9a59a33787cb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1533,7 +1533,7 @@ static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs *ipvs)
 
 void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs);
 #else
-static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs) {}
+static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs *ipvs) {}
 #endif
 
 #define IP_VS_DFWD_METHOD(dest) (atomic_read(&(dest)->conn_flags) & \
-- 
2.20.1

