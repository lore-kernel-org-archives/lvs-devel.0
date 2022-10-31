From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipvs: fix WARNING in __ip_vs_cleanup_batch()
Date: Mon, 31 Oct 2022 12:35:27 +0200 (EET)
Message-ID: <a92e1453-aa84-92f-5f6f-de1b7ec5d381@ssi.bg>
References: <20221031064956.332614-1-shaozhengchao@huawei.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20221031064956.332614-1-shaozhengchao@huawei.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zhengchao Shao <shaozhengchao@huawei.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Simon Horman <horms@verge.net.au>, pablo@netfilter.org, weiyongjun1@huawei.com, yuehaibing@huawei.com


	Hello,

On Mon, 31 Oct 2022, Zhengchao Shao wrote:

> During the initialization of ip_vs_conn_net_init(), if file ip_vs_conn
> or ip_vs_conn_sync fails to be created, the initialization is successful
> by default. Therefore, the ip_vs_conn or ip_vs_conn_sync file doesn't
> be found during the remove.
> 
> The following is the stack information:
> name 'ip_vs_conn_sync'
> WARNING: CPU: 3 PID: 9 at fs/proc/generic.c:712
> remove_proc_entry+0x389/0x460
> Modules linked in:
> Workqueue: netns cleanup_net
> RIP: 0010:remove_proc_entry+0x389/0x460
> Call Trace:
> <TASK>
> __ip_vs_cleanup_batch+0x7d/0x120
> ops_exit_list+0x125/0x170
> cleanup_net+0x4ea/0xb00
> process_one_work+0x9bf/0x1710
> worker_thread+0x665/0x1080
> kthread+0x2e4/0x3a0
> ret_from_fork+0x1f/0x30
> </TASK>
> 
> Fixes: 61b1ab4583e2 ("IPVS: netns, add basic init per netns.")
> Signed-off-by: Zhengchao Shao <shaozhengchao@huawei.com>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 8c04bb57dd6f..b126bd7df321 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1447,12 +1447,22 @@ int __net_init ip_vs_conn_net_init(struct netns_ipvs *ipvs)
>  {
>  	atomic_set(&ipvs->conn_count, 0);
>  
> -	proc_create_net("ip_vs_conn", 0, ipvs->net->proc_net,
> -			&ip_vs_conn_seq_ops, sizeof(struct ip_vs_iter_state));
> -	proc_create_net("ip_vs_conn_sync", 0, ipvs->net->proc_net,
> -			&ip_vs_conn_sync_seq_ops,
> -			sizeof(struct ip_vs_iter_state));
> +	if (!proc_create_net("ip_vs_conn", 0, ipvs->net->proc_net,
> +			     &ip_vs_conn_seq_ops,
> +			     sizeof(struct ip_vs_iter_state)))
> +		goto err_conn;
> +
> +	if (!proc_create_net("ip_vs_conn_sync", 0, ipvs->net->proc_net,
> +			     &ip_vs_conn_sync_seq_ops,
> +			     sizeof(struct ip_vs_iter_state)))
> +		goto err_conn_sync;
> +
>  	return 0;
> +
> +err_conn_sync:
> +	remove_proc_entry("ip_vs_conn", ipvs->net->proc_net);
> +err_conn:
> +	return -ENOMEM;
>  }
>  
>  void __net_exit ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs)
> -- 
> 2.17.1

	Good catch. But can you add some #ifdef CONFIG_PROC_FS
as done in commit 4bc3c8dc9f5f ("ipvs: fix possible memory leak in 
ip_vs_control_net_init") ? You can also extend it to include
ifdefs and ENOMEM in ip_vs_app.c:ip_vs_app_net_init(). If you
prefer, it can be a separate patch.

Regards

--
Julian Anastasov <ja@ssi.bg>

