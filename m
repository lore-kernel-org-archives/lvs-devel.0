From: Zhengchao Shao <shaozhengchao@huawei.com>
Subject: [PATCH net,v2 2/2] ipvs: fix WARNING in ip_vs_app_net_cleanup()
Date: Mon, 31 Oct 2022 20:07:05 +0800
Message-ID: <20221031120705.230059-3-shaozhengchao@huawei.com>
References: <20221031120705.230059-1-shaozhengchao@huawei.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221031120705.230059-1-shaozhengchao@huawei.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com
Cc: hans.schillstrom@ericsson.com, ebiederm@xmission.com, weiyongjun1@huawei.com, yuehaibing@huawei.com, shaozhengchao@huawei.com

During the initialization of ip_vs_app_net_init(), if file ip_vs_app
fails to be created, the initialization is successful by default.
Therefore, the ip_vs_app file doesn't be found during the remove in
ip_vs_app_net_cleanup(). It will cause WRNING.

The following is the stack information:
name 'ip_vs_app'
WARNING: CPU: 1 PID: 9 at fs/proc/generic.c:712 remove_proc_entry+0x389/0x460
Modules linked in:
Workqueue: netns cleanup_net
RIP: 0010:remove_proc_entry+0x389/0x460
Call Trace:
<TASK>
ops_exit_list+0x125/0x170
cleanup_net+0x4ea/0xb00
process_one_work+0x9bf/0x1710
worker_thread+0x665/0x1080
kthread+0x2e4/0x3a0
ret_from_fork+0x1f/0x30
</TASK>

Fixes: 457c4cbc5a3d ("[NET]: Make /proc/net per network namespace")
Signed-off-by: Zhengchao Shao <shaozhengchao@huawei.com>
---
 net/netfilter/ipvs/ip_vs_app.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index f9b16f2b2219..fdacbc3c15be 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -599,13 +599,19 @@ static const struct seq_operations ip_vs_app_seq_ops = {
 int __net_init ip_vs_app_net_init(struct netns_ipvs *ipvs)
 {
 	INIT_LIST_HEAD(&ipvs->app_list);
-	proc_create_net("ip_vs_app", 0, ipvs->net->proc_net, &ip_vs_app_seq_ops,
-			sizeof(struct seq_net_private));
+#ifdef CONFIG_PROC_FS
+	if (!proc_create_net("ip_vs_app", 0, ipvs->net->proc_net,
+			     &ip_vs_app_seq_ops,
+			     sizeof(struct seq_net_private)))
+		return -ENOMEM;
+#endif
 	return 0;
 }
 
 void __net_exit ip_vs_app_net_cleanup(struct netns_ipvs *ipvs)
 {
 	unregister_ip_vs_app(ipvs, NULL /* all */);
+#ifdef CONFIG_PROC_FS
 	remove_proc_entry("ip_vs_app", ipvs->net->proc_net);
+#endif
 }
-- 
2.17.1

