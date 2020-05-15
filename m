From: Andrew Sy Kim <kim.andrewsy@gmail.com>
Subject: [PATCH] netfilter/ipvs: expire no destination UDP connections when expire_nodest_conn=1
Date: Thu, 14 May 2020 21:35:56 -0400
Message-ID: <20200515013556.5582-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=0VjQ+Ma3qI88glsLS8F0bIG67DtfNMG5fSLchrZlPkw=;
        b=BZH27tzHemzdhmeAt5qyR6/wV3Rep0NuG5yApKqgOQnaClXU3DcmTpxeToHmrIa15l
         e/VU6aF7VhSU4G6nrw4DsMvQvfQn5gePKL/mL5Ip1KjkVJequxf52sqv4NWsvQrlyzIl
         VQ8GsWnQ2KmNG4nUelqamCKaGM4nwe7OEROb4Mv33JGjGkhx/Ed70ZHgjJ2UAt3HbgWe
         gLdBaa0JYh2H8FCFSy8Q3WEBJ7mcUCNK81II+EB30V2TJ8KFGzjS98HFmUz0+cNkAmBM
         cuxIoNM2qoSTz/bTGviWjKAFqNQXMd2af7Xrp6THTo6nXJN9TexjHiE7l9BAYNLlpGpL
         0dkQ==
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 
Cc: kim.andrewsy@gmail.com, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, "open list:IPVS" <netdev@vger.kernel.org>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>, "open list:NETFILTER" <coreteam@netfilter.org>, open list <linux-kernel@vger.kernel.org>

When expire_nodest_conn=1 and an IPVS destination is deleted, IPVS
doesn't expire connections with the IP_VS_CONN_F_ONE_PACKET flag set (any
UDP connection). If there are many UDP packets to a virtual server from a
single client and a destination is deleted, many packets are silently
dropped whenever an existing connection entry with the same source port
exists. This patch ensures IPVS also expires UDP connections when a
packet matches an existing connection with no destinations.

Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index aa6a603a2425..f0535586fe75 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2116,8 +2116,7 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 		else
 			ip_vs_conn_put(cp);
 
-		if (sysctl_expire_nodest_conn(ipvs) &&
-		    !(flags & IP_VS_CONN_F_ONE_PACKET)) {
+		if (sysctl_expire_nodest_conn(ipvs)) {
 			/* try to expire the connection immediately */
 			ip_vs_conn_expire_now(cp);
 		}
-- 
2.20.1

