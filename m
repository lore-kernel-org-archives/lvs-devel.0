From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs 5/7] ipvs: maintain a mixed_address_family_dest count
Date: Tue, 29 Jul 2014 21:10:53 -0700
Message-ID: <1406693455-915-6-git-send-email-agartrell@fb.com>
References: <1406693455-915-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=BOdH2ndjyyW02vPRk0se3sxAEr+c1cznLtkDVHRNeXA=;
 b=rPAdmBh4rTiOpxjGv6hdCxmxT3o5sI5NEeZW8BNiIJNOZ98UkEGKxpvfyXFLHV0cssXg
 SKsSxlmMQpacjgz83n1XQ+iQQ37Wmg0iVLLp62u1SZdH1EMEwsA5rBXalaMjiHvboSa+
 o0dVsIdVleLopRRbGOky2JeCc5Xtc+/Bfdw= 
In-Reply-To: <1406693455-915-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

This is necessary to validate that we're not accidentally enabling
heterogeneous pool incompatible features like syncing.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h            |  4 ++++
 net/netfilter/ipvs/ip_vs_ctl.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 72698b1..69d8722 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -989,6 +989,10 @@ struct netns_ipvs {
 	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 	/* net name space ptr */
 	struct net		*net;            /* Needed by timer routines */
+	/* Number of heterogeneous destinations, needed because
+	 * heterogeneous are not supported when synchronization is
+	 * enabled */
+	unsigned int 		mixed_address_family_dests;
 };
 
 #define DEFAULT_SYNC_THRESHOLD	3
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6702cf8..1c0621b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -778,6 +778,21 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	struct ip_vs_service *old_svc;
 	struct ip_vs_scheduler *sched;
 	int conn_flags;
+	u16 old_af, new_af;
+
+	new_af = udest->af;
+	old_af = dest->af;
+
+	/* If we're adding a new dest or changing from the old one and the
+	 * af has changed */
+	if ((add || new_af != old_af) && new_af != svc->af) {
+		ipvs->mixed_address_family_dests++;
+	}
+	/* If we're editing an old dest, the af's have changed, and the af
+	 * is now the same as the service */
+	else if (!add && new_af != old_af && new_af == svc->af) {
+		ipvs->mixed_address_family_dests--;
+	}
 
 	/* set the weight and the flags */
 	atomic_set(&dest->weight, udest->weight);
@@ -1061,6 +1076,9 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	list_del_rcu(&dest->n_list);
 	svc->num_dests--;
 
+	if (dest->af != svc->af)
+		net_ipvs(svc->net)->mixed_address_family_dests--;
+
 	if (svcupd) {
 		struct ip_vs_scheduler *sched;
 
@@ -3336,6 +3354,11 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
 	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
 		return -EINVAL;
 
+	/* The synchronization protocol is incompatible with mixed family
+	 * services */
+	if (net_ipvs(net)->mixed_address_family_dests > 0)
+		return -EINVAL;
+
 	return start_sync_thread(net,
 				 nla_get_u32(attrs[IPVS_DAEMON_ATTR_STATE]),
 				 nla_data(attrs[IPVS_DAEMON_ATTR_MCAST_IFN]),
@@ -3466,6 +3489,25 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 		 * this will have the same address family as the service. */
 		if (udest.af == 0)
 			udest.af = svc->af;
+
+		if (udest.af != svc->af) {
+			/* The synchronization protocol is incompatible
+			 * with mixed family services */
+			if (net_ipvs(net)->sync_state) {
+				ret = -EINVAL;
+				goto out;
+			}
+
+			/* Which connection types do we support? */
+			switch (udest.conn_flags) {
+			case IP_VS_CONN_F_TUNNEL:
+				/* We are able to forward this */
+				break;
+			default:
+				ret = -EINVAL;
+				goto out;
+			}
+		}
 	}
 
 	switch (cmd) {
-- 
1.8.1

