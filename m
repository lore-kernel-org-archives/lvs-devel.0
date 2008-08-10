From: sven.wegener@stealer.net
Subject: [PATCH 2/9] ipvs: Fix possible deadlock in estimator code
Date: Sun, 10 Aug 2008 11:07:32 +0000
Message-ID: <1218366459-23971-3-git-send-email-sven.wegener@stealer.net>
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

There is a slight chance for a deadlock in the estimator code. We can't call
del_timer_sync() while holding our lock, as the timer might be active and
spinning for the lock on another cpu. Work around this issue by using
try_to_del_timer_sync() and releasing the lock. We could actually delete the
timer outside of our lock, as the add and kill functions are only every called
from userspace via [gs]etsockopt() and are serialized by a mutex, but better
make this explicit.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
Cc: stable <stable@kernel.org>
---
 net/ipv4/ipvs/ip_vs_est.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_est.c b/net/ipv4/ipvs/ip_vs_est.c
index bc04eed..1d6e58e 100644
--- a/net/ipv4/ipvs/ip_vs_est.c
+++ b/net/ipv4/ipvs/ip_vs_est.c
@@ -170,8 +170,11 @@ void ip_vs_kill_estimator(struct ip_vs_stats *stats)
 		kfree(est);
 		killed++;
 	}
-	if (killed && est_list == NULL)
-		del_timer_sync(&est_timer);
+	while (killed && !est_list && try_to_del_timer_sync(&est_timer) < 0) {
+		write_unlock_bh(&est_lock);
+		cpu_relax();
+		write_lock_bh(&est_lock);
+	}
 	write_unlock_bh(&est_lock);
 }
 
-- 
1.5.6.4

