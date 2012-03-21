From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/9] ipvs: use adaptive pause in master thread
Date: Wed, 21 Mar 2012 17:56:20 +0900
Message-ID: <1332320185-27157-6-git-send-email-horms@verge.net.au>
References: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1332320185-27157-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	High rate of sync messages in master can lead to
overflowing the socket buffer and dropping the messages.
Instead of using fixed pause try to adapt to the sync
rate, so that we do not wakeup too often while at the same
time staying below the socket buffer limit.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Tested-by: Aleksey Chudov <aleksey.chudov@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |   60 +++++++++++++++++++++++++++++---------
 1 files changed, 46 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 0e36679..9201c43 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1392,18 +1392,22 @@ ip_vs_send_async(struct socket *sock, const char *buffer, const size_t length)
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
@@ -1428,33 +1432,61 @@ ip_vs_receive(struct socket *sock, char *buffer, const size_t buflen)
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
-	struct ip_vs_sync_buff *sb;
+	struct ip_vs_sync_buff *sb = NULL;
+	int pause = HZ / 10;
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
 		"syncid = %d\n",
 		ipvs->master_mcast_ifn, ipvs->master_syncid);
 
 	while (!kthread_should_stop()) {
-		while ((sb = sb_dequeue(ipvs))) {
-			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
-			ip_vs_sync_buff_release(sb);
-		}
+		int count = 0;
 
-		/* check if entries stay in ipvs->sync_buff for 2 seconds */
-		sb = get_curr_sync_buff(ipvs, 2 * HZ);
-		if (sb) {
-			ip_vs_send_sync_msg(tinfo->sock, sb->mesg);
-			ip_vs_sync_buff_release(sb);
+		for (;;) {
+			if (!sb) {
+				sb = next_sync_buff(ipvs);
+				if (!sb)
+					break;
+			}
+			if (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) >= 0 ||
+			    pause == 1) {
+				ip_vs_sync_buff_release(sb);
+				sb = NULL;
+				count++;
+			} else {
+				pause = max(1, (pause >> 1));
+				break;
+			}
 		}
 
-		schedule_timeout_interruptible(HZ);
+		/* Max packets to send at once */
+		if (count > 200)
+			pause = max(1, (pause - HZ / 20));
+		else if (count < 20)
+			pause = min(HZ / 4, (pause + HZ / 20));
+		schedule_timeout_interruptible(sb ? 1 : pause);
 	}
 
+	if (sb)
+		ip_vs_sync_buff_release(sb);
+
 	/* clean up the sync_buff queue */
 	while ((sb = sb_dequeue(ipvs)))
 		ip_vs_sync_buff_release(sb);
-- 
1.7.6.3
