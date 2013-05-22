From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] ipvs: change type of netns_ipvs->sysctl_sync_qlen_max
Date: Wed, 22 May 2013 14:56:48 +0900
Message-ID: <1369202209-18570-2-git-send-email-horms@verge.net.au>
References: <1369202209-18570-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369202209-18570-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Simon Horman <horms@verge.net.au>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

This member of struct netns_ipvs is calculated from nr_free_buffer_pages
so change its type to unsigned long in case of overflow.  Also, type of
its related proc var sync_qlen_max and the return type of function
sysctl_sync_qlen_max() should be changed to unsigned long, too.

Besides, the type of ipvs_master_sync_state->sync_queue_len should be
changed to unsigned long accordingly.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h            | 8 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4c062cc..4405886 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -905,7 +905,7 @@ struct ip_vs_app {
 struct ipvs_master_sync_state {
 	struct list_head	sync_queue;
 	struct ip_vs_sync_buff	*sync_buff;
-	int			sync_queue_len;
+	unsigned long		sync_queue_len;
 	unsigned int		sync_queue_delay;
 	struct task_struct	*master_thread;
 	struct delayed_work	master_wakeup_work;
@@ -998,7 +998,7 @@ struct netns_ipvs {
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
 	int			sysctl_sync_ports;
-	int			sysctl_sync_qlen_max;
+	unsigned long		sysctl_sync_qlen_max;
 	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
@@ -1085,7 +1085,7 @@ static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
 	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
 }
 
-static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_sync_qlen_max;
 }
@@ -1138,7 +1138,7 @@ static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
 	return 1;
 }
 
-static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return IPVS_SYNC_QLEN_MAX;
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5b142fb..7014649 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1716,9 +1716,9 @@ static struct ctl_table vs_vars[] = {
 	},
 	{
 		.procname	= "sync_qlen_max",
-		.maxlen		= sizeof(int),
+		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_doulongvec_minmax,
 	},
 	{
 		.procname	= "sync_sock_size",
-- 
1.8.2.1

