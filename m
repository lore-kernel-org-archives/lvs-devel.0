From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 12/12] ipvs: avoid kmem_cache_zalloc in ip_vs_conn_new
Date: Wed,  6 Mar 2013 10:42:22 +0200
Message-ID: <1362559342-18784-13-git-send-email-ja@ssi.bg>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1362559342-18784-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	We have many fields to set and few to reset,
use kmem_cache_alloc instead to save some cycles.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a4d8ec5..1a0c7f3 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -860,7 +860,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	struct ip_vs_proto_data *pd = ip_vs_proto_data_get(p->net,
 							   p->protocol);
 
-	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
+	cp = kmem_cache_alloc(ip_vs_conn_cachep, GFP_ATOMIC);
 	if (cp == NULL) {
 		IP_VS_ERR_RL("%s(): no memory\n", __func__);
 		return NULL;
@@ -886,6 +886,10 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 		cp->pe = p->pe;
 		cp->pe_data = p->pe_data;
 		cp->pe_data_len = p->pe_data_len;
+	} else {
+		cp->pe = NULL;
+		cp->pe_data = NULL;
+		cp->pe_data_len = 0;
 	}
 	spin_lock_init(&cp->lock);
 
@@ -896,18 +900,28 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
 	 */
 	atomic_set(&cp->refcnt, 1);
 
+	cp->control = NULL;
 	atomic_set(&cp->n_control, 0);
 	atomic_set(&cp->in_pkts, 0);
 
+	cp->packet_xmit = NULL;
+	cp->app = NULL;
+	cp->app_data = NULL;
+	/* reset struct ip_vs_seq */
+	cp->in_seq.delta = 0;
+	cp->out_seq.delta = 0;
+
 	atomic_inc(&ipvs->conn_count);
 	if (flags & IP_VS_CONN_F_NO_CPORT)
 		atomic_inc(&ip_vs_conn_no_cport_cnt);
 
 	/* Bind the connection with a destination server */
+	cp->dest = NULL;
 	ip_vs_bind_dest(cp, dest);
 
 	/* Set its state and timeout */
 	cp->state = 0;
+	cp->old_state = 0;
 	cp->timeout = 3*HZ;
 	cp->sync_endtime = jiffies & ~3UL;
 
-- 
1.7.3.4
