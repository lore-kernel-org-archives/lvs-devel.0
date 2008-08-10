From: sven.wegener@stealer.net
Subject: [PATCH 1/9] ipvs: Fix possible deadlock in sync code
Date: Sun, 10 Aug 2008 11:07:31 +0000
Message-ID: <1218366459-23971-2-git-send-email-sven.wegener@stealer.net>
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

Commit 998e7a76804b7a273a0460c2cdd5a51fa9856717 ("ipvs: Use kthread_run()
instead of doing a double-fork via kernel_thread()") introduced a possible
deadlock in the sync code. We need to use the _bh versions for the lock, as the
lock is also accessed from a bottom half.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sync.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 45e9bd9..a652da2 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -904,9 +904,9 @@ int stop_sync_thread(int state)
 		 * progress of stopping the master sync daemon.
 		 */
 
-		spin_lock(&ip_vs_sync_lock);
+		spin_lock_bh(&ip_vs_sync_lock);
 		ip_vs_sync_state &= ~IP_VS_STATE_MASTER;
-		spin_unlock(&ip_vs_sync_lock);
+		spin_unlock_bh(&ip_vs_sync_lock);
 		kthread_stop(sync_master_thread);
 		sync_master_thread = NULL;
 	} else if (state == IP_VS_STATE_BACKUP) {
-- 
1.5.6.4

