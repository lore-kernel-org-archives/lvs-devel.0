From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH,v2] ipvs: fix the connection sync failed in some cases
Date: Sun, 19 Jul 2020 09:08:39 +0300 (EEST)
Message-ID: <alpine.LFD.2.23.451.2007190837120.3463@ja.home.ssi.bg>
References: <1594887128-7453-1-git-send-email-geffrey.guo@huawei.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1594887128-7453-1-git-send-email-geffrey.guo@huawei.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: guodeqing <geffrey.guo@huawei.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Thu, 16 Jul 2020, guodeqing wrote:

> The sync_thread_backup only checks sk_receive_queue is empty or not,
> there is a situation which cannot sync the connection entries when
> sk_receive_queue is empty and sk_rmem_alloc is larger than sk_rcvbuf,
> the sync packets are dropped in __udp_enqueue_schedule_skb, this is
> because the packets in reader_queue is not read, so the rmem is
> not reclaimed.
> 
> Here I add the check of whether the reader_queue of the udp sock is
> empty or not to solve this problem.
> 
> Fixes: 2276f58ac589 ("udp: use a separate rx queue for packet reception")
> Reported-by: zhouxudong <zhouxudong8@huawei.com>
> Signed-off-by: guodeqing <geffrey.guo@huawei.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, Pablo, this patch should be applied to the nf tree.
As the reader_queue appears in 4.13, this patch can be backported
to 4.14, 4.19, 5.4, etc, they all have skb_queue_empty_lockless.

> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 605e0f6..2b8abbf 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1717,6 +1717,8 @@ static int sync_thread_backup(void *data)
>  {
>  	struct ip_vs_sync_thread_data *tinfo = data;
>  	struct netns_ipvs *ipvs = tinfo->ipvs;
> +	struct sock *sk = tinfo->sock->sk;
> +	struct udp_sock *up = udp_sk(sk);
>  	int len;
>  
>  	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
> @@ -1724,12 +1726,14 @@ static int sync_thread_backup(void *data)
>  		ipvs->bcfg.mcast_ifn, ipvs->bcfg.syncid, tinfo->id);
>  
>  	while (!kthread_should_stop()) {
> -		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
> -			 !skb_queue_empty(&tinfo->sock->sk->sk_receive_queue)
> -			 || kthread_should_stop());
> +		wait_event_interruptible(*sk_sleep(sk),
> +					 !skb_queue_empty_lockless(&sk->sk_receive_queue) ||
> +					 !skb_queue_empty_lockless(&up->reader_queue) ||
> +					 kthread_should_stop());
>  
>  		/* do we have data now? */
> -		while (!skb_queue_empty(&(tinfo->sock->sk->sk_receive_queue))) {
> +		while (!skb_queue_empty_lockless(&sk->sk_receive_queue) ||
> +		       !skb_queue_empty_lockless(&up->reader_queue)) {
>  			len = ip_vs_receive(tinfo->sock, tinfo->buf,
>  					ipvs->bcfg.sync_maxlen);
>  			if (len <= 0) {
> -- 
> 2.7.4

Regards

--
Julian Anastasov <ja@ssi.bg>
