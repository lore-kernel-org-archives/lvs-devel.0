From: menglong8.dong@gmail.com
Subject: [PATCH net-next] net: ipvs: random start for RR scheduler
Date: Mon,  9 May 2022 20:22:13 +0800
Message-ID: <20220509122213.19508-1-imagedong@tencent.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=MBkrt0SUkDfCJX6P4GbifrxeHSLkx5CXpfEy6Fo+oxI=;
        b=j24J2mmCWVTfciS79l9WsXOME+o2GRmy+XDFsljOg+u/rf3JIlbK8C8C0/obdWTlYs
         Lyti8j7T+/vIlQ1XYwUg2ldJUT97k2PP1fMeNVClx5eFDgP2NXxMtIYEtBVsPfXd23+k
         sC6PJPEiTSPZ1oDuttnRAaFAuNgX2OUVT84kuFFx1RVubJu3ba4vG6Th4E96AgExGGeu
         arf7htlXrjeuT5jr0ESUIH/b6InURDwz8lCl+eKwRXOEzGBcIfi9eoJNdUXsj22MT55A
         tDsQqKWZw3Q6MEtyxVeyvhSDCEJYD5Ng3OSPtkcvTBCWOwAUXd4MsXOfab9pN6ncp3aj
         QmGg==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: kuba@kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, edumazet@google.com, pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Menglong Dong <imagedong@tencent.com>

From: Menglong Dong <imagedong@tencent.com>

For now, the start of the RR scheduler is in the order of dest
service added, it will result in imbalance if the load balance
is done in client side and long connect is used.

For example, we have client1, client2, ..., client5 and real service
service1, service2, service3. All clients have the same ipvs config,
and each of them will create 2 long TCP connect to the virtual
service. Therefore, all the clients will connect to service1 and
service2, leaving service3 free.

Fix this by randomize the start of dest service to RR scheduler when
IP_VS_SVC_F_SCHED_RR_RANDOM is set.

Signed-off-by: Menglong Dong <imagedong@tencent.com>
---
 include/uapi/linux/ip_vs.h    |  2 ++
 net/netfilter/ipvs/ip_vs_rr.c | 25 ++++++++++++++++++++++++-
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 4102ddcb4e14..7f74bafd3211 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -28,6 +28,8 @@
 #define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
 #define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
 
+#define IP_VS_SVC_F_SCHED_RR_RANDOM	IP_VS_SVC_F_SCHED1 /* random start */
+
 /*
  *      Destination Server Flags
  */
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 38495c6f6c7c..e309d97bdd08 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -22,13 +22,36 @@
 
 #include <net/ip_vs.h>
 
+static void ip_vs_rr_random_start(struct ip_vs_service *svc)
+{
+	struct list_head *cur;
+	u32 start;
+
+	if (!(svc->flags | IP_VS_SVC_F_SCHED_RR_RANDOM) ||
+	    svc->num_dests <= 1)
+		return;
+
+	spin_lock_bh(&svc->sched_lock);
+	start = get_random_u32() % svc->num_dests;
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
-- 
2.36.0

