From: sven.wegener@stealer.net
Subject: [PATCH 9/9] ipvs: No need to zero out ip_vs_stats during initialization
Date: Sun, 10 Aug 2008 11:07:39 +0000
Message-ID: <1218366459-23971-10-git-send-email-sven.wegener@stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: Sven Wegener <sven.wegener@stealer.net>

It's a global variable and automatically initialized to zero. And now we can
also initialize the lock at compile time.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_ctl.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index d651bce..cfb1d20 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1784,7 +1784,9 @@ static const struct file_operations ip_vs_info_fops = {
 
 #endif
 
-struct ip_vs_stats ip_vs_stats;
+struct ip_vs_stats ip_vs_stats = {
+	.lock = __SPIN_LOCK_UNLOCKED(ip_vs_stats.lock),
+};
 
 #ifdef CONFIG_PROC_FS
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
@@ -2333,8 +2335,6 @@ int __init ip_vs_control_init(void)
 		INIT_LIST_HEAD(&ip_vs_rtable[idx]);
 	}
 
-	memset(&ip_vs_stats, 0, sizeof(ip_vs_stats));
-	spin_lock_init(&ip_vs_stats.lock);
 	ip_vs_new_estimator(&ip_vs_stats);
 
 	/* Hook the defense timer */
-- 
1.5.6.4

