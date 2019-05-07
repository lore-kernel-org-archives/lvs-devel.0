From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.9 17/25] ipvs: do not schedule icmp errors from tunnels
Date: Tue,  7 May 2019 01:41:14 -0400
Message-ID: <20190507054123.32514-17-sashal@kernel.org>
References: <20190507054123.32514-1-sashal@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1557207723;
        bh=tw/ZK2MiLfteMwogSB2X8LZjAsBVawNDkiDoHhMj7O0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=OjrjMFZWVccPmTOpzqp0uZm7NwmQoBbR6n/AUGAywMsaqc7OUFcj0W5uXceu7YKA5
         LaVSLpYW6wJuLMKqgiq2iUEH4tUcPPPn9DwloKSx+6iI7pGbZ2X6vTpJTGZ3IvwhXa
         VlryTcPkqbUMVGeoR6o1UQVH3zx4DVkeRHOChkn8=
In-Reply-To: <20190507054123.32514-1-sashal@kernel.org>
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
index fd186b011a99..8475e8692ff0 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1643,7 +1643,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 	if (!cp) {
 		int v;
 
-		if (!sysctl_schedule_icmp(ipvs))
+		if (ipip || !sysctl_schedule_icmp(ipvs))
 			return NF_ACCEPT;
 
 		if (!ip_vs_try_to_schedule(ipvs, AF_INET, skb, pd, &v, &cp, &ciph))
-- 
2.20.1

