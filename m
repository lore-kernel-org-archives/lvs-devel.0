From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v3 05/20] ipvs: maintain a mixed_address_family_dest count
Date: Wed, 27 Aug 2014 22:43:39 -0700
Message-ID: <1409204634-1123-6-git-send-email-agartrell@fb.com>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=jeKf0JNsPIUaXHYHeYLMsI6boQQqFJmwOw9Iniacuwo=;
 b=OoAOqhFNd+n9GgH/yxuocHJEK9WyZM826DvvCn31FLwdeBE/WPpJ/IbU7RxuUW9q/9F1
 Oin5JJiWaPwdZfmFV6xmAI0f907x9Q6uizueq46dv9Q+x4ULHXR8cQPUqkSdir6UQ0UD
 5QRO7WacwkDdYiDseGpU7OirLRBtsSaDGjM= 
In-Reply-To: <1409204634-1123-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

This is necessary to validate that we're not accidentally enabling
heterogeneous pool incompatible features like syncing.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h            | 4 ++++
 net/netfilter/ipvs/ip_vs_ctl.c | 9 +++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7600dbe..576d7f0 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -990,6 +990,10 @@ struct netns_ipvs {
 	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 	/* net name space ptr */
 	struct net		*net;            /* Needed by timer routines */
+	/* Number of heterogeneous destinations, needed because
+	 * heterogeneous are not supported when synchronization is
+	 * enabled */
+	unsigned int		mixed_address_family_dests;
 };
 
 #define DEFAULT_SYNC_THRESHOLD	3
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 01c813e..beffb8f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -779,6 +779,12 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	struct ip_vs_scheduler *sched;
 	int conn_flags;
 
+	/* We cannot modify an address and change the address family */
+	BUG_ON(!add && udest->af != dest->af);
+
+	if (add && udest->af != svc->af)
+		ipvs->mixed_address_family_dests++;
+
 	/* set the weight and the flags */
 	atomic_set(&dest->weight, udest->weight);
 	conn_flags = udest->conn_flags & IP_VS_CONN_F_DEST_MASK;
@@ -1061,6 +1067,9 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	list_del_rcu(&dest->n_list);
 	svc->num_dests--;
 
+	if (dest->af != svc->af)
+		net_ipvs(svc->net)->mixed_address_family_dests--;
+
 	if (svcupd) {
 		struct ip_vs_scheduler *sched;
 
-- 
1.8.1

