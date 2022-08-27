From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC PATCH 4/4] ipvs: run_estimation should control the kthread tasks
Date: Sat, 27 Aug 2022 20:41:54 +0300
Message-ID: <20220827174154.220651-5-ja@ssi.bg>
References: <20220827174154.220651-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220827174154.220651-1-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, yunhjiang@ebay.com, dust.li@linux.alibaba.com, tangyang@zhihu.com

Change the run_estimation flag to start/stop the kthread tasks.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Documentation/networking/ipvs-sysctl.rst |  4 ++--
 include/net/ip_vs.h                      |  6 +++--
 net/netfilter/ipvs/ip_vs_ctl.c           | 29 +++++++++++++++++++++++-
 net/netfilter/ipvs/ip_vs_est.c           |  4 +---
 4 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index 90c7c325421a..eb33355aa625 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -324,8 +324,8 @@ run_estimation - BOOLEAN
 	0 - disabled
 	not 0 - enabled (default)
 
-	If disabled, the estimation will be stop, and you can't see
-	any update on speed estimation data.
+	If disabled, the estimation will be suspended and kthread tasks
+	stopped.
 
 	You can always re-enable estimation by setting this value to 1.
 	But be careful, the first estimation after re-enable is not
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7027eca6dab8..428b885c2063 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1598,8 +1598,10 @@ static inline void ip_vs_est_wait_resched(struct netns_ipvs *ipvs,
 static inline void ip_vs_est_stopped_recalc(struct netns_ipvs *ipvs)
 {
 #ifdef CONFIG_SYSCTL
-	ipvs->est_stopped = ipvs->est_cpulist_valid &&
-			    cpumask_empty(sysctl_est_cpulist(ipvs));
+	/* Stop tasks while cpulist is empty or if disabled with flag */
+	ipvs->est_stopped = !sysctl_run_estimation(ipvs) ||
+			    (ipvs->est_cpulist_valid &&
+			     cpumask_empty(sysctl_est_cpulist(ipvs)));
 #endif
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6279517104c6..8d03eddfb19f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2020,6 +2020,32 @@ static int ipvs_proc_est_nice(struct ctl_table *table, int write,
 	return ret;
 }
 
+static int ipvs_proc_run_estimation(struct ctl_table *table, int write,
+				    void *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct netns_ipvs *ipvs = table->extra2;
+	int *valp = table->data;
+	int val = *valp;
+	int ret;
+
+	struct ctl_table tmp_table = {
+		.data = &val,
+		.maxlen = sizeof(int),
+		.mode = table->mode,
+	};
+
+	ret = proc_dointvec(&tmp_table, write, buffer, lenp, ppos);
+	if (write && ret >= 0) {
+		mutex_lock(&ipvs->est_mutex);
+		if (*valp != val) {
+			*valp = val;
+			ip_vs_est_reload_start(ipvs, true);
+		}
+		mutex_unlock(&ipvs->est_mutex);
+	}
+	return ret;
+}
+
 /*
  *	IPVS sysctl table (under the /proc/sys/net/ipv4/vs/)
  *	Do not change order or insert new entries without
@@ -2194,7 +2220,7 @@ static struct ctl_table vs_vars[] = {
 		.procname	= "run_estimation",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= ipvs_proc_run_estimation,
 	},
 	{
 		.procname	= "est_cpulist",
@@ -4282,6 +4308,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	tbl[idx++].data = &ipvs->sysctl_schedule_icmp;
 	tbl[idx++].data = &ipvs->sysctl_ignore_tunneled;
 	ipvs->sysctl_run_estimation = 1;
+	tbl[idx].extra2 = ipvs;
 	tbl[idx++].data = &ipvs->sysctl_run_estimation;
 
 	ipvs->est_cpulist_valid = 0;
diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 0bbc6158339e..0e52e64efac8 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -146,7 +146,6 @@ static void ip_vs_estimation_chain(struct ip_vs_est_kt_data *kd, int row)
 static int ip_vs_estimation_kthread(void *data)
 {
 	struct ip_vs_est_kt_data *kd = data;
-	struct netns_ipvs *ipvs = kd->ipvs;
 	int row = kd->est_row;
 	unsigned long now;
 	long gap;
@@ -171,8 +170,7 @@ static int ip_vs_estimation_kthread(void *data)
 				kd->est_timer = now;
 		}
 
-		if (sysctl_run_estimation(ipvs) &&
-		    !hlist_empty(&kd->chains[row]))
+		if (!hlist_empty(&kd->chains[row]))
 			ip_vs_estimation_chain(kd, row);
 
 		row++;
-- 
2.37.2


