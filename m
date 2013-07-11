From: Dragos Foianu <dragos.foianu@gmail.com>
Subject: [PATCH] ipvs: fixed style errors and warnings in ip_vs_conn
Date: Thu, 11 Jul 2013 22:41:35 +0300
Message-ID: <1373571695-24933-1-git-send-email-dragos.foianu@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id:x-mailer;
        bh=vtfXouqvaL1LCEVZexjVA4FN5DV2Cdew3op0gQOQpBY=;
        b=IQWqAEpiyLZp9zD109rDvTyNYP0zEg+xk6VWBmJ5BhjxGESJ/Yxg3Ywq4QooRxcH3R
         4uvE5hu050ir6J0pjsNnaxJjM1WPxCQJjyOx4CY8TOL95EhnWvXiouLSyw51woJkUZkU
         E08W2/hJ6RIyqQbXiiGP57S+jgsdb2VHr9ExZkyaGKq4AOv48BTWi88l5nFz21tmfeyY
         32QzfdzUSgHbuXn2w3xlCHnRG4v97O8qZyalkMQnObehz6bEEq2vtX7PNzegCAvcaDPx
         KsoLV1PrZD2/cu950stj07uTdEmwlQxBf6TzfbajwUfvPOpqj+58rokgq1//531NmwJF
         dvLA==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, Dragos Foianu <dragos.foianu@gmail.com>

found with the help of checkpatch.pl

Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
---
 net/netfilter/ipvs/ip_vs_conn.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 4c8e5c0..4927a52 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -77,8 +77,7 @@ static unsigned int ip_vs_conn_rnd __read_mostly;
 #define CT_LOCKARRAY_SIZE  (1<<CT_LOCKARRAY_BITS)
 #define CT_LOCKARRAY_MASK  (CT_LOCKARRAY_SIZE-1)
 
-struct ip_vs_aligned_lock
-{
+struct ip_vs_aligned_lock {
 	spinlock_t	l;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
@@ -395,7 +394,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 {
 	unsigned int hash;
-	struct ip_vs_conn *cp, *ret=NULL;
+	struct ip_vs_conn *cp, *ret = NULL;
 
 	/*
 	 *	Check for "full" addressed entries
@@ -680,11 +679,10 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
 		/* It is a normal connection, so decrease the inactconns
 		   or activeconns counter */
-		if (cp->flags & IP_VS_CONN_F_INACTIVE) {
+		if (cp->flags & IP_VS_CONN_F_INACTIVE)
 			atomic_dec(&dest->inactconns);
-		} else {
+		else
 			atomic_dec(&dest->activeconns);
-		}
 	} else {
 		/* It is a persistent connection/template, so decrease
 		   the persistent connection counter */
@@ -817,7 +815,7 @@ static void ip_vs_conn_expire(unsigned long data)
 		return;
 	}
 
-  expire_later:
+expire_later:
 	IP_VS_DBG(7, "delayed: conn->refcnt=%d conn->n_control=%d\n",
 		  atomic_read(&cp->refcnt),
 		  atomic_read(&cp->n_control));
@@ -988,7 +986,7 @@ static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
 
 	iter->l = NULL;
 	rcu_read_lock();
-	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;
+	return *pos ? ip_vs_conn_array(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -1189,10 +1187,13 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
 	/* Don't drop the entry if its number of incoming packets is not
 	   located in [0, 8] */
 	i = atomic_read(&cp->in_pkts);
-	if (i > 8 || i < 0) return 0;
+	if (i > 8 || i < 0)
+		return 0;
 
-	if (!todrop_rate[i]) return 0;
-	if (--todrop_counter[i] > 0) return 0;
+	if (!todrop_rate[i])
+		return 0;
+	if (--todrop_counter[i] > 0)
+		return 0;
 
 	todrop_counter[i] = todrop_rate[i];
 	return 1;
@@ -1218,7 +1219,7 @@ void ip_vs_random_dropentry(struct net *net)
 			if (!ip_vs_conn_net_eq(cp, net))
 				continue;
 			if (cp->protocol == IPPROTO_TCP) {
-				switch(cp->state) {
+				switch (cp->state) {
 				case IP_VS_TCP_S_SYN_RECV:
 				case IP_VS_TCP_S_SYNACK:
 					break;
@@ -1357,9 +1358,8 @@ int __init ip_vs_conn_init(void)
 	for (idx = 0; idx < ip_vs_conn_tab_size; idx++)
 		INIT_HLIST_HEAD(&ip_vs_conn_tab[idx]);
 
-	for (idx = 0; idx < CT_LOCKARRAY_SIZE; idx++)  {
+	for (idx = 0; idx < CT_LOCKARRAY_SIZE; idx++) 
 		spin_lock_init(&__ip_vs_conntbl_lock_array[idx].l);
-	}
 
 	/* calculate the random value for connection hash */
 	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
-- 
1.7.10.4

