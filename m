From: sven.wegener@stealer.net
Subject: [PATCH 4/9] ipvs: Use list_empty() instead of open-coding the same functionality
Date: Sun, 10 Aug 2008 11:07:34 +0000
Message-ID: <1218366459-23971-5-git-send-email-sven.wegener@stealer.net>
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

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_sched.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_sched.c b/net/ipv4/ipvs/ip_vs_sched.c
index b647673..a46ad9e 100644
--- a/net/ipv4/ipvs/ip_vs_sched.c
+++ b/net/ipv4/ipvs/ip_vs_sched.c
@@ -184,7 +184,7 @@ int register_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 
 	write_lock_bh(&__ip_vs_sched_lock);
 
-	if (scheduler->n_list.next != &scheduler->n_list) {
+	if (!list_empty(&scheduler->n_list)) {
 		write_unlock_bh(&__ip_vs_sched_lock);
 		ip_vs_use_count_dec();
 		IP_VS_ERR("register_ip_vs_scheduler(): [%s] scheduler "
@@ -229,7 +229,7 @@ int unregister_ip_vs_scheduler(struct ip_vs_scheduler *scheduler)
 	}
 
 	write_lock_bh(&__ip_vs_sched_lock);
-	if (scheduler->n_list.next == &scheduler->n_list) {
+	if (list_empty(&scheduler->n_list)) {
 		write_unlock_bh(&__ip_vs_sched_lock);
 		IP_VS_ERR("unregister_ip_vs_scheduler(): [%s] scheduler "
 			  "is not in the list. failed\n", scheduler->name);
-- 
1.5.6.4

