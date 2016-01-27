From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] netfilter: ipvs/SIP: handle ip_vs_fill_iph_skb_off failure
Date: Wed, 27 Jan 2016 14:52:02 +0100
Message-ID: <1453902749-3422685-2-git-send-email-arnd@arndb.de>
References: <1453902749-3422685-1-git-send-email-arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1453902749-3422685-1-git-send-email-arnd@arndb.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

ip_vs_fill_iph_skb_off() may not find an IP header, and gcc has
determined that ip_vs_sip_fill_param() then incorrectly accesses
the protocol fields:

net/netfilter/ipvs/ip_vs_pe_sip.c: In function 'ip_vs_sip_fill_param':
net/netfilter/ipvs/ip_vs_pe_sip.c:76:5: error: 'iph.protocol' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  if (iph.protocol != IPPROTO_UDP)
     ^
net/netfilter/ipvs/ip_vs_pe_sip.c:81:10: error: 'iph.len' may be used uninitialized in this function [-Werror=maybe-uninitialized]
  dataoff = iph.len + sizeof(struct udphdr);
          ^

This adds a check for the ip_vs_fill_iph_skb_off() return code
before looking at the ip header data returned from it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: b0e010c527de ("ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off")
---
 net/netfilter/ipvs/ip_vs_pe_sip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 1b8d594e493a..c4e9ca016a88 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -70,10 +70,10 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	const char *dptr;
 	int retc;
 
-	ip_vs_fill_iph_skb(p->af, skb, false, &iph);
+	retc = ip_vs_fill_iph_skb(p->af, skb, false, &iph);
 
 	/* Only useful with UDP */
-	if (iph.protocol != IPPROTO_UDP)
+	if (!retc || iph.protocol != IPPROTO_UDP)
 		return -EINVAL;
 	/* todo: IPv6 fragments:
 	 *       I think this only should be done for the first fragment. /HS
-- 
2.7.0

