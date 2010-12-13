From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 19/22] IPVS: netns, trash handling
Date: Mon, 13 Dec 2010 14:38:27 +0100
Message-ID: <1292247510-753-20-git-send-email-hans.schillstrom@ericsson.com>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

trash list per namspace,
and reordering of some params in dst struct.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/ip_vs.h            |    4 ++--
 include/net/netns/ip_vs.h      |    3 +++
 net/netfilter/ipvs/ip_vs_ctl.c |   23 ++++++++++-------------
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 057c954..943c766 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -644,8 +644,8 @@ struct ip_vs_dest {
 	struct list_head	d_list;   /* for table with all the dests */
 
 	u16			af;		/* address family */
-	union nf_inet_addr	addr;		/* IP address of the server */
 	__be16			port;		/* port number of the server */
+	union nf_inet_addr	addr;		/* IP address of the server */
 	volatile unsigned	flags;		/* dest status flags */
 	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
@@ -672,8 +672,8 @@ struct ip_vs_dest {
 	/* for virtual service */
 	struct ip_vs_service	*svc;		/* service it belongs to */
 	__u16			protocol;	/* which protocol (TCP/UDP) */
-	union nf_inet_addr	vaddr;		/* virtual IP address */
 	__be16			vport;		/* virtual port number */
+	union nf_inet_addr	vaddr;		/* virtual IP address */
 	__u32			vfwmark;	/* firewall mark of service */
 };
 
diff --git a/include/net/netns/ip_vs.h b/include/net/netns/ip_vs.h
index eeb1dd1..b70444d 100644
--- a/include/net/netns/ip_vs.h
+++ b/include/net/netns/ip_vs.h
@@ -82,6 +82,9 @@ struct netns_ipvs {
 	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
 	struct mutex		ctl_mutex;
 	struct lock_class_key 	ctl_key;	/* ctl_mutex debuging */
+	/* Trash for destinations */
+	struct list_head	dest_trash;
+
 	/* sys-ctl struct */
 	struct ctl_table_header	*sysctl_hdr;
 	struct ctl_table	*sysctl_tbl;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 747bc96..418f6ba 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -253,11 +253,6 @@ static struct list_head ip_vs_svc_table[IP_VS_SVC_TAB_SIZE];
 static struct list_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
 
 /*
- *	Trash for destinations
- */
-static LIST_HEAD(ip_vs_dest_trash);
-
-/*
  *	FTP & NULL virtual service counters
  */
 static atomic_t ip_vs_ftpsvc_counter = ATOMIC_INIT(0);
@@ -645,11 +640,12 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
 		     __be16 dport)
 {
 	struct ip_vs_dest *dest, *nxt;
+	struct netns_ipvs *ipvs = net_ipvs(svc->net);
 
 	/*
 	 * Find the destination in trash
 	 */
-	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
+	list_for_each_entry_safe(dest, nxt, &ipvs->dest_trash, n_list) {
 		IP_VS_DBG_BUF(3, "Destination %u/%s:%u still in trash, "
 			      "dest->refcnt=%d\n",
 			      dest->vfwmark,
@@ -697,11 +693,12 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, const union nf_inet_addr *daddr,
  *  are expired, and the refcnt of each destination in the trash must
  *  be 1, so we simply release them here.
  */
-static void ip_vs_trash_cleanup(void)
+static void ip_vs_trash_cleanup(struct net *net)
 {
 	struct ip_vs_dest *dest, *nxt;
+	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
+	list_for_each_entry_safe(dest, nxt, &ipvs->dest_trash, n_list) {
 		list_del(&dest->n_list);
 		ip_vs_dst_reset(dest);
 		__ip_vs_unbind_svc(dest);
@@ -826,7 +823,6 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 		pr_err("%s(): no memory.\n", __func__);
 		return -ENOMEM;
 	}
-
 	dest->af = svc->af;
 	dest->protocol = svc->protocol;
 	dest->vaddr = svc->addr;
@@ -1004,7 +1000,7 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest)
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port),
 			      atomic_read(&dest->refcnt));
-		list_add(&dest->n_list, &ip_vs_dest_trash);
+		list_add(&dest->n_list, &ipvs->dest_trash);
 		atomic_inc(&dest->refcnt);
 	}
 }
@@ -3435,6 +3431,7 @@ int __net_init __ip_vs_control_init(struct net *net)
 	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)  {
 		INIT_LIST_HEAD(&ipvs->rs_table[idx]);
 	}
+	INIT_LIST_HEAD(&ipvs->dest_trash);
 
 	/* procfs stats */
 	ipvs->ctl_stats = kzalloc(sizeof(struct ip_vs_stats), GFP_KERNEL);
@@ -3515,12 +3512,13 @@ static void __net_exit __ip_vs_control_cleanup(struct net *net)
 	if (!net_eq(net, &init_net))	/* netns not enabled yet */
 		return;
 
+	ip_vs_trash_cleanup(net);
 	ip_vs_kill_estimator(net, ipvs->ctl_stats);
+	cancel_rearming_delayed_work(&ipvs->defense_work);
+	cancel_work_sync(&ipvs->defense_work.work);
 	unregister_net_sysctl_table(ipvs->sysctl_hdr);
 	proc_net_remove(net, "ip_vs_stats");
 	proc_net_remove(net, "ip_vs");
-	cancel_rearming_delayed_work(&ipvs->defense_work);
-	cancel_work_sync(&ipvs->defense_work.work);
 	free_percpu(ipvs->ustats);
 	kfree(ipvs->ctl_stats);
 }
@@ -3577,7 +3575,6 @@ err:
 void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
-	ip_vs_trash_cleanup();
 	unregister_pernet_subsys(&ipvs_control_ops);
 	ip_vs_genl_unregister();
 	nf_unregister_sockopt(&ip_vs_sockopts);
-- 
1.7.2.3

