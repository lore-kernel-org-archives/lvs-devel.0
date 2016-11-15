From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 1/2] ipvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc) || svc == NULL
Date: Tue, 15 Nov 2016 10:01:42 +0100
Message-ID: <1479200503-25842-2-git-send-email-horms@verge.net.au>
References: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1479200513; bh=DLMr4N+q+l4zL8QiCnwqGB5YWcvsbSiBvkkJHksaYQY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=NUIvQFA8tLuYAGqjcaqHWiSe7oUNc2pPZmKFnjNs4NIefIgNGKxtF70QrdBEXyhOD
         7hvLDnn6b9Uwq1408R/TXS/xadBq6f5tr5XUXRQRKby0Df6INLINPJnmt6Btlsrg44
         R7ztH/jxZbZ2l7Acb7+laU1NPEssT2B1f3q+GCHg=
In-Reply-To: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Gao Feng <fgao@ikuai8.com>, Simon Horman <horms@verge.net.au>

From: Gao Feng <fgao@ikuai8.com>

This minor refactoring does not change the logic of function
ip_vs_genl_dump_dests.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6b85ded4f91d..217e0105b5e0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3260,7 +3260,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 
 
 	svc = ip_vs_genl_find_service(ipvs, attrs[IPVS_CMD_ATTR_SERVICE]);
-	if (IS_ERR(svc) || svc == NULL)
+	if (IS_ERR_OR_NULL(svc))
 		goto out_err;
 
 	/* Dump the destinations */
-- 
2.7.0.rc3.207.g0ac5344

