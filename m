From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v2 03/18] ipvs: maintain a mixed_address_family_dest count
Date: Thu, 14 Aug 2014 20:23:26 -0700
Message-ID: <1408073021-24007-4-git-send-email-agartrell@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=jBvaTudpXd2/vo998Y9xHQxyFFBahke+jAYMwZbxVXk=;
 b=C9EJ00oEH6p1Wv8W5yUD5SiRNlDHG+shN4s+2jooeFfNmJqvt7HNspzypGiK6JmXz1UK
 Jyti5kYoOBpYEL8N9Jjfy0VsGcX7MITKR1QrMzc0Zl6xFUVy/8LYl/PTJhdV+udnFoNj
 zLEdvYAYb8AqJT903yzsTdblu/XhEowzJKo= 
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
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
 include/net/ip_vs.h            |  4 ++++
 net/netfilter/ipvs/ip_vs_ctl.c | 13 +++++++++++++
 2 files changed, 17 insertions(+)

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
index 01c813e..2356f1d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -778,6 +778,16 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
 	struct ip_vs_service *old_svc;
 	struct ip_vs_scheduler *sched;
 	int conn_flags;
+	u16 old_af, new_af;
+
+	new_af = udest->af;
+	old_af = dest->af;
+
+	/* We cannot modify an address and change the address family */
+	BUG_ON(!add && udest->af != dest->af);
+
+	if (add && udest->af != svc->af)
+		ipvs->mixed_address_family_dests++;
 
 	/* set the weight and the flags */
 	atomic_set(&dest->weight, udest->weight);
@@ -1061,6 +1071,9 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	list_del_rcu(&dest->n_list);
 	svc->num_dests--;
 
+	if (dest->af != svc->af)
+		net_ipvs(svc->net)->mixed_address_family_dests--;
+
 	if (svcupd) {
 		struct ip_vs_scheduler *sched;
 
-- 
1.8.1

