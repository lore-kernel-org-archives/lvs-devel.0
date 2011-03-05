From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 18/18] IPVS: Conditionally include sysctl members of struct netns_ipvs
Date: Sun,  6 Mar 2011 08:46:00 +0900
Message-ID: <1299368760-14271-19-git-send-email-horms@verge.net.au>
References: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1299368760-14271-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>, Simon Horman <horms@verge.net.au>

There is now no need to include sysctl members of struct netns_ipvs
unless CONFIG_SYSCTL is defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7ef0813..9b92190 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -838,6 +838,17 @@ struct netns_ipvs {
 	struct ip_vs_stats		tot_stats;  /* Statistics & est. */
 
 	int			num_services;    /* no of virtual services */
+
+	rwlock_t		rs_lock;         /* real services table */
+	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
+	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
+	/* Trash for destinations */
+	struct list_head	dest_trash;
+	/* Service counters */
+	atomic_t		ftpsvc_counter;
+	atomic_t		nullsvc_counter;
+
+#ifdef CONFIG_SYSCTL
 	/* 1/rate drop and drop-entry variables */
 	struct delayed_work	defense_work;   /* Work handler */
 	int			drop_rate;
@@ -847,18 +858,12 @@ struct netns_ipvs {
 	spinlock_t		dropentry_lock;  /* drop entry handling */
 	spinlock_t		droppacket_lock; /* drop packet handling */
 	spinlock_t		securetcp_lock;  /* state and timeout tables */
-	rwlock_t		rs_lock;         /* real services table */
-	/* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
-	struct lock_class_key	ctl_key;	/* ctl_mutex debuging */
-	/* Trash for destinations */
-	struct list_head	dest_trash;
-	/* Service counters */
-	atomic_t		ftpsvc_counter;
-	atomic_t		nullsvc_counter;
 
 	/* sys-ctl struct */
 	struct ctl_table_header	*sysctl_hdr;
 	struct ctl_table	*sysctl_tbl;
+#endif
+
 	/* sysctl variables */
 	int			sysctl_amemthresh;
 	int			sysctl_am_droprate;
-- 
1.7.2.3

