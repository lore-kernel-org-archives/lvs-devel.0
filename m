From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 2/6] ipvs: SH scheduler does not need GFP_ATOMIC allocation
Date: Fri, 13 Apr 2012 16:49:38 +0300
Message-ID: <1334324982-3143-3-git-send-email-ja@ssi.bg>
References: <1334324982-3143-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1334324982-3143-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

        Schedulers are initialized and bound to services only
on commands.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sh.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 069e8d4..47182dd 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -162,7 +162,7 @@ static int ip_vs_sh_init_svc(struct ip_vs_service *svc)
 
 	/* allocate the SH table for this service */
 	tbl = kmalloc(sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE,
-		      GFP_ATOMIC);
+		      GFP_KERNEL);
 	if (tbl == NULL)
 		return -ENOMEM;
 
-- 
1.7.3.4

