From: Dust Li <dust.li@linux.alibaba.com>
Subject: [PATCH net-next v3] net: ipvs: add sysctl_run_estimation to support disable estimation
Date: Thu, 19 Aug 2021 16:44:18 +0800
Message-ID: <20210819084418.27004-1-dust.li@linux.alibaba.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>

estimation_timer will iterater the est_list to do estimation
for each ipvs stats. When there are lots of services, the
list can be very large.
We observiced estimation_timer() run for more then 200ms on
a machine with 104 CPU and 50K services.

yunhong-cgl jiang report the same phenomenon before:
https://www.spinics.net/lists/lvs-devel/msg05426.html

In some cases(for example a large K8S cluster with many ipvs services),
ipvs estimation may not be needed. So adding a sysctl blob to allow
users to disable this completely.

Default is: 1 (enable)

Cc: yunhong-cgl jiang <xintian1976@gmail.com>
Signed-off-by: Dust Li <dust.li@linux.alibaba.com>
---
v2: Use common sysctl facilities
v3: Fix sysctl_run_estimation() redefine when CONFIG_SYSCTL not enabled
---
 Documentation/networking/ipvs-sysctl.rst | 17 +++++++++++++++++
 include/net/ip_vs.h                      | 12 ++++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c           |  8 ++++++++
 net/netfilter/ipvs/ip_vs_est.c           |  5 +++++
 4 files changed, 42 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index 2afccc63856e..e20f7a27fc85 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -300,3 +300,20 @@ sync_version - INTEGER
 
 	Kernels with this sync_version entry are able to receive messages
 	of both version 1 and version 2 of the synchronisation protocol.
+
+run_estimation - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	If disabled, the estimation will be stop, and you can't see
+	any update on speed estimation data.
+
+	For example
+	'Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s'
+	those data in /proc/net/ip_vs_stats will always be zero.
+	Note, this only affect the speed estimation, the total data
+	will still be updated.
+
+	You can always re-enable estimation by setting this value to 1.
+	But be carefull, the first estimation after re-enable is not
+	accurate.
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7cb5a1aace40..269f8808f6db 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -931,6 +931,7 @@ struct netns_ipvs {
 	int			sysctl_conn_reuse_mode;
 	int			sysctl_schedule_icmp;
 	int			sysctl_ignore_tunneled;
+	int 			sysctl_run_estimation;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1071,6 +1072,11 @@ static inline int sysctl_cache_bypass(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_cache_bypass;
 }
 
+static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_run_estimation;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1163,6 +1169,11 @@ static inline int sysctl_cache_bypass(struct netns_ipvs *ipvs)
 	return 0;
 }
 
+static inline int sysctl_run_estimation(struct netns_ipvs *ipvs)
+{
+	return 1;
+}
+
 #endif
 
 /* IPVS core functions
@@ -1650,6 +1661,7 @@ static inline int ip_vs_confirm_conntrack(struct sk_buff *skb)
 static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 {
 }
+
 #endif /* CONFIG_IP_VS_NFCT */
 
 /* Using old conntrack that can not be redirected to another real server? */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c25097092a06..cbea5a68afb5 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2017,6 +2017,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "run_estimation",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -4090,6 +4096,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
 	tbl[idx++].data = &ipvs->sysctl_schedule_icmp;
 	tbl[idx++].data = &ipvs->sysctl_ignore_tunneled;
+	ipvs->sysctl_run_estimation = 1;
+	tbl[idx++].data = &ipvs->sysctl_run_estimation;
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
 	if (ipvs->sysctl_hdr == NULL) {
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 05b8112ffb37..9a1a7af6a186 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -100,6 +100,9 @@ static void estimation_timer(struct timer_list *t)
 	u64 rate;
 	struct netns_ipvs *ipvs = from_timer(ipvs, t, est_timer);
 
+	if (!sysctl_run_estimation(ipvs))
+		goto skip;
+
 	spin_lock(&ipvs->est_lock);
 	list_for_each_entry(e, &ipvs->est_list, list) {
 		s = container_of(e, struct ip_vs_stats, est);
@@ -131,6 +134,8 @@ static void estimation_timer(struct timer_list *t)
 		spin_unlock(&s->lock);
 	}
 	spin_unlock(&ipvs->est_lock);
+
+skip:
 	mod_timer(&ipvs->est_timer, jiffies + 2*HZ);
 }
 
-- 
2.19.1.3.ge56e4f7

