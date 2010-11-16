From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/6] ipvs: add static and read_mostly attributes
Date: Tue, 16 Nov 2010 15:34:57 +0900
Message-ID: <1289889298-17287-6-git-send-email-horms@verge.net.au>
References: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, n
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Simon Horman <horms@verge.net.au>

From: Eric Dumazet <eric.dumazet@gmail.com>

ip_vs_conn_tab_bits & ip_vs_conn_tab_mask are static to
ipvs/ip_vs_conn.c

ip_vs_conn_tab_size, ip_vs_conn_tab_mask, ip_vs_conn_tab [the pointer],
ip_vs_conn_rnd are mostly read.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 261db1a..7615f9e 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -48,18 +48,18 @@
 /*
  * Connection hash size. Default is what was selected at compile time.
 */
-int ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
+static int ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
 module_param_named(conn_tab_bits, ip_vs_conn_tab_bits, int, 0444);
 MODULE_PARM_DESC(conn_tab_bits, "Set connections' hash size");
 
 /* size and mask values */
-int ip_vs_conn_tab_size;
-int ip_vs_conn_tab_mask;
+int ip_vs_conn_tab_size __read_mostly;
+static int ip_vs_conn_tab_mask __read_mostly;
 
 /*
  *  Connection hash table: for input and output packets lookups of IPVS
  */
-static struct list_head *ip_vs_conn_tab;
+static struct list_head *ip_vs_conn_tab __read_mostly;
 
 /*  SLAB cache for IPVS connections */
 static struct kmem_cache *ip_vs_conn_cachep __read_mostly;
@@ -71,7 +71,7 @@ static atomic_t ip_vs_conn_count = ATOMIC_INIT(0);
 static atomic_t ip_vs_conn_no_cport_cnt = ATOMIC_INIT(0);
 
 /* random value for IPVS connection hash */
-static unsigned int ip_vs_conn_rnd;
+static unsigned int ip_vs_conn_rnd __read_mostly;
 
 /*
  *  Fine locking granularity for big connection hash table
-- 
1.7.2.3

