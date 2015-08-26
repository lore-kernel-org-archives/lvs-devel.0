From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next,v4 07/14] ipvs: add schedule_icmp sysctl
Date: Wed, 26 Aug 2015 09:40:34 -0700
Message-ID: <1440607241-355987-7-git-send-email-agartrell@fb.com>
References: <1440607241-355987-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=GQNFndpIyn6AB1Iqsh61xAZf58w6sPy5bJ2BXYOdHnU=;
 b=rHurbnlp9kuEU7WT/Vduz4TeEcuHPKilhzHvOMJytPB18BrWDegirXfb7vUDWSJLQku3
 IxzqRm6HE39Izu7Fae183i1alv+u8Lc7IJMwuuCqwnjYHmVCzznXI5NweZdz2tpqWfnr
 B/lIGJ7Fs2zvr4F5s0bi+blxJP2MonohvOA= 
In-Reply-To: <1440607241-355987-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: alexgartrell@gmail.com, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

This sysctl will be used to enable the scheduling of icmp packets.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/ip_vs.h            | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c |  8 +++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3d47b5f..786cb9b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -986,6 +986,7 @@ struct netns_ipvs {
 	int			sysctl_pmtu_disc;
 	int			sysctl_backup_only;
 	int			sysctl_conn_reuse_mode;
+	int			sysctl_schedule_icmp;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1109,6 +1110,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_conn_reuse_mode;
 }
 
+static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_schedule_icmp;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1181,6 +1187,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
 	return 1;
 }
 
+static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
+{
+	return 0;
+}
+
 #endif
 
 /* IPVS core functions
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 24c5542..2d57d41 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1844,6 +1844,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "schedule_icmp",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -3818,7 +3824,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_backup_only;
 	ipvs->sysctl_conn_reuse_mode = 1;
 	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
