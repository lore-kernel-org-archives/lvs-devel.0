From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv2 net-next 14/15] ipvs: reorder keys in connection structure
Date: Sat,  9 Mar 2013 23:16:54 +0200
Message-ID: <1362863815-5898-15-git-send-email-ja@ssi.bg>
References: <1362863815-5898-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362863815-5898-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

	__ip_vs_conn_in_get and ip_vs_conn_out_get are
hot places. Optimize them, so that ports are matched first.
By moving net and fwmark below, on 32-bit arch we can fit
caddr in 32-byte cache line and all addresses in 64-byte
cache line.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |   12 ++++++------
 net/netfilter/ipvs/ip_vs_conn.c |   19 ++++++++++---------
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9059360..2bc30e6 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -566,20 +566,19 @@ struct ip_vs_conn_param {
  */
 struct ip_vs_conn {
 	struct hlist_node	c_list;         /* hashed list heads */
-#ifdef CONFIG_NET_NS
-	struct net              *net;           /* Name space */
-#endif
 	/* Protocol, addresses and port numbers */
-	u16                     af;             /* address family */
 	__be16                  cport;
-	__be16                  vport;
 	__be16                  dport;
-	__u32                   fwmark;         /* Fire wall mark from skb */
+	__be16                  vport;
+	u16			af;		/* address family */
 	union nf_inet_addr      caddr;          /* client address */
 	union nf_inet_addr      vaddr;          /* virtual address */
 	union nf_inet_addr      daddr;          /* destination address */
 	volatile __u32          flags;          /* status flags */
 	__u16                   protocol;       /* Which protocol (TCP/UDP) */
+#ifdef CONFIG_NET_NS
+	struct net              *net;           /* Name space */
+#endif
 
 	/* counter and timer */
 	atomic_t		refcnt;		/* reference count */
@@ -593,6 +592,7 @@ struct ip_vs_conn {
 						 * state transition triggerd
 						 * synchronization
 						 */
+	__u32			fwmark;		/* Fire wall mark from skb */
 	unsigned long		sync_endtime;	/* jiffies + sent_retries */
 
 	/* Control members */
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index b0cd2be..416015b 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -265,8 +265,8 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
 	rcu_read_lock();
 
 	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (cp->af == p->af &&
-		    p->cport == cp->cport && p->vport == cp->vport &&
+		if (p->cport == cp->cport && p->vport == cp->vport &&
+		    cp->af == p->af &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->vaddr) &&
 		    ((!p->cport) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
@@ -350,9 +350,9 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 	rcu_read_lock();
 
 	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (!ip_vs_conn_net_eq(cp, p->net))
-			continue;
-		if (p->pe_data && p->pe->ct_match) {
+		if (unlikely(p->pe_data && p->pe->ct_match)) {
+			if (!ip_vs_conn_net_eq(cp, p->net))
+				continue;
 			if (p->pe == cp->pe && p->pe->ct_match(p, cp)) {
 				if (__ip_vs_conn_get(cp))
 					goto out;
@@ -366,9 +366,10 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 		     * p->vaddr is a fwmark */
 		    ip_vs_addr_equal(p->protocol == IPPROTO_IP ? AF_UNSPEC :
 				     p->af, p->vaddr, &cp->vaddr) &&
-		    p->cport == cp->cport && p->vport == cp->vport &&
+		    p->vport == cp->vport && p->cport == cp->cport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
-		    p->protocol == cp->protocol) {
+		    p->protocol == cp->protocol &&
+		    ip_vs_conn_net_eq(cp, p->net)) {
 			if (__ip_vs_conn_get(cp))
 				goto out;
 		}
@@ -404,8 +405,8 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 	rcu_read_lock();
 
 	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (cp->af == p->af &&
-		    p->vport == cp->cport && p->cport == cp->dport &&
+		if (p->vport == cp->cport && p->cport == cp->dport &&
+		    cp->af == p->af &&
 		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
 		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
 		    p->protocol == cp->protocol &&
-- 
1.7.3.4

