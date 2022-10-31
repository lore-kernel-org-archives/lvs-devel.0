From: Zhengchao Shao <shaozhengchao@huawei.com>
Subject: [PATCH net,v2 1/2] ipvs: fix WARNING in __ip_vs_cleanup_batch()
Date: Mon, 31 Oct 2022 20:07:04 +0800
Message-ID: <20221031120705.230059-2-shaozhengchao@huawei.com>
References: <20221031120705.230059-1-shaozhengchao@huawei.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20221031120705.230059-1-shaozhengchao@huawei.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com
Cc: hans.schillstrom@ericsson.com, ebiederm@xmission.com, weiyongjun1@huawei.com, yuehaibing@huawei.com, shaozhengchao@huawei.com

During the initialization of ip_vs_conn_net_init(), if file ip_vs_conn
or ip_vs_conn_sync fails to be created, the initialization is successful
by default. Therefore, the ip_vs_conn or ip_vs_conn_sync file doesn't
be found during the remove.

The following is the stack information:
name 'ip_vs_conn_sync'
WARNING: CPU: 3 PID: 9 at fs/proc/generic.c:712
remove_proc_entry+0x389/0x460
Modules linked in:
Workqueue: netns cleanup_net
RIP: 0010:remove_proc_entry+0x389/0x460
Call Trace:
<TASK>
__ip_vs_cleanup_batch+0x7d/0x120
ops_exit_list+0x125/0x170
cleanup_net+0x4ea/0xb00
process_one_work+0x9bf/0x1710
worker_thread+0x665/0x1080
kthread+0x2e4/0x3a0
ret_from_fork+0x1f/0x30
</TASK>

Fixes: 61b1ab4583e2 ("IPVS: netns, add basic init per netns.")
Signed-off-by: Zhengchao Shao <shaozhengchao@huawei.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 8c04bb57dd6f..fa548c9e6aae 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1447,20 +1447,36 @@ int __net_init ip_vs_conn_net_init(struct netns_ipvs *ipvs)
 {
 	atomic_set(&ipvs->conn_count, 0);
 
-	proc_create_net("ip_vs_conn", 0, ipvs->net->proc_net,
-			&ip_vs_conn_seq_ops, sizeof(struct ip_vs_iter_state));
-	proc_create_net("ip_vs_conn_sync", 0, ipvs->net->proc_net,
-			&ip_vs_conn_sync_seq_ops,
-			sizeof(struct ip_vs_iter_state));
+#ifdef CONFIG_PROC_FS
+	if (!proc_create_net("ip_vs_conn", 0, ipvs->net->proc_net,
+			     &ip_vs_conn_seq_ops,
+			     sizeof(struct ip_vs_iter_state)))
+		goto err_conn;
+
+	if (!proc_create_net("ip_vs_conn_sync", 0, ipvs->net->proc_net,
+			     &ip_vs_conn_sync_seq_ops,
+			     sizeof(struct ip_vs_iter_state)))
+		goto err_conn_sync;
+#endif
+
 	return 0;
+
+#ifdef CONFIG_PROC_FS
+err_conn_sync:
+	remove_proc_entry("ip_vs_conn", ipvs->net->proc_net);
+err_conn:
+	return -ENOMEM;
+#endif
 }
 
 void __net_exit ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs)
 {
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(ipvs);
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("ip_vs_conn", ipvs->net->proc_net);
 	remove_proc_entry("ip_vs_conn_sync", ipvs->net->proc_net);
+#endif
 }
 
 int __init ip_vs_conn_init(void)
-- 
2.17.1

