From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.4 11/14] ipvs: do not schedule icmp errors from tunnels
Date: Tue,  7 May 2019 01:42:13 -0400
Message-ID: <20190507054218.340-11-sashal@kernel.org>
References: <20190507054218.340-1-sashal@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1557207762;
        bh=+kACfupaAaVCm6jAKa9+y7DVVVVW7QKdcJ+pTqSk9fU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=AVUd+kUVgZQ5zo0SSow/O7Sihv59KNOgYQgmnkrHwjBBDtQU4FsZmeksDcBkzdzu3
         ++v4aHtTm5aet6MPdx9IRlJuTq37NH+CynNsu4JWisMSWK2B/ExXerlRcuNoPSQwg3
         cF2l4Y3awL9VwPiYS2DBuUC0N+EHQU2pSxhNaapg=
In-Reply-To: <20190507054218.340-1-sashal@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sashal@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

From: Julian Anastasov <ja@ssi.bg>

[ Upstream commit 0261ea1bd1eb0da5c0792a9119b8655cf33c80a3 ]

We can receive ICMP errors from client or from
tunneling real server. While the former can be
scheduled to real server, the latter should
not be scheduled, they are decapsulated only when
existing connection is found.

Fixes: 6044eeffafbe ("ipvs: attempt to schedule icmp packets")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ac212542a217..c4509a10ce52 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1484,7 +1484,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	if (!cp) {
 		int v;
 
-		if (!sysctl_schedule_icmp(ipvs))
+		if (ipip || !sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
 		if (!ip_vs_try_to_schedule(ipvs, AF_INET, skb, pd, &v, &cp, &ciph))
-- 
2.20.1

