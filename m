From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH v3 4/4] ipvs: log additional sync daemon parameters
Date: Wed, 15 Jun 2016 22:42:44 +0100
Message-ID: <1466026964-14114-5-git-send-email-quentin@armitage.org.uk>
References: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
 <1466026964-14114-1-git-send-email-quentin@armitage.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466026964-14114-1-git-send-email-quentin@armitage.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Quentin Armitage <quentin@armitage.org.uk>

Add new multicast parameters to log messages when sync daemons start.

Commit e4ff67513096 ("ipvs: add sync_maxlen parameter for the sync
daemon") and commit d33288172e72 ("ipvs: add more mcast parameters for
the sync daemon") added additional multicast parameters, but didn't add
them to the log messages when the sync daemons started.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 net/netfilter/ipvs/ip_vs_sync.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2be99b2..a52c4be 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1669,9 +1669,17 @@ static int sync_thread_master(void *data)
 	struct sock *sk = tinfo->sock->sk;
 	struct ip_vs_sync_buff *sb;
 
-	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
-		"syncid = %d, id = %d\n",
-		ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid, tinfo->id);
+	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, syncid = %d, id = %d, maxlen = %d\n",
+		ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid,
+		tinfo->id, ipvs->mcfg.sync_maxlen);
+	if (ipvs->mcfg.mcast_af == AF_INET)
+		pr_info("group = %pI4, port = %d, ttl = %d\n",
+			&ipvs->mcfg.mcast_group.in, ipvs->mcfg.mcast_port,
+			ipvs->mcfg.mcast_ttl);
+	else
+		pr_info("group = %pI6c, port = %d, ttl = %d\n",
+			&ipvs->mcfg.mcast_group.in6, ipvs->mcfg.mcast_port,
+			ipvs->mcfg.mcast_ttl);
 
 	for (;;) {
 		sb = next_sync_buff(ipvs, ms);
@@ -1723,9 +1731,17 @@ static int sync_thread_backup(void *data)
 	struct netns_ipvs *ipvs = tinfo->ipvs;
 	int len;
 
-	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
-		"syncid = %d, id = %d\n",
-		ipvs->bcfg.mcast_ifn, ipvs->bcfg.syncid, tinfo->id);
+	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, syncid = %d, id = %d, maxlen = %d\n",
+		ipvs->bcfg.mcast_ifn, ipvs->bcfg.syncid,
+		tinfo->id, ipvs->bcfg.sync_maxlen);
+	if (ipvs->bcfg.mcast_af == AF_INET)
+		pr_info("group = %pI4, port = %d, ttl = %d\n",
+			&ipvs->bcfg.mcast_group.in, ipvs->bcfg.mcast_port,
+			ipvs->bcfg.mcast_ttl);
+	else
+		pr_info("group = %pI6c, port = %d, ttl = %d\n",
+			&ipvs->bcfg.mcast_group.in6, ipvs->bcfg.mcast_port,
+			ipvs->bcfg.mcast_ttl);
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
-- 
1.7.7.6

