From: Michael Maxim <mike@okcupid.com>
Subject: [PATCH 2/2] IPVS: Modify the SH scheduler to use weights
Date: Thu,  8 Dec 2011 10:55:09 -0500
Message-ID: <1323359709-759-1-git-send-email-mike@okcupid.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Mike Maxim <mike@okcupid.com>

Modify the algorithm to build the source hashing hash table to add
extra slots for destinations with higher weight. This has the effect
of allowing an IPVS SH user to give more connections to hosts that
have been configured to have a higher weight.

The reason for the Kconfig change is because the size of the hash table
becomes more relevant/important if you decide to use the weights in the
manner this patch lets you. It would be conceivable that someone might
need to increase the size of that table to accommodate their
configuration, so it will be handy to be able to do that through the
regular configuration system instead of editing the source.

Signed-off-by: Michael Maxim <mike@okcupid.com>
---
 net/netfilter/ipvs/Kconfig    |   15 +++++++++++++++
 net/netfilter/ipvs/ip_vs_sh.c |   18 +++++++++++++++++-
 2 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 70bd1d0..af4c0b8 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -232,6 +232,21 @@ config	IP_VS_NQ
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
+comment 'IPVS SH scheduler'
+
+config IP_VS_SH_TAB_BITS
+	int "IPVS source hashing table size (the Nth power of 2)"
+	range 4 20
+	default 8
+	---help---
+	  The source hashing scheduler maps source IPs to destinations
+	  stored in a hash table. This table is tiled by each destination
+	  until all slots in the table are filled. When using weights to
+	  allow destinations to receive more connections, the table is
+	  tiled an amount proportional to the weights specified. The table
+	  needs to be large enough to effectively fit all the destinations
+	  multiplied by their respective weights.
+
 comment 'IPVS application helper'
 
 config	IP_VS_FTP
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 33815f4..069e8d4 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -30,6 +30,11 @@
  * server is dead or overloaded, the load balancer can bypass the cache
  * server and send requests to the original server directly.
  *
+ * The weight destination attribute can be used to control the
+ * distribution of connections to the destinations in servernode. The
+ * greater the weight, the more connections the destination
+ * will receive.
+ *
  */
 
 #define KMSG_COMPONENT "IPVS"
@@ -99,9 +104,11 @@ ip_vs_sh_assign(struct ip_vs_sh_bucket *tbl, struct ip_vs_service *svc)
 	struct ip_vs_sh_bucket *b;
 	struct list_head *p;
 	struct ip_vs_dest *dest;
+	int d_count;
 
 	b = tbl;
 	p = &svc->destinations;
+	d_count = 0;
 	for (i=0; i<IP_VS_SH_TAB_SIZE; i++) {
 		if (list_empty(p)) {
 			b->dest = NULL;
@@ -113,7 +120,16 @@ ip_vs_sh_assign(struct ip_vs_sh_bucket *tbl, struct ip_vs_service *svc)
 			atomic_inc(&dest->refcnt);
 			b->dest = dest;
 
-			p = p->next;
+			IP_VS_DBG_BUF(6, "assigned i: %d dest: %s weight: %d\n",
+				      i, IP_VS_DBG_ADDR(svc->af, &dest->addr),
+				      atomic_read(&dest->weight));
+
+			/* Don't move to next dest until filling weight */
+			if (++d_count >= atomic_read(&dest->weight)) {
+				p = p->next;
+				d_count = 0;
+			}
+
 		}
 		b++;
 	}
-- 
1.7.4.1

