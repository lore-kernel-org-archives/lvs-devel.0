From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 20/22] IPVS: netns, svc counters moved in ip_vs_ctl,c
Date: Thu,  6 Jan 2011 15:16:16 +0900
Message-ID: <1294294578-8601-21-git-send-email-horms@verge.net.au>
References: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1294294578-8601-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

Last two global vars to be moved,
ip_vs_ftpsvc_counter and ip_vs_nullsvc_counter.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/netns/ip_vs.h      |    4 ++++
 net/netfilter/ipvs/ip_vs_ctl.c |   21 +++++++++------------
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index 67ca1cf..48d7f54 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -70,6 +70,7 @@ struct netns_ipvs {
 	seqcount_t			*ustats_seq; /* u64 read retry */
 
 	int			num_services;    /* no of virtual services */
+
 	/* 1/rate drop and drop-entry variables */
 	struct delayed_work	defense_work;   /* Work handler */
 	int			drop_rate;
@@ -84,6 +85,9 @@ struct netns_ipvs {
 	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
 	/* Trash for destinations */
 	struct list_head	dest_trash;
+	/* Service counters */
+	atomic_t		ftpsvc_counter;
+	atomic_t		nullsvc_counter;
 
 	/* sys-ctl struct */
 	struct ctl_table_header	*sysctl_hdr;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index f99f075..090eba7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -256,12 +256,6 @@ static struct list_head ip_vs_svc_table[IP_VS_SVC_TAB_SIZE];
 /* the service table hashed by fwmark */
 static struct list_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
 
-/*
- *	FTP & NULL virtual service counters
- */
-static atomic_t ip_vs_ftpsvc_counter = ATOMIC_INIT(0);
-static atomic_t ip_vs_nullsvc_counter = ATOMIC_INIT(0);
-
 
 /*
  *	Returns hash value for virtual service
@@ -411,6 +405,7 @@ ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport)
 {
 	struct ip_vs_service *svc;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	read_lock(&__ip_vs_svc_lock);
 
@@ -429,7 +424,7 @@ ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 
 	if (svc == NULL
 	    && protocol == IPPROTO_TCP
-	    && atomic_read(&ip_vs_ftpsvc_counter)
+	    && atomic_read(&ipvs->ftpsvc_counter)
 	    && (vport == FTPDATA || ntohs(vport) >= PROT_SOCK)) {
 		/*
 		 * Check if ftp service entry exists, the packet
@@ -439,7 +434,7 @@ ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 	}
 
 	if (svc == NULL
-	    && atomic_read(&ip_vs_nullsvc_counter)) {
+	    && atomic_read(&ipvs->nullsvc_counter)) {
 		/*
 		 * Check if the catch-all port (port zero) exists
 		 */
@@ -1175,9 +1170,9 @@ ip_vs_add_service(struct net *net, struct ip_vs_service_user_kern *u,
 
 	/* Update the virtual service counters */
 	if (svc->port == FTPPORT)
-		atomic_inc(&ip_vs_ftpsvc_counter);
+		atomic_inc(&ipvs->ftpsvc_counter);
 	else if (svc->port == 0)
-		atomic_inc(&ip_vs_nullsvc_counter);
+		atomic_inc(&ipvs->nullsvc_counter);
 
 	ip_vs_new_estimator(net, &svc->stats);
 
@@ -1361,9 +1356,9 @@ static void __ip_vs_del_service(struct ip_vs_service *svc)
 	 *    Update the virtual service counters
 	 */
 	if (svc->port == FTPPORT)
-		atomic_dec(&ip_vs_ftpsvc_counter);
+		atomic_dec(&ipvs->ftpsvc_counter);
 	else if (svc->port == 0)
-		atomic_dec(&ip_vs_nullsvc_counter);
+		atomic_dec(&ipvs->nullsvc_counter);
 
 	/*
 	 *    Free the service if nobody refers to it
@@ -3503,6 +3498,8 @@ int __net_init __ip_vs_control_init(struct net *net)
 		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
 
 	INIT_LIST_HEAD(&ipvs->dest_trash);
+	atomic_set(&ipvs->ftpsvc_counter, 0);
+	atomic_set(&ipvs->nullsvc_counter, 0);
 
 	/* procfs stats */
 	ipvs->tot_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
-- 
1.7.2.3

