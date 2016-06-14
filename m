From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH v2 5/5] ipvs: log additional sync daemon parameters
Date: Tue, 14 Jun 2016 15:24:22 +0100
Message-ID: <1465914262-30112-6-git-send-email-quentin@armitage.org.uk>
References: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Quentin Armitage <quentin@armitage.org.uk>

Add new multicast parameters to log messages when sync daemons start.

Commits <e4ff67513096> ("ipvs: add sync_maxlen parameter for the sync
daemon") and <d33288172e72> ("ipvs: add more mcast parameters for the
sync daemon") added additional multicast parameters, but didn't add
them to the log messages when the sync daemons started.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 net/netfilter/ipvs/ip_vs_sync.c |   26 ++++++++++++++++++++++----
 1 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 734335a..bb59b84 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1669,8 +1669,17 @@ static int sync_thread_master(void *data)
 	struct ip_vs_sync_buff *sb;
 
 	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
-		"syncid = %d, id = %d\n",
-		ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid, tinfo->id);
+			"syncid = %d, id = %d, maxlen = %d\n",
+			ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid,
+			tinfo->id, ipvs->mcfg.sync_maxlen);
+	if (ipvs->mcfg.mcast_af == AF_INET)
+		pr_info("                   : group = %pI4, port = %d, ttl = %d\n",
+			&ipvs->mcfg.mcast_group.in, ipvs->mcfg.mcast_port,
+			ipvs->mcfg.mcast_ttl);
+	else
+		pr_info("                   : group = %pI6c, port = %d, ttl = %d\n",
+			&ipvs->mcfg.mcast_group.in6, ipvs->mcfg.mcast_port,
+			ipvs->mcfg.mcast_ttl);
 
 	for (;;) {
 		sb = next_sync_buff(ipvs, ms);
@@ -1723,8 +1732,17 @@ static int sync_thread_backup(void *data)
 	int len;
 
 	pr_info("sync thread started: state = BACKUP, mcast_ifn = %s, "
-		"syncid = %d, id = %d\n",
-		ipvs->bcfg.mcast_ifn, ipvs->bcfg.syncid, tinfo->id);
+			"syncid = %d, id = %d, maxlen = %d\n",
+			ipvs->bcfg.mcast_ifn, ipvs->bcfg.syncid,
+			tinfo->id, ipvs->bcfg.sync_maxlen);
+	if (ipvs->bcfg.mcast_af == AF_INET)
+		pr_info("                   : group = %pI4, port = %d, ttl = %d\n",
+			&ipvs->bcfg.mcast_group.in, ipvs->bcfg.mcast_port,
+			ipvs->bcfg.mcast_ttl);
+	else
+		pr_info("                   : group = %pI6c, port = %d, ttl = %d\n",
+			&ipvs->bcfg.mcast_group.in6, ipvs->bcfg.mcast_port,
+			ipvs->bcfg.mcast_ttl);
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
-- 
1.7.7.6

