From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 2/5] ipvs: remove extra rcu lock
Date: Sat,  9 Mar 2013 23:25:05 +0200
Message-ID: <1362864308-8259-3-git-send-email-ja@ssi.bg>
References: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	In 3.7 we added code that uses ipv4_update_pmtu
but after commit c5ae7d4192 (ipv4: must use rcu protection
while calling fib_lookup) the RCU lock is not needed.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 15a051c..207c3b9 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1393,10 +1393,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 			skb_reset_network_header(skb);
 			IP_VS_DBG(12, "ICMP for IPIP %pI4->%pI4: mtu=%u\n",
 				&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr, mtu);
-			rcu_read_lock();
 			ipv4_update_pmtu(skb, dev_net(skb->dev),
 					 mtu, 0, 0, 0, 0);
-			rcu_read_unlock();
 			/* Client uses PMTUD? */
 			if (!(cih->frag_off & htons(IP_DF)))
 				goto ignore_ipip;
-- 
1.7.3.4

