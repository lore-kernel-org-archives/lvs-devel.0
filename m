From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/2] fix lockdep warning
Date: Mon, 3 Oct 2011 12:56:38 +0200
Message-ID: <1317639399-4522-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Hans Schillstrom <hans@schillstrom.com>

rs_lock needs a key to make lock dep happy.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 2b771dc..a1af72f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -57,6 +57,7 @@ static DEFINE_MUTEX(__ip_vs_mutex);
 
 /* lock for service table */
 static DEFINE_RWLOCK(__ip_vs_svc_lock);
+static struct lock_class_key ip_vs_rs_key;
 
 /* sysctl variables */
 
@@ -3680,6 +3681,7 @@ int __net_init ip_vs_control_net_init(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ipvs->rs_lock = __RW_LOCK_UNLOCKED(ipvs->rs_lock);
+	__rwlock_init(&ipvs->rs_lock, "ipvs->rs_lock", &ip_vs_rs_key);
 
 	/* Initialize rs_table */
 	for (idx = 0; idx < IP_VS_RTAB_SIZE; idx++)
-- 
1.7.4.4

