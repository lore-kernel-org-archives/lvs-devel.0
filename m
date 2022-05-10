From: menglong8.dong@gmail.com
Subject: [PATCH net-next v2] net: ipvs: randomize starting destination of RR/WRR scheduler
Date: Tue, 10 May 2022 15:43:01 +0800
Message-ID: <20220510074301.480941-1-imagedong@tencent.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=/PQpWDOLtgetCHx/Dm+r4oknUTM2WK+PRWdFcr5XoII=;
        b=aURwVS5zElR52e8zV0QIOuj1FVJJkiACBIsmRaO9iIegJRMF+wu+p5WlRSh1hWGk62
         McGGASA7KaNIZCxvdGxk/20xGF0WScmDWfsXY2EJsXyKcsMnajuhXQ7tbk+u5BVqYo0L
         2KR3rLTua6et8Nl640WAKPJLsivZWemlxof5yRLbzmywoH2yGuJGRKZj9htqY3SobXlZ
         ZzNLSgOERY2lRrxnEFlO1YHW2QwMkEh5QYhylJeXl4+c1g8OuDGbty+jJXFmhqix7tAg
         aS1XMz0H3NkadthMDz/wChWkiA7mksnMYx+xava+g1uEAXc7oOUeHu30WMLxS5erI/yu
         L0NQ==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: ja@ssi.bg
Cc: horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Menglong Dong <imagedong@tencent.com>, Jiang Biao <benbjiang@tencent.com>, Hao Peng <flyingpeng@tencent.com>

From: Menglong Dong <imagedong@tencent.com>

For now, the start of the RR/WRR scheduler is in order of added
destinations, it will result in imbalance if the director is local
to the clients and the number of connection is small.

For example, we have client1, client2, ..., client100 and real service
service1, service2, ..., service10. All clients have local director with
the same ipvs config, and each of them will create 2 long TCP connect to
the virtual service. Therefore, all the clients will connect to service1
and service2, leaving others free, which will make service1 and service2
overloaded.

Fix this by randomizing the starting destination when
IP_VS_SVC_F_SCHED_RR_RANDOM/IP_VS_SVC_F_SCHED_WRR_RANDOM is set.

I start the randomizing from svc->destinations, as we choose the starting
destination from all of the destinations, so it makes no different to
start from svc->sched_data or svc->destinations. If we start from
svc->sched_data, we have to avoid the 'head' node of the list being the
next node of svc->sched_data, to make the choose totally random.

Reviewed-by: Jiang Biao <benbjiang@tencent.com>
Reviewed-by: Hao Peng <flyingpeng@tencent.com>
Signed-off-by: Menglong Dong <imagedong@tencent.com>
---
v2:
- randomizing the starting of WRR scheduler too
- Replace '|' with '&' in ip_vs_rr_random_start(Julian Anastasov)
- Replace get_random_u32() with prandom_u32_max() (Julian Anastasov)
---
 include/uapi/linux/ip_vs.h     |  3 +++
 net/netfilter/ipvs/ip_vs_rr.c  | 25 ++++++++++++++++++++++++-
 net/netfilter/ipvs/ip_vs_wrr.c | 20 ++++++++++++++++++++
 3 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 4102ddcb4e14..9543906dae7d 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -28,6 +28,9 @@
 #define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
 #define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
 
+#define IP_VS_SVC_F_SCHED_WRR_RANDOM	IP_VS_SVC_F_SCHED1 /* random start */
+#define IP_VS_SVC_F_SCHED_RR_RANDOM	IP_VS_SVC_F_SCHED1 /* random start */
+
 /*
  *      Destination Server Flags
  */
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 38495c6f6c7c..d53bfaf7aadf 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -22,13 +22,36 @@
 
 #include <net/ip_vs.h>
 
+static void ip_vs_rr_random_start(struct ip_vs_service *svc)
+{
+	struct list_head *cur;
+	u32 start;
+
+	if (!(svc->flags & IP_VS_SVC_F_SCHED_RR_RANDOM) ||
+	    svc->num_dests <= 1)
+		return;
+
+	start = prandom_u32_max(svc->num_dests);
+	spin_lock_bh(&svc->sched_lock);
+	cur = &svc->destinations;
+	while (start--)
+		cur = cur->next;
+	svc->sched_data = cur;
+	spin_unlock_bh(&svc->sched_lock);
+}
 
 static int ip_vs_rr_init_svc(struct ip_vs_service *svc)
 {
 	svc->sched_data = &svc->destinations;
+	ip_vs_rr_random_start(svc);
 	return 0;
 }
 
+static int ip_vs_rr_add_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
+{
+	ip_vs_rr_random_start(svc);
+	return 0;
+}
 
 static int ip_vs_rr_del_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
 {
@@ -104,7 +127,7 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
 	.init_service =		ip_vs_rr_init_svc,
-	.add_dest =		NULL,
+	.add_dest =		ip_vs_rr_add_dest,
 	.del_dest =		ip_vs_rr_del_dest,
 	.schedule =		ip_vs_rr_schedule,
 };
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 1bc7a0789d85..ed6230976379 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -102,6 +102,24 @@ static int ip_vs_wrr_max_weight(struct ip_vs_service *svc)
 	return weight;
 }
 
+static void ip_vs_wrr_random_start(struct ip_vs_service *svc)
+{
+	struct ip_vs_wrr_mark *mark = svc->sched_data;
+	struct list_head *cur;
+	u32 start;
+
+	if (!(svc->flags & IP_VS_SVC_F_SCHED_WRR_RANDOM) ||
+	    svc->num_dests <= 1)
+		return;
+
+	start = prandom_u32_max(svc->num_dests);
+	spin_lock_bh(&svc->sched_lock);
+	cur = &svc->destinations;
+	while (start--)
+		cur = cur->next;
+	mark->cl = list_entry(cur, struct ip_vs_dest, n_list);
+	spin_unlock_bh(&svc->sched_lock);
+}
 
 static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 {
@@ -119,6 +137,7 @@ static int ip_vs_wrr_init_svc(struct ip_vs_service *svc)
 	mark->mw = ip_vs_wrr_max_weight(svc) - (mark->di - 1);
 	mark->cw = mark->mw;
 	svc->sched_data = mark;
+	ip_vs_wrr_random_start(svc);
 
 	return 0;
 }
@@ -149,6 +168,7 @@ static int ip_vs_wrr_dest_changed(struct ip_vs_service *svc,
 	else if (mark->di > 1)
 		mark->cw = (mark->cw / mark->di) * mark->di + 1;
 	spin_unlock_bh(&svc->sched_lock);
+	ip_vs_wrr_random_start(svc);
 	return 0;
 }
 
-- 
2.36.0

