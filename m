From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 5/9] ipvs: use adaptive pause in master thread
Date: Sun, 8 Apr 2012 23:12:53 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204082221440.6964@ja.ssi.bg>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au> <1332320185-27157-6-git-send-email-horms@verge.net.au> <20120402111145.GA15181@1984> <alpine.LFD.2.00.1204032258540.1995@ja.ssi.bg> <20120405150553.GA8144@1984>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120405150553.GA8144@1984>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Thu, 5 Apr 2012, Pablo Neira Ayuso wrote:

> I think you can control when the kernel thread is woken up with a
> counting semaphore. The counter of that semaphore will be initially
> set to zero. Then, you can up() the semaphore once per new buffer
> that you enqueue to the sender.
> 
> feeder:
>         add message to sync buffer
>         if buffer full:
>                 enqueue buffer to sender_thread
>                 up(s)
> 
> sender_thread:
>         while (1) {
>                 down(s)
>                 retrieve message from queue
>                 send message
>         }
> 
> It seems to me like the classical producer/consumer problem that you
> can resolve with semaphores.

	May be it is possible to use up/down but we
have to handle the kthread_should_stop check and also
I prefer to reduce the wakeup events. So, I'm trying
another solution which is appended just for review.

> Under congestion the situation is complicated. At some point you'll
> end up dropping messages.
> 
> You may want to increase the socket queue to delay the moment at which
> we start dropping messages. You can expose the socke buffer length via
> /proc interface I guess (not sure if you're already doing that or
> suggesting to use the global socket buffer length).

	I'm still thinking if sndbuf value should be exported,
currently users have to modify the global default/max value.
But in below version I'm trying to handle the sndbuf overflow
by blocking for write_space event. By this way we should work
with any sndbuf configuration.

> You also can define some mechanism to reduce the amount of events,
> some state filtering so you only propagate important states.
> 
> Some partially reliable protocol, so the backup can request messages
> that got lost in a smart way would can also in handy. Basically, the
> master only retransmits the current state, not the whole sequence of
> messages (this is good under congestion, since you save messages).
> I implement that in conntrackd, but that's more complex solution,
> of course. I'd start with something simple.

	The patch "reduce sync rate with time thresholds"
that follows the discussed one in the changeset has such
purpose to reduce the events, in tests the sync traffic is
reduced ~10 times. But it does not modify the current
protocol, it adds a very limited logic for retransmissions.

	Here is the new version for review. It compiles
and does not crash in simple tests.

ipvs: wakeup master thread

	High rate of sync messages in master can lead to
overflowing the socket buffer and dropping the messages.
Fixed pause of 1 second is not suitable for loaded masters,
so allow packet processing to wakeup the master thread
once per 32 messages (IPVS_SYNC_WAKEUP_RATE), so that
we do not send in long bursts even when socket buffer is
very large.

	Add hard limit for the queued messages before sending
by using "sync_qlen_max" sysctl var. It defaults to 1/32 of
the memory pages but actually represents number of messages.
It will protect us from allocating large parts of memory
when the sending rate is lower than the queuing rate.

	Change the master thread to detect and block on
SNDBUF overflow, so that we do not drop messages when
the socket limit is low but the sync_qlen_max limit is
not reached. On ENOBUFS or other errors just drop the
messages.

	Use lower pause (200ms) to wait for messages, it
takes effect when the sync rate is low. It has two purposes,
to limit the delay for queued messages and to avoid
many wakeups when no messages are queued.

	Finally, make sure kthread_should_stop is checked
properly in TASK_INTERRUPTIBLE state when going to sleep
to avoid delays in thread stopping.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |   15 ++++++++
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++
 net/netfilter/ipvs/ip_vs_sync.c |   74 +++++++++++++++++++++++++++++---------
 3 files changed, 79 insertions(+), 18 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2bdee51..539f557 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -870,6 +870,7 @@ struct netns_ipvs {
 #endif
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
+	int			sysctl_sync_qlen_max;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
 	int			sysctl_expire_quiescent_template;
@@ -890,6 +891,8 @@ struct netns_ipvs {
 	struct timer_list	est_timer;	/* Estimation timer */
 	/* ip_vs_sync */
 	struct list_head	sync_queue;
+	int			sync_queue_len;
+	unsigned int		sync_queue_sent;
 	spinlock_t		sync_lock;
 	struct ip_vs_sync_buff  *sync_buff;
 	spinlock_t		sync_buff_lock;
@@ -912,6 +915,8 @@ struct netns_ipvs {
 #define DEFAULT_SYNC_THRESHOLD	3
 #define DEFAULT_SYNC_PERIOD	50
 #define DEFAULT_SYNC_VER	1
+#define IPVS_SYNC_WAKEUP_RATE	32
+#define IPVS_SYNC_QLEN_MAX	(IPVS_SYNC_WAKEUP_RATE * 4)
 
 #ifdef CONFIG_SYSCTL
 
@@ -930,6 +935,11 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_sync_ver;
 }
 
+static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sync_qlen_max;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -947,6 +957,11 @@ static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
 	return DEFAULT_SYNC_VER;
 }
 
+static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+{
+	return IPVS_SYNC_QLEN_MAX;
+}
+
 #endif
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 964d426..e3280ae 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1718,6 +1718,12 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_sync_mode,
 	},
 	{
+		.procname	= "sync_qlen_max",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "cache_bypass",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
@@ -3662,6 +3668,8 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_snat_reroute;
 	ipvs->sysctl_sync_ver = 1;
 	tbl[idx++].data = &ipvs->sysctl_sync_ver;
+	ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
+	tbl[idx++].data = &ipvs->sysctl_sync_qlen_max;
 	tbl[idx++].data = &ipvs->sysctl_cache_bypass;
 	tbl[idx++].data = &ipvs->sysctl_expire_nodest_conn;
 	tbl[idx++].data = &ipvs->sysctl_expire_quiescent_template;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 0e36679..b36f89b 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -312,6 +312,7 @@ static inline struct ip_vs_sync_buff *sb_dequeue(struct netns_ipvs *ipvs)
 				struct ip_vs_sync_buff,
 				list);
 		list_del(&sb->list);
+		ipvs->sync_queue_len--;
 	}
 	spin_unlock_bh(&ipvs->sync_lock);
 
@@ -358,9 +359,13 @@ static inline void sb_queue_tail(struct netns_ipvs *ipvs)
 	struct ip_vs_sync_buff *sb = ipvs->sync_buff;
 
 	spin_lock(&ipvs->sync_lock);
-	if (ipvs->sync_state & IP_VS_STATE_MASTER)
+	if (ipvs->sync_state & IP_VS_STATE_MASTER &&
+	    ipvs->sync_queue_len < sysctl_sync_qlen_max(ipvs)) {
 		list_add_tail(&sb->list, &ipvs->sync_queue);
-	else
+		ipvs->sync_queue_len++;
+		if (!((++ipvs->sync_queue_sent) & (IPVS_SYNC_WAKEUP_RATE-1)))
+			wake_up_process(ipvs->master_thread);
+	} else
 		ip_vs_sync_buff_release(sb);
 	spin_unlock(&ipvs->sync_lock);
 }
@@ -405,10 +410,11 @@ void ip_vs_sync_switch_mode(struct net *net, int mode)
 		ipvs->sync_buff = NULL;
 	} else {
 		spin_lock_bh(&ipvs->sync_lock);
-		if (ipvs->sync_state & IP_VS_STATE_MASTER)
+		if (ipvs->sync_state & IP_VS_STATE_MASTER) {
 			list_add_tail(&ipvs->sync_buff->list,
 				      &ipvs->sync_queue);
-		else
+			ipvs->sync_queue_len++;
+		} else
 			ip_vs_sync_buff_release(ipvs->sync_buff);
 		spin_unlock_bh(&ipvs->sync_lock);
 	}
@@ -1392,18 +1398,22 @@ ip_vs_send_async(struct socket *sock, const char *buffer, const size_t length)
 	return len;
 }
 
-static void
+static int
 ip_vs_send_sync_msg(struct socket *sock, struct ip_vs_sync_mesg *msg)
 {
 	int msize;
+	int ret;
 
 	msize = msg->size;
 
 	/* Put size in network byte order */
 	msg->size = htons(msg->size);
 
-	if (ip_vs_send_async(sock, (char *)msg, msize) != msize)
-		pr_err("ip_vs_send_async error\n");
+	ret = ip_vs_send_async(sock, (char *)msg, msize);
+	if (ret >= 0 || ret == -EAGAIN)
+		return ret;
+	pr_err("ip_vs_send_async error %d\n", ret);
+	return 0;
 }
 
 static int
@@ -1428,32 +1438,58 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
 	return len;
 }
 
+/* Get next buffer to send */
+static inline struct ip_vs_sync_buff *
+next_sync_buff(struct netns_ipvs *ipvs)
+{
+	struct ip_vs_sync_buff *sb;
+
+	sb = sb_dequeue(ipvs);
+	if (sb)
+		return sb;
+	/* Do not delay entries in buffer for more than 2 seconds */
+	return get_curr_sync_buff(ipvs, 2 * HZ);
+}
 
 static int sync_thread_master(void *data)
 {
 	struct ip_vs_sync_thread_data *tinfo = data;
 	struct netns_ipvs *ipvs = net_ipvs(tinfo->net);
+	struct sock *sk = tinfo->sock->sk;
 	struct ip_vs_sync_buff *sb;
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
 		"syncid = %d\n",
 		ipvs->master_mcast_ifn, ipvs->master_syncid);
 
-	while (!kthread_should_stop()) {
-		while ((sb = sb_dequeue(ipvs))) {
-			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
-			ip_vs_sync_buff_release(sb);
+	for (;;) {
+		sb = next_sync_buff(ipvs);
+		if (!sb) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			if (kthread_should_stop())
+				break;
+			schedule_timeout(HZ / 5);
+			continue;
 		}
 
-		/* check if entries stay in ipvs->sync_buff for 2 seconds */
-		sb = get_curr_sync_buff(ipvs, 2 * HZ);
-		if (sb) {
-			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
-			ip_vs_sync_buff_release(sb);
+retry:
+		if (unlikely(kthread_should_stop()))
+			break;
+		if (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
+			int ret = 0;
+
+			__wait_event_interruptible(*sk_sleep(sk),
+						   sock_writeable(sk) ||
+						   kthread_should_stop(),
+						   ret);
+			goto retry;
 		}
